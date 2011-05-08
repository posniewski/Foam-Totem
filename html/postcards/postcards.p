require "../../perl/preproc.p";
require "../../perl/stddefs.p";

require "./postcardsdefs.p";

require "./cal.p";

# Get list of files and sort them by name (which is also a sort by date).
opendir DIR, "." or die;
@allfiles = sort grep !/^tn_.*/, grep /^.*-f-.*\.jpg$/, readdir DIR;
closedir DIR;

$Prev="index.html";
$Next="index.html";
$fn=0;

for($i=0; $i<(scalar @allfiles); $i++) {

	$infname=$allfiles[$i];

	$outfname=$infname;
	$outfname=~s/\.[^.]*$//;
	$outfname=~s/-f-/-/;
	$outfname.="\.html";

	$nicename=$infname;
	$nicename=~s/.+-f-([^.]+)\.jpg/$1/i;

	$nicedate=$infname;
	$nicedate=~s/(.+)-f-[^.]+\.jpg/$1/i;

	print "Processing $infname and making $outfname for '$nicename'\n";

	open OUT, ">$outfname" or die "Can't open '$outfname'.";
	select OUT;

	if(!$allfiles[$i+1]) {
		$Next="index.html";
	}
	else {
		$Next="$allfiles[$i+1]";
		$Next=~s/\.[^.]*$//;
		$Next=~s/-f-/-/;
		$Next.="\.html";
	}

	$backfname=$infname;
	$backfname=~s/-f-/-b-/;

	$Title="Postcards - $nicename";
	$Date="$nicedate";

	StdFoamTotemHTMLStart();
	StdFoamTotemBodyStart();
#	StdFoamTotemContentStart();

	print "<table width=\"100%\">\n";
	print "	<tr valign=\"center\">\n";
	print "		<td align=\"center\">\n";
	print "			<img src=\"./$infname\" border=0><br>\n";
	print "			<img src=\"./$backfname\" border=0>\n";
	print "		</td>\n";
	print "	</tr>\n";
	print "</table>\n";

#	StdFoamTotemContentEnd();
	StdFoamTotemBodyEnd();
	StdFoamTotemHTMLEnd();

	$Prev="$outfname";

	$htmls[$fn]=$Prev;
	$titles[$fn]=$nicename;
	$dates[$fn]=$Date;
	$files[$fn]=$infname;
	$links{$Date}=$htmls[$fn];
	$fn++;


	select STDOUT;
}

#
# make index.html
#
#print "Making index.html\n";

open OUT, ">index.html";
select OUT;

$Title="Postcard Index";

StdFoamTotemHTMLStart();
StdFoamTotemBodyStart();

print "<center>\n";

print <<'EOSTUFF';
	<h2>
	[2006]
		<a href="./archive2005.html">2005</a>
		<a href="./archive2004.html">2004</a>
		<a href="./archive2003.html">2003</a>
		<a href="./archive2002.html">2002</a>
		<a href="./archive2001.html">2001</a>
		<a href="./archive2000.html">2000</a>
		<a href="./archive1999.html">1999</a>
		<a href="./archive1998.html">1998-</a>
	</h2>
	<p>
		<font size="1">(Also try the experimental and not entirely correct 
			<a href="./index2.html">calendar view</a>.)</font>
	</p>
EOSTUFF

print "<table cellspacing=\"5\">\n";

for($i=(scalar @htmls)-1; $i>=0; $i--) {
	$thumbname='tn_'.$files[$i];
	$thumbname=~s/\.jpg$/_jpg.jpg/i;

	print "	<tr valign=\"center\">\n";
	print "		<td align=\"center\">\n";
	print "			<a href=\"$htmls[$i]\"><img src=\"./$thumbname\" border=\"0\"></a>\n";
	print "		</td>\n";
	print "		<td>\n";
	print "			<a href=\"$htmls[$i]\">$titles[$i]</a>\n";
	print "			<br><font size=\"1\">$dates[$i]</font>\n";
	print "		</td>\n";
	print "	</tr>\n";
	print "\n";
}

print "</table>\n";
print "</center>\n";

StdFoamTotemBodyEnd();
StdFoamTotemHTMLEnd();

select STDOUT;


#
# Done with index.html
#
open OUT, ">index2.html";
select OUT;

$Title="Postcard Index (Calendar)";

StdFoamTotemHTMLStart();
StdFoamTotemBodyStart();

print "<table width=\"100%\">";
for($i=1997; $i<2007; $i++)
{
	print "<tr>\n";
	print "<td align=\"right\" valign=\"middle\">\n";
	print "$i\n";
	print "</td>\n";
	print "<td>\n";;
	EmitYear($i);
	print "</td>\n";
	print "</tr>\n";
}
print "</table>\n";


StdFoamTotemBodyEnd();
StdFoamTotemHTMLEnd();

select STDOUT;

