
sub GetFieldNum
{
	my $fieldname = lc shift;
	my $fields = shift;
	my $idx=0;

#	print ">>Looking for $fieldname...\n";

#	if(!defined($fieldnum{$fieldname}))
	{
#		print ">>>>Not in hash, going for it.\n";
		$idx=0;
		foreach (@$fields)
		{
#			print ">>>>is it $_?\n";
			if(/$fieldname/i)
			{
#				print ">>>>Found at $idx\n";
				last;
			}
			$idx++;
		}

#		$fieldnum{$fieldname} = $idx;
	}

#	print ">>Returning $fieldnum{$fieldname}\n";
#	return $fieldnum{$fieldname};
	return $idx;
}

sub FmtPrint
{
	my $fields = shift;
	my $person = shift;

	foreach (@_)
	{
		my $bDelBlank=0;
		my $final;

		if(/^~/)
		{
			$bDelBlank = 1;
		}

		my ($prev, $op, $name, $op2, $end) = /(.*)%(%|\?)([^%]+)(%|\]|\[)%(.*)/s;
		if(defined($name))
		{
			my $val = $person->[GetFieldNum($name, $fields)];
			if(!defined($val))
			{
				$val="";
			}

			if($op2 eq ']')
			{
				# get just the thing in parens
				my ($paren) = $val=~/.*\((.*)\).*/;

				if(defined($paren))
				{
				   $val = $paren;
				}
			}
			if($op2 eq '[')
			{
				# get just the thing in parens
				my ($paren, $paren2) = $val=~/(.*)\(.*\)(.*)/;
				if(defined($paren))
				{
				   $val = $paren;
				}
				elsif(defined($paren2))
				{
				   $val = $paren2;
				}
			}

			if($val=~/^\s*$/ && $op eq '?')
			{
				$prev=$end="";
			}

			$final = "$prev$val$end";
		}
		else
		{
			$final = $_;
		}

		if(!$bDelBlank || !$final=~/^\s*$/)
		{
			print $final;
		}
	}
}

1;
