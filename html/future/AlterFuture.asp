<%@ LANGUAGE = PerlScript %>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 3.2//EN">
<html>
	<!-- This page is part of the FoamTotem web site. -->
<head>
<title>Tell the Orb of Your Vision</title>
</head>

<body>

<!-- Standard header -->
	<table bgcolor="black" width="100%" border="0" cellpadding="1" cellspacing="0">
		<tr>
			<td valign="center" align="left" width="20%">
				<a href="../index.html"><img hspace="5" src="../images/totemicon.gif" width="16" height="16" border="0" alt="Home"></a>
			</td>
			<td valign="center" align="center" width="60%"><font size="-2" face="Verdana,sans-serif" color="white">Tell the Orb of Your Vision</font></td>
			<td valign="center" align="right" width="20%">
				<img hspace="2" src="../images/left-bw-disabled.gif" width="16" height="16" border="0" alt="Previous">
				<img hspace="2" src="../images/right-bw-disabled.gif" width="16" height="16" border="0" alt="Next">
				<img src="../images/blank.gif" width="5" height="1" border="0">
				<a href="../help/index.html"><img src="../images/question-bw.gif" width="16" height="16" border="0" alt="About"></a>
				<img src="../images/blank.gif" width="5" height="1" border="0">
			</td>
		</tr>
	</table>
<!-- End standard header -->

<%
	my $path = $Request->ServerVariables('SCRIPT_FILENAME');
	$path =~ s/[\/\\](\w*\.asp\Z)//m;
	# make path to look at

	do "$path/FutureSupport.pl";

	my $name = '';
	my $reason = '';
	my $title = '';

	my ($names, $titles, $reasons, $prophecies) = ParseStdProphecies($path);

	my $idx=$Request->QueryString('idx');

	if($names->[$idx] ne "")
	{
		$name = $names->[$idx];
	}

	$title = $titles->[$idx];
	$title =~ s/\n/ /g;

	if($reasons->[$idx] ne "")
	{
		$reason = $reasons->[$idx];
		$reason =~ s/\n/ /g;
	}
%>


<center>
<table width="100%" height="90%" border="0">

<tr valign="middle">
<td>

<form method="POST" action="./SubmitFuture.asp">

<h3>In the future...</h3>
Number <%= $idx %><br>
<font size="1">(Describe your vision. e.g. "We will find alien life in Big Ben.")</font><br>
<textarea name="prophecy" COLS="70" ROWS="4"><%= $title %></textarea><br>
<h3>Because...</h3>
<font size="1">(Leave blank if you cannot see why this will happen.)</font><br>
<textarea name="reason" COLS="70" ROWS="20" wrap="physical"><%= $reason %></textarea><br>
<br>
<h3>So saith...</h3>
<font size="1">(Your name, with title. e.g. Exalted Master Emmanuel Lewis)</font><br>
<input type="text" name="name" size="50" value="<%= $name %>"><br>

<%
	use Captcha::reCAPTCHA;
	my $c = Captcha::reCAPTCHA->new;
	print $c->get_html('6LcoAL0SAAAAAGAoDP7b5-pI213rg-NxiANRYO9B');
%>

<input type="hidden" name="index" size="4" value="<%= $idx %>"><br>
<br>
<br>
<input type="submit" value="Submit to the Orb">

</form>

</td>
</tr>
</table>
</center>
<!-- Standard header -->
	<table bgcolor="black" width="100%" border="0" cellpadding="1" cellspacing="0">
		<tr>
			<td valign="center" align="left" width="20%">
				<a href="../index.html"><img hspace="5" src="../images/totemicon.gif" width="16" height="16" border="0" alt="Home"></a>
			</td>
			<td valign="center" align="center" width="60%"><font size="-2" face="Verdana,sans-serif" color="white"></font></td>
			<td valign="center" align="right" width="20%">
				<img hspace="2" src="../images/left-bw-disabled.gif" width="16" height="16" border="0" alt="Previous">
				<img hspace="2" src="../images/right-bw-disabled.gif" width="16" height="16" border="0" alt="Next">
				<img src="../images/blank.gif" width="5" height="1" border="0">
				<a href="../help/index.html"><img src="../images/question-bw.gif" width="16" height="16" border="0" alt="About"></a>
				<img src="../images/blank.gif" width="5" height="1" border="0">
			</td>
		</tr>
	</table>
<!-- End standard header -->

</body>
</html>
