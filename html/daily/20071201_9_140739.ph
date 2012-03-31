There are a lot of computer languages out there, and I'm largely agnostic about them. Most are somehow the same at some level (with the exception of the willfully obtuse ones). Syntax isn't unimportant, but the basic facilities of the language are more important.

Cryptic Studios writes practically everything in C. In addition, we support evaluating expressions provided at runtime. The combat system in particular uses these expressions for calculating damage and duration of effects. The alternative to using data-driven expressions is to compile them directly into the code. This makes simple changes to the combat system much more difficult to test (and therefore fix rapidly).

I wrote the expression evaluator used in City of Heroes/Villains. It was a very simple, Forth-like stack machine. I chose this approach because I wanted to spend the minimum time writing the code for it. At that point in the project there was really only a single use for it (badges), so I didn't try to make it nice. Stack machines aren't easy on the uninitiated; they are postfix. But it was extensible, could support C functions and so on, and the implementation was dead simple.

I have found that often wanted more than this simple evaluator. I've wanted a little more oomph. I have realized that there are some features which are very cool to have in a small utility language.

And that's the point of this post: to list the things one needs from an evaluator. (And I know that 98% of you don't care about this.)

A simple evaluator needs to have this:
<ul>
<li>All standard C expressions. Duh.
<li>Automatic type conversion from string to int to float and back.
<li>Natively understands strings. Can concatenate, split, etc.
<li>It must be easy to export and use variables and functions from C to the evaluator.
<li>Argument count and type checking.
<li>Bullet-proof. If a function doesn't exist, the syntax is wrong, or something goes haywire, the evaluation must still properly terminate. So, no loops.
<li>If...else
</ul>

Probably useful
<ul>
<li>Variables. It turns out that you need access to read C variables much more than you need your own variables in the eval or write to C variables. (Especially if it's a stack machine since the stack is actually a bunch of variables.)
</ul>

Things which are scary but oh so useful
<ul>
<li>Loops. Here begins the possibility for infinite loops and thus bullet-proofness is harder.
<li>Able to self-eval. An expression should be able to construct another expression as a string which is then evaluated.
</ul>

A useful full language further needs
<ul>
<li>Arrays
<li>Hash tables. How did I ever live without these as a basic data type? There is very little cooler than Stuff["Hat"] = "Touque".
<li>Anonymous/lambda functions. sort(list, { a.field - b.field })
</ul>

(The above is a lot of shorthand too.)

<p style="text-align:right;font-size:10px;clear:right"><a href="javascript:HaloScan('20071201_9_140739');" target="_self"><script type="text/javascript">postCount('20071201_9_140739');</script></a></p>