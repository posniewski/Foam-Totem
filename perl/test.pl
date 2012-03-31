#!/usr/bin/perl -w

use strict;
use warnings;
use Carp;

use Facebook::Graph;

print "content-type: text/html\n\n";
print "$Facebook::Graph::VERSION\n";
