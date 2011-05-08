sub EmitEmail
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
<h2>Email Address Edition</h1>

<p>
Send additions, corrections, or comments you want added to your entry to
<a href="mailto:poz@broadcom.com">poz@broadcom.com</a>.
</p>

<p>
This list can also be obtained in a number of other forms as well:
<ul>
<li><a href="./index.html">HTML-enhanced table-fest with hyperlinking index</a></li>
<li><a href="./CSV.html">Comma separated text file</a></li>
<li><a href="./PreferredEmail.html">Cut and paste email addresses</a></li>
</ul>
</p>

EOSTUFF

	FmtPrint($fields, $person, qq(<table width="100%" border="0" cellpadding="8">\n));
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

		FmtPrint($fields, $person, qq(<tr bgcolor="wheat">\n));
		FmtPrint($fields, $person, qq(<td align="right">\n));
		FmtPrint($fields, $person, qq(<a name="%%Last name%%">\n));
		FmtPrint($fields, $person, qq(%%First name%%\n));
		FmtPrint($fields, $person, qq(	<b>%%Last name%%</b>\n));
		FmtPrint($fields, $person, qq(</td>\n));
		FmtPrint($fields, $person, qq(<td>\n));
		FmtPrint($fields, $person, qq(	<a href="mailto:%?E-mail Address%%">));
		FmtPrint($fields, $person, qq(%?E-mail Address%%</a><br>\n));
		FmtPrint($fields, $person, qq(	<a href="mailto:%?E-mail 2 Address%%">));
		FmtPrint($fields, $person, qq(%?E-mail 2 Address%%</a><br>\n));
		FmtPrint($fields, $person, qq(	<a href="mailto:%?E-mail 3 Address%%">));
		FmtPrint($fields, $person, qq(%?E-mail 3 Address%%</a><br>\n));
		FmtPrint($fields, $person, qq(</td>\n));
		FmtPrint($fields, $person, qq(</tr>\n));
	}
	FmtPrint($fields, $person, qq(</table>\n));
}
1;