<%@ LANGUAGE = PerlScript %>
<%
	use Foam2;

	my $path = $Request->ServerVariables('SCRIPT_FILENAME');
	$path =~ s/[\/\\](\w*\.asp\Z)//m;

	my $user = $Request->Cookies("foamtotem", "user");
	my $fullname = $Request->Cookies("foamtotem", "fullname");
	my $password = $Request->Cookies("foamtotem", "password");

	if($password ne "muonhotep")
	{
		$Response->Redirect("./login.asp");
	}

	my $phfile=$Request->QueryString('phfile');
	my $show=$Request->QueryString('show');

	# cleanse the phfile, in case someone is evil
	$phfile =~ s'/'-'g;
	$phfile =~ s'\.\.'_'g;

	my $entry = from_json_file("$path/$phfile");
	my ($year, $mon, $day) = GetDateTimeFromAtomTimestamp($entry->{publishedDate});

	if(defined($phfile))
	{
		if($show)
		{
			my $newname = $phfile;
			$newname =~ s/x$//;
			rename("$path/$phfile", $newname);
		}
		else
		{
			rename("$path/$phfile", "$path/$phfile" . "x");
		}

		UpdateHTML($path, $year, $mon);
	}

	my $date = MakeYYYYMMDD($year,$mon,$day);
	$Response->Redirect("/daily/ChooseDaily.asp?date=$date");
%>

