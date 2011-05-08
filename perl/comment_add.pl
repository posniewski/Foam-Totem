#!/usr/bin/perl -w

use strict;

use CGI::Lite;
use Captcha::reCAPTCHA;
use Foam2;
use Data::Dumper;

my $c = Captcha::reCAPTCHA->new;

my $cgi = new CGI::Lite;

print "content-type: text/html\n\n";

my $q = $cgi->parse_new_form_data();

my $challenge = $q->{'recaptcha_challenge_field'};
my $response = $q->{'recaptcha_response_field'};

# Verify submission
my $result = $c->check_answer(
	'6LcoAL0SAAAAAKe2lBk9LL5XeSSqddDYrXtZqwEK', $ENV{'REMOTE_ADDR'},
	$challenge, $response
);


if(!$result->{is_valid})
{
	print "Bad Captcha. Are you a robot?";
}
else
{
	my $entry;
	my $id = $q->{fid};
	# cleanse the phfile, in case someone is evil
	$id =~ s'/'-'g;
	$id =~ s'\.\.'_'g;

	my $phfile = "/home/www/html/daily/$id.json";

	if(-e $phfile)
	{
		$entry = from_json_file($phfile);
	}
	elsif(-e $phfile.'x')
	{
		$phfile .= 'x';
		$entry = from_json_file($phfile);
	}

	if(!defined($entry))
	{
		print "Cheater!";
	}
	else
	{
		# Get the current date
		my ($sec,$min,$hour,$mday,$mon,$year) = gmtime(time);
		$year+=1900;
		$mon+=1;

		my $date = MakeAtomTimestamp($year, $mon, $mday, $hour, $min, $sec);
		my $tag = sprintf("%04d%02d%02d_8_%02d%02d%02d", $year, $mon, $mday, $hour, $min, $sec);


		my %comment = (
			'from' => {
				'name' => $q->{name},
				'id' => $ENV{REMOTE_ADDR}
			},
			'created_time' => $date,
			'id' => "$q->{fid}_$tag",
			'message' => $q->{message}
		);

		# Merge it with the Foamy comments
		push(@{ $entry->{comments}->{data} }, \%comment );

		# Sort them by date.
		@{ $entry->{comments}->{data} } = sort { $a->{created_time} cmp $b->{created_time} } @{ $entry->{comments}->{data} };

		open PHFILE, ">:utf8", $phfile or die $! . ": $phfile";
		print PHFILE scalar to_json($entry);
		close PHFILE;
	}

}

#
# End
#