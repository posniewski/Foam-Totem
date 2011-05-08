#!/usr/bin/perl -w

use strict;
use warnings;
use Carp;

use FoamFacebook;


print "content-type: text/html\n\n";


use CGI::Lite;

my $cgi = new CGI::Lite;
my $q = $cgi->parse_new_form_data();


UpdateFacebookComments($q->{fid});


#
# End
#