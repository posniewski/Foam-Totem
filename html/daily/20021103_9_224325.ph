Still working on the email indexer, which I've named Haystack. It's basically functional, but every time I add a feature I can see four others which I think would be cool. It does full text indexing of the content as well as the various email headers.

Right now, I'm focussing on getting it to work for my email environment (although I think it should be readily usable for any IMAP-based email account). I use MS Outlook and all my email is on an MS Exchange server. Luckily, work runs an IMAP server on the Exchange database as well.

I can get to the data (via IMAP and perl), but that doesn't let me connect the indexer direcly to my mail client. I want to be able to click on a message link and have it open in Outlook. I can get it to pop up any message I want assuming that the message has a unique subject (outlook://[server]/[user]/[folder]/~[subject] Try it!). Any email discussion has multiple messages with the same subject, though.

So, that'll never work in practice. I had to write a web mail message viewer to view individual messages. This is not trivial, but didn't seem very hard. I have code which works 100% for me, but I'm guessing that it is only 85% of all possible cases. The last 15% of cases are probably really nasty. Since they don't occur in my system, I'll probably not address them beyond a "TODO:" in the code.