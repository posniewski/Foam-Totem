#!/usr/bin/perl -w
use Data::Dumper;
use Time::Local;
use Foam;
use WebService::Google::Reader;

my $user='posniewski';
my $pass='number65536';

my $dc = XML::Atom::Namespace->new(dc => 'http://www.google.com/schemas/reader/atom/');

my $reader = WebService::Google::Reader->new(
    username => $user,
    password => $pass,
);

my $feed = $reader->starred(count => 50) or die $reader->error;

do
{
	for my $entry ($feed->entries())
	{
		print $entry->title, "\n";
		print $entry->link->href, "\n" if $entry->link and $entry->link->href;
		print $entry->summary, "\n";
		print "***************\n";
	}

	# $reader->mark_read_entry($feed->entries) or die $reader->error;

} while $reader->more($feed);



#eval
#{
#	my ($last_year, $last_mon) = (0, 0);
#
#	my $statuses = $nt->user_timeline({ screen_name => $username, count => 10 });
#	for my $status ( @$statuses )
#	{
#		my $id = $status->{id};
#		my $created = $status->{created_at};
#		my $text = $status->{text};
#		my $reply_to_username = $status->{in_reply_to_screen_name};
#		my $reply_to_id = $status->{in_reply_to_status_id};
#
#		if(defined($reply_to_username) && $text=~m/^@/)
#		{
#			# Skip direct replies
##			print qq(Skipping $text\n);
#			next;
#		}
#		else
#		{
##			print qq(Keeping $text\n);
#		}
#
#		my ($year, $mon, $day, $hh, $mm, $ss) = GetDateTimeFromTwitterTimestamp($created);
#
#		my $foam_id = GetYYYYMMDD_0_HHMMSS($year, $mon, $day, $hh, $mm, $ss);
#
#		my $contents = '';
##		$contents.=qq(<p class="comments_0"><a href="javascript:HaloScan('$foam_id');" target="_self"><script type="text/javascript">postCount('$foam_id');</script></a></p>);
##		$contents.=qq(<span class="twitter">);
#		$contents.=Twitterize($text);
#		$contents.=" <i>(at ".sprintf("%2d:%02d", $hh,$mm).")</i>";
##		$contents.=qq(</span>);
#		if(defined($reply_to_username))
#		{
#			$contents.=qq(<span class="twitreply">);
#			$contents.=qq(<a href="http://twitter.com/$reply_to_username/status/$reply_to_id">(in reply to $reply_to_username)</a>);
#			$contents.=qq(</span>\n);
#		}
#
#		#
#		# If the file exists, then open it up and read it in for editing
#		#
#		open PHFILE, ">/home/www/html/daily/$foam_id.ph" or die $! . ": $foam_id";
#		print PHFILE $contents;
#		close PHFILE;
#
#		if(($last_year && $last_year!=$year) || ($last_mon && $last_mon!=$mon))
#		{
#			Foam::UpdateHTML('/home/www/html/daily', $last_year, $last_mon);
#		}
#		$last_year = $year;
#		$last_mon = $mon;
#	}
#
#	if($last_year && $last_mon)
#	{
#		Foam::UpdateHTML('/home/www/html/daily', $last_year, $last_mon);
#	}
#};
##warn "$@\n" if $@;
#
##
## $monthnum = FromShortMonth("Mon")
##
#sub FromShortMonth
#{
#	my $monstr = shift;
#
#	my %months =
#	(
#		'Jan' =>  1,
#		'Feb' =>  2,
#		'Mar' =>  3,
#		'Apr' =>  4,
#		'May' =>  5,
#		'Jun' =>  6,
#		'Jul' =>  7,
#		'Aug' =>  8,
#		'Sep' =>  9,
#		'Oct' => 10,
#		'Nov' => 11,
#		'Dec' => 12
#	);
#
#	return $months{$monstr};
#}
#
#sub GetDateTimeFromTwitterTimestamp
#{
#	# Sat Jan 24 22:14:29 +0000 2009
#	my @parts = split /[ :]/, shift;
#
#	my $mon = FromShortMonth($parts[1]);
#	my $day = $parts[2];
#	my $hh = $parts[3];
#	my $mm = $parts[4];
#	my $ss = $parts[5];
#	my $year = $parts[7];
#
#	my $x;
#	my $time = timegm($ss,$mm,$hh,$day,$mon-1,$year);
#	($ss,$mm,$hh,$day,$mon,$year,$x,$x,$x) = localtime($time);
#	$mon+=1;
#	$year+=1900;
#
#	return ($year, $mon, $day, $hh, $mm, $ss);
#}
#
#sub GetYYYYMMDD_0_HHMMSS
#{
#	my ($year, $mon, $mday, $hh, $mm, $ss) = @_;
#	return sprintf("%04d%02d%02d_0_%02d%02d%02d", $year, $mon, $mday, $hh, $mm, $ss);
#}
#
#sub Twitterize
#{
#	my $text = shift;
#
#	$text =~ s{(http://[^ ]+)}{<a href="$1">$1</a>}g;
#	$text =~ s{@([^ ][^ ]+)}{<a href="http://twitter.com/$1">@$1</a>}g;
#
#	return $text;
#}
-->

