#! perl -w

use strict;
use warnings;
use Carp;

use ObjectLinks;
use Foam2;


ol_Load('/home/www/html/daily/object.links');


my @files = GetFileList('/home/www/html/daily');

@files = grep /\.json$/, @files;

foreach my $file (@files)
{
	my $entry = ParseFile($file);

	if($entry->{via} && $entry->{via} =~ m/<a[ \n\r\t]+href=/i)
	{
		my ($link) = $entry->{via} =~ m/<a.*?href=["']([^"']+)/i;

		ol_Add($entry->{id}, $link) if($link);
	}

	ol_Add($entry->{id}, $entry->{link})    if($entry->{link});

	if($entry->{source} =~ m/facebook/i)
	{
		ol_Add($entry->{id}, $entry->{'~orig'}->{id})        if($entry->{'~orig'}->{id});
		ol_Add($entry->{id}, $entry->{'~orig'}->{object_id}) if($entry->{'~orig'}->{object_id});
	}
}


ol_Save();