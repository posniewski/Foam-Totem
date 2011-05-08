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
use Data::Dumper;

my $result = head('http://j.mp/lzF0y7');
print $result->base;
#print Dumper($result);
