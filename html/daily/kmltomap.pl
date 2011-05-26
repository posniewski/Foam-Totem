#!/usr/bin/perl -w

use strict;
use warnings 'all';
use Carp;

### use URI::Encode qw(uri_encode uri_decode);
###
### my $kml;
###
### {
### 	local( $/, *KML ) ;
### 	open KML, '<kml.kml' or die;
### 	$kml = <KML>;
### 	close KML;
### }
###
### my ($coords) = $kml =~ m[.*<abvio:coordinateTable>(.*)</abvio:coordinateTable>]s;
###
### # secs elapsed, lat, long, delta m, m/s
### # 3094.809,37.4125777,-122.0888823,17.2,2.7
###
### $coords =~ s/^.+?,(.+?,.+?,).+?,(.*)/$1$2/mg;
###
### my $baseurl='http://maps.google.com/maps/api/staticmap?';
###
### my $params='size=300x300';
### # $params .= '&' . uri_encode()
###
### my $path = ';path=color:blue|';
### $coords =~ s/^(.+?),(.+?),.*\n/$1,$2|/mg;
###
### $params .= '&' . uri_encode($path.$coords);
###
### print $baseurl.$params;

use LWP::Simple;
use URI::Escape;
use Data::Dumper;
use Geo::Google::PolylineEncoder;

sub bin
{
	my $x = shift;

#1156.9 406 3.7
#2.84950738916256

#	return 4  if($x>3.0);
	return 3  if($x>3.3);
	return 2  if($x>2.8);
	return 1  if($x>2.5);

	return 0;
}

#my @colors = qw( red yellow green violet );
#my @colors = qw( 0xff0000ff 0xff8800ff 0x00aa22ff 0xaa4499ff );
my @colors = qw( 0xff0000ff 0xffee00ff 0x00ee55ff 0xff55ccff );
my $result = head('http://j.mp/lzF0y7');

#print Dumper($result);

my ($url) = $result->base =~ m/q=(.*)/;
my $kml = get($url);

my ($coords) = $kml =~ m[.*<abvio:coordinateTable>(.*)</abvio:coordinateTable>]s;
$coords =~ s/^.+?,(.+?),(.+?),.+?,(.*)/$1,$2,$3/mg;

my @points = split("\n", $coords);

@points = grep m/,/, @points;

@points = map { [ split(',', $_) ] } @points;

my $encoder = Geo::Google::PolylineEncoder->new;
my $eline;
my @path = ();

$url = 'http://maps.google.com/maps/api/staticmap?'
	. 'maptype=terrain&style=lightness:40&'
	. 'size=350x250&sensor=false';

my $col = 0;
my $total = 0;
my $max = 0;
my $count = 0;

foreach my $pt (@points)
{
	$total += $pt->[2];
	$count++;
	$max = $pt->[2] if($pt->[2] > $max);

#	if($count % 7 != 0)
#	{
#		next;
#	}

	if(bin($pt->[2]) != $col)
	{
		if($#path>0)
		{
			@path = simplify(\@path);
			$eline = $encoder->encode( \@path );
			$url .= '&path=' . uri_escape('color:' . $colors[$col] . '|enc:' . $eline->{points});

			# print "[ $col, '$eline->{points}' ]\n";

			print "[ $col, [ ";
			foreach my $pp (@path) {
				print "[ $pp->[0], $pp->[1] ], ";
			}
			print "] ],\n";
		}

		my $p = $path[-1];

		@path = ();
		push @path, [ $p->[0], $p->[1] ]    if($p);

		$col = bin($pt->[2]);
	}

	push @path, [ $pt->[0], $pt->[1] ];
}

if($#path>0)
{
	@path = simplify(\@path);
	$eline = $encoder->encode( \@path );
	$url .= '&path=' . uri_escape('color:' . $colors[$col] . '|enc:' . $eline->{points});

	# print "[ $col, '$eline->{points}' ]\n";


	print "[ $col, [ ";
	foreach my $pp (@path) {
		print "[ $pp->[0], $pp->[1] ], ";
	}
	print "] ],\n";
}

print $url;

print "\n$total $count $max\n" . $total/$count;

sub simplify
{
	my $l = shift;
	my $i = 0;

	my @res = grep {not $i++ % 1 } @{ $l };
	push @res, $l->[-1] if($i % 1 != 1);

	return @res;
}