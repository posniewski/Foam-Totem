package Foam2;

use strict;
use warnings;
no warnings 'redefine';

use Apache::ASP;

use Time::Local;
use File::Copy;
use IO::File;
use Data::Dumper;

use JSON::DWIW;

use URI::Find::Schemeless;
use URI::Escape;
use HTML::Entities; # for encode_entities

use ObjectLinks;

BEGIN {
	use Exporter ();

	our($VERSION, @ISA, @EXPORT, @EXPORT_OK);


	$VERSION = "1.00";

	@ISA     = qw();
	*import = \&Exporter::import;

	@EXPORT  = qw(
		to_json
		from_json_file

		UpdateHTML

		StdHTMLStart
		StdMinHead
		StdBodyStart
		StdBodyEnd
		StdHTMLEnd
		GetFileList
		EditGenMonth

		GenCommentList
		ParseFile

		GetSemaphore
		ReleaseSemaphore

		Linkify

		FromShortMonth
		MakeYYYYMMDD
		GetDateFromYYYYMMDD
		MakeDD_Mon_YYYY
		GetDateTimeFromYYYYMMDD_x_HHMMSS
		GetDateTimeFromAtomTimestamp
		GetLocalDateFromAtomTimestamp
		MakeAtomTimestamp
		ConvertDateTimeToLocal
);
}


# When non-zero, no index.html is generated, and the months are generated
# as "dbg_yyyymm.html"
my $g_debug = 0;

# JSON formatter/deformatter

sub from_json_file
{
	my $foam_json = JSON::DWIW->new({ pretty => 1, sort_keys => 1 , bad_char_policy => 'convert'});
	return $foam_json->from_json_file(@_);
}

sub to_json
{
	my $foam_json = JSON::DWIW->new({ pretty => 1, sort_keys => 1 , bad_char_policy => 'convert'});
	return $foam_json->to_json(@_);
}

sub to_json_tight
{
	my $foam_json = JSON::DWIW->new({ sort_keys => 1 , bad_char_policy => 'convert'});
	return $foam_json->to_json(@_);
}


my $g_flotsam;
#
# "links" = GetFlotsamLinks()
#
sub GetFlotsamLinks
{
	return $g_flotsam;
}

#
# "links" = MakeFlotsamLinks(@files)
#
sub MakeFlotsamLinks
{
	my @files = @_;

	$g_flotsam = '';

	my %available = ();

	my @earliest = GetLocalDateTimeFromName($files[-1]);
	my @latest = GetLocalDateTimeFromName($files[0]);
	foreach my $file (@files)
	{
		my ($year, $month) = GetLocalDateTimeFromName($file);
		$available{ sprintf('%04d%02d', $year, $month) } = 1;
	}

	$g_flotsam .= '<div class="calendar">';
	for(my $year=$earliest[0]; $year<=$latest[0]; $year++)
	{
		$g_flotsam .= '<div class="year">';
		$g_flotsam .= "<h2>$year</h2>";
		for(my $month=1; $month<=12; $month++)
		{
			my $date = sprintf("%04d%02d", $year, $month);
			if(exists($available{$date}))
			{
				$g_flotsam .= "<a href=\"/$date.html\">" . LetterMonth($month) ."</a> ";
			}
		}
		$g_flotsam .= "</div>\n";
	}
	$g_flotsam .= "</div>\n";
}

#
# TotemTop($fh, "Title", $props)
#
sub TotemTop
{
	my $fh = shift;
	my $title = shift;
	my $props = shift;

	StdHTMLStart($fh);
	StdHead($fh, $title, $props);
	StdBodyStart($fh);

	MainHeader($fh);
}

#
# TotemTopAtom($fh, "Title")
#
sub TotemTopAtom
{
	my $fh = shift;
	my $title = shift;
	my $update = MakeAtomTimestamp(GetLastUpdate());

	print $fh <<"EOSTUFF";
<?xml version="1.0" encoding="utf-8"?>
<feed xmlns="http://www.w3.org/2005/Atom">

	<title>Foam Totem</title>
	<link href="http://foamtotem.org/"/>
	<link rel="self" href="http://foamtotem.org/atom.xml"/>
	<icon>favicon.ico</icon>
	<updated>$update</updated>
	<author>
		<name>Shannon Posniewski</name>
	</author>
	<id>tag:foamtotem.org,2008:</id>

EOSTUFF
}

#
# TotemBottom($fh, "links")
#
sub TotemBottom
{
	my $fh = shift;
	my $links=shift;

	MainFooter($fh, $links);
	StdBodyEnd($fh);
	StdHTMLEnd($fh);
}

#
# TotemBottomAtom($fh)
#
sub TotemBottomAtom
{
	my $fh = shift;

	print $fh qq(</feed>\n);
}



#
# (y,m,d,h,m,s) = GetLastUpdate()
#
my $g_newest_file;
sub GetLastUpdate
{
	my ($sec,$min,$hour,$mday,$mon,$year);
	my $datetime;

	if($g_newest_file)
	{
		($year, $mon, $mday, $hour, $min, $sec) = GetDateTimeFromAtomTimestamp($g_newest_file);
	}
	else
	{
		($sec,$min,$hour,$mday,$mon,$year)=gmtime(time);
		$mon += 1;
		$year += 1900;
	}

	return ($year, $mon, $mday, $hour, $min, $sec);
}

#
# $str = MainHeaderLastUpdate()
#
sub MainHeaderLastUpdate
{
	my $datetime = MakeAtomTimestamp(@_);
	my ($year, $mon, $mday, $hour, $min, $sec) = ConvertDateTimeToLocal(@_);

	my $tmon=ShortMonth($mon);

	$min= sprintf("%02d", $min);

	my $ampm="am";
	if($hour>12)
	{
		$hour-=12;
		$ampm="pm";
	}


	return qq(<time datetime="$datetime">)
		. qq($mday $tmon $year -- )
		. qq($hour:$min$ampm</time>\n);
}

