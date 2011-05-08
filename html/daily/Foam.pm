package Foam;

use strict;
use Time::Local;
use Apache::ASP;
use File::Copy;

BEGIN {
	use Exporter ();

	our($VERSION, @ISA, @EXPORT, @EXPORT_OK);

	$VERSION = "1.00";
	@ISA     = qw(Exporter);
	@EXPORT  = qw(
		MakeFlotsamLinks
		TotemTop
		TotemBottom
		LastUpdate
		ShortMonth
		LongMonth
		GetDateFromName
		GetFileList
		GenMonth
		EditGenMonth
		ParseFile
		StartItems
		EndItems
		StdBodyEnd
		StdBodyStart
		StdFoamTotemHTMLEnd
		StdFoamTotemHTMLStart
		GetDateFromYYYYMMDD
		MakeDD_Mon_YYYY
		UpdateHTML
		GetSemaphore
		ReleaseSemaphore
		MakeYYYYMMDD
	);
}


# When non-zero, no index.html is generated, and the months are generated
# as "dbg_yyyymm.html"
my $g_debug = 0;

# hallowe'en (black and orange)
#my $background='';
#my $alink='';
#my $titlecolor='orange';
#my $titleimg = '/daily/images/foamtotem-halloween.png'; # optional
#my $bgcolor='black';
#my $bgimg = '/daily/images/haunted.gif'; # optional
#my $link='#ff8809';
#my $vlink='#b56001';
#my $textcolor='orange';
#my $textcolor_dim='gray';
#my $datecolor='black';
##
#my $lightbgcolor='#080808';
#my $darkbgcolor='#111111';
#my $lightcolor2='#ff8809';
#my $darkcolor2='#7F3900';
#my $color2='#D36E08';
#my $teat='teat.gif';
#my $foamster='blank.gif';
#my $radio = 'foamy';
##my $twitter = 'Ephemera';
#my $twitter;

## christmas
#my $background='';
#my $alink='';
#my $titlecolor='';
#my $titleimg;
#my $bgcolor='#0C3A01';
#my $bgimg;
#my $link='#aaffaa';
#my $vlink='#88ee88';
#my $textcolor='#ffffff';
#my $textcolor_dim='gray';
#my $datecolor=$textcolor;
##
#my $lightbgcolor='#1C6B02';
#my $darkbgcolor='#134401';
#my $color2='#8E0000';
#my $lightcolor2='#a00000';
#my $darkcolor2='#700000';
#my $teat='teat-red.gif';
#my $foamster='xmasfoamster.gif';
#my $radio = 'christmas';
##my $twitter = 'Ephemera';
#my $twitter;

# orange
#my $background='';
#my $titlecolor='black';
#my $titleimg;
#my $alink='';
#my $bgcolor='#eeeecc';
#my $bgimg;
#my $link='#b56001';
#my $vlink='#824000';
#my $textcolor='black';
#my $textcolor_dim='gray';
#my $datecolor=$textcolor;
#
#my $darkbgcolor='#ddddbb';
#my $color2='#ff8809';
#my $teat='teat.gif';
#my $foamster='foamster.gif';
#my $radio = 'foamy';
##my $twitter = 'Ephemera';
#my $twitter;

# spring greenish
#my $background='';
#my $titlecolor='#ff4400';
#my $titleimg;
#my $alink='';
#my $bgcolor='#ffff99';
#my $bgimg;
#my $link='#336644';
#my $vlink='#003311';
#my $textcolor='black';
#my $textcolor_dim='gray';
#my $datecolor=$bgcolor;
#
#my $darkbgcolor='#ffff55';
#my $color2='#336644';
#my $teat='teat-red.gif';
#my $radio = 'foamy';
#my $foamster='';
##my $twitter = 'Ephemera';
#my $twitter;

