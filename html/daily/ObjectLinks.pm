package ObjectLinks;

use warnings "all";
use strict;
use Carp;

use Data::Dumper;
use JSON::DWIW;

BEGIN {
	use Exporter ();

	our($VERSION, @ISA, @EXPORT, @EXPORT_OK);

	$VERSION = "1.00";
	@ISA     = qw(Exporter);
	@EXPORT  = qw(
		ol_Load
		ol_Save
		ol_Add
		ol_Resolve
	);
}


$Carp::Verbose = 1;

my $g_links;
my $g_file;

sub ol_Load
{
	$g_file = shift // '/home/www/html/daily/object.links';

	my $json = JSON::DWIW->new({ pretty => 1, sort_keys => 1 , bad_char_policy => 'convert'});
	$g_links = $json->from_json_file($g_file);
}

sub ol_Add
{
	my ($target, $id) = @_;

	if(exists($g_links->{$target}))
	{
		croak "Target ($target) is also a key. It shouldn't be. (id = $id)\n";
	}

	$g_links->{$id} = $target;
}

sub ol_Resolve
{
	my $id = shift;

	if($id =~ m{foamtotem.*/(\d\d\d\d\d\d\d\d_\d_\d\d\d\d\d\d)\.}i)
	{
		$id = $1;

		if($g_links->{$id})
		{
			return $g_links->{$id};
		}
		else
		{
			return $id;
		}
	}

	if($g_links->{$id})
	{
		return $g_links->{$id};
	}
	else
	{
		return '';
	}
}

sub ol_Save
{
	my $json = JSON::DWIW->new({ pretty => 1, sort_keys => 1 , bad_char_policy => 'convert'});

	open FILE, ">:utf8", $g_file or die $! . ": $g_file";
	print FILE scalar $json->to_json($g_links);
	close FILE;
}

1;
