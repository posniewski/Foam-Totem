How hard can making an email indexer be? Not very, as it turns out. Using Perl (using Mail::IMAPClient), I connected up to my Exchange server via an IMAP server it runs. I sucked out all my email into individual files to my disk, dropping all non-html and text portions of the emails (e.g. attachments). (38 lines of code total.) Then I used <a href="ww.namazu.org">Namazu</a> to index the mail files (which are all rfc822).

I copied a couple files into the Apache cgi-bin, and poof! searchable email. Another 25 lines of perl code lets me link the search results to the original email (instead of the downloaded copy).

Namazu has a few things lacking. I might go to <a href="http://webglimpse.org">Glimpse</a> (or some other search engine), but I need to figure out how it handles fields. 