# winter (icy blue)
my $background='#6bcdff';
my $alink='';
my $titlecolor='black';
my $titleimg='/daily/images/foamtotem-winter.png';
my $bgcolor='#';
my $bgimg='/daily/images/background-tree.gif';
my $link='#004C72';
my $vlink='#004C72'; ##06689a';
my $textcolor='black';
my $textcolor_dim='gray';
my $datecolor=$textcolor;
#
my $lightbgcolor='rgba(255, 255, 255, .6)';
my $darkbgcolor='rgba(107, 205, 255, .2)';
my $color2='#58AAD3';
my $lightcolor2='#6bcdff';
my $darkcolor2='#407f99';
my $teat='teat-blue.gif';
my $foamster='foamster-blue.gif';
my $radio = 'christmas';
#my $twitter = 'Ephemera';
my $twitter;

if(!defined($lightbgcolor))
{
	$lightbgcolor = $bgcolor;
}

if(!defined($lightcolor2))
{
	$lightcolor2 = $color2;
	$darkcolor2 = $color2;
}

#
#
# "links" = MakeFlotsamLinks(@files)
#
sub MakeFlotsamLinks
{
	my @files = @_;
	my $ret;

	my %available = ();

	my @earliest = GetDateFromName($files[-1]);
	my @latest = GetDateFromName($files[0]);
	foreach my $file (@files)
	{
		my ($year, $month) = GetDateFromName($file);
		$available{"$year$month"} = 1;
	}

	for(my $year=$earliest[0]; $year<=$latest[0]; $year++)
	{
		$ret .= '<td align="center" valign="top" width="6.5%"><font size="1">';
		$ret .= "$year<br>";
		for(my $month=1; $month<=12; $month++)
		{
			my $date = sprintf("%04d%02d", $year, $month);
			if(exists($available{$date}))
			{
				$ret .= "<a href=\"/$date.html\">" . ShortMonth($month) ."</a> ";
			}
		}
		$ret .= "</font></td>\n";
	}

	return $ret;
}

#
# TotemTop("Title")
#
sub TotemTop
{
	my $title = shift;

	StdFoamTotemHTMLStart();
	StdBodyStart($title);

	print <<'EOSTUFF';
<table style="height: 98%" width="98%" cellspacing="0" cellpadding="0" border="0">
		<tr><td align="center" colspan="2">
<table width="100%" cellspacing="0" cellpadding="0" border="0">
<tr>
EOSTUFF
	if(defined($radio) || defined($twitter))
	{
		print qq(<td align=center width="15%">\n);

		if($radio eq 'christmas')
		{
			print <<"EOSTUFF";
		<!-- xmas radio -->
		<img src="/images/wreath.gif"><br>
		<font size=1>Foamy<br>Christmas&nbsp;Radio<br>
		<a href="/radio/christmas/?option=recursive&amp;option=shuffle&amp;action=playall">[high]</a>&nbsp;<a href="/radio/christmas_low/?option=recursive&amp;option=shuffle&amp;action=playall">[low]</a>
		</font>
EOSTUFF
		}
		elsif($radio eq 'foamy')
		{
			print <<"EOSTUFF";
		<!-- foamy radio -->
		<font size=1>Foamy&nbsp;Radio<br>
		<a href="/radio/lounge/?option=recursive&amp;option=shuffle&amp;action=playall">[high]</a>&nbsp;<a href="/radio/lounge_low/?option=recursive&amp;option=shuffle&amp;action=playall">[low]</a>
		</font>
EOSTUFF
		}

		print "</td>\n";
	}

	print qq(<td align="center" width="70%">\n);

	if($titleimg)
	{
		print qq(<img src="$titleimg" alt="FOAM TOTEM"/><br>\n);
	}
	else
	{
		print qq(<font size="+3" color="$titlecolor"><b>FOAM TOTEM</b></font><br>\n);
	}

	print <<"EOSTUFF";
			<a href="./WebCam/index.html">Naked Programmer Cam</a> -
			<a href="./postcards/index.html">Postcards</a> -
			<a href="http://www.zazzle.com/foamtotem*">Schwag</a> -
			<a href="./tsp">The Svelte Programmer</a><br>

			<font size="-2">
			<a href="./future/index.html">Orb of Hotep</a> -
			<a href="./random/index.html">Random Stuff</a> -
			<a href="./SFBay/index.html">SF Bay Trojans</a> -
			<a href="./foamtotm/index.html">Totem Tales</a> -
<!--			<a href="./albums/">Photos</a> - -->
			<a href="./gallery/">Gallery</a>
			<br>
			<br>
			</font>
			<font size="-3">
			<a href="/daily/AlterDaily.asp">Last update:</a>
EOSTUFF

	LastUpdate();

	print <<'EOSTUFF';
			</font>
		</td>
EOSTUFF
	if(defined($radio) || defined($twitter))
	{
		print qq(	<td width="15%">\n);
		if(defined($twitter))
		{
			print qq(	<div id="twitter_div">\n);
			print qq(		<div align=center><font size=-2><b>$twitter</b></font></div>\n);
			print qq(		<ul style="margin-left:3; margin-top:0; margin-bottom:2; padding-left:13" id="twitter_update_list"></ul>\n);
			print qq(	</div>);
		}
		print qq(	</td>\n);
	}
	print <<"EOSTUFF";
</tr>
</table>
</td>
</tr>
EOSTUFF
}

