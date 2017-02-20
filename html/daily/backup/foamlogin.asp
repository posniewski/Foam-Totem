<%@ LANGUAGE = PerlScript %>
<%
	my $path = $Request->ServerVariables('SCRIPT_FILENAME');
	$path =~ s/[\/\\](\w*\.asp\Z)//m;
	# make path to look at

	my $user = $Request->Form("user");
	my $fullname = $Request->Form("fullname");
	my $password = $Request->Form("password");

	$Response->{Cookies}{foamtotem} = 
	{
		user => $user,
		fullname => $fullname,
		password => $password,
		Expires => 30*60*60*24
	};

	$Response->Redirect("/");
%>
