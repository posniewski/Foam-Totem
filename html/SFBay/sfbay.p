require "../../perl/preproc.p";
require "../../perl/stddefs.p";

require "sfbaydefs.p";

# Get list of files and sort them by name (which is also a sort by date).
opendir DIR, "." or die;
@allfiles = sort grep /\.ph$/, readdir DIR;
closedir DIR;

$Prev="index.html";
$Next="index.html";
$fn=0;

for($i=0; $i<(scalar @allfiles); $i++) {

	$infname=$allfiles[$i];

	$outfname=$infname;
	$outfname=~s/\.[^.]*$//;
	$outfname.="\.html";

	print "Processing $infname and making $outfname\n";

	open OUT, ">$outfname" or die;
	select OUT;

	if(!$allfiles[$i+1]) {
		$Next="index.html";
	}
	else {
		$Next="$allfiles[$i+1]";
		$Next=~s/\.[^.]*$//;
		$Next.="\.html";
	}

	Preproc($infname);

	$Prev="$outfname";

	$htmls[$fn]=$Prev;
	$titles[$fn]=$Title;
	$dates[$fn]=$Date;
	$fn++;

	select STDOUT;
}

#
# make index.html
#
print "Making index.html\n";

open OUT, ">index.html";
select OUT;

$Title="Index";

StdFoamTotemHTMLStart();
StdFoamTotemBodyStart();

print "<center>\n";

for($i=(scalar @htmls)-1; $i>=0; $i--) {
	print "<p><a href=\"$htmls[$i]\">$titles[$i]</a>\n";
	print "<br><font size=\"1\">$dates[$i]</font>\n";
	print "\n";
}

print "</center>\n";

StdFoamTotemBodyEnd();
StdFoamTotemHTMLEnd();

select STDOUT;

#
# Done with index.html
#
