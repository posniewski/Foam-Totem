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

my @titles=();
my @reasons=();
my @names=();
my @prophecies=();

my $MaxIndex=0;

sub ParseStdProphecies
{
	$path=shift @_;

	ParseProphecies("$path/CleanProphecies.ph");
	ParseProphecies("$path/NewFuture.ph");

	return \@names, \@titles, \@reasons, \@prophecies;
}

sub ParseProphecies
{
	my $HaveOne = 0;
	my $HaveReason=0;
	my $title="";
	my $reason="";
	my $name="";
	my $index=-1;

	my $filename = shift @_;


	if(!-e $filename)
	{
		return;
	}

#	print "Processing $filename...\n";

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

#	print "Largest item number: $MaxIndex\n";
}

sub SaveItemHTML
{
	my($fh, $idx, $prophecy, $name, $reason) = @_;

	print $fh <<EOF;
<table width="100%" height="75%" border="0">
	<tr valign="center" align="center">
		<td>
EOF

	print $fh "<h3>$prophecy</h3>\n";

	if(defined($reason) && $reason ne "")
	{
		print $fh <<EOF;
			<br>
			<br>
			<br>
			<br>
			<table width="60%" border="0">
				<tr >
					<td>
EOF
		print $fh $reason;
	}
	else
	{
		print $fh <<EOF;
			<br>
			<br>
			<br>
			<br>
			<br>
			<font size="1">
EOF
		print $fh "<a href=\"AlterFuture.asp?idx=$idx\">Tell the priests how this will happen</a>\n";
		print $fh "</font>";
	}

	if(defined($name) && $name ne "")
	{
		print $fh "<p><font size=\"1\">as seen by $name</font>\n";
	}

	print $fh <<EOF;
					</td>
				</tr>
			</table>
		</td>
	</tr>
</table>
EOF
}

sub SaveItemDB
{
	my($fh, $idx, $prophecy, $name, $reason) = @_;

	print $fh "%%\n";
	print $fh  "## $idx\n";
	if(defined($name) && $name ne "")
	{
		print $fh "@@ $name\n";
	}
	print $fh "$prophecy\n";
	if(defined($reason) && $reason ne "")
	{
		print $fh "--\n";
		print $fh "$reason\n";
	}
}

sub SaveItemList
{
	my($fh, $idx, $prophecy, $name, $reason) = @_;

	print $fh "<tr valign=\"top\"><td>\n";
	print $fh "	<a href=\"./AlterFuture.asp?idx=$idx\"><font size=\"1\">[edit]</font></a>\n";
	print $fh "</td><td>\n";
	if($reasons[$idx] ne "")
	{
		print $fh "*";
	}
	print $fh "</td><td>\n";
	print $fh "$idx\n";
	print $fh "</td><td>\n";
	print $fh "	<a href=\"./ShowFuture.asp?idx=$idx\">$prophecy</a>\n";
	print $fh "</td></tr>\n";
}

1;