#
# Sort and ignore the "priority" value stuck in the middle
#
sub byid
{
	substr($a,0,8).substr($a,11,6) cmp substr($b,0,8).substr($b,11,6);
}

#
# @list = GetFileList("dir")
#
sub GetFileList
{
	my $dailydir = shift;

	opendir DIR, $dailydir or die "Couldn't open directory.";
	my @allfiles = reverse map "$dailydir/$_", sort byid grep /\.(json|ph).?$/, readdir DIR;
	closedir DIR;

	my $modtime = (stat($allfiles[0]))[9];
	# modtime is in local time, dammit.
	my @td = gmtime($modtime);

	$g_newest_file = MakeAtomTimestamp($td[5]+1900, $td[4]+1, $td[3], $td[2], $td[1], $td[0]);

	return @allfiles;
}

##
## GenMonth($fh, year, month, path, @filelist)
##
sub GenMonth
{
	my $fh = shift;
	my $year = shift;
	my $month = shift;
	my $path = shift;
	my @files = @_;

	my %stories = ();

	my $fname = sprintf("%04d%02d",$year,$month);

	@files = grep /\.json$/, @files;

	foreach my $file (@files)
	{
		my $entry = ParseFile($file);

		if($entry->{date} =~ m/^$fname/)
		{
			push @{ $stories{$entry->{date}} }, $entry;
		}
	}

	foreach my $curday (reverse sort keys %stories)
	{
		StartDay($fh, $curday);

		foreach my $story (@{$stories{$curday}})
		{
			# Skip twitter repeats
			if(exists($story->{source}) && defined($story->{source}) && $story->{source} !~ m/twitter/i)
			{
				next if(exists($story->{via}) && defined($story->{via}) && $story->{via} =~ m/twitter/i)
			}

			StartArticle($fh, $story);

			print $fh $story->{content};

			EndArticle($fh, $story);


			# Put out the permalink file
			my $permalink_fh = new IO::File;

			$fname = sprintf("%04d",$year);
			mkdir "$path/../$fname" if(!-e "$path/../$fname");

			$fname .= '/' . ($g_debug ? 'dbg_' : '') . $story->{id} . '.html';

			$permalink_fh->open(">$path/../$fname") or die "can't open $path/../$fname";
			binmode $permalink_fh, ":utf8";

			TotemTop($permalink_fh, GetTitle($story), GetProps($story) );
			StartBlog($permalink_fh);

			StartDay($permalink_fh, $curday);
			StartArticle($permalink_fh, $story);

			print $permalink_fh $story->{content};

			EndFullArticle($permalink_fh, $story);
			EndDay($permalink_fh, $curday);

			EndBlog($permalink_fh);
			TotemBottom($permalink_fh, GetFlotsamLinks());
		}

		EndDay($fh, $curday);
	}
}