<generator uri="http://www.google.com/reader">
Google Reader
</generator>

<id>
tag:google.com,2005:reader/user/03605314877498906387/state/com.google/broadcast
</id>

<link rel="hub" href="http://pubsubhubbub.appspot.com/"/>

<title>
Shannon's shared items in Google Reader
</title>

<gr:continuation>
CN693IKlq50C
</gr:continuation>

<link rel="self" href="http://www.google.com/reader/atom/user/03605314877498906387/state/com.google/broadcast"/>

<author>

<name>
Shannon
</name>

</author>

<updated>
2009-11-22T04:05:44Z
</updated>

<entry gr:crawl-timestamp-msec="1258862744688">

	<id gr:original-id="">
	tag:google.com,2005:reader/item/f7e5c7377b690a3e
	</id>

	<category term="user/03605314877498906387/source/com.google/link" scheme="http://www.google.com/reader/" label="link"/>

	<category term="user/03605314877498906387/state/com.google/broadcast" scheme="http://www.google.com/reader/" label="broadcast"/>

	<category term="user/03605314877498906387/state/com.google/read" scheme="http://www.google.com/reader/" label="read"/>

	<category term="user/03605314877498906387/state/com.google/starred" scheme="http://www.google.com/reader/" label="starred"/>

	<category term="user/03605314877498906387/state/com.google/fresh" scheme="http://www.google.com/reader/" label="fresh"/>

	<title type="html">
	Art Nouveau Slave Leia by *AdamHughes on deviantART
	</title>

	<published>
	2009-11-22T04:05:44Z
	</published>

	<updated>
	2009-11-22T04:05:44Z
	</updated>

	<link rel="alternate" href="http://unpoco.tumblr.com/post/246808948" type="text/html"/>

	<link rel="related" href="http://unpoco.tumblr.com/" title="Unpolitically correct"/>

	<content xml:base="http://unpoco.tumblr.com/post/246808948" type="html">
		&lt;blockquote&gt;Shared by  Shannon
		&lt;br&gt;
		Awesome&lt;/blockquote&gt;

		&lt;img src="http://1.media.tumblr.com/tumblr_kt74ubkVjo1qznthto1_500.jpg"&gt;&lt;br&gt;&lt;br&gt;&lt;p&gt;&lt;a href="http://adamhughes.deviantart.com/art/Art-Nouveau-Slave-Leia-91409621"&gt;Art Nouveau Slave Leia by *AdamHughes on deviantART&lt;/a&gt;&lt;/p&gt;
	</content>

	<author gr:unknown-author="true">

	<name>
	(author unknown)
	</name>

	</author>

	<gr:annotation>

		<content type="html">
		Awesome
		</content>

		<author gr:user-id="03605314877498906387" gr:profile-id="103104079397182944597">

		<name>
		Shannon
		</name>

		</author>

	</gr:annotation>

	<source gr:stream-id="user/03605314877498906387/source/com.google/link">

	<id>
	tag:google.com,2005:reader/user/03605314877498906387/source/com.google/link
	</id>

	<title type="html">
	Unpolitically correct
	</title>

	<link rel="alternate" href="http://unpoco.tumblr.com/" type="text/html"/>

	</source>

