package FoamFacebook;

use warnings "all";
use strict;
use Carp;

use Data::Dumper;
use URI::Escape;
use HTTP::Request;
use LWP::Simple;
use Time::Local;

use Foam2;
use Facebook::Graph;

BEGIN {
	use Exporter ();

	our($VERSION, @ISA, @EXPORT, @EXPORT_OK);

	$VERSION = "1.00";
	@ISA     = qw(Exporter);
	@EXPORT  = qw(
		GetYYYYMMDD_2_HHMMSS
		FindImage
		UpdateComments
		GetFacebook
		PeriodicUpdate
		UpdateFacebookComments
	);
}


$Carp::Verbose = 1;


sub GetYYYYMMDD_2_HHMMSS($$$$$$)
{
	my ($year, $mon, $mday, $hh, $mm, $ss) = @_;
	return sprintf("%04d%02d%02d_2_%02d%02d%02d", $year, $mon, $mday, $hh, $mm, $ss);
}


sub FindImage($)
{
	my $arr = shift;
	my $best = $arr->[0];
	my $min = 0;

	foreach my $img (@{ $arr })
	{
		if(abs($img->{width} - 500) < $min)
		{
			$min = abs($img->{width} - 500);
			$best = $img;
		}
	}

	return $best;
}


sub UpdateComments($$$)
{
	my $fb = shift;
	my $entry = shift;
	my $post = shift;

	my $orig_count = 0;

	#
	# Sadly, it appears as if Facebook sometimes doesn't put any clue in
	# the responses that there are comments for an item once it (or
	# maybe the comments) are a certain age. This is true even if you specify
	# that you want the comments field.
	#
	# Worse, it seems even trying to fetch the comments (which I can plainly
	# see on Facebook) directly doesn't always bring them back. So, if I'll
	# try to fetch the comments if I have any at all from before. If I get
	# nothing back at all, I'll assume they've timed out. If anything is
	# returned, I'll replace the set I have with them. I'll assume for now
	# that the whole block times out at once as opposed to individual comments.
	#

	my $resp;
	my $id = $post->{id} || $post->{object_id};
	if($id)
	{
		$resp = $fb->fetch("$id/comments");
	}
	else
	{
		# No ID to look up?
		print "\tNo Facebook ID. That's really weird.\n";
		return;
	}

	if( defined($resp) && scalar(@{ $resp->{data} }))
	{
		my $orig_count = 0;

		# OK, we got some comments, assume that all the ones are there that
		# should be.

		if(exists($entry->{comments}) && exists($entry->{comments}->{data}))
		{
			$orig_count = scalar @{ $entry->{comments}->{data} };

			# Go through and remove all the FB comments, leaving the Foamy ones
			my @foam_list = grep { $_->{id} =~ m/fid/ } @{ $entry->{comments}->{data} };
			$entry->{comments}->{data} = \@foam_list;
		}

		$post->{comments} = $resp;

		# $post has been updated and now has all the comments in it from FB

		# Merge it with the Foamy comments
		push(@{ $entry->{comments}->{data} }, @{ $post->{comments}->{data} });

		# Sort them by date.
		@{ $entry->{comments}->{data} } = sort { $a->{created_time} cmp $b->{created_time} } @{ $entry->{comments}->{data} };

		my $count = 0;
		if(exists($entry->{comments}) && exists($entry->{comments}->{data}))
		{
			$count = scalar @{ $entry->{comments}->{data} };
		}

		if($count > $orig_count)
		{
			printf("\t%d new comments\n", $count-$orig_count);
		}
		elsif($count != $orig_count)
		{
			printf("\tRemoved %d comments\n", $orig_count-$count);
		}
	}
	else
	{
		if(exists($entry->{comments}) && exists($entry->{comments}->{data}))
		{
			print("\tNo comments found, keeping old ones.\n");
		}
	}
}

sub GetFacebook()
{
	my $fb = Facebook::Graph->new(
		app_id => '202981499713630',
		secret => '7c4028223161aedc2325605745a01313');

	$fb->access_token('202981499713630|f0e29551db76a6dbed4c8d5e.1-728337349|1C7yRomzW6wd2-7ogKO4lZLcdEI');

	return $fb;
}

