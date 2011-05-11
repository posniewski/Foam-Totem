<%@ LANGUAGE = PerlScript %>
<%
	use strict;
	use warnings;
	use Carp;

	use Data::Dumper;
	use Foam2;
	use IO::Scalar;

	my $path = $Request->ServerVariables('SCRIPT_FILENAME');
	$path =~ s/[\/\\](\w*\.asp\Z)//m;

	my $user = $Request->Cookies("foamtotem", "user");
	my $fullname = $Request->Cookies("foamtotem", "fullname");
	my $password = $Request->Cookies("foamtotem", "password");

	$user = 'Dr. Falken' unless $user;
	$fullname = 'Dr. Falken' unless $fullname;

	if(!defined($password) || $password ne "muonhotep")
	{
		$Response->Redirect("./login.asp");
	}

	$Response->AddHeader("Cache-Control", "no-cache");

	my ($sec,$min,$hour,$mday,$mon,$year);

	my $phfile=$Request->QueryString('phfile');

	#
	# If no phfile has been specified, then we're making a new one.
	# Generate a new name.
	#
	if(!defined($phfile))
	{
		# Get the current date
		($sec,$min,$hour,$mday,$mon,$year) = gmtime(time);
		$year+=1900;
		$mon+=1;

		$phfile = sprintf("%04d%02d%02d_9_%02d%02d%02d.json", $year, $mon, $mday, $hour, $min, $sec);
	}
	else
	{
		# cleanse the phfile, in case someone is evil
		$phfile =~ s'/'-'g;
		$phfile =~ s'\.\.'_'g;

		($sec,$min,$hour,$mday,$mon,$year) = GetDateTimeFromYYYYMMDD_x_HHMMSS($phfile);
	}


	my ($foam_id) = $phfile =~ m/(.*)\.json/;

	my $entry;
	#
	# If the file exists, then open it up and read it in for editing
	# (Even if phfile was defined, it may not exist.)
	#
	if(-e "$path/$phfile")
	{
		$entry = from_json_file("$path/$phfile");

		if(exists($entry->{content}))
		{
			$entry->{content} =~ s/&/&amp;/g;
		}

		$entry->{content} = '' unless($entry->{content});
		$entry->{title} = '' unless($entry->{title});
		$entry->{link} = '' unless($entry->{link});
		$entry->{via} = '' unless($entry->{via});
		$entry->{source} = '' unless($entry->{source});
	}
	else
	{
		$entry->{id} = $foam_id;
		$entry->{publishedDate} = MakeAtomTimestamp($year, $mon, $mday, $hour, $min, $sec);
		$entry->{content} = '';
		$entry->{title} = '';
		$entry->{link} = '';
		$entry->{via} = '';
		$entry->{source} = 'foamtotem';
	}
%>

<%
	use IO::Scalar;
	my $out;

	my $fh = new IO::Scalar \$out;

	StdHTMLStart($fh);
	StdMinHead($fh, "Modify a story - Foam Totem");
	StdBodyStart($fh);

	print $out;
%>

<p>Welcome, <%= $user %>. You are editing <%= $phfile %>.</p>

<table width="98%" height="98%" border="0" cellpadding="3">
<tr>
<td>
	</font>
	<form method="POST" action="./SubmitDaily.asp">
	<table>
		<tr><td class="name">Title:</td><td><textarea name="title" cols="80" rows="1"><%= $entry->{title} %></textarea></td></tr>
		<tr><td class="name">Via:</td><td><textarea name="via" cols="80" rows="1"><%= $entry->{via} %></textarea></td></tr>
		<tr><td class="name">Content:</td><td><textarea name="content" cols="80" rows="25"><%= $entry->{content} %></textarea></td></tr>
		<tr><td class="name">Date:</td><td><textarea name="publishedDate" cols="40" rows="1"><%= $entry->{publishedDate} %></textarea></td></tr>
		<tr><td class="name">Link:</td><td><textarea name="link" cols="80" rows="1"><%= $entry->{link} %></textarea></td></tr>
		<tr><td class="name">ID:</td><td><textarea name="id" cols="20" rows="1"><%= $entry->{id} %></textarea></td></tr>
<%
	foreach my $key (sort keys %{ $entry })
	{
		next if($key =~ /~/);
		next if($key =~ /title|via|content|publishedDate|link|id/);
		next unless(ref( \$entry->{$key} ) eq 'SCALAR');

		print qq(<tr><td  class="name">$key:</td><td><textarea name="$key" cols="80" rows="1">) . $entry->{$key} . qq(</textarea></td></tr>);
	}
%>
	</table>
		<input type="submit" value="Save changes">

		<input type="hidden" name="phfile" value="<%= $phfile %>">
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
&lt;a href="http://movie"&gt;&lt;b&gt;&lt;i&gt;Movie Title&lt;/i&gt;&lt;/b&gt;&lt;/a&gt;&lt;font size="1"&gt; (&lt;a href="http://www.imdb.com/movie"&gt;IMDB 7.1&lt;/a&gt;|&lt;a href="http://www.rottentomatoes.com/movie"&gt;Rot 30%&lt;/a&gt;|&lt;a href="http://www.netflix.com/Movie/"&gt;Netflix 3.0&lt;/a&gt;)&lt;/font&gt;&lt;br/&gt;
</p>
	<p>
		Push the "Save Changes" button to save any changes made.
		Don't make edits AND upload. In other words,
		push the "Save Changes" button before uploading a file.
	</p>

	<p />
	<p />
	<hr>
	<p />
	You can also show and hide this entry.
	<a href="./hide.asp?phfile=<%= $phfile %>&show=1">[show]</a>
	<a href="./hide.asp?phfile=<%= $phfile %>&show=0">[hide]</a>
</td>
</tr>
<tr>
<td colspan=2>
<pre>
<%
	my $all = Dumper($entry);
	$all =~ s/</&lt;/g;
	$all =~ s/>/&gt;/g;
	print $all;
%>
</pre>
</td>
</tr>

<tr>
<td colspan="2">
Other stories on this day:<br>
<hr>
<a href="/daily/AlterDailyJson.asp">Add a new story</a>
<%
	$out = '';

	my @files = GetFileList($path);

	my $fname = sprintf("%04d%02d%02d",$year,$mon,$mday);
	@files = grep /$fname.._......\.json/, @files;

	EditGenMonth($fh, $path, $year, $mon, @files);

	print $out;
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
			if($name=~m/\.asp|\.p|^\./)
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

<%
	$out = '';
	StdBodyEnd($fh);
	StdHTMLEnd($fh);
	print $out;
%>
