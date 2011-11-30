package Runmeter;

use warnings "all";
use strict;
use Carp;

use LWP::Simple;
use URI::Escape;
use Data::Dumper;
use Geo::Google::PolylineEncoder;
use Math::Polygon;

BEGIN {
	use Exporter ();

	our($VERSION, @ISA, @EXPORT, @EXPORT_OK);

	$VERSION = "1.00";
	@ISA     = qw(Exporter);
	@EXPORT  = qw(
		CacheRunmeterMap
	);
}


$Carp::Verbose = 1;

sub dsqr($$)
{
	my $ra = shift;
	my $rb = shift;

	return ($rb->[1]-$ra->[0])*($rb->[1]-$ra->[0])
		+ ($rb->[2]-$ra->[1])*($rb->[2]-$ra->[1]);
}

sub bin($)
{
	my $x = shift;

	return 3  if($x>3.35);
	return 2  if($x>3.10);
	return 1  if($x>2.82);

	return 0;
}

sub CacheRunmeterMap
{
	my $entry = shift;

	my $LOW_CUTOFF = 2.3;

	#my @colors = qw( 0xff0000ff 0xff8800ff 0x00aa22ff 0xaa4499ff );
	#my @colors = qw( 0xff0000ff 0xffee00ff 0x00ee55ff 0xff55ccff );
	my @colors = qw( 0xb60019ff 0x780cffff 0x0050ffff 0x00b5beff );

	my $result;
	if(!exists($entry->{mapurl}))
	{
		# Get the real URL from the short url
		$result = head($entry->{link});
		$result = $result->base;
	}
	else
	{
		$result = $entry->{mapurl};
	}

	my ($url) = $result =~ m/q=(.*)/;
	my $kml = get($url);

	# Grab the coordinate table from the KML, and make it useful
	my ($coords) = $kml =~ m[.*<abvio:coordinateTable>(.*)</abvio:coordinateTable>]s;
	$coords =~ s/^(.+?),(.+?),(.+?),.+?,(.*)/$1,$2,$3,$4/mg;
	my @points = split("\n", $coords);
	@points = grep m/,/, @points;
	@points = map { [ split(',', $_) ] } @points;

	# Each array entry is now [ elapsed time, lat, long, pace ]

	# We need to greatly reduce the number of points in the path because there
	# is a URL length limit for the static map API.
	my @simple_points = map { [ $_->[1], $_->[2] ] } @points;
	my $poly = Math::Polygon->new(points => \@simple_points);
	my $npoly = $poly->simplify(same => 0.0005, max_points => 50);
	@simple_points = $npoly->points;

	# And since points were manipulated to make a simpler polygon, none of the
	# pace data matches up. So, the following attempts to re-average the pace
	# data and attach it to the approximately best simplified point.

	my @allpaths = ();
	my $curpt=0;
	while(@simple_points > 1)
	{
		my $avg = 0;
		my $tot = 0.00000001;

		my $last;
		do {
			$last = dsqr($simple_points[0], $points[$curpt]);

			if($points[$curpt]->[3] > $LOW_CUTOFF)
			{
				$avg += $points[$curpt]->[3]*$points[$curpt]->[0];
				$tot += $points[$curpt]->[0];
			}
			$curpt++;

		} while(dsqr($simple_points[0], $points[$curpt]) < $last);
#		} while(dsqr($simple_points[0], $points[$curpt]) <= dsqr($simple_points[1], $points[$curpt]));

		$avg = $avg/$tot;

		push @allpaths, [ $simple_points[0]->[0], $simple_points[0]->[1], $avg ];
		shift @simple_points;
	}

	my $avg = 0;
	my $tot = 0.00000001;

	while($curpt < @points)
	{
		if($points[$curpt]->[3] > $LOW_CUTOFF)
		{
			$avg += $points[$curpt]->[3]*$points[$curpt]->[0];
			$tot += $points[$curpt]->[0];
		}
		$curpt++;
	}

	$avg = $avg/$tot;

	push @allpaths, [ $simple_points[0]->[0], $simple_points[0]->[1], $avg ];
	shift @simple_points;

	#
	# @allpaths should now be the simplified path with paces.
	#
	# Now colorize it by pace and make a URL.
	#

	$url = 'http://maps.google.com/maps/api/staticmap?'
		. 'maptype=terrain&style=lightness:40&'
		. 'size=350x250&sensor=false';

	my $encoder = Geo::Google::PolylineEncoder->new;
	my $eline;

	my @path = ();
	my $col = 0;
	my $total = 0;
	my $max = 0;
	my $count = 0;

	foreach my $pt (@allpaths)
	{
		$total += $pt->[2];
		$count++;
		$max = $pt->[2] if($pt->[2] > $max);

		if(bin($pt->[2]) != $col)
		{
			if(@path > 0)
			{
				$eline = $encoder->encode( \@path );
				$url .= '&path=' . uri_escape('color:' . $colors[$col] . '|enc:' . $eline->{points});
			}

			my $p = $path[-1];

			@path = ();
			push @path, [ $p->[0], $p->[1] ]    if($p);

			$col = bin($pt->[2]);
		}

		push @path, [ $pt->[0], $pt->[1] ];
	}

	if(@path > 0)
	{
		$eline = $encoder->encode( \@path );
		$url .= '&path=' . uri_escape('color:' . $colors[$col] . '|enc:' . $eline->{points});
	}

	#
	# And now $url has the url for the static map image.
	#

#	print "Fetching: $url\n";

	my $fragment = "daily/runs/$entry->{id}.jpg";
	$result = getstore($url, "/home/www/html/$fragment");
	$entry->{mapurl_cached} = "http://foamtotem.org/$fragment";
}

1;
