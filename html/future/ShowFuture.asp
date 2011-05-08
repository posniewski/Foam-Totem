<%@ LANGUAGE = PerlScript %>
<%
	my $path = $Request->ServerVariables('SCRIPT_FILENAME');
	$path =~ s/[\/\\](\w*\.asp\Z)//m;

	my $idx=$Request->QueryString('idx');

	if(!-e $path."/$idx.phtm")
	{
		$idx=0;
	}

	while($idx==0)
	{
		my $countfile = $path.'/count';
		open COUNT, "<$countfile";
		my $count = <COUNT>;
		close COUNT;

		$idx = int(rand $count)+1;

		if(!-e $path."/$idx.phtm")
		{
			$idx=0;
		}
	}

	EchoHTML("top.htm");

	EchoHTML("$idx.phtm");

	$Response->Write("<p align=\"right\"><font size=\"1\">Number $idx</font>\n");
	$Response->Write("<br><font size=\"1\"><a href=\"./AlterFuture.asp?idx=$idx\">Fix a typo</a></font>\n");
	$Response->Write("</p>\n");

	EchoHTML("bottom.htm");

	sub EchoHTML
	{
		my $base = shift @_;
		my $file = $path.'/'.$base;

		if(!-e $file)
		{
			$file = $path.'/unknown.phtm';
		}

		open IN, "<$file";
		while(<IN>)
		{
			$Response->Write($_);
		}
		close IN;
	}
%>
