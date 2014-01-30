#!perl -w
use strict;
use warnings;
use Carp;

require FoamFacebook;

#FoamFacebook::PeriodicUpdate();

#FoamFacebook::UpdateFacebookComments("20120329_2_055126");


require Foam2;
Foam2::UpdateHTML("/home/www/html/daily", 2011, 1);
Foam2::UpdateHTML("/home/www/html/daily", 2011, 2);
Foam2::UpdateHTML("/home/www/html/daily", 2011, 3);
Foam2::UpdateHTML("/home/www/html/daily", 2011, 4);
Foam2::UpdateHTML("/home/www/html/daily", 2011, 5);
Foam2::UpdateHTML("/home/www/html/daily", 2011, 6);
Foam2::UpdateHTML("/home/www/html/daily", 2011, 7);
Foam2::UpdateHTML("/home/www/html/daily", 2011, 8);
Foam2::UpdateHTML("/home/www/html/daily", 2011, 9);
Foam2::UpdateHTML("/home/www/html/daily", 2011, 10);
Foam2::UpdateHTML("/home/www/html/daily", 2011, 11);
Foam2::UpdateHTML("/home/www/html/daily", 2011, 12);
Foam2::UpdateHTML("/home/www/html/daily", 2012, 1);
Foam2::UpdateHTML("/home/www/html/daily", 2012, 2);
Foam2::UpdateHTML("/home/www/html/daily", 2012, 3);
Foam2::UpdateHTML("/home/www/html/daily", 2012, 4);
Foam2::UpdateHTML("/home/www/html/daily", 2012, 5);
Foam2::UpdateHTML("/home/www/html/daily", 2012, 6);
Foam2::UpdateHTML("/home/www/html/daily", 2012, 7);
Foam2::UpdateHTML("/home/www/html/daily", 2012, 8);
Foam2::UpdateHTML("/home/www/html/daily", 2012, 9);
Foam2::UpdateHTML("/home/www/html/daily", 2012, 10);
Foam2::UpdateHTML("/home/www/html/daily", 2012, 11);
Foam2::UpdateHTML("/home/www/html/daily", 2012, 12);

#my $dailydir = '/home/www/html/daily';
#opendir DIR, $dailydir or die "Couldn't open directory.";
#my @allfiles = reverse map "$dailydir/$_", sort grep /.*_2_.*\.json.?$/, readdir DIR;
#closedir DIR;
#
#my $fb = FoamFacebook::GetFacebook();
#foreach my $id (@allfiles)
#{
##	print "******* $id\n";
#	FoamFacebook::UpdateCachePictureForFile($fb, $id);
#}


