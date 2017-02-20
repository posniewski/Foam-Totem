package Foam;

use 5.005_64;
use strict;
our($VERSION, @ISA, @EXPORT, @EXPORT_OK);

$VERSION = "1.00";
@ISA     = qw(Exporter);
@EXPORT  = qw(
	MakeFlotsamLinks
	StartContent
	EndContent
	TotemBar
	LastUpdate
	ShortMonth
	LongMonth
	GetDateFromName
	GetFileFromList
	GenMonth
	ParseFile
	StartItems
	EndItems
);

#
# "links" = MakeFlotsamLinks(@files)
#
sub MakeFlotsamLinks
{
	my @files = @_;
	my $ret;

	my @earliest = GetDateFromName($files[-1]);
	my @latest = GetDateFromName($files[0]);
	foreach my $file (@files)
	{
		my ($year, $month) = GetDateFromName($file);
		$available{"$year$month"} = 1;
	}

	for(my $year=$latest[0]; $year>=$earliest[0]; $year--)
	{
		$ret .= "<br>$year<br>";
		for(my $month=1; $month<=12; $month++)
		{
			my $date = sprintf("%04d%02d", $year, $month);
			if(exists($available{$date}))
			{
				my $gak = substr($date, 2);
				$ret .= "<a href=\"./$gak.html\">" . ShortMonth($month) ."</a> ";
			}
		}
	}

	return $ret;
}

sub StartContent
{
	my $title = shift;

	StdFoamTotemHTMLStart();
	StdBodyStart($title);

	print "<table height=\"95%\" width=\"100%\" border=0>\n";
	print "\t<tr>\n";
}

sub EndContent
{
	print "</table>\n";
	StdFoamTotemHTMLEnd();
}

#
# TotemBar("LongMonth", "links HTML")
#
sub TotemBar
{
	my $mon=shift;
	my $links=shift;

	print "\t\t<td width=\"10%\" valign=\"top\" bgcolor=\"#669966\" >\n";
	print "\t\t\t<table width=\"100%\" height=\"100%\">\n";
	print "\t\t\t\t<tr><td height=\"10\">\n";
	print "\t\t\t\t</td></tr>\n";
	print "\t\t\t\t<tr><td align=\"center\">\n";
	print "\t\t\t\t\t<h2>FOAM TOTEM</h2>\n";
	print "\t\t\t\t\t<img src=\"/images/foamtotemlogo.gif\" border=\"0\" align=\"center\" alt=\"FOAM TOTEM\">\n";
	print "\t\t\t\t</td></tr>\n";
	print "\t\t\t\t<tr><td height=\"20\">\n";
	print "\t\t\t\t</td></tr>\n";
	print "\t\t\t\t<tr><td align=\"center\">\n";
	print "\t\t\t\t\t<b>Flotsam</b><br><br>\n";
	print "\t\t\t\t\t<b>$mon</b><br><br>\n";
	print "\t\t\t\t\t<font size=\"1\">\n";

	LastUpdate();

	print "\t\t\t\t\t</font>\n";
	print "\t\t\t\t</td></tr>\n";
	print "\n";
	print "\t\t\t\t<tr><td height=\"40\">\n";
	print "\t\t\t\t</td></tr>\n";
	print "\n";
	print "\t\t\t\t<tr><td align=\"center\">\n";
	print "\t\t\t\t\t<h3><a href=\"./WebCam/index.html\">Naked Programmer Cam</a></h3>\n";
	print "\t\t\t\t\t<h3><a href=\"./postcards/index.html\">Postcards</a></h3>\n";
	print "\t\t\t\t\t<h3><a href=\"./albums/\">Photos</a></h3>\n";
	print "\t\t\t\t\t<h4><a href=\"./future/index.html\">Orb of Hotep</a><br>\n";
	print "\t\t\t\t\t\t<a href=\"./random/index.html\">Random Stuff</a><br>\n";
	print "\t\t\t\t\t\t<a href=\"./SFBay/index.html\">SF Bay Trojans</a><br>\n";
	print "\t\t\t\t\t\t<a href=\"./foamtotm/index.html\">Totem Tales</a></h4>\n";
	print "\t\t\t\t</td></tr>\n";
	print "\t\t\t\t<tr><td height=\"30\">\n";
	print "\t\t\t\t</td></tr>\n";
	print "\t\t\t\t<tr><td align=\"center\">\n";
	print "\t\t\t\t\t<font size=\"1\"><b>Aged Flotsam</b></font><br>\n";
	print "\t\t\t\t\t<font size=\"1\"><b>$links</b></font>\n";
	print "\t\t\t\t</td></tr>\n";
	print "\t\t\t\t<tr><td height=\"100%\">\n";
	print "\t\t\t\t</td></tr>\n";
	print "\t\t\t</table>\n";
	print "\t\t</td>\n";
}

