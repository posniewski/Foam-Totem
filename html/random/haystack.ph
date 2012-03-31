%$Title="Haystack";
%$Date="7 Nov 2002";

%StdFoamTotemHTMLStart;
%StdFoamTotemBodyStart;
%StdFoamTotemContentStart;

%makepara=0;

<p>
I've been writing an email-oriented full-text search engine. Well, the 
interface, really. I'm using Swish-E as the actual search engine. 
(It's really nice.)
<p>
Here are a couple shots of the front end. (Excuse the colors, they're the closest ones GIF had.) This is a search for "coefficient."
<p>
<img src="./haystack_1.gif" border="0" align="center">

<p>
Nearly everything on this page is live. Clicking on the title of a hit will
bring up the message itself. Clicking on "[thrd]" returns all messages
with that subject (ignoring the leading FW: and RE:). 
Clicking on any of the names on the right returns all the messages from that person.
Can you guess what clicking on the date does? Yup, you guessed it.
Here is what I got when I clicked on the date on the first hit: "23 Oct 2002."
<p>
<img src="./haystack_2.gif" border="0" align="center">

<p>
Haystack lets you search on date spans (as is evident by the above picture). Well, Swish does the work. I just provide the data.

<p>
Moving on, here's an example of clicking on [thrd]. I can imagine having a tiny calendar at the top of this page which shows the dates of the hits. Actually, I think the calendar idea would work for regular searches as well. A mock-up is on the way.
<p>
<img src="./haystack_3.gif" border="0" align="center">

<p>
When I say everything is active, I mean everything is active.
This is a shot of an email message found in Haystack by subject.
Using the mouse, I can select any text ("Expolratorium") and it automatically gets entered into the search box. (Also note how all the names, the date, and the subject are also linked.)

<p>
<img src="./haystack_4.gif" border="0" align="center">

<p>
Features to be added:
<ul>
<li>Hyperbolic/exponential overview celendar of hits.
<li>Option to refine search rather than re-search when clicking on a link or making a text selection.
<li>Better summarization.
<li>Condensed display for threads and searches which collate all the participants.
<li>Many, many more
</ul>


%StdFoamTotemContentEnd;
%StdFoamTotemBodyEnd;
%StdFoamTotemHTMLEnd;
