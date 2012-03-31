Hell, damnation, blast, woe, anger, and hate. And if Stephen Fry were here he'd throw in a thrice-damned arse. Comcast has blocked inbound port 25 to foamtotem.org. Which means that I can't receive email via SMTP. Which means Foam Totem gets no email.

It is true that port 25 outbound should likely be blocked for client accounts.  It's unauthenticated and easy to spam that way. Instead, you use port 587 for message submissions (it's authenticated and specifically for injecting messages into the email 'verse).

Blocking inbound ports doesn't do anything, unless those ports are hooked up to bad software. Examples of good things to block happen to be things that Microsoft wrote: SMB (file system) and SQL Server.

I can't think of any good reason to block inbound 25, though. Sigh. Security Theater has now jumped from the TSA to my ISP.

For now, I have all foamtotem mail being bounced to another externally accessible account. If the apocalypse is upon us (and it really seems like it is) then I'll end up using fetchmail I guess. I can't bring myself to get a "commercial account" which is exactly the same except for the price and what ports aren't blocked.

<p class="comments"><a href="javascript:HaloScan('20090309_9_004530');" target="_self"><script type="text/javascript">postCount('20090309_9_004530');</script></a></p>