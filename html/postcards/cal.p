#!perl -w

use Time::JulianDay;

sub EmitYear()
{
	my $year=shift;

	print "<pre><font size=\"-9\"><b>\n";

	my $i;
	my @dat;

	for($monthofyear=1; $monthofyear<13; $monthofyear++)
	{
		$dat[$monthofyear]  = julian_day($year,$monthofyear,1);
		my $dayofweek = day_of_week($dat[$monthofyear]);
		for($i=0; $i<$dayofweek; $i++)
		{
			emitnoday();
		}
		for($i=$dayofweek; $i<7; $i++)
		{
			emitday($year, $monthofyear, $i-$dayofweek+1);
			$dat[$monthofyear] = add_day($dat[$monthofyear]);
		}
		emitspace();
	}
	emitline();

	for(my $weekofmonth=1; $weekofmonth<6; $weekofmonth++)
	{
		for(my $monthofyear=1; $monthofyear<13; $monthofyear++)
		{
			for($i=0; $i<7; $i++)
			{
				my ($yy,$mm,$dd) = inverse_julian_day($dat[$monthofyear]);
				if($mm!=$monthofyear)
				{
					emitnoday();
				}
				else
				{
					emitday($year, $mm, $dd);
				}

				$dat[$monthofyear] = add_day($dat[$monthofyear]);
			}

			emitspace();
		}
		emitline();
	}

	print "</b></font></pre>\n";
}

sub add_day
{
	my $dat = shift;
	my ($yy,$mm,$dd)=inverse_julian_day($dat);
	return julian_day($yy,$mm,$dd+1);
}

sub emitnoday()
{
#	print '<img src="./blank.gif" border="0" width="3" height="3">';
	print ' ';
}

sub emitday()
{
	my $yy=shift;
	my $mm=shift;
	my $dd=shift;

	my $goof = sprintf("%04d%02d%02d",$yy,$mm,$dd);

	if(exists($links{$goof}))
	{
		print '<a href="./' . $links{$goof}. '">';
		print '*';
#		print '<img src="./yesday.gif" border="0" width="3" height="3">';
		print '</a>';
	}
	else
	{
		print '.';
#		print '<img src="./noday.gif" border="0" width="3" height="3">';
	}
}

sub emitspace()
{
#	print '<img src="./blank.gif" border="0" width="3" height="3">';
#	print '<img src="./blank.gif" border="0" width="3" height="3">';
	print '  ';
}

sub emitline()
{
	print "\n";
}

1;