</entry>

<entry gr:crawl-timestamp-msec="1258862550233">

	<id gr:original-id="">
	tag:google.com,2005:reader/item/959e4ad067f66359
	</id>

	<category term="user/03605314877498906387/source/com.google/post" scheme="http://www.google.com/reader/" label="post"/>

	<category term="user/03605314877498906387/state/com.google/broadcast" scheme="http://www.google.com/reader/" label="broadcast"/>

	<category term="user/03605314877498906387/state/com.google/read" scheme="http://www.google.com/reader/" label="read"/>

	<category term="user/03605314877498906387/state/com.google/starred" scheme="http://www.google.com/reader/" label="starred"/>

	<category term="user/03605314877498906387/state/com.google/fresh" scheme="http://www.google.com/reader/" label="fresh"/>

	<title type="html">
	Blah blah blah
	</title>

	<published>
	2009-11-22T04:02:30Z
	</published>

	<updated>
	2009-11-22T04:02:30Z
	</updated>

	<link rel="alternate" href="http://www.google.com/reader/item/tag:google.com,2005:reader/item/959e4ad067f66359" type="text/html"/>

	<link rel="related" href="http://www.google.com/reader/shared/03605314877498906387"/>

	<content xml:base="http://www.google.com/reader/item/tag:google.com,2005:reader/item/959e4ad067f66359" type="html">
		Blah blah blah
	</content>

	<author>

	<name>
	Shannon
	</name>

	</author>

	<source gr:stream-id="user/03605314877498906387/source/com.google/post">

	<id>
	tag:google.com,2005:reader/user/03605314877498906387/source/com.google/post
	</id>

	<title type="text">
	(title unknown)
	</title>

	<link rel="alternate" href="http://www.google.com/reader/shared/03605314877498906387" type="text/html"/>

	</source>

</entry>

<entry gr:crawl-timestamp-msec="1258832661185">

	<id gr:original-id="http://unpoco.tumblr.com/post/246514604">
	tag:google.com,2005:reader/item/09d0fcc16fd13da7
	</id>

	<category term="user/03605314877498906387/state/com.google/broadcast" scheme="http://www.google.com/reader/" label="broadcast"/>

	<category term="user/03605314877498906387/state/com.google/read" scheme="http://www.google.com/reader/" label="read"/>

	<category term="user/03605314877498906387/state/com.google/fresh" scheme="http://www.google.com/reader/" label="fresh"/>

	<category term="hand"/>

	<title type="html">
	Signalnoise.com
	</title>

	<published>
	2009-11-16T23:55:49Z
	</published>

	<updated>
	2009-11-16T23:55:49Z
	</updated>

	<link rel="alternate" href="http://unpoco.tumblr.com/post/246514604" type="text/html"/>

	<summary xml:base="http://unpoco.tumblr.com/" type="html">
		&lt;img src="http://4.media.tumblr.com/tumblr_kt747pZeuj1qznthto1_500.jpg"&gt;&lt;br&gt;&lt;br&gt;&lt;p&gt;&lt;a href="http://blog.signalnoise.com/?p=1883"&gt;Signalnoise.com&lt;/a&gt;&lt;/p&gt;
	</summary>

	<author gr:unknown-author="true">

	<name>
	(author unknown)
	</name>

	</author>

	<source gr:stream-id="feed/http://unpoco.tumblr.com/rss">
		<id>
		tag:google.com,2005:reader/feed/http://unpoco.tumblr.com/rss
		</id>

		<title type="html">
		Unpolitically correct
		</title>

		<link rel="alternate" href="http://unpoco.tumblr.com/" type="text/html"/>
	</source>

</entry>

<entry gr:crawl-timestamp-msec="1258832641582">

<id gr:original-id="http://unpoco.tumblr.com/post/246808948">
tag:google.com,2005:reader/item/98f29742d54ca168
</id>

<category term="user/03605314877498906387/state/com.google/broadcast" scheme="http://www.google.com/reader/" label="broadcast"/>

<category term="user/03605314877498906387/state/com.google/read" scheme="http://www.google.com/reader/" label="read"/>

