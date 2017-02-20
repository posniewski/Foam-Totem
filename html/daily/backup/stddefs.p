
sub StdFoamTotemHTMLStart
{
	my $StdHTMLHeader='<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 3.2//EN">' . "\n";
	my $StdFoamTotemHeader="<HTML>\n\t<!-- This page is part of the FoamTotem web site. -->\n\t<!-- Copyright (c) 1996-2002, Shannon Posniewski  -->\n";

	print $StdHTMLHeader;
	print $StdFoamTotemHeader;
}

sub StdBodyStart
{
	my $title = shift;

	print "<head>\n";
	print "<title>$title</title>\n";
	print "</head>\n";
	print "\n";

	my $bgcolor="\#eeeecc";
	my $link="\#524510";
	my $vlink="\#524510";
#	my $link="\#846f1a";
	my $textcolor="black";

	print "<body ";
	if($background) {
		print "background=\"$background\" ";
	}
	if($bgcolor) {
		print "bgcolor=\"$bgcolor\" ";
	}
	if($alink) {
		print "alink=\"$alink\" ";
	}
	if($vlink) {
		print "vlink=\"$vlink\" ";
	}
	if($link) {
		print "link=\"$link\" ";
	}
	if($textcolor) {
		print "text=\"$textcolor\" ";
	}
	print ">\n";

	print "\n";
}

sub StdBodyEnd
{
	print "\n</body>\n";
}

sub StdFoamTotemHTMLEnd
{
	print "\n";
	print "</HTML>\n";
}

1;
