#!/usr/bin/perl -w
use Data::Dumper;
use URI::Escape;
use HTTP::Request;
use LWP::UserAgent;
use Time::Local;

use Posterous;

use Foam2;
use ObjectLinks;

sub GetDateTimeFromPosterousTimestamp($)
{
	# Sat, 12 Dec 2009 19:14:08 -0800
	my @parts = split /[ :]/, shift;

	my $day = $parts[1];
	my $mon = FromShortMonth($parts[2]);
	my $year = $parts[3];
	my $hh = $parts[4];
	my $mm = $parts[5];
	my $ss = $parts[6];

	return ($year, $mon, $day, $hh, $mm, $ss);
}

sub GetYYYYMMDD_1_HHMMSS($$$$$$)
{
	my ($year, $mon, $mday, $hh, $mm, $ss) = @_;
	return sprintf("%04d%02d%02d_1_%02d%02d%02d", $year, $mon, $mday, $hh, $mm, $ss);
}

sub Reformat($)
{
	my $entry = shift;

	# Find the via, if there is one
	my ($via) = $entry->{content} =~ m{<div[^>]*>via[\s]*(.*?)</div>}s;
	if($via)
	{
		$entry->{content} =~ s{<div[^>]*>via.*?</div>}{}g;
		$entry->{link_posterous} = $entry->{link};

		($entry->{link}, $entry->{via}) = $via =~ m{<a.*?href=["']([^"']+)[^>]+>(.*)</a>}i;
	}

	# Check to see if there are a stack of images. If so, reformat them into
	# a gallery
	my $cnt = () = ($entry->{content} =~ m/<img/ig);
	if($cnt > 1)
	{
		my $foam_id = $entry->{id};

		# this is a gallery, hopefully.
		$entry->{content} =~ s{p_image_embed}{p_image_embed gallery_$foam_id}s;
		$entry->{content} .= qq(<script>\n\tGalleria.loadTheme('/js/galleria_themes/classic/galleria.classic.js');\n\t\$(".gallery_$foam_id").galleria();\n</script>\n);
	}
	else
	{
		# Mark images from posterous as posterous images.
		$entry->{content} =~ s{<img }{<img class="posterous" }s;
	}

	# XHTMLify img tags
	$entry->{content} =~ s{(<img[^>]+[^/])>}{$1 />}ig;

	# Get rid of leading and trailing blanks.
	$entry->{content} =~ s{^[\s\n\r]+}{}s;
	$entry->{content} =~ s{[\s\n\r]+$}{}s;
}


#eval
{
	ol_Load();

	my ($last_year, $last_mon) = (0, 0);
	my $posterous = Posterous->new('posniewski@gmail.com', 'number6');

	my $resp = $posterous->read_posts(num_posts => 10);

	if(exists($resp->{post}->{id}))
	{
		# This is a single post. Sadly, there's a different structure
		# with singleton post in it. Remunge $resp to be the same.
		my %foo = ();

		$foo->{post}->{$resp->{post}->{id}} = $resp->{post};
		$foo->{stat} = $resp->{stat};
		$resp = $foo;
	}

	my $posts = $resp->{post};
	for my $post_id (sort keys %{ $posts })
	{
		my $post = $posts->{$post_id};

		my ($year, $mon, $day, $hh, $mm, $ss) = GetDateTimeFromPosterousTimestamp($post->{date});
		my $foam_id = GetYYYYMMDD_1_HHMMSS($year, $mon, $day, $hh, $mm, $ss);

		next if($year<2011);

		if(!(-e '/home/www/html/daily/'.$foam_id.'.json') && !(-e '/home/www/html/daily/'.$foam_id.'.jsonx'))
		{
			my $entry;

			$entry->{id} = $foam_id;
			$entry->{publishedDate} = MakeAtomTimestamp($year, $mon, $day, $hh, $mm, $ss);
			$entry->{content} = $post->{body};
			$entry->{title} = $post->{title};
			$entry->{link} = $post->{link};

			$entry->{source} = 'posterous';

#			$entry->{via} = filled inside of reformat
#			$entry->{link} = potentially modified inside of reformat
			Reformat($entry);

			ol_Add($entry->{id}, $entry->{link})   if($entry->{link});

			open PHFILE, ">:utf8", "/home/www/html/daily/$foam_id.json" or die $! . ": $foam_id";
			print PHFILE scalar to_json($entry);
			close PHFILE;

			if(($last_year && $last_year!=$year) || ($last_mon && $last_mon!=$mon))
			{
				Foam2::UpdateHTML('/home/www/html/daily', $last_year, $last_mon);
			}

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

