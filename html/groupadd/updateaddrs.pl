require "loadcsv.pl";
require "emithtml.pl";
require "emitpref.pl";
require "emitemail.pl";


open IN, '<addresses.csv' or die 'Unable to open input file.';
@foo = <IN>;
close IN;

@vals = parse_csv(@foo);
$fields = @vals[0];

shift @vals;

open OUT, ">index.html";
select OUT;
EmitHTML($fields, \@vals);
select STDOUT;
close OUT;

open OUT, ">PreferredEmail.html";
select OUT;
EmitPref($fields, \@vals);
select STDOUT;
close OUT;

open OUT, ">JustEmail.html";
select OUT;
EmitEmail($fields, \@vals);
select STDOUT;
close OUT;

sub parse_csv
{
	my @ret = ();
	my $linestr;

	foreach $linestr (@_)
	{
		my @line = ();

		chomp $linestr;

		push(@line, $+) while $linestr =~ m{
			"([^\"\\]*(?:\\.[^\"\\]*)*)",?
			| ([^,]+),?
			| ,
		}gx;

		if(substr($linestr, -1, 1) eq ',')
		{
			push(@line, undef);
		}

		push(@ret, \@line);
	}

	return @ret;
}

1;
