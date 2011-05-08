#!/usr/bin/perl -w

use strict;

use IO::Scalar;
use Foam2;

print "content-type: text/html\n\n";

my %param = ();

if(length ($ENV{'QUERY_STRING'}) > 0)
{
	my @pairs = split(/&/, $ENV{'QUERY_STRING'});
	foreach my $pair (@pairs)
	{
		my ($name, $value) = split(/=/, $pair);

		$name =~ tr/+/ /;
		$name =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;
		$value =~ tr/+/ /;
		$value =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;

		$param{$name} = $value;
	}
}

if(exists($param{'fid'}))
{
	my $id = $param{'fid'};

	$id =~ s/^fid_//i;

	my $fname = '/home/www/html/daily/' . $id . '.json';
	if(-e $fname)
	{
		my $entry = ParseFile($fname);
		my $count = $param{'count'} // 0;

		if(exists($entry->{comments}))
		{
			my $out;

			my $fh = new IO::Scalar \$out;

			GenCommentList($fh, $entry->{comments}, $count);

			print $out;
		}
	}
}

#
# End
#