<%@ LANGUAGE = PerlScript %>
<%
	my $path = $Request->ServerVariables('SCRIPT_FILENAME');
	$path =~ s/[\/\\](\w*\.asp\Z)//m;
	# make path to look at

	do "$path/FutureSupport.pl";

	my $failed = 0;
	my $prophecy = $Request->Form("prophecy");
	my $name = $Request->Form("name");
	my $reason = $Request->Form("reason");
	my $count = $Request->Form("index");

	$count = int($count);

	my $semfile = '/tmp/NewFuture.$';


	use Captcha::reCAPTCHA;
	my $c = Captcha::reCAPTCHA->new;
	my $challenge = $Request->Form('recaptcha_challenge_field');
	my $response = $Request->Form('recaptcha_response_field');

	# Verify submission
	my $result = $c->check_answer(
		'6LcoAL0SAAAAAKe2lBk9LL5XeSSqddDYrXtZqwEK', $ENV{'REMOTE_ADDR'},
		$challenge, $response
	);

	if(!$result->{is_valid})
	{
		$prophecy="";
		$name="";
		$reason="Your CAPTCHA failed. Are you a machine sent from THE FUTURE?!";

		$failed = 1;
	}
	elsif(-e $semfile)
	{
		$prophecy="";
		$name="";
		$reason="I was unable to submit your prophecy. The Orb is cloudy now, try again at some other time.";

		$failed = 1;
	}

	if($failed)
	{
		EchoHTML("top.htm");

		$Response->Write("<p>$reason</p>");

		EchoHTML("bottom.htm");
	}
	else
	{
		if(!open SEM, ">$semfile")
		{
			$prophecy="";
			$name="";
			$reason="I was unable to submit your prophecy. The Orb is cloudy now, try again at some other time.";
			goto bail;
		}
		print SEM "locked";
		close SEM;

		if($count<=0)
		{
			my $countfile = $path.'/count';
			if(open COUNT, "<$countfile")
			{
				$count=<COUNT>;
				close COUNT;

				$count++;

				open COUNT, ">$countfile";
				print COUNT "$count\n";
				close COUNT;
			}
			else
			{
				print "can't change count\n";
			}
		}

		# Yank out any embedded commands some evil person has put in their text.
		$prophecy =~ s/\<%//;
		$name =~ s/\<%//;
		$reason =~ s/\<%//;

		open OUT, ">>$path/NewFuture.ph";
		SaveItemDB(\*OUT, $count, $prophecy, $name, $reason);
		close OUT;

		open OUT, ">>$path/AllFuture.html";
		SaveItemList(\*OUT, $count, $prophecy, $name, $reason);
		close OUT;

		open OUT, ">$path/$count.phtm";
		SaveItemHTML(\*OUT, $count, $prophecy, $name, $reason);
		close OUT;

		unlink $semfile;

		$Response->Redirect("./ShowFuture.asp?idx=$count");
	}

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

