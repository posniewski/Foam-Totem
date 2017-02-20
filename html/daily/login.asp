<%@ LANGUAGE = PerlScript %>
<%
	use Foam;
	my $path = $Request->ServerVariables('SCRIPT_FILENAME');
	$path =~ s/[\/\\](\w*\.asp\Z)//m;

	my $user = $Request->Cookies("foamtotem", "user");
	my $fullname = $Request->Cookies("foamtotem", "fullname");
	my $password = $Request->Cookies("foamtotem", "password");

	Foam::StdFoamTotemHTMLStart();
	Foam::StdBodyStart("Log in to the Foam Totem");

%>

<br>
<br>
<br>
<br>
<br>
<br>
<form method="POST" action="./foamlogin.asp">
	<table border="0">
		<tr>
			<td>User name:</td>
			<td><input type="text" name="user" value="<%= $user %>"> (This is your short name, like "poz")</td>
		</tr>
		<tr>
			<td>Full name:</td>
			<td><input type="text" name="fullname" value="<%= $fullname %>">  (This is your full name, like "Shannon Posniewski")</td>
		<tr>
			<td>Password:</td>
			<td><input type="text" name="password" value="<%= $password %>">  (This is the edit password)</td>
		<tr>
	</table>
	<input type="submit" value="Log in to Foam Totem">
</form>

<%
	Foam::StdFoamTotemHTMLEnd();
	Foam::StdBodyEnd();
%>
