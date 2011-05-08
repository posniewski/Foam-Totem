#!/usr/bin/perl -w
use Data::Dumper;
use URI::Escape;
use HTTP::Request;
use LWP::UserAgent;
use Time::Local;
use JSON::DWIW qw(from_json to_json);

use Foam2;

sub feedurl($$)
{
	my ($url, $count) = @_;

#	my $s = 'http://www.poweringnews.com/feed-to-json.aspx?feedurl='
#		. uri_escape($url);

	my $s = 'http://ajax.googleapis.com/ajax/services/feed/load?'
		.'v=1.0&num='
		.$count
		.'&q='
		.uri_escape($url);

	return $s;
}

sub GetDateTimeFromPosterousTimestamp($)
{
	# Sat, 12 Dec 2009 19:14:08 -0800
	my @parts = split /[ :]/, shift;

	my $day = $parts[1];
	my $mon = FromShortMonth($parts[2]);
	my $year = $parts[3];
	my $hh = $parts[4];
	my $mm = $parts[5];
	my $ss = $parts[6];

	my $x;
	my $time = timegm($ss,$mm,$hh,$day,$mon-1,$year);
	($ss,$mm,$hh,$day,$mon,$year,$x,$x,$x) = localtime($time);
	$mon+=1;
	$year+=1900;

	return ($year, $mon, $day, $hh, $mm, $ss);
}

sub GetYYYYMMDD_0_HHMMSS($$$$$$)
{
	my ($year, $mon, $mday, $hh, $mm, $ss) = @_;
	return sprintf("%04d%02d%02d_1_%02d%02d%02d", $year, $mon, $mday, $hh, $mm, $ss);
}

#
# $monthnum = FromShortMonth("Mon")
#
sub FromShortMonth($)
{
	my $monstr = shift;

	my %months =
	(
		'Jan' =>  1,
		'Feb' =>  2,
		'Mar' =>  3,
		'Apr' =>  4,
		'May' =>  5,
		'Jun' =>  6,
		'Jul' =>  7,
		'Aug' =>  8,
		'Sep' =>  9,
		'Oct' => 10,
		'Nov' => 11,
		'Dec' => 12
	);

	return $months{$monstr};
}


sub Reformat($)
{
	my $entry = shift;

	# Use description instead of content for the other ATOM to JSON
	# converter

	# Remove the posterous permalink
	$entry->{content} =~ s{(.*)(<p>.*?ermalink.*?</p>)}{$1}s;

	# Remove the any extraneous <p>s or <div>s bracketing the post.
	# todo: this looks aggressive since it isn't restricted to the beginning
	#       of the post. What is it actually doing?
	$entry->{content} =~ s{[\s\n]*<p>(.*)</p>}{$1}s;

	# Divs don't always bracket the post, it seems.
#	$entry->{content} =~ s{[\s\n]*<div>(.*)</div>}{$1}s;

	# Trim out leading blanks
	$entry->{content} =~ s{^[\s\n]*\n}{}mg;

print "b********************\n";
print $entry->{content};
print "\n";
	# Find the via, if there is one
	my ($via) = $entry->{content} =~ m{<div>via(.*?)</div>}s;
	if($via)
	{
		$entry->{content} =~ s{<div>via.*?</div>}{}g;
		$entry->{via} = $via;
	}

	# Check to see if there are a stack of images. If so, reformat them into
	# a gallery
	my $cnt = () = ($entry->{content} =~ m/<img/ig);
	if($cnt > 1)
	{
		my $foam_id = $entry->{id};

		# this is a gallery, hopefully.
#		$text =~ s{<a href=(.*?)>[^<]*<img.*?</a>}{<img src=$1 />}g;
		$entry->{content} =~ s{<p>([\s\n]*<a .*?>[\s\n]*<img .*?)</p>}{<div class="gallery_$foam_id">$1</div>}is;
		$entry->{content} =~ s{<p>([\s\n]*<img .*?)</p>}{<div class="gallery_$foam_id">$1</div>}is;
		$entry->{content} =~ s{(<img[^>]+[^/])>}{$1 />}ig;

		$entry->{content} .= <<"EOSTUFF";
<script src="http://ajax.googleapis.com/ajax/libs/jquery/1/jquery.min.js"></script>
<script src="/js/galleria.js"></script>
<script>
	Galleria.loadTheme('/js/galleria_themes/classic/galleria.classic.js');
	\$(".gallery_$foam_id").galleria();
</script>
EOSTUFF
	}
	else
	{
		# Mark images from posterous as posterous images.
		$entry->{content} =~ s{<img }{<img class="posterous" }s;
		# XHTML the img tags
		$entry->{content} =~ s{(<img.*?[^/])>}{$1/>}s;
	}

print "Z********************\n";
print $entry->{content};
print "\n";
}


eval
{
	my $ua = LWP::UserAgent->new;
	my $response = $ua->get(feedurl('http://posniewski.posterous.com/rss.xml', 1));

	my $foo = JSON::DWIW::from_json($response->content);

	my ($last_year, $last_mon) = (0, 0);

	for my $entry (@{ $foo->{responseData}->{feed}->{entries} })
#	for my $entry (@{ $foo->{rss}->{channel}->[0]->{item} })
	{

		my ($year, $mon, $day, $hh, $mm, $ss) = GetDateTimeFromPosterousTimestamp($entry->{publishedDate});
#		my ($year, $mon, $day, $hh, $mm, $ss) = GetDateTimeFromPosterousTimestamp($entry->{pubDate});
		my $foam_id = GetYYYYMMDD_0_HHMMSS($year, $mon, $day, $hh, $mm, $ss);

		$entry->{id} = $foam_id;
		$entry->{publishedDate} = MakeAtomDateTime($year, $mon, $day, $hh, $mm, $ss);

#		if(!(-e '/home/www/html/daily/'.$foam_id.'.json') && !(-e '/home/www/html/daily/'.$foam_id.'.jsonx'))
		{
			Reformat($entry);

			open PHFILE, ">:utf8", "/home/www/html/daily/$foam_id.json" or die $! . ": $foam_id";
			print PHFILE scalar JSON::DWIW::to_json($entry, { pretty => 1, bad_char_policy => convert});
			close PHFILE;
		}

		if(($last_year && $last_year!=$year) || ($last_mon && $last_mon!=$mon))
		{
#			Foam2::UpdateHTML('/home/www/html/daily', $last_year, $last_mon);
		}

		$last_year = $year;
		$last_mon = $mon;
	}

	if($last_year && $last_mon)
	{
#		Foam2::UpdateHTML('/home/www/html/daily', $last_year, $last_mon);
	}
};
#warn "$@\n" if $@;

#use Data::Dumper;
#use Time::Local;
#use Foam;
#use WebService::Google::Reader;
#
#my $user='posniewski';
#my $pass='number65536';
#
#my $dc = XML::Atom::Namespace->new(dc => 'http://www.google.com/schemas/reader/atom/');
#
#my $reader = WebService::Google::Reader->new(
#    username => $user,
#    password => $pass,
#);
#
#my $feed = $reader->starred(count => 50) or die $reader->error;
#
#do
#{
#	for my $entry ($feed->entries())
#	{
#		print $entry->title, "\n";
#		print $entry->link->href, "\n" if $entry->link and $entry->link->href;
#		print $entry->summary, "\n";
#		print "***************\n";
#	}
#
#	# $reader->mark_read_entry($feed->entries) or die $reader->error;
#
#} while $reader->more($feed);


