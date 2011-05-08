<%@ LANGUAGE = PerlScript %>
<%
	use Foam2;
	use Carp;

	$Carp::Verbose = 1;

	my $path = $Request->ServerVariables('SCRIPT_FILENAME');
	$path =~ s/[\/\\](\w*\.asp\Z)//m;

	my $user = $Request->Cookies("foamtotem", "user");
	my $fullname = $Request->Cookies("foamtotem", "fullname");
	my $password = $Request->Cookies("foamtotem", "password");

	if($password ne "muonhotep")
	{
		$Response->Redirect("./login.asp");
	}

	$Response->AddHeader("Cache-Control", "no-cache");

	my $date=$Request->QueryString('date');

	if(!defined($date))
	{
		$Response->Redirect("/");
	}

	my @files = GetFileList($path);
	@files = grep /$date\_/, @files;
	if($#files == 0)
	{
		my $phfile = $files[0];
		$phfile =~ s"^$path/"";

		if($phfile =~ m/\.json/)
		{
			$Response->Redirect("./AlterDailyJson.asp?phfile=$phfile");
		}
		else
		{
			$Response->Redirect("./AlterDaily.asp?phfile=$phfile");
		}
	}

	my ($year, $month, $day) = GetDateFromYYYYMMDD($date);
%>

<%
	use IO::Scalar;
	my $out;

	my $fh = new IO::Scalar \$out;

	StdHTMLStart($fh);
	StdMinHead($fh, "Choose a story to edit - Foam Totem");
	StdBodyStart($fh);

	print $out;
%>

<center>
<table width="100%" height="90%" border="0" cellpadding="3">

<tr>
<td>
	<p>Welcome, <%= $user %>. You are editing the stories for
	<%= MakeDD_Mon_YYYY($year,$month,$day) %>.</p>
	<font size="-2">
	<p>
		There are <% $#files+1 %> stories available to edit for this day.
	</p>
	<p>
		You may also use the section at the bottom to upload images (or whatnot) into
		the /daily directory for use on the news page.
	</p>
</td>
</tr>

<tr>
<td>
<hr>
<%
	$out = '';
	EditGenMonth($fh, $path, $year, $month, @files);
	print $out;
%>
<hr>
</td>
</tr>

<tr>
<td>
	<form method="POST"  enctype="multipart/form-data" action="./AddFile.asp">
		<table>
		<tr><td>Dest name:</td><td><input type="text" name="filename" value=""></td></tr>
		<tr><td>File to upload:</td>
			<td><input type="hidden" name="file_upload" value="hidden file upload form text">
			<input type="file" name="uploaded_file" value="starting value"></td>
		</tr>
		<tr><td colspan="2" align="center"><input type="submit" name="upload file" value="Upload file"></td></tr>
		</table>
	</form>

	Files in /daily:
	<hr>
	<%
		opendir DIR, $path or die "Couldn't open directory.";
		my @allfiles = reverse sort, readdir DIR;
		closedir DIR;

		my $i=1;
		print"<table><tr>";
		foreach my $name (sort @allfiles)
		{
			if($name=~m/\.asp|\.p|\.json|^\./)
			{
				next;
			}

			print '<td><a href="' . $name .'">' . $name .'</td>';
			if($i%4 == 0)
			{
				print"</tr>\n<tr>";
			}
			$i++;
		}
		print"</tr></table>";
	%>
	<hr>
</td>
</tr>

</table>
</center>

<%
	$out = '';

	StdBodyEnd($fh);
	StdHTMLEnd($fh);

	print $out;
%>