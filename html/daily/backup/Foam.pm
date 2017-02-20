package Foam;

use strict;
use Time::Local;

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
		GetFileFromList
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
	);
}

my $background='';
my $alink='';
my $bgcolor='#eeeecc';
my $link='#b56001';
my $vlink='#524510';
my $textcolor='black';

my $darkbgcolor='#ddddbb';
my $color2='#ff8809';

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
		$ret .= '<td align="center" width="20%"><font size="1">';
		$ret .= "$year<br>";
		for(my $month=1; $month<=12; $month++)
		{
			my $date = sprintf("%04d%02d", $year, $month);
			if(exists($available{$date}))
			{
				my $gak = substr($date, 2);
				$ret .= "<a href=\"/$gak.html\">" . ShortMonth($month) ."</a> ";
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
<table height="98%" width="98%" cellspacing="0" cellpadding="0" border="0">
	<tr>
		<td align="center" colspan="2">
			<font size="+3"><b>FOAM TOTEM</b></font><br>

			<a href="./WebCam/index.html">Naked Programmer Cam</a> -
			<a href="./postcards/index.html">Postcards</a> -
			<a href="./albums/">Photos</a><br>

			<font size="-2">
			<a href="./future/index.html">Orb of Hotep</a> -
			<a href="./random/index.html">Random Stuff</a> -
			<a href="./SFBay/index.html">SF Bay Trojans</a> -
			<a href="./foamtotm/index.html">Totem Tales</a>
			<br>
			<br>
			</font>
			<font size="-3">
			Last update: 
EOSTUFF

	LastUpdate();

	print <<'EOSTUFF';
			</font>
		</td>
	</tr>
EOSTUFF
}

#
# TotemBottom("links")
#
sub TotemBottom
{
	my $links=shift;

	print <<"EOSTUFF";

	<tr height=\"100%\">
		<td></td>
		<td></td>
	</tr>

	<tr>
		<td>
		<img src=\"/images/foamster.gif\">
		</td>
		<td width=\"100%\">
			<table width=\"100%\" cellspacing=\"10\" cellpadding=\"0\" border=\"0\">
				<tr><td bgcolor=\"$color2\" height=\"2\" colspan=\"5\"></td></tr>
				<tr>
					$links
				</tr>
				<tr><td bgcolor=\"$color2\" height=\"2\" colspan=\"5\"></td></tr>
			</table>
		</td>
	</tr>
</table>
EOSTUFF

	StdBodyEnd();
	StdFoamTotemHTMLEnd();
}

#
# "date" = LastUpdate()
#
sub LastUpdate
{
	my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=localtime(time);

	my $tmon=ShortMonth($mon);
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
# ($year, $month, $day) = GetDateFromName("filename");
#
sub GetDateFromName
{
	my $filename = shift;

	$filename =~ s".*/([^/]+)\.ph"\1";
	return GetDateFromYYYYMMDD($filename);
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
# ($year, $month, $day) = GetDateFromDD_Mon_YYYY("str");
#
sub GetDateFromDD_Mon_YYYY
{
	my $str = shift;

	my ($day,$mon,$year) = split(/ /,$str);
	$mon = FromShortMonth($mon);

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
# GetFileList("dir")
#
sub GetFileList
{
	my $dailydir = shift;

	opendir DIR, $dailydir or die "Couldn't open directory.";
	my @allfiles = reverse sort grep /\.ph$/, map "$dailydir/$_", readdir DIR;
	closedir DIR;

	return @allfiles;
}

#
# GenMonth(year, month, @filelist)
#
sub GenMonth
{
	my $year = shift;
	my $month = shift;
	my @files = @_;

	my %stories = ();

	my $fname = sprintf("%04d%02d",$year,$month);

	@files = grep /$fname.._......\.ph$/, @files;

	foreach my $file (@files)
	{
		my ($date, $story) = ParseFile($file);
		push @{$stories{$date}}, $story;
	}

	my $pingpong = 1;
	foreach my $curday (reverse sort keys %stories)
	{
		StartItems($curday);
		foreach my $story (@{$stories{$curday}})
		{
			StartItem($pingpong ? "" : "$darkbgcolor");
			$pingpong = !$pingpong;
			print $story;
			EndItem();
		}
		EndItems($curday);
	}
}

#
# EditGenMonth($path, @filelist)
#
sub EditGenMonth
{
	my $path = shift;
	my @files = @_;

	my %stories = ();

	foreach my $file (@files)
	{
		my ($date, $story) = ParseFile($file);
		$file =~ s"^$path/"";
		$stories{$file} = $story;
	}

	my $pingpong = '';
	print "<table width=\"100%\" cellspacing=\"0\" cellpadding=\"5\" border=\"0\">\n";
	foreach my $file (reverse sort keys %stories)
	{
		print "<tr bgcolor=\"$pingpong\">\n";
		print "	<td valign=\"middle\"><a href=\"./AlterDaily.asp?phfile=$file\">$file</a></td>\n";
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
	my $story = '';

	open FILE, "<$file" or die "Unable to open [$file]\n";
	my $file = <FILE>;
	close FILE;
	my @file = split(/\n/, $file);

	my $inpara = 0;
	foreach my $line (@file)
	{
#		if($line =~ /^%/)
#		{
#			if($line =~ /^%StartItems\("(.*)"\)/)
#			{
#				if($inpara)
#				{
#					$storiesref->{$curday} .= "</p>\n";
#					$inpara = 0;
#				}
#				$curday = MakeYYYYMMDD(GetDateFromDD_Mon_YYYY($1));
#				if(!exists($storiesref->{$curday}))
#				{
#					push @$dayref, $curday;
#				}
#				$storiesref->{$curday} .= '';
#			}
#			elsif($line =~ /^%EndItems/)
#			{
#				if($inpara)
#				{
#					$storiesref->{$curday} .= "</p>\n";
#					$inpara = 0;
#				}
#			}
#			else
#			{
#				$inpara = eval($line);
#			}
#		}
#		else
		{
			if($line=~/^\s*$/)
			{
				if($inpara)
				{
					$story .= "</p>\n";
					$inpara=0;
				}
			}
			else
			{
				if(!$inpara)
				{
					$story .= "<p>";
					$inpara=1;
				}
				$story .= $line;
			}
		}
	}
	if($inpara)
	{
		$story .= "</p>\n";
		$inpara=0;
	}

	return ($date, $story);
}

#
# StartItems("YYYYMMDD")
#
#
sub StartItems
{
	my $date = shift;

	my ($year, $month, $day) = GetDateFromYYYYMMDD($date);
	my $nicedate =  MakeDD_Mon_YYYY($year, $month, $day);
	$nicedate =~ s/ /&nbsp;/g;

	my $time = timelocal(0,0,0,$day,$month-1,$year);
	my $wday = (localtime($time))[6];
	$wday = ('Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday')[$wday];

	print <<"EOSTUFF";
	<tr><td bgcolor=\"$color2\" height=\"2\" width=\"100%\" colspan=\"2\"></td></tr>
	<tr valign=\"top\">
		<td>
			<table cellspacing=\"0\" cellpadding=\"3\" border=\"0\" width=\"100%\">
				<tr bgcolor=\"$color2\" height=\"5\"><td><img src=\"/images/blank.gif\" border=\"0\" height=\"1\"></td></tr>
				<tr bgcolor=\"$color2\"><td align="right" valign="top">
					<font size="-2">
						<a href=\"/daily/ChooseDaily.asp?date=$date\"><img src=\"/images/teat.gif\" border=\"0\" align=\"center\"></a>
						$wday<br>$nicedate
					</font></td></tr>
				<tr><td></td></tr>
			</table>
		</td>
		<td width=\"100%\">
			<table width=\"100%\" cellspacing=\"0\" cellpadding=\"10\" border=\"0\">
EOSTUFF
}

sub StartItem
{
	my $bgcolor = shift;

	print "\t\t\t\t<tr><td bgcolor=\"$bgcolor\">";
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
	my $StdHTMLHeader='<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 3.2//EN">' . "\n";
	my $StdFoamTotemHeader="<HTML>\n\t<!-- This page is part of the FoamTotem web site. -->\n\t<!-- Copyright (c) 1996-2002, Shannon Posniewski  -->\n";

	print $StdHTMLHeader;
	print $StdFoamTotemHeader;
}

#
# StdBodyStart
#
sub StdBodyStart
{
	my $title = shift;

	print "<head>\n";
	print "<title>$title</title>\n";
	print "</head>\n";
	print "\n";

#	my $background='';
#	my $alink='';
#	my $bgcolor='#eeeecc';
#	my $link='#b56001';
#	my $vlink='#524510';
#	my $textcolor='black';

	print "<body ";
	if($background) {
		print "background=\"$background\" ";
	}
	if($bgcolor) {
		print "bgcolor=\"$bgcolor\" ";
	}
	if($alink) {
		print "alink=\"$alink\" ";
	}
	if($vlink) {
		print "vlink=\"$vlink\" ";
	}
	if($link) {
		print "link=\"$link\" ";
	}
	if($textcolor) {
		print "text=\"$textcolor\" ";
	}
	print ">\n";

	print "\n";
}

#
# StdBodyEnd
#
sub StdBodyEnd
{
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

1;
