<%@ LANGUAGE = PerlScript %>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 3.2//EN">
<html>
	<!-- This page is part of the FoamTotem web site. -->
<head>
<title>Update your address and stuff!</title>
</head>

<body>

<!-- Standard header -->
	<table bgcolor="black" width="100%" border="0" cellpadding="1" cellspacing="0">
		<tr>
			<td valign="center" align="left" width="20%">
				<a href="../index.html"><img hspace="5" src="../images/totemicon.gif" width="16" height="16" border="0" alt="Home"></a>
			</td>
			<td valign="center" align="center" width="60%"><font size="-2" face="Verdana,sans-serif" color="white">Update your address and stuff!</font></td>
			<td valign="center" align="right" width="20%">
				<img hspace="2" src="../images/left-bw-disabled.gif" width="16" height="16" border="0" alt="Previous">
				<img hspace="2" src="../images/right-bw-disabled.gif" width="16" height="16" border="0" alt="Next">
				<img src="/images/blank.gif" width="5" height="1" border="0">
				<a href="/help/index.html"><img src="/images/question-bw.gif" width="16" height="16" border="0" alt="About"></a>
				<img src="/images/blank.gif" width="5" height="1" border="0">
			</td>
		</tr>
	</table>
<!-- End standard header -->

<%
	my $found;
	my $path;
	my @vals = ();
	my @foo = ();
	my $fields;

	$path = $Request->ServerVariables('SCRIPT_FILENAME');
	$path =~ s/[\/\\](\w*\.asp\Z)//m;
	# make path to look at

	require "$path/loadcsv.pl";

	open IN, "<$path/addresses.csv" or die 'Unable to open input file. [$path/addresses.csv]';
	@foo = <IN>;
	close IN;

	foreach my $linestr (@foo)
	{
		my @line = ();

		push(@line, $+) while $linestr =~ m{
			"([^\"\\]*(?:\\.[^\"\\]*)*)",?
			| ([^,]+),?
			| ,
		}gx;

		if(substr($linestr, -1, 1) eq ',')
		{
			push(@line, undef);
		}

		push(@vals, \@line);
	}
	$fields = @vals[0];
	shift @vals;

	my $fname = $Request->QueryString('fname');
	my $lname = $Request->QueryString('lname');
	my $found;
	my $recnum = 0;

	foreach my $person (@vals)
	{
my $perfname = $person->[GetFieldNum("First Name", $fields)];
my $perlname = $person->[GetFieldNum("Last Name", $fields)];
		$perfname =~ s/[&;\s,]/_/g;
		$perlname =~ s/[&;\s,]/_/g;
		if($perfname eq $fname &&
			$perlname eq $lname)
		{
			$found = $person;
			last;
		}
		$recnum++;
	}

if(defined $found)
{
print <<"EOSTUFF";

<center>
<table width="100%" height="90%" border="0">

<tr valign="middle">
<td>

<form method="POST" action="./submitadd.asp">
<input type="hidden" name="recnum" value="$recnum">
<table>
EOSTUFF
	foreach my $field (@$fields)
	{
		print '<tr><td>';
		print $field;
		print '</td><td>';
		print '<input type="text" name="';
		print $field;
		print '" size="50" value="';
		print $found->[GetFieldNum($field, $fields)];
		print '">';
		print '</td></tr>';
		print "\n";
	}
print << "EOSTUFF";
</table>
<input type="submit" value="Submit!">

</form>
EOSTUFF
}
else
{
	print "Somthing weird happened and I can't find [$fname] [$lname].";
	print "Send email to Poz and copy this message.";
	print "<br><br>It's probably all Frodo's fault anyway.";
}
%>
</td>
</tr>
</table>
</center>
<!-- Standard header -->
	<table bgcolor="black" width="100%" border="0" cellpadding="1" cellspacing="0">
		<tr>
			<td valign="center" align="left" width="20%">
				<a href="/index.html"><img hspace="5" src="/images/totemicon.gif" width="16" height="16" border="0" alt="Home"></a>
			</td>
			<td valign="center" align="center" width="60%"><font size="-2" face="Verdana,sans-serif" color="white"></font></td>
			<td valign="center" align="right" width="20%">
				<img hspace="2" src="/images/left-bw-disabled.gif" width="16" height="16" border="0" alt="Previous">
				<img hspace="2" src="/images/right-bw-disabled.gif" width="16" height="16" border="0" alt="Next">
				<img src="/images/blank.gif" width="5" height="1" border="0">
				<a href="/help/index.html"><img src="/images/question-bw.gif" width="16" height="16" border="0" alt="About"></a>
				<img src="/images/blank.gif" width="5" height="1" border="0">
			</td>
		</tr>
	</table>
<!-- End standard header -->

</body>
</html>
