Stupid web-people singing the praises of semantic-this and stylesheet-that: Shut. Up.

Can someone give me a sound reason for switching Foam Totem over to using CSS? It's layout is currently done with tables [sharp intake of breath from the crowd, followed by a concerned and partially outraged susurration]. I started to look at it today because it doesn't render superbly on the iPhone. But boy what a pain.

For example, there are separators between the menu items at the top of the page. Only between, not in front of each. OK, so in CSS you define a background image (you can't simply define it as a "-" character) to go in front of each item and then mark the first list item with a special class and then NOT show it on that one. Oh, and fix up the margin, which is now wrong on that one. Cool, that works. But somehow, the five CSS selector rules require to do that seems like overkill compared to simply PUTTING DASHES IN THE DAMN TEXT.

Don't even get me started on horizontally centering. That's practically magic if you want it to handle variously sized windows. Now you know why 90% of web sites today have basically a fixed width for their content.

So, forget it. I'll start again from scratch and instead modify with CSS the existing table-based layout I have so it displays on small screens better.

(Incidentally, Foam Totem renders well at practically all screen sizes. BUT, the iPhone assumes a pixel width for pages which don't force one. They do this because most pages have fixed-widths and the look like vomit if they don't pretend the screen is wider. Soooo, my happily and safely reflowing web site ends up with a crappy experience because of it.)

OK, done now. The next rant is going to be about iTunes. Competitors to Apple take note: iTunes is the chink in their armor.

<p style="text-align:right;font-size:10px;clear:right"><a href="javascript:HaloScan('20090110_9_172120');" target="_self"><script type="text/javascript">postCount('20090110_9_172120');</script></a></p>