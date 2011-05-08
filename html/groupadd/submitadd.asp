<%@ LANGUAGE = PerlScript %>
<%
	my $path;
	my @foo = ();
	my @vals = ();
	my $fields;

	$path = $Request->ServerVariables('SCRIPT_FILENAME');
	$path =~ s/[\/\\](\w*\.asp\Z)//m;
	# make path to look at

	require "$path/loadcsv.pl";
	require "$path/emithtml.pl";
	require "$path/emitpref.pl";
	require "$path/emitemail.pl";

	open IN, "<$path/addresses.csv" or die 'Unable to open input file. [$path/addresses.csv]';
	@foo = <IN>;
	close IN;

	foreach my $linestr (@foo)
	{
		my @line = ();

		push(@line, $+) while $linestr =~ m{
			"([^\"\\]*(?:\\.[^\"\\]*)*)",?
			| ([^,]+),?
			| ,
		}gx;

		if(substr($linestr, -1, 1) eq ',')
		{
			push(@line, undef);
		}

		push(@vals, \@line);
	}
	$fields = @vals[0];
	shift @vals;

	my $recnum = $Request->Form("recnum");
	my $person;

	foreach my $field (@$fields)
	{
		$person->[GetFieldNum($field, $fields)] = $Request->Form($field);
	}

	$vals[$recnum] = $person;

	open OUT, ">$path/addresses.csv";
	my $firsttime = 1;
	foreach my $field (@$fields)
	{
		if(!$firsttime)
		{
			print OUT qq(,);
		}
	
		chomp $field;
		if($field=~m/,/)
		{
			$field = qq("$field");
		}
		print OUT $field;
		$firsttime = 0;
	}
	print OUT qq(\n);
	foreach $person (@vals)
	{
		$firsttime = 1;
		foreach my $field (@$fields)
		{
			if(!$firsttime)
			{
				print OUT qq(,);
			}
			my $tmp = $person->[GetFieldNum($field, $fields)];
			chomp $tmp;
			if($tmp=~m/,/)
			{
				$tmp = qq("$tmp");
			}
			print OUT $tmp;
			$firsttime = 0;
		}
		print  OUT qq(\n);
	}
	close OUT;

open OUT, ">$path/index.html";
select OUT;
EmitHTML($fields, \@vals);
select STDOUT;
close OUT;

open OUT, ">$path/PreferredEmail.html";
select OUT;
EmitPref($fields, \@vals);
select STDOUT;
close OUT;

open OUT, ">$path/JustEmail.html";
select OUT;
EmitEmail($fields, \@vals);
select STDOUT;
close OUT;

$Response->Redirect("./index.html");


%>

