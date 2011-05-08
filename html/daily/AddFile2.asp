<% 
my $filehandle;
if($filehandle = $Request->{Form}{uploaded_file}) { 
    local *FILE;
    my $upload = $Request->{FileUpload}{uploaded_file};
    print "<table>";
    my @data = (
		'$Request->{TotalBytes}', $Request->{TotalBytes},
		'Hidden Text', $Request->Form('file_upload'),
		'Uploaded File Name', $filehandle,
		# we only have the temp file because of the
		# FileUploadTemp setting
		'Temp File', $upload->{TempFile},
		'Temp File Exists', (-e $upload->{TempFile}),
		'Temp File Opened', (open(FILE, $upload->{TempFile}) ? 'yes' : "no: $!"),
		map { 
		    ($_, $Request->FileUpload('uploaded_file', $_)) 
		} sort keys %$upload 
	       );
    close FILE;

    while(@data) {
	my($key, $value) = (shift @data, shift @data);
		%>
		<tr>
			<td><b><font size=-1><%=$key%></font></b></td>
			<td><font size=-1><%=$value%></font></td>
		</tr>
		<%
    }
    print "</table>";
	%>

	<pre>
UPLOADED DATA
=============
<% 
    while(<$filehandle>) { 
	print $Server->HTMLEncode($_);	
    }
%>
	</pre>
<% } %>
