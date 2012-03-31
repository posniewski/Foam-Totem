The Foam Totem server was haxxored sometime in December. There was a user with a common name and an apparently weak password, which was used to get into the system via ssh (secure shell). I do not know how they got in further after that, but they were eventually able to log in as root.

There's no damage to any user data files as far as I can tell. There are traces of hacked OS and application stuff here and there: directories which shouldn't exist, a user added which shouldn't be there, baffling entries in the shell history, and so on. I have shut down everything naughty I have found and have shut off remote shell access (which is how they got in). (Sorry, Snuffy.)

I have backed up all user data to my personal computer just in case there's some kind of time bomb in there.

<i>Sigh</i>

Anyway, the server will need to be wiped and rebuilt. I don't have the gumption to do it now; it's a full day of effort or so. Everything seems safe now, but after being compromised, nothing can be trusted forever. I'll get to it soon. I don't expect anyone will lose any data even if they add it from now on (like Popplers), but I wanted to give the warning.

<p style="text-align:right;font-size:10px;clear:right"><a href="javascript:HaloScan('20060108_9_165116');" target="_self"><script type="text/javascript">postCount('20060108_9_165116');</script></a></p>