#
# $str = Internal_GetContent($story)
#
sub Internal_GetContent
{
	my $story = shift;
	my $s;

	if($story->{source} =~ m/facebook/i)
	{
		my $message = '';

		$message .= $story->{content} if($story->{content});

		if(exists($story->{message}))
		{
			my $msg = Linkify($story->{message});
			$msg =~ s{\n}{<br/>}g;

			$message .= $msg;
		}

		$s = qq(<div class="$story->{type}">);

		if($story->{type} eq 'status')
		{
			if($story->{via} =~ m/runmeter/i)
			{
				if($message =~ m/(Started|Finished) run with runmeter/i)
				{
					my $finish = $story->{message};

					# See if we can find the final info in the comments and
					# hoist it.

					if($story->{comments})
					{
						foreach my $comment (@{ $story->{comments}->{data} })
						{
							if($comment->{message} =~ m/Finished run with runmeter/i)
							{
								$finish = $comment->{message};
							}
						}
					}

					if($finish =~ m/finish/i)
					{
						my ($route, $time, $dist, $pace, $link, $c) = $finish =~ m/, on (.*) route, time (\d+:\d+), (\d+.\d+) miles, average (\d+:\d+), see ([^\n\r ]+)[\n\r ]*(.*)/si;

						$message = qq(Today's run: $route<p/>$dist miles, time $time, pace $pace.<p/>$c<p/>Link: $link);
						$message = Linkify($message);
					}
				}
			}

			if($story->{mapurl})
			{
				my ($url) = $story->{mapurl} =~ m/\?q=(.*)/i;

				$s .= qq(<div class="map" id="map_$story->{id}"></div>);
				$s .= <<"EOSTUFF";
<script>
\$(function() {
	var myOptions = {
		mapTypeId: google.maps.MapTypeId.TERRAIN
	};

	var map = new google.maps.Map(document.getElementById("map_$story->{id}"), myOptions);

	var kml = new google.maps.KmlLayer('$url');
	kml.setMap(map);

});
</script>
EOSTUFF

#				my $url = $story->{mapurl}.'&output=embed&t=p&z=13';
#				$s .= qq(<div class="map">)
#					. qq(<iframe width="350" height="250" frameborder="0" scrolling="no" marginheight="0" marginwidth="0" src="$url"></iframe>)
#					. qq(</div>\n);
			}

			$s .= $message;
		}
		elsif($story->{type} eq 'run')
		{
			if($story->{via} =~ m/runmeter/i)
			{
				if($message =~ m/(Started|Finished) run with runmeter/i)
				{
					my $finish = $story->{message};

					# See if we can find the final info in the comments and
					# hoist it.

					if($story->{comments})
					{
						foreach my $comment (@{ $story->{comments}->{data} })
						{
							if($comment->{message} =~ m/Finished run with runmeter/i)
							{
								$finish = $comment->{message};
							}
						}
					}

					if($finish =~ m/finish/i)
					{
						my ($route, $time, $dist, $pace, $link, $c) = $finish =~ m/, on (.*) route, time (\d+:\d+), (\d+.\d+) miles, average (\d+:\d+), see ([^\n\r ]+)[\n\r ]*(.*)/si;

						$message = qq(Today's run: $route<p/>$dist miles, time $time, pace $pace.<p/>$c<p/>Link: $link);
						$message = Linkify($message);
					}
				}
			}

			if($story->{mapurl})
			{
				my ($url) = $story->{mapurl} =~ m/\?q=(.*)/i;

				$s .= qq(<div class="map" id="map_$story->{id}"></div>);
				$s .= <<"EOSTUFF";
<script>
\$(function() {
	var myOptions = {
		mapTypeId: google.maps.MapTypeId.TERRAIN
	};

	var map = new google.maps.Map(document.getElementById("map_$story->{id}"), myOptions);

	var kml = new google.maps.KmlLayer('$url');
	kml.setMap(map);

});
</script>
EOSTUFF

#				my $url = $story->{mapurl}.'&output=embed&t=p&z=13';
#				$s .= qq(<div class="map">)
#					. qq(<iframe width="350" height="250" frameborder="0" scrolling="no" marginheight="0" marginwidth="0" src="$url"></iframe>)
#					. qq(</div>\n);
			}
			$s .= qq(<div class="message">$message</div>\n)  if($message);
			$s .= qq(<div class="description">) . Linkify($story->{description}) . qq(</div>\n)   if(exists($story->{description}));
		}
		elsif($story->{type} eq 'photo')
		{
			$s .= qq(<div class="message">$message</div>) if($message);
			$s .= qq(<div class="caption">) . Linkify($story->{caption}) . qq(</div>\n)     if(exists($story->{caption}));
			$s .= qq(<a href="$story->{link}">)
				. qq(<img class="facebook" width="$story->{image_width}" height="$story->{image_height}" src="$story->{image}" />)
				. qq(</a>\n);
		}
		else
		{
			$s .= qq(<div class="message">$message</div>\n) if($message);

			# Video links might like this
			#if($story->{link} =~ m/youtube/i)
			#{
			#	$story->{link} =~ m/v=([\-\w]+)/i;
			#	$entry->{content} .= qq(<div class="player"><iframe title="YouTube video player" width="350" height="227" src="http://www.youtube.com/embed/$1?autohide=1" frameborder="0" allowfullscreen></iframe></div>\n);
			#	$entry->{content} .= qq(<div class="picture"><a href="$story->{link}"><img src="$story->{picture}"/></a></div>\n);
			#}
			#else
			#{
			#	$entry->{content} .= qq(<div class="picture"><a href="$story->{link}"><img src="$story->{picture}"/></a></div>\n);
			#}

			$s .= qq(<div class="picture"><a href="$story->{link}"><img src="$story->{picture}"/></a></div>\n) if(exists($story->{picture}));
			$s .= qq(<div class="textblock">\n);
			$s .= qq(<div class="name"><a href="$story->{link}">$story->{name}</a></div>\n) if(exists($story->{name}));
			$s .= qq(<div class="caption">) . Linkify($story->{caption}) . qq(</div>\n)     if(exists($story->{caption}));
			$s .= qq(<div class="description">$story->{description}</div>\n)                if(exists($story->{description}));
			$s .= qq(</div>);
		}
		$s .= qq(</div>);
	}
	elsif($story->{source} =~ m/posterous/i)
	{
		$s .= $story->{content};
	}
	elsif($story->{source} =~ m/twitter/i)
	{
		$s .= $story->{content};
	}
	else
	{
		$s .= $story->{content};
	}

	return $s;
}

#
# $str = StripHaloscan($str, $id)
#
# Removes the comment section if it's embedded.
#    The footer adds one automatically
#
sub StripHaloscan
{
	my $str = shift;
	my $id = shift;

	my ($testid) = $str =~ m/<p.*?HaloScan\('([^']+)'.*?<\/p>/;
	if(defined($testid) && $testid ne $id)
	{
		print "\n<div>comment ID doesn't match! $testid neq $id</div>\n";
		print STDERR "comment ID doesn't match! $testid neq $id\n";
	}
	$str =~ s/<p.*?HaloScan\('([^']+)'.*?<\/p>//;

	return $str;
}


