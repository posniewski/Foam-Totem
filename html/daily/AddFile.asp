<%@ LANGUAGE = PerlScript %>
<%
	my $path = $Request->ServerVariables('SCRIPT_FILENAME');
	$path =~ s/[\/\\](\w*\.asp\Z)//m;
	# make path to look at

	$filehandle = $Request->Form('uploaded_file');
	$name = $Request->Form('filename');

	# Don't let people change directories
	$name =~ s'/'%'g;

	if($filehandle && $name)
	{ 
		if(-e "$path/$name")
		{
			print "That file already exists!\n";
			goto bail;
		}

		local *OUTFILE;
		$\ = '';
		open OUTFILE, ">$path/$name" or die $! . ": on $path/$name";
		while(read($filehandle, $data, 1024)) {
			# data from the uploaded file read into $data
			print OUTFILE $data;
		};
		close OUTFILE;
		$\ = '\n';
	}

	$Response->Redirect("./AlterDaily.asp");

bail:


%>

