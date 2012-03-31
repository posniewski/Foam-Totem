%$Title="Deadlines";
%$Date="27 Aug 1997";

%StdFoamTotemHTMLStart;
%StdFoamTotemBodyStart;
%StdFoamTotemContentStart;

%$makepara=1;

As many of you know, the company I work for (RSSI) had a major deadline
on Monday. Actually, our deadline was July 31st. But we missed it. Our
REAL deadline was Monday at noon. We didn't make this deadline, either;
we missed it by about 30 hours or so.

This is not catastrophic, luckily. We're OK, assuming that the chip
which we just created is functional. The tests we've run make it seem
like it should be. Of course, those are only simulations of what the
chip will do. Nonetheless, I'm pretty confident.

The hardware development universe is much different that software. (I've
talked to some of you about this before, so this may be a repeat-- just
skip to the end.) In software, there are deadlines. So what. Generally,
software gets up to a running state and is modified over time. Features
are added, bugs are fixed, etc. to a running system. In fact, one of our
cardinal rules is that you only "put back" code which works. So, if
reach a deadline, and you just HAD to get something out the door, you
could do it. It may not be pretty, and it may not be in the long-term
best interests of the company, but you have SOMETHING.

With hardware, you have nothing. Much hardware is designed in a
programming language like C (except without even C's feeble typing).
This code is run in a simulator, which knows the C-like language and
does the simulation dance. Once you get this code working, you have
nothing. This is because this high-level language is not AND, OR, and
NOT gates, which are what you put on chips.

So, you run this C-like language through a process called synthesis. The
synthesis tool costs $50K, so you buy only one, and it is copy
protected. It runs on Sun Solaris. It takes your code, and turns it into
gates. Or, it turns it into garbage. It will turn your code into garbage
if you wrote something which is "un-synthesizable" or if you run across
one of its bugs.

When I found this out I was stunned. Imagine if your C++ compiler, got
half way through your source files and said, "Oooo, I don't know how to
do that!" What you wrote is syntactically and semantically correct, but
it is actually UNREALIZABLE in the language of gates. What IDIOT created
a language for hardware design which can represent unrepresentable
things?! AHHHHHH!

Anyway, these syntheses take a long time. A very long time. Days of
continuously running. Because the tool is so expensive, you can't split
the task up on multiple machines. Pain. Pain. You sit there watching the
clock spin towards the deadline and there is nothing you can do but
wait. (Of course, as a basically  useless software guy, I got to watch
other useful people go insane.)

[I see this missive is getting long, so I'll skip some of the other
random crap which you need to do. Like getting your files in a format
which can be read by someone else so that they can actually make the
chip, but they have no spec as to how to do this. Like determining
propagation times along wires using the wire's length, material, etc.
Etc., etc.]

SO...

Once you do all of this, you STILL HAVE NOTHING. You need to verify that
all of these generated gates work like your high-level code, so you run
all your simulations again. And again. And run them on a magic device
which emulates things better. And so on. Ahhhhh!

Now, you can take the final product of all of this (it's called a
net-list) and send it away, not to be seen for 6 weeks. During this
time, you design a board (or finish the design of the board) and write
the programs which will drive the chip (i.e. device drivers). (Of
course, doing this without the actual hardware is a joy.) Then a piece
of silicon in a package comes back. You plug it in on your board. And
put it in a computer. You flip the computer on, and...

Hopefully you don't have a brick. (Chips which don't work are called
"bricks.")

Fall COMDEX is the reason for our deadline. We need to show something
then. It is left as an exercise to the reader to figure out how close
we're cutting it. 6 weeks for silicon, 2 weeks for layout, some time to
finalize timing, a bit for testing...

We've finished our first pass at a net-list just ten minutes ago.
There's more to do, but for now the strong pressure is off. And we are
breathing, eating, and sleeping again.

poz

%StdFoamTotemContentEnd;
%StdFoamTotemBodyEnd;
%StdFoamTotemHTMLEnd;