#
# "date" = LastUpdate()
#
sub LastUpdate
{
	my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=localtime(time);

	$tmon=(Jan,Feb,Mar,Apr,May,Jun,Jul,Aug,Sep,Oct,Nov,Dec)[$mon];
	$tday=(Sun,Mon,Tue,Wed,Thu,Fri,Sat)[$wday];

	$ampm="am";
	if($hour>12) {
		$hour-=12;
		$ampm="pm";
	}

	$tmin="00".$min;
	$tmin=substr($tmin,length($tmin)-2);
	$year = $year+1900;

	print "$tday $mday $tmon $year<br>";
	print "$hour:$tmin$ampm<br>\n";
}

#
# "Mon" = ShortMonth(month)
#
sub ShortMonth
{
	my $mon=(shift)-1;

	return (Jan,Feb,Mar,Apr,May,Jun,Jul,Aug,Sep,Oct,Nov,Dec)[$mon];
}

#
# "Month" = LongMonth(month)
#
sub LongMonth
{
	my $mon=(shift)-1;

	return (January,February,March,April,May,June,July,August,September,October,November,December)[$mon];
}

#
# ($year, $month, $day) = GetDateFromName("filename");
#
sub GetDateFromName
{
	my $filename = shift;

	$filename =~ s".*/([^/]+)\.ph"\1";
	my $year = substr($filename, 0, 4);
	my $month = substr($filename, 4, 2);
	my $day = substr($filename, 6, 2);

	return ($year, $month, $day);
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

	my $fname = sprintf("%04d%02d",$year,$month);

	@files = grep /$fname..\.ph$/, @files;

	print "\t\t<td valign=\"top\">\n";
	print "\t\t\t<table width=\"100%\">\n";
	foreach my $file (@files)
	{
		ParseFile($file);
	}
	print "\t\t\t</table>\n";
	print "\t\t</td>\n";
}

#
# ParseFile("file")
#
sub ParseFile
{
	my $file = shift;
	local $/; # slurp

	$dailyutil_file = $file;
	$dailyutil_file =~ s".*/([^/]+\.ph$)"\1";

	open FILE, "<$file" or die "Unable to open [$file]\n";
	my $file = <FILE>;
	close FILE;
	my @file = split(/\n/, $file);

	my $inpara = 0;
	foreach my $line (@file)
	{
		if($line =~ /^%/)
		{
			$line =~ s/^%//;

			# By convention, if this evals true then we are in a
			# paragraph, otherwise, we aren't.
			$inpara = eval($line);
		}
		else
		{
			if($line=~/^\s*$/)
			{
				if($inpara)
				{
					print("</p>\n");
					$inpara=0;
				}
			}
			else
			{
				if(!$inpara)
				{
					$inpara=1;
				}
				print "$line";
			}
		}
	}
	if($inpara)
	{
		print("</p>\n");
		$inpara=0;
	}
}

#
# StartItems("date", "title")
#
#
sub StartItems
{
	my $date = shift;
	my $title = shift;

	if(defined($title))
	{
		$date .= " - $title";
	}

	print "\t\t\t\t<tr><td bgcolor=\"#669966\" width=\"100%\"><a href=\"/daily/AlterDaily.asp?phfile=$dailyutil_file\"><img src=\"/images/blank.gif\" width=\"5\" height=\"5\" border=\"0\"></a><b>$date</b></td></tr>\n";
	print "\t\t\t\t<tr><td>\n";

	print "\t\t\t\t<p>\n";
	return 1;
}

#
# EndItems()
#
sub EndItems
{
	print "\n\t\t\t\t</p>\n";
	print "\t\t\t\t<p></p>\n";
	print "\t\t\t\t</td></tr>\n";

	return 0;
}

1;
