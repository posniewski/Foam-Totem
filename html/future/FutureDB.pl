#!perl -w
#
#
# %%
# ## number
# @@ name
# prophecy
# --
# reason
#

$HaveOne = 0;
$HaveReason=0;

@titles=();
@reasons=();
@names=();
@prophecies=();

$title="";
$reason="";
$name="";

$index=-1;
$MaxIndex=0;

ParseProphecies("CleanProphecies.ph");
ParseProphecies("NewFuture.ph");

open OUT, ">CleanProphecies.ph" or die;
$idx=0;
foreach $val (@prophecies)
{
	if(!defined($val) || $val==0)
	{
		print "--------- No prophecy for $idx\n";
	}
	else
	{
		print OUT "%%\n";
		print OUT "## $idx\n";
		if($names[$idx] ne "")
		{
			print OUT "@@ $names[$idx]\n";
		}
		print OUT "$titles[$idx]";
		if($reasons[$idx] ne "")
		{
			print OUT "--\n";
			print OUT "$reasons[$idx]";
		}
	}

	$idx++;
}
close OUT;

unlink "NewFuture.ph";

open OUT, ">AllFuture.html";
$idx=0;
print OUT "<table>\n";
foreach $val (@prophecies)
{
	if(!defined($val) || $val==0)
	{
	}
	else
	{
		print OUT "<tr valign=\"top\"><td>\n";
		print OUT "	<a href=\"./AlterFuture.asp?idx=$idx\"><font size=\"1\">[edit]</font></a>\n";
		print OUT "</td><td>\n";
		if($reasons[$idx] ne "")
		{
			print OUT "*";
		}
		print OUT "</td><td>\n";
		print OUT "$idx\n";
		print OUT "</td><td>\n";
		print OUT "	<a href=\"./ShowFuture.asp?idx=$idx\">$titles[$idx]</a>\n";
		print OUT "</td></tr>\n";
	}

	$idx++;
}
print OUT "</table>\n";
close OUT;

$idx=0;
foreach $val (@prophecies)
{
	if(!defined($val) || $val==0)
	{
		print "--------- No prophecy for $idx\n";
	}
	else
	{
		open OUT, ">$idx.phtm";
		print OUT <<EOF;
<table width="100%" height="75%" border="0">
	<tr valign="center" align="center">
		<td>
EOF

		print OUT "<h3>$titles[$idx]</h3>\n";

		if($reasons[$idx] ne "")
		{
			print OUT <<EOF;
			<br>
			<br>
			<br>
			<br>
			<table width="60%" border="0">
				<tr >
					<td>
EOF
			print OUT $reasons[$idx];
		}
		else
		{
			print OUT <<EOF;
			<br>
			<br>
			<br>
			<br>
			<br>
			<font size="1">
EOF
			print OUT "<a href=\"./AlterFuture.asp?idx=$idx\">Tell the priests how this will happen</a>\n";
			print OUT "</font>";
		}

		if($names[$idx] ne "")
		{
			print OUT "<p><font size=\"1\">as seen by $names[$idx]</font>\n";
		}

		print OUT <<EOF;
					</td>
				</tr>
			</table>
		</td>
	</tr>
</table>
EOF

		close OUT;
	}

	$idx++;
}
close OUT;

open OUT, ">count";
print OUT ($idx-1);
close OUT;


sub ParseProphecies
{
	$filename = shift @_;

	if(!-e $filename)
	{
		return;
	}

	open IN, "<$filename" or die;

	while(<IN>)
	{
		if(/^%%/)
		{
			if($HaveOne)
			{
				if($index<0)
				{
					$index=$MaxIndex+1;
				}

				$titles[$index]=$title;
				$reasons[$index]=$reason;
				$names[$index]=$name;
				$prophecies[$index]=1;

				$title="";
				$reason="";
				$name="";

				$HaveOne = 0;
				if($index>$MaxIndex)
				{
					$MaxIndex = $index;
				}

				$index = -1;
			}

			$HaveOne=1;
			$HaveReason=0;
		}
		elsif(/^##/)
		{
			if($HaveOne)
			{
				($index) = /^## ([0-9]+)/;
			}
			else
			{
				print "Got an index at a bad time\n";
			}
		}
		elsif(/^@@/)
		{
			if($HaveOne)
			{
				($name) = /^@@ (.*)/;
			}
			else
			{
				print "Got a name at a bad time\n";
			}
		}
		elsif(/^--/)
		{
			if($HaveOne)
			{
				if($HaveTitle)
				{
					$HaveReason=1;
				}
				else
				{
					print "Got a reason with no title\n";
				}
			}
		}
		else
		{
			if($HaveReason)
			{
				$reason .= $_;
			}
			else
			{
				$HaveTitle=1;
				$title .= $_;
			}
		}
	}
	close IN;

	if($HaveOne)
	{
		if($index<0)
		{
			$index=$MaxIndex+1;
		}

		$titles[$index]=$title;
		$reasons[$index]=$reason;
		$names[$index]=$name;
		$prophecies[$index]=1;

		if($index>$MaxIndex)
		{
			$MaxIndex = $index;
		}
	}
}
