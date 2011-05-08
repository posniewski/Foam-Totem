<%@ LANGUAGE = PerlScript %>
<%
	use Foam;

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

	# Get the current date
	my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
	$year+=1900;
	$mon+=1;       # zero based
	my $date = "$mday " . Foam::ShortMonth($mon) . " $year";

	my $phfile=$Request->QueryString('phfile');
	my $editmode = 1;

	#
	# If no phfile has been specified, then we're making a new one.
	# Generate a new name.
	#
	if(!defined($phfile))
	{
		$phfile = sprintf("%04d%02d%02d_9_%02d%02d%02d.ph", $year, $mon, $mday, $hour, $min, $sec);
		$editmode = 0;
	}

	($year, $mon, $mday) = Foam::GetDateFromName($phfile);

	my ($tag) = $phfile =~ m/(.*)\.ph/;
	my $contents;

	#
	# If the file exists, then open it up and read it in for editing
	#
	open(my $PHFILE, "<$path/$phfile"); # or die $! . ": $phfile";
	if($PHFILE)
	{
		while(<$PHFILE>)
		{
			$contents .= $_;
		}
		close $PHFILE;
	}

	if(!defined($contents) || !$contents)
	{
		$contents = qq(<p class="comments"><a href="javascript:HaloScan\('$tag'\);" target="_self"><script type="text/javascript">postCount\('$tag'\);</script></a></p>);
	}
%>

<%
	Foam::StdFoamTotemHTMLStart();
	Foam::StdBodyStart("Modify a story - Foam Totem");
%>

<center>
<table width="98%" height="98%" border="0" cellpadding="3">

<tr>
<td>
	<p>Welcome, <%= $user %>. You are editing <%= $phfile %>.</p>
	</font>
	<form method="POST" action="./SubmitDaily.asp">
		<textarea name="Contents" COLS="80" ROWS="25" style="font-size:12"><%= $contents %></textarea><br>
		<input type="submit" value="Save changes">
		<input type="hidden" name="phfile" value="<%= $phfile %>">
		<input type="hidden" name="year" value="<%= $year %>">
		<input type="hidden" name="month" value="<%= $mon %>">
		<input type="hidden" name="day" value="<%= $mday %>">
		<input type="hidden" name="creator" value="<%= $user %>">
		<input type="hidden" name="creator_fullname" value="<%= $fullname %>">
	</form>
</td>
<td>
	<font size="-2">
	<p>
		You can enter any HTML you want here, so don't do anything naughty.
		The text auto-wraps, so if you have a really long URL, then
		it might look like there are bad carriage returns in it. There aren't.
	</p>
	<p>
		If you leave a blank line between paragraphs, &lt;p&gt; markers will
		be put in for you. You should never need to put them in by
		hand.
	</p>
	<p>
		Images should float off to the right hand side. This can
		be done by putting the following line of HTML before the paragraph
		you want the image associated with.
		&lt;img src="/daily/<i>filename</i>" border="0" align="right"&gt;
	</p>
<p>
&lt;a href="http://movie"&gt;&lt;b&gt;&lt;i&gt;Movie Title&lt;/i&gt;&lt;/b&gt;&lt;/a&gt;&lt;font size="1"&gt; (&lt;a href="http://www.imdb.com/movie"&gt;IMDB 7.1&lt;/a&gt;|&lt;a href="http://www.rottentomatoes.com/movie"&gt;Rot 30%&lt;/a&gt;|&lt;a href="http://www.netflix.com/Movie/"&gt;Netflix 3.0&lt;/a&gt;)&lt;/font&gt;&lt;br/&gt;
</p>
	<p>
		Push the "Save Changes" button to save anychanges made.
		Don't make edits AND update the text. In other words,
		push the "Save Changes" button before uploading a file.
	</p>
</td>
</tr>

<tr>
<td colspan="2">
Other stories on this day:<br>
<hr>
<a href="/daily/AlterDaily.asp">Add a new story</a>
<%
my @files = Foam::GetFileList($path);
my $fname = sprintf("%04d%02d%02d",$year,$mon,$mday);
@files = grep /$fname.._......\.ph.?$/, @files;
EditGenMonth($path, $year, $mon, @files);
%>
<hr>
</td>
</tr>

<tr>
<td colspan="2">
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

			print '<td><font size="-2"><a href="' . $name .'">' . $name .'</font></td>';
			if($i%5 == 0)
			{
				print"</tr>\n<tr>";
			}
			$i++;
		}
		print"</tr></table>";
	%>
	<hr>
	<form method="POST"  enctype="multipart/form-data" action="./AddFile.asp">
		<table width="100%">
		<tr><td>Dest name:</td><td><input type="text" name="filename" value=""></td>
			<td rowspan="2" align="center" width="50%"><input type="submit" name="upload file" value="Upload file"></td>
		</tr>
		<tr><td>File to upload:</td>
			<td><input type="hidden" name="file_upload" value="hidden file upload form text">
			<input type="file" name="uploaded_file" value="starting value"></td>
		</tr>
		</table>
	</form>

</td>
</tr>

</table>
</center>

<%
	Foam::StdBodyEnd();
	Foam::StdFoamTotemHTMLEnd();
%>
