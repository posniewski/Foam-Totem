#!/usr/bin/perl -w
#
#
# %%
# ## number
# @@ name
# prophecy
# --
# reason
#

require "FutureSupport.pl";

ParseStdProphecies(".");

open PROPH, ">CleanProphecies.ph" or die;

open ALL, ">AllFuture.html" or die;
print ALL "<table>\n";

$idx=0;
foreach $val (@prophecies)
{
	if(!defined($val))
	{
		print "--------- No prophecy for $idx\n";
	}
	else
	{
		SaveItemDB(\*PROPH, $idx, $titles[$idx], $names[$idx], $reasons[$idx]);
		SaveItemList(\*ALL, $idx, $titles[$idx], $names[$idx], $reasons[$idx]);

		open HTML, ">$idx.phtm" or die;
		SaveItemHTML(\*HTML, $idx, $titles[$idx], $names[$idx], $reasons[$idx]);
		close HTML;
	}

	$idx++;
}

print ALL "<tr>  <td colspan=5><hr></td> </tr>\n";
print ALL "<tr>  <td colspan=5>Edited</td> </tr>\n";
close ALL;

close PROPH;
unlink "NewFuture.ph";


open OUT, ">count";
print OUT ($MaxIndex);
close OUT;