sub TotemTopAtom
{
	my $title = shift;
	my $update = LastUpdateAtom();

	print <<"EOSTUFF";
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

sub TotemTopFacebook
{
	my $title = shift;
	my $update = LastUpdateAtom();

	print <<"EOSTUFF";
<?xml version="1.0" encoding="utf-8"?>
<feed xmlns="http://www.w3.org/2005/Atom">

	<title>Foam Totem</title>
	<link href="http://foamtotem.org/"/>
	<link rel="self" href="http://foamtotem.org/facebook.xml"/>
	<icon>favicon.ico</icon>
	<updated>$update</updated>
	<author>
		<name>Shannon Posniewski</name>
	</author>
	<id>tag:foamtotem.org,2008:</id>

EOSTUFF
}

#
# TotemBottom("links")
#
sub TotemBottom
{
	my $links=shift;

	print <<"EOSTUFF";

	<tr>
		<td style="height:100%"></td>
		<td></td>
	</tr>

	<tr>
		<td>
<!--
		<img src=\"/images/$foamster\" alt="Foam Totem">
-->
		</td>
		<td width=\"100%\">
			<table width=\"100%\" cellspacing=\"8\" cellpadding=\"0\" border=\"0\">
				<tr><td bgcolor=\"$color2\" height=\"2\" colspan=\"15\"></td></tr>
				<tr>
					$links
				</tr>
				<tr><td bgcolor=\"$color2\" height=\"2\" colspan=\"15\"></td></tr>
				<tr><td colspan=\"15\" align="center">
					<font size="-2">
						<a href="http://zinc.foamtotem.org">Pictures of Max</a> -
<!--						<a href="http://www.foamtotem.org/~rv/albums/">rv's photos</a> - -->
						<a href="http://www.foamtotem.org/~rv/popplers/">popplers</a>
						<br>
						Me:
						<a href="http://www.google.com/profiles/posniewski" rel="me">Google</a> -
						<a href="http://twitter.com/posniewski" rel="me">Twitter</a> -
						<a href="http://www.facebook.com/posniewski" rel="me">Facebook</a>
					</font>
				</td></tr>
			</table>
		</td>
	</tr>
</table>
EOSTUFF

	StdBodyEnd();
	StdFoamTotemHTMLEnd();
}

sub TotemBottomAtom
{
	print qq(</feed>\n);
}

#
# "date" = LastUpdate()
#
sub LastUpdate
{
	my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=localtime(time);

	my $tmon=ShortMonth($mon+1);
	my $tday=('Sun','Mon','Tue','Wed','Thu','Fri','Sat')[$wday];

	my $ampm="am";
	if($hour>12) {
		$hour-=12;
		$ampm="pm";
	}

	my $tmin="00".$min;
	$tmin=substr($tmin,length($tmin)-2);
	$year = $year+1900;

	print "$mday $tmon $year -- ";
	print "$hour:$tmin$ampm<br>\n";
}

#
# GetFileList("dir")
#
sub GetFileList
{
	my $dailydir = shift;

	opendir DIR, $dailydir or die "Couldn't open directory.";
	my @allfiles = reverse sort grep /\.ph.?$/, map "$dailydir/$_", readdir DIR;
	closedir DIR;

	return @allfiles;
}

##
## GenMonth(year, month, @filelist)
##
sub GenMonth
{
	my $year = shift;
	my $month = shift;
	my @files = @_;

	my %stories = ();

	my $fname = sprintf("%04d%02d",$year,$month);

	@files = grep /$fname.._._......\.ph$/, @files;

	foreach my $file (@files)
	{
		my ($date, $story, $pri) = ParseFile($file);
		my $tag = $file;
		$tag =~ s".*/([^/]+)\.ph"$1";
		push @{$stories{$date}}, [ $tag, $story, $pri ];
	}

	my $pingpong = 1;
	foreach my $curday (reverse sort keys %stories)
	{
		my $has_twitter = 0;
		my $has_normal = 0;

		foreach my $story (@{$stories{$curday}})
		{
			if($story->[2] ==0)
			{
				$has_twitter = 1;
			}
			elsif($story->[2] > 0)
			{
				$has_normal = 1;
			}
		}

		StartItems($curday, $has_normal ? '' : '_0');

		foreach my $story (@{$stories{$curday}})
		{
			next if($story->[2] == 0);

			StartItem($pingpong ? 'a' : 'b', $story->[0]);
			$pingpong = !$pingpong;
			print $story->[1];

			EndItem();
		}

		if($has_twitter)
		{
			my $foam_id = $curday.'_tweets';
			StartItem($pingpong ? "a_0" : "b_0", $foam_id);
			print qq(<div class=twitter>\n);
			print qq(<p class="comments_0"><a href="javascript:HaloScan('$foam_id');" target="_self"><script type="text/javascript">postCount('$foam_id');</script></a></p>);
			print qq(<ul>\n);
			foreach my $story (@{$stories{$curday}})
			{
				next if($story->[2] > 0);
				print qq(<li>\n);
				print $story->[1];
				print qq(</li>\n);
			}
			$pingpong = !$pingpong;
			print qq(</ul>\n);
			print qq(</div>\n);

			EndItem();
		}

		EndItems($curday);
	}
}

#
# GenMonthAtom(year, month, @filelist)
#
sub GenMonthAtom
{
	my $year = shift;
	my $month = shift;
	my @files = @_;

	my %stories = ();

	my $fname = sprintf("%04d%02d",$year,$month);

	@files = grep /$fname.._._......\.ph$/, @files;

	foreach my $file (@files)
	{
		my ($date, $story, $pri) = ParseFile($file);
		if($pri>0)
		{
			$stories{$file} = $story;
		}
	}

	foreach my $file (reverse sort keys %stories)
	{
		my $tag = $file;
		$tag =~ s".*/([^/]+)\.ph"$1";

		my $title = untag($stories{$file});
		# Clean up movie links
		if($title =~ m/IMDB/)
		{
			$title =~ m/(.*?[\n])/;
			$title = $1;
		}
		else
		{
			$title =~ m/(.*?[.\n])/;
			$title = $1;
		}

		if(!$title)
		{
			$title = substr(untag($stories{$file}), 0, 128);
		}

		my $story = $stories{$file};
		$story =~ s(<p.*?HaloScan.*?</p>)();
		$story =~ s"\<br\>"<br/>"g;
		$story =~ s"&"&amp;"g;

		my $updated = MakeAtomDateTime(GetDateTimeFromYYYYMMDD_x_HHMMSS($tag));
		my $href = substr($tag,0,6);

		print <<"EOSTUFF";
	<entry>
		<id>tag:foamtotem.org,2008:$tag</id>
		<title>$title</title>
		<updated>$updated</updated>
		<link rel="alternate" type="text/html" href="http://foamtotem.org/$href.html#$tag" />
		<content type="xhtml">
			<div xmlns="http://www.w3.org/1999/xhtml">
				$story
			</div>
		</content>
	</entry>
EOSTUFF
	}
}

#
# GenMonthFacebook(year, month, @filelist)
#
sub GenMonthFacebook
{
	my $year = shift;
	my $month = shift;
	my @files = @_;

	my %stories = ();

	my $fname = sprintf("%04d%02d",$year,$month);

	@files = grep /$fname.._._......\.ph$/, @files;

	foreach my $file (@files)
	{
		my ($date, $story, $pri) = ParseFile($file);
		if($pri>1)
		{
			$stories{$file} = $story;
		}
	}

	foreach my $file (reverse sort keys %stories)
	{
		my $tag = $file;
		$tag =~ s".*/([^/]+)\.ph"$1";

		my $title = untag($stories{$file});
		# Clean up movie links
		if($title =~ m/IMDB/)
		{
			$title =~ m/(.*?[\n])/;
			$title = $1;
		}
		else
		{
			$title =~ m/(.*?[.\n])/;
			$title = $1;
		}

		if(!$title)
		{
			$title = substr(untag($stories{$file}), 0, 128);
		}

		my $story = $stories{$file};
		$story =~ s(<p.*?HaloScan.*?</p>)();
		$story =~ s"\<br\>"<br/>"g;
		$story =~ s"&"&amp;"g;

		my $updated = MakeAtomDateTime(GetDateTimeFromYYYYMMDD_x_HHMMSS($tag));
		my $href = substr($tag,0,6);

		print <<"EOSTUFF";
	<entry>
		<id>tag:foamtotem.org,2008:$tag</id>
		<title>$title</title>
		<updated>$updated</updated>
		<link rel="alternate" type="text/html" href="http://foamtotem.org/$href.html#$tag" />
		<content type="xhtml">
			<div xmlns="http://www.w3.org/1999/xhtml">
				<a href="http://foamtotem.org/$href.html#$tag">Read this post on Foam Totem.</a>
			</div>
		</content>
	</entry>
EOSTUFF
	}
}

#
# EditGenMonth($path, $year, $month, @files)
#
sub EditGenMonth
{
	my $path = shift;
	my $year = shift;
	my $month = shift;
	my @files = @_;

	my %stories = ();

	foreach my $file (@files)
	{
		my ($date, $story, $pri) = ParseFile($file);
		$file =~ s"^$path/"";
		$stories{$file} = $story;
	}

	my $pingpong = '';
	print "<table width=\"100%\" cellspacing=\"0\" cellpadding=\"5\" border=\"0\">\n";
	foreach my $file (reverse sort keys %stories)
	{
		print "<tr bgcolor=\"$pingpong\">\n";
		print "	<td valign=\"middle\">$file:&nbsp;<a href=\"./AlterDaily.asp?phfile=$file\">[Edit]</a>&nbsp;";
		if($file =~/x$/)
		{
			print "<a href=\"./hide.asp?phfile=$file&show=1\">[show]</a></td>\n";
		}
		else
		{
			print "<a href=\"./hide.asp?phfile=$file&show=0\">[hide]</a></td>\n";
		}
		print "	<td width=\"100%\"><font size=\"-3\">$stories{$file}</font></td>\n";
		print "</tr>\n";
		$pingpong = ($pingpong eq '' ? "$darkbgcolor" : '');
	}
	print "</table>\n";

}

#
# ParseFile("file")
#
sub ParseFile
{
	my $file = shift;
	local $/; # slurp

	my $date = MakeYYYYMMDD(GetDateFromName($file));
	my $priority = GetPriorityFromName($file);
	my $story = '';

	open FILE, "<$file" or die "Unable to open [$file]\n";
	$file = <FILE>;
	close FILE;
	my @file = split(/\n/, $file);

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

	return ($date, $story, $priority);
}

#
# StartItems("YYYYMMDD")
#
#
sub StartItems
{
	my $date = shift;
	my $pri = shift;

	my ($year, $month, $day) = GetDateFromYYYYMMDD($date);
	my $nicedate =  MakeDD_Mon_YYYY($year, $month, $day);
	$nicedate =~ s/ /&nbsp;/g;

	my $time = timelocal(0,0,0,$day,$month-1,$year);
	my $wday = (localtime($time))[6];
	$wday = ('Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday')[$wday];

	print <<"EOSTUFF";
	<tr id=\"#$date\" valign=\"top\">
		<td align="right" valign="top">
			<div class=\"date$pri\">
				<font class=\"datetext$pri\">
				<font style=\"font-size:smaller">
					<a href=\"/daily/ChooseDaily.asp?date=$date\"><img src=\"/images/$teat\" border=\"0\" alt=""></a>&nbsp;$wday<br>
					</font>
					$nicedate
				</font>
			</div><div style=\"padding-top:3px\"></div>
		</td>
		<td class=\"dayblock\">
			<table>
EOSTUFF
}

sub StartItem
{
	my $bg = shift;
	my $id = shift;

	print qq(\t\t\t\t<tr><td class="story_) . $bg . qq(" id="$id">);
}

#
# EndItems()
#
sub EndItems
{
	print "\t\t\t</table>\n";
	print "\t\t</td>\n";
	print "\t</tr>\n";
}

sub EndItem
{
	print "\t\t\t\t</td></tr>\n";
}

#
# StdFoamTotemHTMLStart
#
sub StdFoamTotemHTMLStart
{
#	my $StdHTMLHeader='<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">'
#	my $StdHTMLHeader='<!doctype html>'

	my $StdHTMLHeader='<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">'
		. "\n";
	my $StdFoamTotemHeader="<html>\n\t<!-- This page is part of the FoamTotem web site. -->\n\t<!-- Copyright (c) 1996-2011, Shannon Posniewski  -->\n";

	print $StdHTMLHeader;
	print $StdFoamTotemHeader;
}

#
# StdBodyStart
#
sub StdBodyStart
{
	my $title = shift;

	print qq(<head>\n);

	print qq(<meta charset="utf-8" />\n);

	print qq(<title>$title</title>\n);

	print qq(<link rel="alternate" type="application/atom+xml" title="Foam Totem" href="http://foamtotem.org/atom.xml" />\n);
	print qq(<link rel="openid.server" href="http://www.myopenid.com/server" />\n);
	print qq(<link rel="openid.delegate" href="http://posniewski.myopenid.com/" />\n);
	print qq(<meta name="geo.placename" content="Mountain View, CA 94043, USA" />\n);
	print qq(<meta name="geo.position" content="37.41614;-122.09131" />\n);
	print qq(<meta name="geo.region" content="US-CA" />\n);
	print qq(<meta name="ICBM" content="37.41614;-122.09131" />\n);
	print qq(<meta name="DC.title" content="Foam Totem" />\n);

	print qq(<script type="text/javascript" src="http://www.haloscan.com/load/foamtotem"></script>\n);
	print qq(<style type="text/css">\n);

	# body style def
	print "body { font-family:sans-serif;";
	if($bgimg) {
		print " background-image: url('$bgimg');";
	}
	if($bgcolor) {
		print " background-color: $bgcolor;";
	}
	if($textcolor) {
		print " color: $textcolor;";
	}
	print "}\n";

	# links style def
	if($alink) {
		print "a:active { color: $alink; text-decoration: none; }\n";
	}
	if($vlink) {
		print "a:visited { color: $vlink; text-decoration: none; }\n";
	}
	if($link) {
		print "a:link { color: $link; text-decoration: none; }\n";
	}
	if($bgcolor and $link)
	{
		print "a:hover { color: $bgcolor; background-color: $link; }\n";
	}
	print "li { list-style-position: outside; }\n";

	print ".story_a { background-color: $lightbgcolor; padding: 10px}\n";
	print ".story_b { background-color: $darkbgcolor; padding: 10px}\n";
	print ".story_a_0 { background-color: $lightbgcolor; padding:5px; padding-left: 10px}\n";
	print ".story_b_0 { background-color: $darkbgcolor; padding:5px; padding-left: 10px}\n";

	print ".datetext { color: $datecolor }\n";
	print ".datetext_0 { font-size: 65%; color: $datecolor }\n";

	print <<"EOSTUFF";

.dayblock {
	width: 100%;
	border-width:2px 0px 0px 0px;
	border-style:solid;
	border-color:$color2;
}

.dayblock table {
	width: 100%;
	border-spacing: 0px;
	padding: 0px;
	border: 0px;
	margin: 0px;
}

.date {
	background-color:$color2;
	padding:10px;
	padding-top:12px;
	-moz-border-radius:5px;
	-moz-border-radius-topright:0px;
	-webkit-border-radius:5px;
	-webkit-border-top-right-radius:0px;
	border-top:2px solid $lightcolor2;
	border-left:2px solid $lightcolor2;
	border-bottom:2px solid $darkcolor2;
	border-right:1px solid $darkcolor2;
}

.date_0 {
	background-color:$color2;
	padding:5px;
	padding-right:10px;
	padding-top:7px;
	-moz-border-radius:5px;
	-moz-border-radius-topright:0px;
	-webkit-border-radius:5px;
	-webkit-border-top-right-radius:0px;
	border-top:2px solid $lightcolor2;
	border-left:2px solid $lightcolor2;
	border-bottom:2px solid $darkcolor2;
	border-right:1px solid $darkcolor2;
}

.comments {
	text-align:right;
	font-size:10px;
	clear:right;
}

.comments_0 {
	text-align:right;
	font-size:8px;
	float:right;
	margin-top:3px;
	background-image: none;
}

.twitreply {
	font-size: 8px;
	font-style: italic;
	margin: 0px 0px 0px 10px;
}

.twitter {
	font-size: smaller;
	margin: 0px;
}

.twitter i {
	font-size: smaller;
	color: $textcolor_dim;
}

.twitter ul {
	list-style:none;
	margin:3px;
	padding:0px;
}

.twitter ul li {
	padding-left:13px;
	background-image: url("http://www.foamtotem.org/images/twitter_icon.gif");
	background-repeat: no-repeat;
	background-position: 0 1;
}

img.posterous {
	float: right;
	vertical-align: top;
	border-style: none;
}

.title {
	font-size: larger;
}

.via {
	font-size: smaller;
	margin-left: 20px
}

.via:before
{
	content: 'via '	;
}

embed
{
	margin-left: 20px;
	float: right;
}


EOSTUFF

	print "</style>\n";
	print "</head>\n";

	print "<body>\n";

	print "\n";
}

#
# StdBodyEnd
#
sub StdBodyEnd
{
	print <<'EOSTUFF';
<script type="text/javascript">
var gaJsHost = (("https:" == document.location.protocol) ? "https://ssl." : "http://www.");
document.write(unescape("%3Cscript src='" + gaJsHost + "google-analytics.com/ga.js' type='text/javascript'%3E%3C/script%3E"));
</script>
<script type="text/javascript">
var pageTracker = _gat._getTracker("UA-587357-1");
pageTracker._trackPageview();
</script>
EOSTUFF

	if(defined($twitter))
	{
		print <<'EOSTUFF';
<script type="text/javascript" src="http://foamtotem.org/js/twitter.js"></script>
<script type="text/javascript" src="http://twitter.com/statuses/user_timeline/posniewski.json?callback=twitterCallback2&amp;count=3"></script>
EOSTUFF
	}

	print "\n</body>\n";
}

#
# StdFoamTotemHTMLEnd
#
sub StdFoamTotemHTMLEnd
{
	print "\n";
	print "</HTML>\n";
}

#
# "outfile" = UpdateHTML("basepath", $year, $month)
#
sub UpdateHTML
{
	my $path = shift;
	my $year = shift;
	my $mon = shift;

	my @files = GetFileList($path);

	#
	# HTML page
	#
	my $outfile = sprintf('%04d%02d.html',$year,$mon);
	if($g_debug)
	{
		$outfile = 'dbg_' . $outfile;
	}
	open OUT, ">$path/../$outfile" or die "can't open $path/../$outfile";
	select OUT;

	TotemTop(LongMonth($mon) . " Flotsam - Foam Totem");
	GenMonth($year, $mon, @files);
	TotemBottom(MakeFlotsamLinks(@files));

	select STDOUT;
	close OUT;

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
			open OUT, ">$path/../atom.xml" or die "can't open $path/../atom.xml";
			select OUT;

			TotemTopAtom();
			GenMonthAtom($year, $mon, @files);
			TotemBottomAtom();

			select STDOUT;
			close OUT;

			#
			# Facebook feed
			#
			open OUT, ">$path/../facebook.xml" or die "can't open $path/../facebook.xml";
			select OUT;

			TotemTopFacebook();
			GenMonthFacebook($year, $mon, @files);
			TotemBottomAtom();

			select STDOUT;
			close OUT;
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
# "date" = LastUpdateAtom()
#
sub LastUpdateAtom
{
	my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=localtime(time);
	$year+=1900;
	$mon+=1;       # zero based

	return MakeAtomDateTime($year, $mon, $mday, $hour, $min, $sec);
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

#
# $priority = GetPriorityFromName("filename");
#
sub GetPriorityFromName
{
	my $filename = shift;

	$filename =~ s".*/.*_([0-9]+)_([^/]+)\.ph"$1";
	return $filename;
}

#
# ($year, $month, $day) = GetDateFromName("filename");
#
sub GetDateFromName
{
	my $filename = shift;

	$filename =~ s".*/([^/]+)\.ph"$1";
	return GetDateFromYYYYMMDD($filename);
}

#
# ($year, $month, $day) = GetDateTimeFromName("filename");
#
sub GetDateTimeFromName
{
	my $filename = shift;

	$filename =~ s".*/([^/]+)\.ph"$1";
	return GetDateTimeFromYYYYMMDD_x_HHMMSS($filename);
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

	return ($year, $mon, $day, $hh, $mm, $ss);
}

#
# ($year, $month, $day) = GetDateFromDD_Mon_YYYY("str");
#
sub GetDateFromDD_Mon_YYYY
{
	my $str = shift;

	my ($day,$mon,$year) = split(/ /,$str);
	$mon = FromShortMonth($mon);

	if($year<100)
	{
		$year += 1900;
	}

	return ($year, $mon, $day);
}

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
# "YYYY-MM-DDTHH:MM:SS-08:00" = MakeAtomDateTime($year, $month, $day, $hh, $mm, $ss);
#
sub MakeAtomDateTime
{
	my ($year, $mon, $day, $hh, $mm, $ss) = @_;

	return sprintf("%04d-%02d-%02dT%02d:%02d:%02d-08:00", $year, $mon, $day, $hh, $mm, $ss);
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