#
# GenMonthAtom($fh, year, month, @filelist)
#
sub GenMonthAtom
{
	my $fh = shift;
	my $year = shift;
	my $month = shift;
	my @files = @_;

	my %stories = ();

	my $fname = sprintf("%04d%02d",$year,$month);

	@files = grep /\.json$/, @files;

	foreach my $file (@files)
	{
		my $entry = ParseFile($file);

		if($entry->{date} =~ m/^$fname/
			&& $entry->{source} !~ m/twitter/i
			&& $entry->{via} !~ m/runmeter/i
			&& ($entry->{source} !~ m/facebook/i || $entry->{via} !~ m/twitter/i))
		{
			push @{ $stories{$entry->{date}} }, $entry;
		}
	}

	foreach my $curday (reverse sort keys %stories)
	{
		foreach my $story (@{ $stories{$curday} })
		{
			my $tag = $story->{id};
			my $title = $story->{title};

			$title = GetTitle($story) if(!defined($title) || !$title);
			$title =~ s/&(?!([a-zA-Z]+|#[0-9]+|#x[0-9a-fA-F]+);)/&amp;/g;

			my $tmp = $story->{content};

			$tmp =~ s"\<br\>"<br/>"g;
			$tmp =~ s/&(?!([a-zA-Z]+|#[0-9]+|#x[0-9a-fA-F]+);)/&amp;/g;

			my $updated = $story->{publishedDate};
			my $href = substr($tag,0,4);

			print $fh <<"EOSTUFF";
	<entry>
		<id>tag:foamtotem.org,2008:$tag</id>
		<title>$title</title>
		<updated>$updated</updated>
		<link rel="alternate" type="text/html" href="http://foamtotem.org/$href/$tag.html" />
		<content type="xhtml">
			<div xmlns="http://www.w3.org/1999/xhtml">
				$tmp
			</div>
		</content>
	</entry>
EOSTUFF
		}
	}
}

#
# EditGenMonth($fh, $path, $year, $month, @files)
#
sub EditGenMonth
{
	my $fh = shift;
	my $path = shift;
	my $year = shift;
	my $month = shift;
	my @files = @_;

	my %stories = ();

	foreach my $file (@files)
	{
		$file =~ m{^$path/(.*)};
		$stories{$1} = $file;
	}

	print $fh "<table width=\"100%\" cellspacing=\"0\" cellpadding=\"5\" border=\"0\" class=\"editmonth\">\n";
	foreach my $file (reverse sort keys %stories)
	{
		if($file =~/x$/) {
			print $fh qq(<tr class="hidden">\n);
		}
		else {
			print $fh "<tr>\n";
		}

		if($file =~ m/\.json/)
		{
			print $fh "	<td class=\"edit\">$file:&nbsp;<a href=\"./AlterDailyJson.asp?phfile=$file\">[Edit]</a>&nbsp;";
		}
		else
		{
			print $fh "	<td class=\"edit\">$file:&nbsp;<a href=\"./AlterDaily.asp?phfile=$file\">[Edit]</a>&nbsp;";
		}

		if($file =~/x$/)
		{
			print $fh "<a href=\"./hide.asp?phfile=$file&show=1\">[show]</a></td>\n";
		}
		else
		{
			print $fh "<a href=\"./hide.asp?phfile=$file&show=0\">[hide]</a></td>\n";
		}

		print $fh qq(	<td width=\"100%\" class=\"content\">);
		if($file=~m/\.json/)
		{
			my $entry = ParseFile($stories{$file});
			print $fh $entry->{content};
		}
		else
		{
			print $fh qq(*** OLD STYLE FILE. WON'T BE GENERATED ***);
		}
		print $fh qq(</td>\n);
		print $fh qq(</tr>\n);
	}
	print $fh "</table>\n";
}

#
# %entry = ParseFile("file")
#
sub ParseFile
{
	my $file = shift;

	my ($entry, $error) = from_json_file($file);

	$entry->{date} = GetLocalDateFromAtomTimestamp($entry->{publishedDate});

	$entry->{source} //= 'foamtotem';
	$entry->{content} = Internal_GetContent($entry);

	if(!exists($entry->{permalink}) || !$entry->{permalink})
	{
		my ($year) = GetDateTimeFromAtomTimestamp($entry->{publishedDate});
		$year = sprintf("%04d", $year);
		$entry->{permalink} = "http://foamtotem.org/$year/$entry->{id}" . '.html';
	}

	if($entry->{source} eq 'foamtotem')
	{
		$file = $entry->{content};

		my @file = split(/\n/, $file);

		my $story = '';
		my $inpara = 0;
		my $startparas = 0;
		foreach my $line (@file)
		{
			if($line=~/^\s*$/)
			{
				if($inpara)
				{
					$story .= "</p>\n";
					$inpara=0;
				}
				$startparas=1;
			}
			else
			{
				if($line =~ m/^\s*\</)
				{
					$startparas=0;
				}

				if($startparas && !$inpara)
				{
					$story .= "<p>";
					$inpara=1;
				}
				$story .= "$line\n";
			}
		}
		if($inpara)
		{
			$story .= "</p>\n";
			$inpara=0;
		}

		$entry->{content} = StripHaloscan($story, $entry->{id});
	}

	return $entry;
}

#
# StartBlog($fh)
#
sub StartBlog
{
	my $fh = shift;
	print $fh qq(<div class="blog">\n);
}


#
# StartDay($fh, "YYYYMMDD")
#
sub StartDay
{
	my $fh = shift;
	my $date = shift;

	print $fh qq(	<div id="date_$date" class="dayblock">\n);
}

#
# StartArticle($fh, $story)
#
sub StartArticle
{
	my $fh = shift;
	my $story = shift;

	my $id = $story->{id};
	my $class = $story->{source};

	my @updated = ConvertDateTimeToLocal(GetDateTimeFromAtomTimestamp($story->{publishedDate}));
	my $nicedate = MakeDD_Mon_YYYY(ConvertDateTimeToLocal(@updated));
	$nicedate =~ s/ /&nbsp;/g;


	# Stick my params in there
	my %foam = (
		'fid' => $story->{id},
#		'perm' => $story->{permalink}
	);

	my $fbid = ol_GetBestFbid($story->{id});
	if($fbid)
	{
		$foam{fbid} = $fbid;
	}
	my $foam = to_json_tight(\%foam);

	print $fh qq(		<article id="fid_$id");
	if(defined($class) && $class)
	{
		print $fh qq( class="$class");
	}
	print $fh qq( foam='$foam');
	print $fh qq(>\n);


	print $fh qq(			<header>\n);
	print $fh qq(				<a href="/daily/AlterDailyJson.asp?phfile=$id.json" rel="nofollow" class="edit"></a>\n);

	$id .= '.html';
	if(defined($story->{title}) && $story->{title})
	{
		print $fh qq(				<h1><a href="/$updated[0]/$id">$story->{title}</a></h1>\n);
	}
	else
	{
		print $fh qq(				<a href="/$updated[0]/$id">&#8734</a>\n);
	}

	print $fh qq(				<time datetime="$story->{publishedDate}">$nicedate</time>\n) if(defined($nicedate) && $nicedate);

	if(defined($story->{via}) && $story->{via})
	{
		print $fh qq(				<a href="$story->{link}">)    if(defined($story->{link}) && $story->{link});
		print $fh qq(				<div class="via">$story->{via}</div>);
		print $fh qq(				</a>)                         if(defined($story->{link}) && $story->{link});
		print $fh qq(\n);
	}

	print $fh qq(			</header>\n);
	print $fh qq(			<div class="body">\n);
}

#
# EndArticle($fh, $story)
#
sub EndArticle
{
	my $fh = shift;
	my $story = shift;

	print $fh qq(			</div>\n);
	print $fh qq(			<footer class="body comments">);
#	print $fh qq(<a href="javascript:HaloScan\('$story->{id}'\);" target="_self"><script type="text/javascript">postCount\('$story->{id}'\);</script></a>);

	if(exists($story->{comments}) && exists($story->{comments}->{data}))
	{
		my $count = scalar(@{ $story->{comments}->{data} });
		if($count > 1)
		{
			print $fh qq(<a href="$story->{permalink}" class="permalink">Reply or View all $count comments</a>);
#			print $fh qq(<a href="#" class="expander" onClick="cexpand(this); return false;">Reply or View all $count comments</a>);
		}
		else
		{
			print $fh qq(<a href="$story->{permalink}" class="permalink">Reply or View comments</a>);
#			print $fh qq(<a href="#" class="expander" onClick="cexpand(this); return false;">Reply or View comments</a>);
		}
	}
	else
	{
		print $fh qq(<a href="$story->{permalink}" class="permalink">Add a comment</a>);
	}

	print $fh qq(</footer>\n);

	print $fh qq(		</article>\n);
}

#
# EndFullArticle($fh, $story)
#
sub EndFullArticle
{
	my $fh = shift;
	my $story = shift;

	print $fh qq(			</div>\n);
	print $fh qq(			<footer class="body full_comments">);
#	print $fh qq(<a href="javascript:HaloScan\('$story->{id}'\);" target="_self"><script type="text/javascript">postCount\('$story->{id}'\);</script></a>);

	print $fh qq(</footer>\n);

	print $fh qq(		</article>\n);
}

#
# GenCommentList($fh, \%comments, $count)
#
sub GenCommentList
{
	my $fh = shift;
	my $comments = shift;
	my $max = shift // 0;

	print $fh qq(<ul>);
	my $count = scalar(@{ $comments->{data} });
	if($count > 0)
	{
		if($max>0 && $max<$count)
		{
			print $fh qq{<a href="#" onClick="cexpand(this); return false;">Show }
				. scalar($count-$max)
				. qq( more comments.</a>);
		}

		foreach my $comment (@{ $comments->{data} })
		{
			if($count-- <= $max || $max==0)
			{
				print $fh qq(<li>);
				my @dt = ConvertDateTimeToLocal(GetDateTimeFromAtomTimestamp($comment->{created_time}));
				my $date = sprintf("%s %d at %d:%02d", LongMonth($dt[1]), $dt[2], $dt[3], $dt[4]);
				print $fh qq(<div class="cdate">$date</div>);

				print $fh qq(<div class="cname">$comment->{from}->{name}</div>);

				my $msg = Linkify($comment->{message});
				$msg =~ s{\n}{<br/>}g;
				print $fh qq(<div class="cmessage">$msg</div>);

				print $fh qq(</li>);
			}
		}
	}
	print $fh qq(</ul>);
}

#
# EndDay($fh)
#
sub EndDay
{
	my $fh = shift;
	print $fh qq(	</div>\n);
}

#
# EndBlog($fh)
#
sub EndBlog
{
	my $fh = shift;
	print $fh qq(</div>\n);
}

#
# StdHTMLStart($fh)
#
sub StdHTMLStart
{
	my $fh = shift;

#	my $StdHTMLHeader='<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">'
#	my $StdHTMLHeader='<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">'

	my $StdHTMLHeader='<!doctype html>'
		. "\n";

	my $StdFoamTotemHeader="<html>\n\t<!-- This page is part of the FoamTotem web site. -->\n\t<!-- Copyright (c) 1996-2011, Shannon Posniewski  -->\n";

	print $fh $StdHTMLHeader;
	print $fh $StdFoamTotemHeader;
}

#
# StdHead($fh, "title", $props)
#
sub StdHead
{
	my $fh = shift;
	my $title = encode_entities(shift);
	my $props = shift;

	print $fh qq(<head>\n);
	print $fh qq(<title>$title - Foam Totem</title>\n);

	#
	# Basic HTML and HTTP stuff
	#
	print $fh <<"EOSTUFF";
		<meta charset="utf-8" />
		<link rel="stylesheet" href="/css/foamtotem-weblog.css" />
		<link rel="shortcut icon" href="/favicon.ico" />
		<link rel="alternate" type="application/atom+xml" title="Foam Totem" href="http://foamtotem.org/atom.xml" />
		<link rel="openid.server" href="http://www.myopenid.com/server" />
		<link rel="openid.delegate" href="http://posniewski.myopenid.com/" />
EOSTUFF

	#
	# Site-wide metadata
	#
	print $fh <<"EOSTUFF";
		<meta name="viewport" content="width=850" />
		<meta name="geo.placename" content="Mountain View, CA 94043, USA" />
		<meta name="geo.position" content="37.41614;-122.09131" />
		<meta name="geo.region" content="US-CA" />
		<meta name="ICBM" content="37.41614;-122.09131" />
		<meta name="DC.title" content="Foam Totem" />

		<meta property="fb:app_id" content="219939589007" />
		<meta property="og:site_name" content="Foam Totem" />
EOSTUFF

	#
	# Extra meta properties (page-level)
	#
	print $fh qq(		<meta property="og:title" content="$title" />\n);

	foreach my $key ( keys %{ $props } )
	{
		my $property = $key;
		$property =~ s/~.*//;

		my $content = encode_entities($props->{$key});
		$content =~ s/^\s*//g;
		$content =~ s/\s*$//g;
		print $fh qq(		<meta property="$property" content="$content" />\n);
	}

	#
	# Putting the site's image last.
	#
	print $fh qq(		<meta property="og:image" content="http://foamtotem.org/images/totemhead.png" />\n);

	#
	# Scripts
	#
	print $fh <<"EOSTUFF";
<!-- <script type="text/javascript" src="http://www.haloscan.com/load/foamtotem"></script> -->
<script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jquery/1/jquery.min.js"></script>
<script type="text/javascript" src="http://www.google.com/recaptcha/api/js/recaptcha_ajax.js"></script>
<script type="text/javascript" src="http://maps.google.com/maps/api/js?sensor=false"></script>
<script type="text/javascript" src="/js/galleria-min.js"></script>
<script type="text/javascript" src="/js/fbcomment.js"></script>
<script type="text/javascript" src="/js/jquery.form.js"></script>

<!--[if lt IE 9]>
<script src="http://html5shim.googlecode.com/svn/trunk/html5.js"></script>
<![endif]-->
EOSTUFF

	print $fh qq(</head>\n);
}

#
# StdMinHead($fh, "title")
#
sub StdMinHead
{
	my $fh = shift;
	my $title = shift;

	print $fh qq(<head>\n);
	print $fh qq(<title>$title</title>\n);

	print $fh <<'EOSTUFF';
<meta charset="utf-8" />
<link rel="stylesheet" href="/css/foamtotem-admin.css" />

<!--[if lt IE 9]>
<script src="http://html5shim.googlecode.com/svn/trunk/html5.js"></script>
<![endif]-->

</head>
EOSTUFF
}

#
# StdBodyStart($fh)
#
sub StdBodyStart
{
	my $fh = shift;

	print $fh qq(<body>\n);

	print $fh <<'END_FACEBOOK_STUFF';
	<div id="fb-root"></div>
<script>
	(function() {
		var e = document.createElement('script');
		e.async = true;
		e.src = document.location.protocol +
		'//connect.facebook.net/en_US/all.js';
		document.getElementById('fb-root').appendChild(e);
	}());
</script>
END_FACEBOOK_STUFF

	print $fh qq(<div class="all">\n);
}

#
# MainHeader($fh)
#
sub MainHeader
{
	my $fh = shift;

	print $fh <<'EOSTUFF';
<header class="main">
	<h1><a href="http://foamtotem.org"><img src="/images/foamtotem-1.png" alt="FOAM TOTEM" width=549 height=70 /></a></h1>

<!--
	<div id="radio">
			<img src="/images/wreath.gif"><br>
			Foamy<br>Christmas&nbsp;Radio<br>
			<a href="/radio/christmas/?option=recursive&amp;option=shuffle&amp;action=playall">[high]</a>&nbsp;<a href="/radio/christmas_low/?option=recursive&amp;option=shuffle&amp;action=playall">[low]</a>
	</div>
-->

	<div id="last-update">
		<a href="/daily/AlterDailyJson.asp" rel="nofollow">Last update:</a>
EOSTUFF
	print $fh MainHeaderLastUpdate(GetLastUpdate());
	print $fh qq(	</div>\n);
	print $fh qq(</header>\n);
	print $fh qq(<img src="/images/headerbar.png" width=850 height=18 />);
}

#
# MainFooter($fh)
#
sub MainFooter
{
	my $fh = shift;
	my $links = shift;

	print $fh <<"EOSTUFF";
<footer class="main">
<nav>
	$links
</nav>
<img src="/images/longsectionmarker.png" width=100 height=16 />
<nav>
	<a href="./WebCam/index.html">Naked Programmer Cam</a> -
	<a href="./postcards/index.html">Postcards</a> -
	<a href="http://www.zazzle.com/foamtotem*">Schwag</a> -
	<a href="./tsp">The Svelte Programmer</a><br>

	<a href="./future/index.html">Orb of Hotep</a> -
	<a href="./random/index.html">Random Stuff</a> -
	<a href="./SFBay/index.html">SF Bay Trojans</a> -
	<a href="./foamtotm/index.html">Totem Tales</a> -
	<a href="./gallery/">Gallery</a><br>
</nav>
<img src="/images/longsectionmarker.png" width=100 height=16 />
<nav>
Me:
<a href="http://www.google.com/profiles/posniewski" rel="me">Google</a> -
<a href="http://twitter.com/posniewski" rel="me">Twitter</a> -
<a href="http://www.facebook.com/posniewski" rel="me">Facebook</a><br>
</nav>
<img src="/images/totemhead.png" width=40 height=64 />
</footer>
EOSTUFF
}

#
# StdBodyEnd($fh)
#
sub StdBodyEnd
{
	my $fh = shift;

	print $fh <<'EOSTUFF';
<script type="text/javascript">

  var _gaq = _gaq || [];
  _gaq.push(['_setAccount', 'UA-587357-1']);
  _gaq.push(['_trackPageview']);

  (function() {
    var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
    ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
    var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
  })();

</script>
EOSTUFF

	print $fh qq(\n</div>\n);
	print $fh qq(</body>\n);
}

#
# StdHTMLEnd($fh)
#
sub StdHTMLEnd
{
	my $fh = shift;

	print $fh qq(\n);
	print $fh qq(</html>\n);
}

#
# "outfile" = UpdateHTML("basepath", $year, $month)
#
sub UpdateHTML
{
	my $path = shift;
	my $year = shift;
	my $mon = shift;

	my $fh = new IO::File;

	my @files = GetFileList($path);
	MakeFlotsamLinks(@files);

	#
	# HTML page
	#
	my $outfile = sprintf('%04d%02d.html',$year,$mon);
	if($g_debug)
	{
		$outfile = 'dbg_' . $outfile;
	}

	$fh->open(">$path/../$outfile") or die "can't open $path/../$outfile";
	binmode $fh, ":utf8";

	TotemTop($fh, LongMonth($mon) . " Flotsam - Foam Totem");
	StartBlog($fh);
	GenMonth($fh, $year, $mon, $path, @files);
	EndBlog($fh);
	TotemBottom($fh, GetFlotsamLinks());

	$fh->close;

	#
	# If we're regenning this month, update the index and atom feed
	#
	if(!$g_debug)
	{
		my ($gak,$nowmon,$nowyear);
		($gak,$gak,$gak,$gak,$nowmon,$nowyear,$gak,$gak,$gak) = localtime(time);
		if(($nowyear+1900)==$year && ($nowmon+1)==$mon)
		{
			copy("$path/../$outfile","$path/../index.html");
			copy("$path/../$outfile","$path/../index.htm");

			#
			# Atom feed
			#
			$fh->open(">$path/../atom.xml") or die "can't open $path/../atom.xml";
			binmode $fh, ":utf8";

			TotemTopAtom($fh);
			GenMonthAtom($fh, $year, $mon, $path, @files);
			TotemBottomAtom($fh);

			$fh->close;
		}
	}

	return $outfile;
}

#
# $sem = GetSemaphore()
#
sub GetSemaphore
{
	my $semfile = '/tmp/NewDaily.$';
	my $wait=0;

	while(-e $semfile)
	{
		if($wait>20)
		{
			print "I was unable to submit your changes. There is still a lock out.";
			$semfile = '';
			last;
		}
		sleep 1;
		$wait++;
	}

	if($semfile ne '')
	{
		if(!open SEM, ">$semfile")
		{
			print "I was unable to submit your changes. I couldn't make a lock file.";
			$semfile = '';
		}
		else
		{
			print SEM "locked";
			close SEM;
		}
	}

	return $semfile;
}

#
# ReleaseSemaphore($sem)
#
sub ReleaseSemaphore
{
	my $semfile = shift;

	unlink $semfile;
}


#
# GetTitle(%story)
#
sub GetTitle
{
	my $story = shift;

	my $title;

	if(!exists($story->{title}) || !$story->{title})
	{
		$title = untag($story->{content});

		# Take the first sentence (or up to first \n)
		if($title =~ m/[ \n\r\t]*(.*?)([.!?\n])/)
		{
			$title = $1;
			$title .= $2   if($2 eq '!' || $2 eq '?');
		}
		else
		{
			$title = substr($title, 0, 140);
		}
	}
	else
	{
		$title = $story->{title};
	}


	return $title;
}

#
# GetProps(%story)
#
sub GetProps
{
	my $story = shift;
	my $props = {};

	$props->{'og:type'} = 'article';
	$props->{'og:url'} = $story->{permalink};

	if(exists($story->{description}))
	{
		$props->{'og:description'} = $story->{description};
	}
	elsif(exists($story->{message}))
	{
		$props->{'og:description'} = $story->{message};
	}
	elsif(exists($story->{content}))
	{
		my $snippet = substr(untag($story->{content}), 0, 200);
		if($snippet =~ m/(.*[.])/)
		{
			$snippet = $1;
		}
		$props->{'og:description'} = $snippet;
	}

	if(exists($story->{image}))
	{
		$props->{'og:image'} = $story->{image};
	}
	elsif(exists($story->{picture}))
	{
		$props->{'og:image'} = $story->{picture};
	}
	elsif(exists($story->{content}))
	{
		my $count = 0;
		my @images = map { /<img.*?src=['"](.*?)['"].*?>/ig } $story->{content};
		foreach my $img (@images)
		{
			# og:image props need to be full URLs.
			$img = "http://foamtotem.org$img" if($img !~ m/^http:/);

			$count++;
			$props->{"og:image~$count"} = $img;
		}
	}

	return $props;
}

#
# Helper for Linkify
#
my $g_link_finder = URI::Find::Schemeless->new(sub {
	my($uri, $orig_uri) = @_;
	return qq(<a href="$uri">$orig_uri</a>);
});

#
# $str = Linkify($str)
#
sub Linkify
{
	my $text = shift;

	$g_link_finder->find(\$text);

	return $text;
}


#
# "date" = LastUpdateAtom()
#
sub LastUpdateAtomTimestamp
{
	my ($sec,$min,$hour,$mday,$mon,$year)=gmtime(time);
	$year+=1900;
	$mon+=1;

	return MakeAtomTimestamp($year, $mon, $mday, $hour, $min, $sec);
}

#
# "Mon" = ShortMonth(month)
#
sub ShortMonth
{
	my $mon=(shift)-1;

	return ('Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct',
		'Nov','Dec')[$mon];
}

#
# "M" = LetterMonth(month)
#
sub LetterMonth
{
	my $mon=(shift)-1;

	return ('J','F','M','A','M','J','J','A','S','O',
		'N','D')[$mon];
}

#
# "Month" = LongMonth(month)
#
sub LongMonth
{
	my $mon=(shift)-1;

	return ('January','February','March','April','May','June','July',
		'August','September','October','November','December')[$mon];
}

#
# $monthnum = FromShortMonth("Mon")
#
sub FromShortMonth
{
	my $monstr = shift;

	my %months =
	(
		'Jan' =>  1,
		'Feb' =>  2,
		'Mar' =>  3,
		'Apr' =>  4,
		'May' =>  5,
		'Jun' =>  6,
		'Jul' =>  7,
		'Aug' =>  8,
		'Sep' =>  9,
		'Oct' => 10,
		'Nov' => 11,
		'Dec' => 12
	);

	return $months{$monstr};
}

## #
## # $priority = GetPriorityFromName("filename");
## #
## sub GetPriorityFromName
## {
## 	my $filename = shift;
##
## 	$filename =~ s".*/.*_([0-9]+)_([^/]+)\.(json|ph)"$1";
## 	return $filename;
## }

#
# ($year, $month, $day) = GetLocalDateTimeFromName("filename");
#
sub GetLocalDateTimeFromName
{
	my $filename = shift;

	$filename =~ s".*/([^/]+)\.(json|ph)"$1";
	my @dt = GetDateTimeFromYYYYMMDD_x_HHMMSS($filename);
	@dt = ConvertDateTimeToLocal(@dt);
}

#
# ($year, $month, $day) = GetDateFromYYYYMMDD("str");
#
sub GetDateFromYYYYMMDD
{
	my $str = shift;

	my $year = substr($str, 0, 4);
	my $mon = substr($str, 4, 2);
	my $day = substr($str, 6, 2);

	return ($year, $mon, $day);
}

## #
## # ($year, $month, $day) = GetDateTimeFromName("filename");
## #
## sub GetDateTimeFromName
## {
## 	my $filename = shift;
##
## 	$filename =~ s".*/([^/]+)\.(json|ph)"$1";
## 	return GetDateTimeFromYYYYMMDD_x_HHMMSS($filename);
## }

#
# ($year, $month, $day) = GetDateTimeFromYYYYMMDD_x_HHMMSS("str");
#
sub GetDateTimeFromYYYYMMDD_x_HHMMSS
{
	my $str = shift;

	my $year = substr($str, 0, 4);
	my $mon = substr($str, 4, 2);
	my $day = substr($str, 6, 2);
	my $hh = substr($str, 11, 2);
	my $mm = substr($str, 13, 2);
	my $ss = substr($str, 15, 2);

	$hh=0 if($hh !~ m/\d\d/ || $hh<0 || $hh>23);
	$mm=0 if($mm !~ m/\d\d/ || $mm<1 || $mm>12);
	$ss=0 if($ss !~ m/\d\d/ || $ss<0 || $ss>59);

	return ($year, $mon, $day, $hh, $mm, $ss);
}

## #
## # ($year, $month, $day) = GetDateFromDD_Mon_YYYY("str");
## #
## sub GetDateFromDD_Mon_YYYY
## {
## 	my $str = shift;
##
## 	my ($day,$mon,$year) = split(/ /,$str);
## 	$mon = FromShortMonth($mon);
##
## 	if($year<100)
## 	{
## 		$year += 1900;
## 	}
##
## 	return ($year, $mon, $day);
## }

#
# "DD Mon YYYY" = MakeDD_Mon_YYYY($year, $month, $day);
#
sub MakeDD_Mon_YYYY
{
	my $year = shift;
	my $mon = shift;
	my $day = shift;

	return sprintf("%d %s %d", $day, ShortMonth($mon), $year);
}

#
# "YYYYMMDD" = MakeYYYYMMDD($year, $month, $day);
#
sub MakeYYYYMMDD
{
	my $year = shift;
	my $mon = shift;
	my $day = shift;

	return sprintf("%04d%02d%02d", $year, $mon, $day);
}

#
# "YYYY-MM-DDTHH:MM:SS+00:00" = MakeAtomTimestamp($year, $month, $day, $hh, $mm, $ss);
#
sub MakeAtomTimestamp
{
	my ($year, $mon, $day, $hh, $mm, $ss) = @_;

	if(!$hh)
	{
		return sprintf("%04d-%02d-%02d", $year, $mon, $day);
	}
	else
	{
		return sprintf("%04d-%02d-%02dT%02d:%02d:%02d+00:00", $year, $mon, $day, $hh, $mm, $ss);
	}
}

#
# ($year, $month, $day, $hh, $mm, $ss, $tz) = GetDateTimeFromAtomTimestamp("YYYY-MM-DDTHH:MM:SS");
#
# DANGER: Ignores time zone (assumes GMT)
#
sub GetDateTimeFromAtomTimestamp
{
	my $atom = shift;

	my ($year, $mon, $day, $hh, $mm, $ss);

	if( $atom =~ m/T/ )
	{
		($year, $mon, $day, $hh, $mm, $ss) = $atom =~ m/(\d\d\d\d)-(\d\d)-(\d\d)T(\d\d):(\d\d):(\d\d)/;
	}
	else
	{
		($year, $mon, $day) = $atom =~ m/(\d\d\d\d)-(\d\d)-(\d\d)/;
		$hh = $mm = $ss = 0;
	}

	return ($year, $mon, $day, $hh, $mm, $ss);
}

#
# "YYYYMMDD" = GetLocalDateFromAtomTimestamp("YYYY-MM-DDTHH:MM:SS-08:00")
#
sub GetLocalDateFromAtomTimestamp
{
	my @dt = GetDateTimeFromAtomTimestamp(shift);
	@dt = ConvertDateTimeToLocal(@dt);

	return sprintf("%04d%02d%02d", $dt[0], $dt[1], $dt[2]);
}

#
# ConvertDateTimeToLocal
#
sub ConvertDateTimeToLocal
{
	my ($year, $mon, $mday, $hour, $min, $sec) = @_;

	($sec, $min, $hour, $mday, $mon, $year) = localtime(timegm($sec, $min, $hour, $mday, $mon-1, $year-1900));
	$mon += 1;
	$year += 1900;

	return ($year, $mon, $mday, $hour, $min, $sec);
}



sub untag {
  local $_ = $_[0] || $_;
# ALGORITHM:
#   find < ,
#       comment <!-- ... -->,
#       or comment <? ... ?> ,
#       or one of the start tags which require correspond
#           end tag plus all to end tag
#       or if \s or ="
#           then skip to next "
#           else [^>]
#   >
  s{
    <               # open tag
    (?:             # open group (A)
      (!--) |       #   comment (1) or
      (\?) |        #   another comment (2) or
      (?i:          #   open group (B) for /i
        ( TITLE  |  #     one of start tags
          SCRIPT |  #     for which
          APPLET |  #     must be skipped
          OBJECT |  #     all content
          STYLE     #     to correspond
        )           #     end tag (3)
      ) |           #   close group (B), or
      ([!/A-Za-z])  #   one of these chars, remember in (4)
    )               # close group (A)
    (?(4)           # if previous case is (4)
      (?:           #   open group (C)
        (?!         #     and next is not : (D)
          [\s=]     #       \s or "="
          ["`']     #       with open quotes
        )           #     close (D)
        [^>] |      #     and not close tag or
        [\s=]       #     \s or "=" with
        `[^`]*` |   #     something in quotes ` or
        [\s=]       #     \s or "=" with
        '[^']*' |   #     something in quotes ' or
        [\s=]       #     \s or "=" with
        "[^"]*"     #     something in quotes "
      )*            #   repeat (C) 0 or more times
    |               # else (if previous case is not (4))
      .*?           #   minimum of any chars
    )               # end if previous char is (4)
    (?(1)           # if comment (1)
      (?<=--)       #   wait for "--"
    )               # end if comment (1)
    (?(2)           # if another comment (2)
      (?<=\?)       #   wait for "?"
    )               # end if another comment (2)
    (?(3)           # if one of tags-containers (3)
      </            #   wait for end
      (?i:\3)       #   of this tag
      (?:\s[^>]*)?  #   skip junk to ">"
    )               # end if (3)
    >               # tag closed
   }{}gsx;          # STRIP THIS TAG
  return $_ ? $_ : "";
}

1;

