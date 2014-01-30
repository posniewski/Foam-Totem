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
use ObjectLinks;
use Runmeter;
use Facebook::Graph;
use Ouch;

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
		CachePicture
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



sub CachePicture($$)
{
	my $fb = shift;
	my $entry = shift;

	my $picurl = $entry->{picture} || $entry->{image};

    if($picurl)
	{
        my ($ext) = $picurl =~ m{\.([^.]+)$};
		$ext = 'jpg' if !$ext || length($ext)>5;

		my $fragment = "daily/cache/$entry->{id}.$ext";
		my $filename = "/home/www/html/$fragment";

		if(!-e $filename)
		{
			my $result = getstore($picurl, $filename);
			if(is_success($result))
			{
				if((-s $filename) < 45)
				{
					# Old pictures seem to come back as one-pixel gifs, regardless
					#   of what we ask for. :-(
					unlink $filename;
					print "\tPicture is too small, not caching it. (Probably an invisible GIF.)\n";
				}
			}
			else
			{
				print qq(\tFailed with HTTP $result fetching "$picurl"\n");
			}
		}

		if(-e $filename)
		{
			$entry->{picture_cached} = "http://foamtotem.org/$fragment";
			return 1;
		}
	}

	return 0;
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
		eval { $resp = $fb->query
			->find("$id/comments")
			->with_filter("stream")
			->request
			->as_hashref;
		};
		if(hug)
		{
			# Some posts just fail now. Catch these so the whole
			#   update doesn't stop.
			print $@;
			print("\nFailed to fetch comments, keeping old ones.\n");
			return;
		}
	}
	else
	{
		# OK, this wasn't originally a facebook item. See if we can find
		# an id for it.
		$id = ol_GetBestFbid($entry->{id});
		if($id)
		{
			print "Going to $id/comments\n";

			eval { $resp = $fb->query
				->find("$id/comments")
				->with_filter("stream")
				->request
				->as_hashref;
			};
			if(hug)
			{
				# Some posts just fail now. Catch these so the whole
				#   update doesn't stop.
				print $@;
				print("\nFailed to fetch comments, keeping old ones.\n");
				return;
			}
		}
		else
		{
			print "\tNo Facebook ID. That's really weird.\n";
		}
	}

	if(defined($resp) && scalar(@{ $resp->{data} }))
	{
		my $orig_count = 0;

		# OK, we got some comments, assume that all the ones are there that
		# should be.

		if(exists($entry->{comments}) && exists($entry->{comments}->{data}))
		{
			$orig_count = scalar @{ $entry->{comments}->{data} };

			# Go through and remove all the FB comments for this object ID,
			#    leaving the Foamy ones and ones from other linked FB IDs
			my @foam_list = grep { !exists($_->{can_remove}) } @{ $entry->{comments}->{data} };

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
		secret => '7c4028223161aedc2325605745a01313' ,
#		lwp_opts => { ssl_opts => { verify_hostname => 0 } }
	);

#	$fb->access_token('CAAC4nFAvuF4BAImlXAJahOPgUwxXP5ZA0U5ZBWTpGt4XXLTxoPS0PZApE5I9w99ZAFLtHyjszXPAPBn6TEBHk0e6V81XDZBHEWtXwNSRdpgHHQbnBD07OxdmIvoM7FQcTVk9wjk7VBxGoDtSqffJCDZAeWFSmRTb9Yn5fzYl2LmGu24SZCHnOZBg');
	$fb->access_token('CAAC4nFAvuF4BAKyIt6lDZCZAhCZCnEdHXLZBoL129XruxJl8JwkTwwsshdG2nKYC83o6V1HxtZAMl5KEGmeyq7UBW0ZCZAxZCs2LTjdH0Ffjv3MZBdwlRZCniij7gEu9H77mW8p9WgOmTsqNq6DFPvuz6uur0OWpIqNFtCbDKEZBACwJEYPtJ9P8NqC');
	return $fb;
}


sub AddLinks
{
	my $entry = shift;

	ol_Add($entry->{id}, $entry->{link})                 if($entry->{link});
	ol_Add($entry->{id}, 'fbid:' . $entry->{'~orig'}->{id})          if($entry->{'~orig'}->{id});
	ol_Add($entry->{id}, 'fbid2:' . $entry->{'~orig'}->{object_id})  if($entry->{'~orig'}->{object_id});
}

sub PeriodicUpdate()
{
	my ($last_year, $last_mon) = (0, 0);

	my $fb = GetFacebook();

	ol_Load();

	my $resp1 = $fb->query
		->find('posniewski/posts')
		->limit_results(10)
#		->where_until('08 Oct 2012')
		->include_metadata
		->request
		->as_hashref;

	my $resp2 = $fb->query
		->find('posniewski/fitness.runs')
		->limit_results(2)
#		->where_until('08 Oct 2012')
		->include_metadata
		->request
		->as_hashref;

	my $posts = $resp1->{data};
	push( @{ $posts }, @{ $resp2->{data} });

	foreach my $post ( reverse @{ $posts } )
	{
		my $time = $post->{created_time} // $post->{publish_time};
		my ($year, $mon, $day, $hh, $mm, $ss) = GetDateTimeFromAtomTimestamp($time);

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
				if(!defined($post->{message}))
				{
					print "\tStatus with no message (a comment I made, I think.) Skipping.\n";
					next;
				}

				print "\tNew status entry: $phfile\n";

				$entry->{type} = 'status';
				$entry->{id} = $foam_id;
				$entry->{publishedDate} = MakeAtomTimestamp($year, $mon, $day, $hh, $mm, $ss);

				$entry->{message}  = $post->{message}             if(exists($post->{message}));
				$entry->{title}    = $post->{title}               if(exists($post->{title}));
				$entry->{link}     = $post->{link}                if(exists($post->{link}));
				$entry->{via}      = $post->{application}->{name} if(exists($post->{application}));
			}
			elsif($post->{type} eq 'photo')
			{
				if(!defined($post->{message}) && defined($post->{story}))
				{
					print "\tPhoto with no message (Someone tagged me, I think.) Skipping.\n";
					next;
				}

				print "\tNew photo entry: $phfile\n";

				$entry->{type} = 'photo';
				$entry->{id} = $foam_id;
				$entry->{publishedDate} = MakeAtomTimestamp($year, $mon, $day, $hh, $mm, $ss);

				$entry->{link}        = $post->{link};
				$entry->{message}     = $post->{message}     if(exists($post->{message}));

				if(exists($post->{properties}))
				{
					$entry->{via} = join(', ',
						map { $_->{text} if($_->{name} =~ m/by/) }
							@{ $post->{properties} });
				}

				# Add the link to this post to the list. The image's link
				#    will get added with the usual AddLinks call below.
				ol_Add($entry->{id}, $post->{link}) if($post->{link});

				# Fetch the actual photo to embed it

				my $imgpost = eval { $fb->query
					->find($post->{object_id})
					->request
					->as_hashref };

				if(hug)
				{
					# Some image posts just fail now. Catch these so the whole
					#   update doesn't stop.
					print "Exception... continuing...";
					$imgpost = $post;
				}

				# Add the facebook id links for the image too. The link to the
				#    post are added with the AddLinks call as usual.
				ol_Add($entry->{id}, 'fbpic2:' . $imgpost->{id})         if($imgpost->{id});
				ol_Add($entry->{id}, 'fbpic:'  . $imgpost->{object_id})  if($imgpost->{object_id});

				# Get comments from the image. They'll be merged with the
				#    ones from my specific post (which are fetched below)
				UpdateComments($fb, $entry, $imgpost);

				my $wid = 0;
				my $ht = 0;
				my $image = FindImage($imgpost->{images});
				if($image)
				{
					$wid = $image->{width};
					$ht = $image->{height};
					if($image->{width} > 500)
					{
						$wid = 500;
						$ht = int( (500.0/$image->{width}) * $image->{height} );
					}
				}

				$entry->{link}         = $imgpost->{link};
				$entry->{image}        = $image->{source} || $post->{picture};
				$entry->{image_width}  = $wid;
				$entry->{image_height} = $ht;

				$entry->{message}      //= $imgpost->{name}       if(exists($imgpost->{name}));
				$entry->{caption}      = $imgpost->{caption}      if(exists($imgpost->{caption}) && !exists($entry->{via}));

				$entry->{via}          = $imgpost->{application}->{name} if(!exists($entry->{via}) && exists($imgpost->{application}));

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
			elsif($post->{type} eq 'fitness.runs')
			{
				print "\tNew Run entry: $phfile\n";

				$entry->{type} = 'run';
				$entry->{id} = $foam_id;
				$entry->{publishedDate} = MakeAtomTimestamp($year, $mon, $day, $hh, $mm, $ss);

				$entry->{message}     = $post->{message}     if(exists($post->{message}));
#				$entry->{picture}     = $post->{picture}     if(exists($post->{picture}));
#				$entry->{name}        = $post->{name}        if(exists($post->{name}));
#				$entry->{caption}     = $post->{caption}     if(exists($post->{caption}));
#				$entry->{description} = $post->{description} if(exists($post->{description}));

				$entry->{via} = $post->{application}->{name}   if(exists($post->{application}->{name}));

				$entry->{link} = $post->{data}->{course}->{url};

				# Get the KML URL from the overall url
				# http://runmeter.net/97fad4bc4c98783d/Run-20130809-0819?r=f
				# http://share.abvio.com/97fa/d4bc/4c98/783d/Runmeter-Run-20130809-0819.kml
				my ($a, $b, $c, $d, $e) = $entry->{link} =~ m[.*runmeter.net/(....)(....)(....)(....)/([^?]+)];
				$entry->{mapurl} = "http://share.abvio.com/" . $a . "/" . $b . "/" . $c . "/" . $d . "/Runmeter-" . $e . ".kml";
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


			# The target link to test against to see if we already have it.
			my $target = $entry->{link};


			#
			# Do the OLD Runmeter stuff
			#
#			if($entry->{via} =~ m/runmeter/i)
#			{
#				if($entry->{type} =~ m/link/)
#				{
#					# This is a new-style runmeter
#					# Which actually has two styles now. :-(
#					if($entry->{caption} && $entry->{caption}=~m/Check out/)
#					{
#						delete $entry->{caption};
#						$entry->{description} = $entry->{name};
#						$entry->{name} = 'Finished Run';
#
#					}
#				}
#				else
#				{
#					# Old-style runmeter
#
#					# Look for the link.
#					# This is a very naive search, but the links are always
#					#   http://j.mp/lzF0y7
#					#
#					($entry->{link}) = $entry->{message} =~ m{(http:[0-9A-Za-z/.]+)};
#
#					my ($desc, $message) = $entry->{message} =~ m/(.* route, time .* miles, average .* see [^\n\r ]+)[\n\r ]*(.*)/si;
#
#					$entry->{description} = $desc;
#					$entry->{message} = $message;
#				}
#
#				my $url = $entry->{link};
#				$url //= $entry->{message} =~ m{(http:[0-9A-Za-z/.]+)};
#
#				if($entry->{link})
#				{
#					my $resp = head($entry->{link});
#
#					if(defined($resp))
#					{
#						$entry->{mapurl} = $resp->base();
#					}
#				}
#
#				# Convert all Runmeter items to run items.
#				$entry->{type} = 'run';
#
#				CacheRunmeterMap($entry);
#			}
#			els
			if($entry->{via} =~ m/twitter/i)
			{
				if($post->{actions})
				{
					foreach my $action (@{ $post->{actions} })
					{
						if($action->{link} =~ m/twitter.com/)
						{
							my ($id) = $action->{link} =~ m/utm_content=([0-9]+)/i;
							$target = "twit:$id";
						}
					}
				}
			}


			#
			# If the link from facebook references Foam Totem directly,
			#    then it's probably a repeat of content that's already here
			#    somewhere. Try to find and cross-link it.
			#
			if(my $id = ol_Resolve($target))
			{
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
					# If this is a run, then the most recent data should
					# supercede the old data.
					if($entry->{type} =~ m/run/i)
					{
						$xentry->{message} = $entry->{message}           if(exists($post->{message}));
					}

					$phfile = $file;
					$entry = $xentry;

					$entry->{"~orig.$post->{id}"} = $post;

					ol_Add($entry->{id}, 'fbid:'   . $post->{id})         if($post->{id});
					ol_Add($entry->{id}, 'fbid2:'  . $post->{object_id})  if($post->{object_id});

					print "\t\tRedirected comments to target ($phfile).\n";
				}
				else
				{
					# We didn't find the file, so we'll assume it's not
					#   already on the blog. Just let it go.
					print "\t\tNo Totem entry found. Handle as normal.\n";
					print "Creating $phfile\n";
				}
			}
			else
			{
				print "Creating $phfile\n";
			}

			AddLinks($entry);

		}


		# Keep comments up to date
		UpdateComments($fb, $entry, $post);

		if($entry->{type} eq 'run')
		{
			$entry->{message} = $post->{message}     if(exists($post->{message}));
		}


		# Do a fixup on runs to cache their map image
		if(exists($entry->{mapurl})) # && !exists($entry->{mapurl_cached}))
		{
			CacheRunmeterMap($entry);
		}

		# Cache Facebook thumbnails because the image links they give eventually
		#   stop working.
		if(exists($entry->{picture}) || exists($entry->{image}))
		{
			CachePicture($fb, $entry);
		}

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

	ol_Save();
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

#
# Helper which takes a phfile and caches the thumbnail picture (if there is one)
#    (I used this to update all the json files when I added the cache.)
#
sub UpdateCachePictureForFile($$)
{
	my $fb = shift;
	my $phfile = shift;

	my $entry = undef;

	if(-e $phfile)
	{
		$entry = from_json_file($phfile);
	}
	elsif(-e $phfile.'x')
	{
		$phfile .= 'x';
		$entry = from_json_file($phfile);
	}

	print "Loaded $phfile. Type " . $entry->{type} . "\n";
	my $picurl = $entry->{picture} || $entry->{image};
    if(!$picurl || $entry->{type} ne 'photo')
	{
		return;
	}

    if($entry->{picture_cached})
    {
		print "Already cached.\n";
		return;
	}

	$entry = UpdatePictureLinks($fb, $entry);

	if(CachePicture($fb, $entry))
	{
		print "Updated $phfile with ".$entry->{picture_cached} . "\n";
		open PHFILE, ">:utf8", $phfile or die $! . ": $phfile";
		print PHFILE scalar to_json($entry);
		close PHFILE;
	}
}


sub UpdatePictureLinks($$)
{
	my $fb = shift;
	my $entry = shift;

	# Fetch the actual photo to embed it

	my $imgpost = eval { $fb->query
		->find($entry->{'~orig'}->{object_id})
		->request
		->as_hashref };

	if(hug)
	{
		# Some image posts just fail now. Catch these so the whole
		#   update doesn't stop.
		print "Exception... continuing...";
		return;
	}

	my $wid = 0;
	my $ht = 0;
	my $image = FindImage($imgpost->{images});
	if($image)
	{
		$wid = $image->{width};
		$ht = $image->{height};
		if($image->{width} > 500)
		{
			$wid = 500;
			$ht = int( (500.0/$image->{width}) * $image->{height} );
		}
	}

	$entry->{image}        = $image->{source} || $entry->{image};
	$entry->{image_width}  = $wid;
	$entry->{image_height} = $ht;

	return $entry;
}


1;
