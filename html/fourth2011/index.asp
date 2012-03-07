<%@ LANGUAGE = PerlScript %>
<!doctype html>
<html>
	<!-- This page is part of the FoamTotem web site. -->
<head>
<title>Fourth of July Mad Lib</title>
<style type="text/css">
/* http://meyerweb.com/eric/tools/css/reset/
   v2.0b1 | 201101
   NOTE: WORK IN PROGRESS
   USE WITH CAUTION AND TEST WITH ABANDON */

html, body, div, span, applet, object, iframe, p, blockquote, pre, a, abbr, acronym, address, big, cite, code, del, dfn, em, img, ins, kbd, q, s, samp, small, strike, strong, sub, sup, tt, var, b, u, i, center, dl, dt, dd, ol, ul, li, fieldset, form, label, legend, table, caption, tbody, tfoot, thead, tr, th, td, article, aside, canvas, details, figcaption, figure, footer, header, hgroup, menu, nav, section, summary, time, mark, audio, video
	{ margin: 0; padding: 0; border: 0; outline: 0; font-size: 100%; font: inherit; vertical-align: baseline; }

h1, h2, h3, h4, h5, h6
	{ padding: 0; }

article, aside, details, figcaption, figure, footer, header, hgroup, menu, nav, section { display: block; }

body { line-height: 1; }
ol, ul { list-style: none; }
blockquote, q { quotes: none; }
blockquote:before, blockquote:after, q:before, q:after { content: ''; content: none; }

a:focus { outline: thin dotted #666666; }

ins { text-decoration: none; }
del { text-decoration: line-through; }

table { border-collapse: collapse; border-spacing: 0; }

/* *********************************************************************** */

code, pre {
	font: .75em/1.1em "Lucida Console","Courier New", monospace;
	width:600px;
}

p {
	margin: 1em 0px;
}

p:first-child {
	margin-top: 0px;
}

blockquote, q {
	margin: 1em 40px;
}

/* *********************************************************************** */

body {
	font: 1.5em/1.6em "Courier New";
	background-color: #D8BF93;
	color: black;
}

a:visited { color: #703017; text-decoration: none; }
a:link { color: #703017; text-decoration: none; }
a:hover { color: white; background-color: #703017; }

h1, h2, h3, h4, h5 {
	margin: 0 auto;
	text-align: center;
}

h1 {
	font: 2em;
	margin: 5px;
}

h4 {
	line-height: 1em;
}

.rep {
	font-family: "Lucida Handwriting",
	"Comic Sans MS", cursive;

	color: rgb(20,20,200);
}

.all {
	width: 850px;
	margin: 0 auto;
	position: relative;
/*	background-image: url('/images/paper_crumple_tile.jpg'); */
	background-color: #FCFCF1;

	padding: 10px;

	-moz-box-shadow: 5px 5px 5px #8E743E;
	-webkit-box-shadow:  5px 5px 5px #8E743E;
	box-shadow:  5px 5px 5px #8E743E;
	margin-bottom: 5px;
}

.content {
	width:850px;
	padding: 10px;
}
</style>
</head>

<body>

<%
	use strict;

	my $path = $Request->ServerVariables('SCRIPT_FILENAME');
	$path =~ s/[\/\\](\w*\.asp\Z)//m;
	# make path to look at


	my $story = <<'EOF';
<div class="all">
<h4>Ladies and [plural noun],</h4>
<h4>You're needed at the</h4>
<h2>[adj]</h2>
<h4>n+20th Annual</h4>
<h3>4th of July</h3>
<h1>[noun] [verb]</h1>

<h4>To be held at Twin Trees</h4>
<h4>as is the custom</h4>
<h3>2 July to 10 July</h3>
<h3>2011</h3>

<div class="content">
<p>As always, we will be [verb with -ing] so make sure you bring your [noun]. [Person in the group] is expressly prohibited from eating [plural noun] due to the “incident” last year. I fear that the blackflies, [plural noun], and no-see-ums will be [adjective] because it [past tense verb] so much in the Spring. On the plus side, I doubt the [adjective] [verb with -ing] sound will be heard this year.

<p>[Other person in group] mentioned that they were going to [verb] a [adjective] [noun: drink] in celebration of this 20th anniversary. I hope it works out better than the [adj] [noun: food] from a few years ago. Perhaps [Another person in group] will [verb] us with tales from their recent trip to [proper noun: location].

<p>[Yet another person in group] is expected to say they will be [verb with -ing], but we all know that they will instead [verb]. And not tell us.

<p>Apologies for the late announcement, my time was taken up [verb with -ing] with [public figure].
</div>

<h3>See You Soon!</h3>

<h5>Print this out and bring it with you!</h5>
</div>
EOF

%>

<br>

<%
	my $i = 0;

	my $val = $Request->Form('0');

	if(!$val) {
		print qq(<center>);
		print qq(<form method="POST" action="./index.asp">);
		while($story =~ /\[(.*?)\]/g) {   #Find anything in []
			print qq($1: <textarea name="$i" cols=30 rows=1></textarea><br>);
			$i++;
		}
		print qq(<input type="submit" value="Go MAD!">);
		print qq(</form>);
		print qq(</center>);
	}
	else
	{
		while($story =~ /\[(.*?)\]/g) {   #Find anything in []
			my $val = $Request->Form($i);
			$story =~ s/\[$1\]/<span class="rep">$val<\/span>/;
			$i++;
		}
		print $story;
	}

%>

</body>
</html>
