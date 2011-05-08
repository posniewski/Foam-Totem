<%@ LANGUAGE = PerlScript %>
<%
	use Data::Dumper;

	use Foam2;

	my $path = $Request->ServerVariables('SCRIPT_FILENAME');
	$path =~ s/[\/\\](\w*\.asp\Z)//m;
	# make path to look at

	my $user = $Request->Cookies("foamtotem", "user");
	my $fullname = $Request->Cookies("foamtotem", "fullname");
	my $password = $Request->Cookies("foamtotem", "password");

	if($password ne "muonhotep")
	{
		$Response->Redirect("./login.asp");
	}

	my ($sec,$min,$hour,$mday,$mon,$year);
	my $entry;

	my $phfile = $Request->Form("phfile");

	if(defined($phfile) && $phfile)
	{
		# cleanse the phfile, in case someone is evil
		$phfile =~ s'/'-'g;
		$phfile =~ s'\.\.'_'g;

		if(-e "$path/$phfile")
		{
			$entry = from_json_file("$path/$phfile");
			($year, $mon, $mday, $hour, $min, $sec) = ConvertDateTimeToLocal(GetDateTimeFromAtomTimestamp($entry->{publishedDate}));
		}
	}

#	$entry->{id} = $Request->Form("id");
#	$entry->{publishedDate} = $Request->Form("publishedDate");
#	$entry->{content} = $Request->Form("content");
#	$entry->{title} = $Request->Form("title");
#	$entry->{link} = $Request->Form("link");
#	$entry->{via} = $Request->Form("via");

	my $form = $Request->Form;
	foreach my $id (keys %{ $form })
	{
		if(exists($entry->{$id}))
		{
			$entry->{$id} = $form->{$id};
		}
	}

	# Yank out any embedded commands some evil person has put in their text.
	$entry->{content} =~ s/\<%//g;
	# change EOLs
	$entry->{content} =~ s/\r\n/\n/g;

	if(!defined($year))
	{
		if($entry->{publishedDate})
		{
			($year, $mon, $mday, $hour, $min, $sec) = GetDateTimeFromAtomTimestamp($entry->{publishedDate});

			if(!$phfile)
			{
				$phfile = sprintf("%04d%02d%02d_9_%02d%02d%02d.json", $year, $mon, $mday, $hour, $min, $sec);
			}

			($year, $mon, $mday, $hour, $min, $sec) = ConvertDateTimeToLocal($year, $mon, $mday, $hour, $min, $sec);
		}
		else
		{
			if(!$phfile)
			{
				my $mday;

				($sec,$min,$hour,$mday,$mon,$year) = gmtime(time);
				$year+=1900;
				$mon+=1;       # zero based

				$phfile = sprintf("%04d%02d%02d_9_%02d%02d%02d.json", $year, $mon, $mday, $hour, $min, $sec);
				$entry->{publishedDate} = MakeAtomTimestamp($year, $mon, $mday, $hour, $min, $sec);

				($year, $mon, $mday, $hour, $min, $sec) = ConvertDateTimeToLocal($year, $mon, $mday, $hour, $min, $sec);
			}
		}
	}

	# Don't let people change directories
	$phfile =~ s'/'%'g;

#	my $sem = GetSemaphore();
#	if($sem eq '')
#	{
#		goto bail;
#	}

	open OUT, ">$path/$phfile";
	print OUT scalar to_json($entry);
	close OUT;

	my $outfile = UpdateHTML($path, $year, $mon);

#	ReleaseSemaphore($sem);

	$Response->Redirect("http://www.foamtotem.org/$outfile");
bail:

%>
