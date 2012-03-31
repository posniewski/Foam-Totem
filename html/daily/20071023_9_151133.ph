For the love of all that is holy, the Naked Programmer Cam is working again.

All sorts of fun with configuration. I don't know why, but I could no longer FTP using the same config I had before. Back in May or thereabouts, some haxxor was banging on the ftp door constantly. They weren't getting in, but just the trying was problematic. So, I just shut FTP down (since the ProgCam was off anyway).

So, when I decided to set up the cam again, I uncommented the line which shut it off and VOILA! It didn't work. Long story short, the address Foam Totem was giving to FTP clients was its internal one and not the external one and so they couldn't talk to me. I had to add a couple config lines to tell it to give a different address and it works now. I have no idea how it worked before, honestly, unless my firewall was stateful and fixing up those packets.

Anyway, you are now free to look at the back of my head. Enjoy.
<p style="text-align:right;font-size:10px;clear:right"><a href="javascript:HaloScan('20071023_9_151133');" target="_self"><script type="text/javascript">postCount('20071023_9_151133');</script></a></p>