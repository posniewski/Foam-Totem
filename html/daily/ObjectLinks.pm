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
		ol_GetBestFbid
	);
}


$Carp::Verbose = 1;

my $g_links;
my %g_rev_links;
my $g_file;

my $g_reverse_hash_dirty;
my $g_loaded;

sub ol_Load
{
	$g_file = shift // '/home/www/html/daily/object.links';

	my $json = JSON::DWIW->new({ pretty => 1, sort_keys => 1 , bad_char_policy => 'convert'});
	$g_links = $json->from_json_file($g_file);

	$g_reverse_hash_dirty = 1;
	$g_loaded = 1;
}

sub ol_Add
{
	my ($target, $id) = @_;

	ol_Load() if(!$g_loaded);

	if(exists($g_links->{$target}))
	{
		croak "Target ($target) is also a key. It shouldn't be. (id = $id)\n";
	}

	$g_links->{$id} = $target;
	$g_reverse_hash_dirty = 1;
}

sub ol_Resolve
{
	my $id = shift;

	ol_Load() if(!$g_loaded);

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
	if($g_loaded)
	{
		my $json = JSON::DWIW->new({ pretty => 1, sort_keys => 1 , bad_char_policy => 'convert'});

		open FILE, ">:utf8", $g_file or die $! . ": $g_file";
		print FILE scalar $json->to_json($g_links);
		close FILE;
	}
}

sub ol_GetBestFbid
{
	my $l = shift;

	ol_Load() if(!$g_loaded);

	if($g_reverse_hash_dirty)
	{
		%g_rev_links = ();
		while (my ($link, $target) = each(%{ $g_links }))
		{
			push( @{ $g_rev_links{$target} }, $link );
		}

		$g_reverse_hash_dirty = 0;
	}


	if($g_rev_links{$l})
	{
		my ($fbid, $fbid2, $fbpic, $fbpic2);

# print "\t$l ->\n";
		# OK, we found it, get the best one in the list.
		foreach my $link ( @{ $g_rev_links{$l} } )
		{
			if($link =~ m/^fbid:/)
			{
				$fbid = $link;
# print "\t\t$link\n";
			}
			elsif($link =~ m/^fbid2:/)
			{
				$fbid2 = $link;
# print "\t\t$link\n";
			}
			elsif($link =~ m/^fbpic:/)
			{
				$fbpic = $link;
# print "\t\t$link\n";
			}
			elsif($link =~ m/^fbpic2:/)
			{
				$fbpic2 = $link;
# print "\t\t$link\n";
			}
		}

		$fbid = $fbid // $fbid2 // $fbpic // $fbpic2;
		if($fbid)
		{
			$fbid =~ s/^fb.*?://;
# print "== $fbid\n";
			return $fbid;
		}

# print "== none\n";
	}
	else
	{
		# That link isn't being tracked, apparently.
	}
}

1;