sub PeriodicUpdate()
{
	my ($last_year, $last_mon) = (0, 0);

	my $fb = GetFacebook();

	my $resp = $fb->query
		->find('posniewski/posts')
		->limit_results(30)
#		->where_since('yesterday')
		->include_metadata
		->request
		->as_hashref;

	my $posts = $resp->{data};

	foreach my $post ( @{ $posts } )
	{
		my ($year, $mon, $day, $hh, $mm, $ss) = GetDateTimeFromAtomTimestamp($post->{created_time});
		my $foam_id = GetYYYYMMDD_2_HHMMSS($year, $mon, $day, $hh, $mm, $ss);

		next if($year<2011);

		my $entry = undef;
		my $phfile = '/home/www/html/daily/'.$foam_id.'.json';

		if(-e $phfile)
		{
			$entry = from_json_file($phfile);
		}
		elsif(-e $phfile.'x')
		{
			$phfile .= 'x';
			$entry = from_json_file($phfile);
		}

		if(defined($entry))
		{
			$entry->{'~orig'} = $post;

			print "Updating $phfile\n"
		}
		else
		{
			$entry->{'~orig'} = $post;

			# Only update the basic entry if we've never seen it before.

			if($post->{type} eq 'status')
			{
				print "\tNew status entry: $phfile\n";

				$entry->{type} = 'status';
				$entry->{id} = $foam_id;
				$entry->{publishedDate} = MakeAtomTimestamp($year, $mon, $day, $hh, $mm, $ss);

				$entry->{message}  = $post->{message};
				$entry->{title}    = $post->{title};
				$entry->{link}     = $post->{link};
				$entry->{via}      = $post->{application}->{name} if(exists($post->{application}));
			}
			elsif($post->{type} eq 'photo')
			{
				print "\tNew photo entry: $phfile\n";

				$entry->{type} = 'photo';
				$entry->{id} = $foam_id;
				$entry->{publishedDate} = MakeAtomTimestamp($year, $mon, $day, $hh, $mm, $ss);

				# Fetch the actual photo to embed it
				$post = $fb->query
					->find($post->{object_id})
					->request
					->as_hashref;

				my $image = FindImage($post->{images});
				my $wid = $image->{width};
				my $ht = $image->{height};
				if($image->{width} > 500)
				{
					$wid = 500;
					$ht = int( (500.0/$image->{width}) * $image->{height} );
				}

				$entry->{link}         = $post->{link};
				$entry->{image}        = $image->{source};
				$entry->{image_width}  = $wid;
				$entry->{image_height} = $ht;
				$entry->{message}      = $post->{name}       if(exists($post->{name}));
				$entry->{via} = $post->{application}->{name} if(exists($post->{application}));
			}
			elsif($post->{type} eq 'link' || $post->{type} eq 'video')
			{
				print "\tNew link entry: $phfile\n";

				$entry->{type} = 'link';
				$entry->{id} = $foam_id;
				$entry->{publishedDate} = MakeAtomTimestamp($year, $mon, $day, $hh, $mm, $ss);

				$entry->{link}        = $post->{link};
				$entry->{message}     = $post->{message}     if(exists($post->{message}));
				$entry->{picture}     = $post->{picture}     if(exists($post->{picture}));
				$entry->{name}        = $post->{name}        if(exists($post->{name}));
				$entry->{caption}     = $post->{caption}     if(exists($post->{caption}));
				$entry->{description} = $post->{description} if(exists($post->{description}));

				$entry->{via} = $post->{application}->{name}   if(exists($post->{application}->{name})  && $post->{application}->{name} !~ m/links|video/i);
			}
			else
			{
				print "\tSome other kind of thing ($post->{type}). Skipping.\n";
				next;
			}

			if(!$entry->{link} && exists($post->{actions}))
			{
				$entry->{link} = $post->{actions}->[0]->{link};
			}

			$entry->{via} = 'Facebook' if(!exists($entry->{via}) || !$entry->{via});
			$entry->{source} = 'facebook';

			#
			# If the link from facebook references Foam Totem directly,
			#    then it's probably a repeat of content that's already here
			#    somewhere. Try to find and cross-link it.
			#
			if($entry->{link} =~ m{foamtotem.*/(\d\d\d\d\d\d\d\d_\d_\d\d\d\d\d\d)\.}i)
			{
				my $id = $1;
				my $file = '/home/www/html/daily/'.$id.'.json';

				print "\tReferenced Foam Totem: $id.\n";

				# Ugh. Yes this is a copy of the code above. But it's readable
				#   and easier to write than some crazy other thing which
				#   reuses code.
				my $xentry = undef;
				if(-e $file)
				{
					print "\t\tTarget already exists\n";
					$xentry = from_json_file($file);
				}
				elsif(-e $file.'x')
				{
					print "\tTarget already exists (but is hidden)\n";
					$file .= 'x';
					$xentry = from_json_file($file);
				}

				if(defined($xentry))
				{
					$phfile = $file;
					$entry = $xentry;

					$entry->{'~orig'} = $post;
					print "\t\tRedirected comments to target ($phfile).\n";
				}
				else
				{
					# We didn't find the file, so we'll assume it's not
					#   already on the blog. Just let it go.
					print "\t\tNo Totem entry found. Handle as normal.\n";
				}
			}

			#
			# Do the Runmeter stuff
			#
			if($entry->{via} =~ m/runmeter/i)
			{
				# Look for the link.
				# This is a very naive search, but the links are always
				#   http://j.mp/lzF0y7
				#
				my ($url) = $entry->{message} =~ m{(http:[0-9A-Za-z/.]+)};

				if(defined($url))
				{
					my $resp = head($url);
					if(defined($resp))
					{
						$entry->{mapurl} = $resp->base();
					}
				}
			}
		}


		UpdateComments($fb, $entry, $post);


		open PHFILE, ">:utf8", $phfile or die $! . ": $phfile";
		print PHFILE scalar to_json($entry);
		close PHFILE;

		if(($last_year && $last_year!=$year) || ($last_mon && $last_mon!=$mon))
		{
			Foam2::UpdateHTML('/home/www/html/daily', $last_year, $last_mon);
		}

		$last_year = $year;
		$last_mon = $mon;
	}

	if($last_year && $last_mon)
	{
		Foam2::UpdateHTML('/home/www/html/daily', $last_year, $last_mon);
	}
}

sub UpdateFacebookComments($)
{
	my $foam_id = shift;
	my $fb = GetFacebook();

	my $entry = undef;
	my $phfile = '/home/www/html/daily/'.$foam_id.'.json';

	if(-e $phfile)
	{
		$entry = from_json_file($phfile);
	}
	elsif(-e $phfile.'x')
	{
		$phfile .= 'x';
		$entry = from_json_file($phfile);
	}

	my %post;
	$post{id} = $entry->{'~orig'}->{id};
	$post{object_id} = $entry->{'~orig'}->{object_id};


	UpdateComments($fb, $entry, \%post);


	open PHFILE, ">:utf8", $phfile or die $! . ": $phfile";
	print PHFILE scalar to_json($entry);
	close PHFILE;
}

1;