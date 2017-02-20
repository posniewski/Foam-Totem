use Foam;


#@phfiles = GetFileList('./phfiles');

#for $file (@phfiles)
#{
#	open FILE, "<$file";
#	print "$file...\n";
#	while(<FILE>)
#	{
#		$line = $_;
#		if($line =~ /^%StartItems\(\"(.*)\"\)/)
#		{
#			close OUTFILE if $fileopen;
#
#			my $newfile = Foam::MakeYYYYMMDD(Foam::GetDateFromDD_Mon_YYYY($1));
#			$newfile .= "_9_000001.ph";
#			
#			if(-e $newfile)
#			{
##				print "File exists! $newfile ($file)\n";
##				exit(0);
#			}
#
#			open OUTFILE, ">$newfile";
#			$fileopen = 1;
#			if($line =~ /-/)
#			{
#				# It had a title, deal with it.
#				$line = /.*- (.*)\"\)/;
#				print OUTFILE "<b>$1</b><br>\n";
#			}
#			
#		}
#		elsif($line =~ /^%EndItems/)
#		{
#			$fileopen = 0;
#			close OUTFILE;
#		}
#		elsif($line =~ /^%/)
#		{
#			
#		}
#		else
#		{
#			if(!$fileopen)
#			{
#				if(!($line =~ /^\s*$/))
#				{
#					print "Error: Text outside of Start/End in $file\n";
#					exit(0);
#				}
#			}
#			print OUTFILE $line;
#		}
#	}
#	close FILE;
#}

@phfiles = GetFileList('.');

foreach $year (1997..2003)
{
	foreach $mon (1..12)
	{
		my $outfile = sprintf("%04d%02d",$year,$mon);
		my $hat = grep m/$outfile/, @phfiles;
		if($hat)
		{
			my $outfile2 = sprintf("%04d%02d.html",$year,$mon);
			open OUT, ">../$outfile2";
			select OUT;

			Foam::TotemTop(Foam::LongMonth($mon) . " Flotsam - Foam Totem");
			Foam::GenMonth($year, $mon, @phfiles);
			Foam::TotemBottom(Foam::MakeFlotsamLinks(@phfiles));
			select STDOUT;
			close OUT;
		}
		else
		{
			print "No stories for $outfile\n";
		}
		
	}
}
