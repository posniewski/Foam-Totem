sub EmitHTML
{
	my $fields = shift;
	my $vals = shift;

	print <<'EOSTUFF';
<html>

<head>
<meta http-equiv="content-type" content="text/html; charset=windows-1252">
<meta name="generator" content="poz">

<title>Those Who Are Young and Exotic</title>
</head>

<body>

<h1>Those Who Are Young and Exotic</h1>

<p>
Send additions, corrections, or comments you want added to your entry to
<a href="mailto:poz@broadcom.com">poz@broadcom.com</a>.
</p>

<p>
This list can also be obtained in a number of other forms besides the
egregious one below:
<ul>
<li><a href="./CSV.html">Comma separated text file</a></li>
<li><a href="./JustEmail.html">Just names and email addresses</a></li>
<li><a href="./PreferredEmail.html">Cut and paste email addresses</a></li>
</ul>
<p>

<hr width="100%">
<table width=100%>
<tr valign=top>
<td>

EOSTUFF

	my $count;
	foreach (@$vals)
	{
		$count++;
	}
	$count = int($count/2);

	FmtPrint($fields, $person, qq(<font size="-7">\n));

	my $i=0;
	foreach my $person (@$vals)
	{
		FmtPrint($fields, $person, qq(<a href="#%%Last name%%">));
		FmtPrint($fields, $person, qq(%%Last name%%, ));
		FmtPrint($fields, $person, qq(%%First name%%</a><br>\n));

		if($i == $count)
		{
			FmtPrint($fields, $person, qq(</font>\n));
			FmtPrint($fields, $person, qq(</td><td>\n));
			FmtPrint($fields, $person, qq(<font size="-7">\n));
		}

		$i++;
	}

	FmtPrint($fields, $person, qq(</font>\n));
	FmtPrint($fields, $person, qq(</td>\n));
	FmtPrint($fields, $person, qq(</tr>\n));
	FmtPrint($fields, $person, qq(</table>\n));

	foreach my $person (@$vals)
	{
		# The following fields are supported:
		# First Name
		# Last name
		# E-mail Address
		# E-mail 2 Address
		# E-mail 3 Address
		# Home Street
		# Home Street 2
		# Home City
		# Home State
		# Home Postal Code
		# Home Phone
		# Home Phone 2
		# Other Phone
		# Business Street
		# Business Street 2
		# Business City
		# Business State
		# Business Postal Code
		# Business Phone
		# Business Phone 2
		# Pager
		# Business Fax
		# Mobile Phone
		# Web Page
		# Business Web Page
		# Birthday
		# Birthday 2
		# Birthday 3
		# Birthday 4

		FmtPrint($fields, $person, qq(<a name="%%Last name%%">\n));
		FmtPrint($fields, $person, qq(&nbsp;<br>\n));
		FmtPrint($fields, $person, qq(<table width="100%" border="0">\n));
		FmtPrint($fields, $person, qq(	<tr>\n));
		FmtPrint($fields, $person, qq(	<td colspan="3" valign="top" bgcolor="Wheat">\n));

		FmtPrint($fields, $person, qq(<table width="100%" border="0">\n));
		FmtPrint($fields, $person, qq(<tr>\n));
		FmtPrint($fields, $person, qq(	<td align="left">\n));
		FmtPrint($fields, $person, qq(		<h3>%%First name%%\n));
		FmtPrint($fields, $person, qq(		%%Last name%%\n));
		my $fiddledname = $person->[GetFieldNum("First Name", $fields)];
		$fiddledname =~ s/[&;\s,]/_/g;
		FmtPrint($fields, $person, qq(            <font size="1"><a href="./alteradd.asp?fname=$fiddledname));
		$fiddledname = $person->[GetFieldNum("Last Name", $fields)];
		$fiddledname =~ s/[&;\s,]/_/g;
		FmtPrint($fields, $person, qq(&lname=$fiddledname">[Edit]</a></font></h3>\n));
		FmtPrint($fields, $person, qq(	</td>\n));
		FmtPrint($fields, $person, qq(	<td align="right">\n));
		FmtPrint($fields, $person, qq(		<a href="mailto:%?E-mail Address%%">));
		FmtPrint($fields, $person, qq(%?E-mail Address%%</a><br>\n));
		FmtPrint($fields, $person, qq(		<a href="mailto:%?E-mail 2 Address%%">));
		FmtPrint($fields, $person, qq(%?E-mail 2 Address%%</a><br>\n));
		FmtPrint($fields, $person, qq(		<a href="mailto:%?E-mail 3 Address%%">));
		FmtPrint($fields, $person, qq(%?E-mail 3 Address%%</a><br>\n));
		FmtPrint($fields, $person, qq(	</td>\n));
		FmtPrint($fields, $person, qq(</tr>\n));
		FmtPrint($fields, $person, qq(</table>\n));
		FmtPrint($fields, $person, qq(	</td>\n));
		FmtPrint($fields, $person, qq(	</tr>\n));
		FmtPrint($fields, $person, qq(	<tr>\n));
		FmtPrint($fields, $person, qq(	<td>&nbsp;\n));
		FmtPrint($fields, $person, qq(	</td>\n));
		FmtPrint($fields, $person, qq(	<td width="47%" valign="top" bgcolor="wheat">\n));
		FmtPrint($fields, $person, qq(<font size="-3">Home</font><br>\n));
		FmtPrint($fields, $person, qq(%?Home Street%%<br>\n));
		FmtPrint($fields, $person, qq(%?Home Street 2%%<br>\n));
		FmtPrint($fields, $person, qq(%?Home City%%, \n));
		FmtPrint($fields, $person, qq(%?Home State%% \n));
		FmtPrint($fields, $person, qq(%?Home Postal Code%%<br>\n));
		FmtPrint($fields, $person, qq(<br>\n));
		FmtPrint($fields, $person, qq(<b>BD:</b> %?Birthday%%<br>\n));
		FmtPrint($fields, $person, qq(<b>BD:</b> %?Birthday 2%%<br>\n));
		FmtPrint($fields, $person, qq(<b>BD:</b> %?Birthday 3%%<br>\n));
		FmtPrint($fields, $person, qq(<b>BD:</b> %?Birthday 4%%<br>\n));
		FmtPrint($fields, $person, qq(<b>Anniv:</b> %?Anniversary%%<br>\n));
		FmtPrint($fields, $person, qq(<br>\n));
		FmtPrint($fields, $person, qq(<b>H:</b> %?Home Phone%%<br>\n));
		FmtPrint($fields, $person, qq(<b>H:</b> %?Home Phone 2%%<br>\n));
		FmtPrint($fields, $person, qq(<b>Other:</b> %?Other Phone%%<br>\n));
		FmtPrint($fields, $person, qq(<b>Mobile:</b> %?Mobile Phone%%<br>\n));

		FmtPrint($fields, $person, qq(<b>WWW:</b> <a href="%?Web Page[%">));
		FmtPrint($fields, $person, qq(%?Web Page]%</a><br>\n));

		FmtPrint($fields, $person, qq(	</td>\n));
		FmtPrint($fields, $person, qq(	<td width="47%" valign="top" bgcolor="wheat">\n));
		FmtPrint($fields, $person, qq(<font size="-3">Work</font><br>\n));
		FmtPrint($fields, $person, qq(%?Business Street%%<br>\n));
		FmtPrint($fields, $person, qq(%?Business Street 2%%<br>\n));
		FmtPrint($fields, $person, qq(%?Business City%%, \n));
		FmtPrint($fields, $person, qq(%?Business State%% \n));
		FmtPrint($fields, $person, qq(%?Business Postal Code%%<br>\n));
		FmtPrint($fields, $person, qq(<b>W:</b> %?Business Phone%%<br>\n));
		FmtPrint($fields, $person, qq(<b>W:</b> %?Business Phone 2%%<br>\n));
		FmtPrint($fields, $person, qq(<b>F:</b> %?Business Fax%%<br>\n));
		FmtPrint($fields, $person, qq(<b>Pager:</b> %?Pager%%<br>\n));
		FmtPrint($fields, $person, qq(<b>WWW:</b> %?Business Web Page%%<br>\n));
		FmtPrint($fields, $person, qq(	</td>\n));
		FmtPrint($fields, $person, qq(	</tr>\n));
		FmtPrint($fields, $person, qq(</table>\n));


	}
}
1;