<category term="user/03605314877498906387/state/com.google/starred" scheme="http://www.google.com/reader/" label="starred"/>

<category term="user/03605314877498906387/state/com.google/fresh" scheme="http://www.google.com/reader/" label="fresh"/>

<title type="html">
Art Nouveau Slave Leia by *AdamHughes on deviantART
</title>

<published>
2009-11-17T03:58:53Z
</published>

<updated>
2009-11-17T03:58:53Z
</updated>

<link rel="alternate" href="http://unpoco.tumblr.com/post/246808948" type="text/html"/>

<summary xml:base="http://unpoco.tumblr.com/" type="html">
&lt;img src="http://1.media.tumblr.com/tumblr_kt74ubkVjo1qznthto1_500.jpg"&gt;&lt;br&gt;&lt;br&gt;&lt;p&gt;&lt;a href="http://adamhughes.deviantart.com/art/Art-Nouveau-Slave-Leia-91409621"&gt;Art Nouveau Slave Leia by *AdamHughes on deviantART&lt;/a&gt;&lt;/p&gt;
</summary>

<author gr:unknown-author="true">

<name>
(author unknown)
</name>

</author>

<gr:likingUser>
04157312489260547510
</gr:likingUser>

<source gr:stream-id="feed/http://unpoco.tumblr.com/rss">

<id>
tag:google.com,2005:reader/feed/http://unpoco.tumblr.com/rss
</id>

<title type="html">
Unpolitically correct
</title>

<link rel="alternate" href="http://unpoco.tumblr.com/" type="text/html"/>

</source>

</entry>

<entry gr:crawl-timestamp-msec="1258000993056">

<id gr:original-id="http://www.pinktentacle.com/?p=4360">
tag:google.com,2005:reader/item/263e341bbf872ee0
</id>

<category term="user/03605314877498906387/state/com.google/broadcast" scheme="http://www.google.com/reader/" label="broadcast"/>

<category term="user/03605314877498906387/state/com.google/like" scheme="http://www.google.com/reader/" label="like"/>

<category term="user/03605314877498906387/state/com.google/read" scheme="http://www.google.com/reader/" label="read"/>

<category term="user/03605314877498906387/state/com.google/fresh" scheme="http://www.google.com/reader/" label="fresh"/>

<category term="Art/Culture"/>

<category term="Art"/>

<category term="Monster"/>

<category term="Paranormal"/>

<category term="Yokai"/>

<title type="html">
Anatomy of Japanese folk monsters
</title>

<published>
2009-10-14T07:05:35Z
</published>

<updated>
2009-10-14T07:05:35Z
</updated>

<link rel="alternate" href="http://feedproxy.google.com/~r/PinkTentacle/~3/LCu8UlVx6gE/" type="text/html"/>

<content xml:base="http://pinktentacle.com/" type="html">
&lt;p&gt;&lt;em&gt;Yo-kai Daizukai&lt;/em&gt;, an illustrated guide to yo-kai authored by manga artist Shigeru Mizuki, features a collection of cutaway diagrams showing the anatomy of 85 traditional monsters from Japanese folklore (which also appear in Mizuki’s &lt;a href="http://en.wikipedia.org/wiki/GeGeGe_no_Kitaro"&gt;GeGeGe no Kitaro-&lt;/a&gt; anime/manga). Here are a few illustrations from the book.&lt;/p&gt;

&lt;p align="center"&gt;&lt;img src="http://www.pinktentacle.com/images/yokai_daizukai_2.jpg" alt="Kurokamikiri anatomical illustration from Shigeru Mizuki&amp;#39;s Yokai Daizukai -- "&gt;&lt;br&gt;&lt;em&gt;Kuro-kamikiri&lt;/em&gt; [&lt;a href="http://www.pinktentacle.com/images/yokai_daizukai_2_large.jpg"&gt;+&lt;/a&gt;]&lt;/p&gt;




javascript:var b=document.body;
var GR________bookmarklet_domain='https://www.google.com';
if(b&&!document.xmlVersion){void(z=document.createElement('script'));
void(z.src='https://www.google.com/reader/ui/link-bookmarklet.js');
void(b.appendChild(z));
}else{}