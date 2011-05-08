#!/usr/bin/perl -w
use Data::Dumper;
use Time::Local;
use NetTwitterLite;
use Foam2;

$username = 'posniewski';
$password = 'number6';

my $nt = Net::Twitter::Lite->new( username => $username, password => $password);

#eval
{
	my ($last_year, $last_mon) = (0, 0);

	my $statuses = $nt->user_timeline({ screen_name => $username, count => 10 });
	for my $status ( @$statuses )
	{
		my $id = $status->{id};
		my $created = $status->{created_at};
		my $text = $status->{text};
		my $reply_to_username = $status->{in_reply_to_screen_name};
		my $reply_to_id = $status->{in_reply_to_status_id};

		# Skip direct replies
		next if(defined($reply_to_username) && $text=~m/^@/);

		my ($year, $mon, $day, $hh, $mm, $ss) = GetDateTimeFromTwitterTimestamp($created);
		my $foam_id = GetYYYYMMDD_0_HHMMSS($year, $mon, $day, $hh, $mm, $ss);

		next if($year<2011);

		my %entry = ();

		$entry->{source} = 'twitter';
		$entry->{id} = $foam_id;
		$entry->{publishedDate} = Foam2::MakeAtomTimestamp($year, $mon, $day, $hh, $mm, $ss);

		$entry->{link} = 'http://twitter.com/'.$status->{user}->{name}.'/status/'.$id;
		$entry->{content} = Twitterize($text);
		$entry->{via} = 'Twitter';

		$entry->{content} .= qq( <time datetime="$entry->{publishedDate}">\(at&nbsp;$hh:).sprintf("%02d)</time>",$mm);

		if(defined($reply_to_username))
		{
			$entry->{content}.=qq(<span class="twitreply">);
			$entry->{content}.=qq(<a href="http://twitter.com/$reply_to_username/status/$reply_to_id">(in reply to $reply_to_username)</a>);
			$entry->{content}.=qq(</span>\n);
		}

		if(!(-e '/home/www/html/daily/'.$foam_id.'.json') && !(-e '/home/www/html/daily/'.$foam_id.'.jsonx'))
		{
			#
			# If the file exists, then open it up and read it in for editing
			#
			open PHFILE, ">:utf8", "/home/www/html/daily/$foam_id.json" or die $! . ": $foam_id";
			print PHFILE scalar to_json($entry);
			close PHFILE;

			if(($last_year && $last_year!=$year) || ($last_mon && $last_mon!=$mon))
			{
				Foam2::UpdateHTML('/home/www/html/daily', $last_year, $last_mon);
			}

			$last_year = $year;
			$last_mon = $mon;
		}
	}

	if($last_year && $last_mon)
	{
		Foam2::UpdateHTML('/home/www/html/daily', $last_year, $last_mon);
	}
};

sub GetDateTimeFromTwitterTimestamp
{
	# Sat Jan 24 22:14:29 +0000 2009
	my @parts = split /[ :]/, shift;

	my $mon = FromShortMonth($parts[1]);
	my $day = $parts[2];
	my $hh = $parts[3];
	my $mm = $parts[4];
	my $ss = $parts[5];
	my $year = $parts[7];

	return ($year, $mon, $day, $hh, $mm, $ss);
}

sub GetYYYYMMDD_0_HHMMSS
{
	my ($year, $mon, $mday, $hh, $mm, $ss) = @_;
	return sprintf("%04d%02d%02d_0_%02d%02d%02d", $year, $mon, $mday, $hh, $mm, $ss);
}

sub Twitterize
{
	my $text = shift;

	$text = Linkify($text);
	$text =~ s{@([a-zA-Z0-9_]+)}{<a href="http://twitter.com/$1">@$1</a>}g;

	return $text;
}