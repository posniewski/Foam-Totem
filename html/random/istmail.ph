%$Title="Image Systems Email";
%$Date="18 Nov 99";

%StdFoamTotemHTMLStart;
%StdFoamTotemBodyStart;
%StdFoamTotemContentStart;

%makepara=0;

<p>
I was looking through my old Image Systems files in search of information
about Manhattan (a file system/document management system which used database
queries instead of a standard directory structure). Strangely, I can't find 
anything from the work I did on Manhattan. However, I have a slew of memos 
I've written 
(flames, status reports, etc.) and a lot of my email. 
</p>
<p>
I have no email from 
before mid 1992, unfortunately, and a obviously pruned my email in the 
following years. One thing I noticed is that I used to communicate <u>a lot</u> 
by email. Not just important status crap, but everyday work.
</p>
<p>
I have totally forgotten about a lot of things from back then. Although I
have only one example here, I did a lot of managment at the end of my career
at IST. You can sense the difference in tone between the status reports
at the end and a couple years earlier.
</p>
<p>
Just to throw you on the wayback machine, then, here's a couple 
representative samples.
</p>
<p>
I did this a while ago with stuff which reflected the changes at Image 
Systems. This time, I try to show the day to day activities. This time, all 
the mail was sent by myself.
</p>
</p>


<a name="top">
<table width="100%" border="1">
<tr>
<td width="30%"><font size="1">alicia, jpr</font></td>
<td width="50%"><font size="1"><a href="1">feexes</font></a></td>
<td width="20%"><font size="1">Mon 10 Aug 92 20:38</font></td>
</tr>
<tr>
<td><font size="1">bohley</font></td>
<td><font size="1"><a href="2">All of those nasty 00co* files.</a></font></td>
<td><font size="1">Thu 13 Aug 92 19:26</font></td>
</tr>
<tr>
<td><font size="1">djk@rover</font></td>
<td><font size="1"><a href="3">Slash Commands</a></font></td>
<td><font size="1">Thu 3 Sep 92 15:30</font></td>
</tr>
<tr>
<td><font size="1">cjk@imagesys.com</font></td>
<td><font size="1"><a href="4">ug!</a></font></td>
<td><font size="1">Thu 17 Sep 92 15:35</font></td>
</tr>
<tr>
<td><font size="1">alicia, smb, mfb, cjk</font></td>
<td><font size="1"><a href="5">Billions and billions of IREF and ROPS</a></font></td>
<td><font size="1">Tue 1 Dec 92 20:03</font></td>
</tr>
<tr>
<td><font size="1">dmg, gam, smb, alicia, eh, mfb, jpr, cjk</font></td>
<td><font size="1"><a href="6">GSX 2.0 Development Info Letter #7</a></font></td>
<td><font size="1">Mon 7 Dec 92 10:20</font></td>
</tr>
<tr>
<td><font size="1">dmg, gam, smb, alicia, eh, mfb, jpr, cjk</font></td>
<td><font size="1"><a href="7">Dev non-Release F of GSX 2.0</a></font></td>
<td><font size="1">Mon 7 Dec 92 10:23</font></td>
</tr>
<tr>
<td><font size="1">dmg, gam, smb, alicia, eh, mfb, jpr, cjk, kgb, mbd</font></td>
<td><font size="1"><a href="8">GSX rev C</a></font></td>
<td><font size="1">Thu 25 Mar 1993 11:51</font></td>
</tr>
<tr>
<td><font size="1">jjr (John J. Racz), joh (Jim Harrigan)</font></td>
<td><font size="1"><a href="9">Dangerous Grass</a></font></td>
<td><font size="1">Wed 12 May 1993 21:57</font></td>
</tr>
<tr>
<td><font size="1">development</font></td>
<td><font size="1"><a href="10">Programming Update</a></font></td>
<td><font size="1">Mon 15 Nov 1993 23:00</font></td>
</tr>
<tr>
<td><font size="1">dap@softdesk.com</font></td>
<td><font size="1"><a href="11">CAD Overlay and RasterCore team status</a></font></td>
<td><font size="1">Fri 15 Jul 1994 17:15</font></td>
</tr>
</table>


<pre>
<a name="1">
Date: Mon, 10 Aug 92 20:38:10 EDT
To: alicia, jpr
Subject: feexes

Oh Tay, 

I have hopefully fixed the entity caching bugs.  The changes have been 
put back.  I've been using them with rev X since about 3:30pm Monday with
no problem.  (Including flushes, etc.)

Plotting without an image pasted was tough, but I think I fixed it.  I am 
unsure as to the ramifications of my change, though.  (I modified 
regen_raster in drivtool.c, so it's anybody's guess as to what I messed
up in the process.)  (We're up to rev 185 in drivtool!)

In addition, db.c has been modified.  I crippled some functions which 
should be unused (and are terribly misleading to the programmer.)  They
are stubbed with a hard-coded error message that I should be called
immediately.  I'll take them out tomorrow after doing the 2 zillion greps
necessary to figure out if they are used.  (/SC is modified, /SS and /SR
should produce the errors.)

Alicia, this version is vastly superior to X in that it works.  Even if there
are some sundry strange things, I'd cut a master (at least a driver update).
X's driver is simply worthless.

I'm going to go home and get some sleep.

Poz

<font size="1"><a href="top">[back to top]</a></font>
<hr>
<a name="2">
Date: Thu, 13 Aug 92 19:26:13 EDT
To: bohley
Subject: All of those nasty 00co* files.
In-Reply-To: The Gods

OK, here's the scoop on our temporary files.  Much of this information
will probably not matter to you.  Although each of these filenames begins
with "00co", the "00" will change if there are stale lock files or multiple
users using the same temp directory.

ESP 4.0 files -------------------------------------------------------------

Segment files

   00cofd   -- File Description Segment
   00cord   -- Raster Image Data Segment
   00corh   -- Raster Image Header Segment
   00cori   -- Raster Image Index Segment
   00coir   -- Image Reference Data Segment
   00coop   -- Raster Operation Segment
   00covh   -- Vector Header Segment
   00covd   -- Vector Data Segment
   00cosv   -- System Variables
   00coxo   -- This was the "unknown" seg, now it's the CALS segment
   00coff   -- Free-form segment

Utility Temporary files
   Most of these are used so that the main image isn't destroyed if an
   error occurs.  The main image (00cord) is unlinked and this file renamed
   to 00cord at the end of successful processing.

   00coarg  -- argument file to a utility
   00cobis  -- bias temp file
   00coskw  -- deskew temp file
   00cofil  -- filter temp file      (obsolete)
   00coinv  -- invert temp file
   00comrg  -- merge temp file
   00corot  -- rotate temp file
   00cospec -- despeckle temp file
   00coras  -- rasteriz temp file    (obsolete)
   00coffee -- Psychoactive Botanical Filtrate during smoking chain
   00cot1rd -- temporary raster data file during plot chain
   00cot2rd -- temporary raster data file during plot chain

Other temporary files
   Most of these are used by the CAD Overlay driver and lisp to coordinate
   calling utilities and pass information.

   00colok  -- The infamous lock file.
   00colut  -- LUT file              (internal driver entity info file)
   00coscr  -- plot script file
   00coswp  -- swap file             (probably unused)
   00corr   -- raster reference file (now obsolete, used in 3.5)

AutoCAD Script files 
   Used to automate the Plot command, mostly.  These files are held open
   by AutoCAD and are often difficult to delete.  We are working on it.

   00cotmp0.scr 
   00cotmp1.scr

GS and GSX segment files (unused in ESP 4.0)

   00corp   -- Raster Palette
   00corg   -- Raster Histogram
   00cor8   -- 8 Bit Raster Header

Reserved but completely unused files 
   These files will probably never be used by Image Systems.

   00cosh   -- Snapshot Header Segment
   00cosd   -- Snapshot Data Segment
   00coih   -- Icon Header Segment
   00coid   -- Icon Data Segment (or possibly where my ego is hid)
   00cogod  -- Contains the 9 billion names of God
   00cobim  -- Unrecoverable, Undeterminable Application Error
   00corpse -- Program died
   00codpc  -- Created by internal virus on every February 29, 1988
   00codfsh -- fishy error ocurred in driver
   00cobjob -- ESP 4.0 program files
   00cohab  -- Created when VB and ESP are living together on the same PC
   00corny  -- Contains Dave Geoghegan's last joke
   00costly -- The number of sqaure feet of paper wasted by PRVPI
   00coven  -- Witch file is this?
   00coward -- I wouldn't delete this if I were you

Share and Enjoy!

Poz

<font size="1"><a href="top">[back to top]</a></font>
<hr>
<a name="3">
Date: Thu, 3 Sep 92 15:30:35 EDT
To: djk@rover
Subject: Slash Commands

DJ,

Directly from our source file, procmd.c, here is the complete list
of slash commands.

Poz

 * Here are the currently supported commands:
 * /A   -- set variables
 * /AP  -- set packet buffer pointer
 * /AR  -- set rlcio variables
 * /AS  -- set system variables
 * /AT  -- set tmpload variable
 * /A?  -- query system variables
 * /DC+ -- turn entity count checking on  (default)
 * /DC- -- turn entity count checking off
 * /DE  -- End session
 * /DH  -- clear highlights
 * /DV  -- set acad version
 * /D+  -- Turn on driver
 * /D-  -- Shut off driver
 * /DS  -- Start session
 * /DP  -- Pump AutoCAD command out when possible.
 * /DR  -- Driver reset
 * /DZ  -- Zoom dynamic
 * /DL+ -- Use display list - DLON
 * /DL? -- Query display list status
 * /D=  -- Sync driver
 * /IN  -- Image name
 * /IG  -- Regen everything
 * /IA  -- Allocate entity
 * /ID  -- Dump entity
 * /I#  -- Get ilist of entity
 * /I+  -- New image
 * /I-  -- Remove image
 * /I=  -- Remove image
 * /I?  -- Get image iname
 * /I?? -- Get image iname, but don't check authorization code
 * /VN  -- number of allowable viewports
 * /VZ  -- set y size
 * /VX  -- set center x
 * /VY  -- set center y
 * /SS  -- save segment
 * /SR  -- restore segment
 * /SC  -- copy segment
 * /SP  -- write string to arg file
 * /SD  -- dump segment
 * /SF# -- sync to file (if # is there then dump all entities of type #)
 * /SM  -- sync to memory
 * /FC  -- copy file
 * /FD  -- delete file
 * /RO  -- Set one-snap mode
 * /RA  -- prompt (Ask) for one-snap
 * /XF  -- Display available fds              (debugging only)
 * /XS  -- Display info about fd              (debugging only)
 * /#H  -- highlight entity (# is a number)
 * /#G  -- regen entity (# is a number)
 * /#Y  -- yank entity (# is a number)
 * /#:  -- modify entity tag (# is a number)
 *

<font size="1"><a href="top">[back to top]</a></font>
<hr>
<a name="4">
Date: Thu, 17 Sep 92 15:35:27 EDT
To: cjk@imagesys.com (Curt Krone) (Curt Krone)
Subject: ug!
In-Reply-To: <9209171843.AA00667@dino.imagesys.com>; from "Curt Krone" at Sep 17, 92 2:43 pm

> 
> 
> >> 
> >> fitscale should be called when pasting or iref/inserting an image.
> >> 
> >> image_fitscale should be used for image/sc and iref/modify/scale.
> >> 
> >> Poz
> >> 
> >
> >Oops, forgot you mail-name...
> 
> Me mail-name Tarzan.  What you mail-name?
> 

Me Tantor!

<font size="1"><a href="top">[back to top]</a></font>
<hr>
<a name="5">
Date: Tue, 1 Dec 92 20:03:57 EST
To: alicia, smb, mfb, cjk
Subject: Billions and billions of IREF and ROPS

OK, I made the changes to swabseg.h and the format converters which
will allow as many IREFs as are put into the file.

The make is running overnight.

What remains is the following:

  Alicia/Michele: modifications to QPLOT so that it handles more than
                  one ROP segment.
                  Remove the check on the number of IREFs.

  Alicia: Make COPLOT capable of writing more than one ROP entry in 
          the queue.
          Make sure there is no limit placed on the number of irefs.
          Think about the ramifications of >50 rops in masker and flush.

  Shawn:  Make ESPLOT treat IREFs individiually.  (Both I8 and IR.)

  Curt:   Centralize the hardcoding of limits for ROPS and IREFs to a 
          single accessible place.

  Shannon: Talk to JRA about how this hoses ViewBase.

Anything else?

These changes are not astronomically important, but since my changes are
in the library, plotting won't work until the plot chain things are
done.  So, tell me if you will need more than the end of the day 
Thursday.

Poz

<font size="1"><a href="top">[back to top]</a></font>
<hr>
<a name="6">
Date: Mon, 7 Dec 92 10:20:08 EST
To: shannon, dmg, gam, smb, alicia, eh, mfb, jpr, cjk
Subject: GSX 2.0 Development Info Letter #7


                          CAD Overlay GS/GSX 2.0
                        Development Info Letter #7
                                 7 Dec 92

               This week's host:  The Lord of Time and Space
           (Email all corrections and clarifications to Shannon.)


Functional Spec -----------------------------------------------------------

The functional spec is more or less firmed up.  (The fruit is actually 
now in suspension in the Jello.)

We will probably be supporting 8-bit color TIFF files (only).  Continue to
stay tuned for development specs.

Time Frame ---------------------------------------------------------------

The milestone for a complete product is 18 Dec 1992.  We are currently
right on schedule.  The TIFF stuff has been almost completed, and is now 
in the debugging phase.

In the meantime, we've gone ahead with other items (QPLOT).

What this continues to mean is that we won't be shipping before RasterWorld.

Implementation Spec -------------------------------------------------------

The GS/GSX 2.0 Bible does not yet have the new command structure in it.
I'll get to it someday, when the new command structure is complete.

Milestones ----------------------------------------------------------------

Short term goals (until 7 Dec):
    Add TIFF support to utilities.
    More IREF plotting.
    Further work on queue plotting.

Long term goals: 
DONE! 1. View IGS files.  (Using ESP 4.0 as the basis for changes.) 
DONE! 2. View bytemaps.  (Bytemaps will be our new internal format.)

DONE! 3. Plot GS raster to scale through the plot chain.
           - Confuser, rasterop (scaler), and at least one print driver
             are done.

DONE! 3.5. Plot GS raster to landscape and portrait.
           - Rotate is added

DONE! 4. Plot correlated raster and vector.
          - rasterizer will need to be changed to take a bitmap.
          - other stuff will surely come up.

DONE! 4.5  Add RMASKs to plots.
          - A masker utility will have to be written to create the RMASKs.
            Rasterop will then use the maskfile to mask out portions of
            the image.

done? 4.75  Display IREFs.
          - TIFF library
          - Requires the driver to read them.

IP    5. Add IREFs to plots.
          - Rasterop and ESPLOT must be modified.
          - Requires the driver to read them and a library to do so.

New Projects --------------------------------------------------------------

(The following is not yet implemented:)
We came up with the need for a non-drawing, "editing" color.  We need it for
masks and plotting.  The decision was to reserve color 255 for this purpose.
When we paste an image, any pixels which are 255 are changed to 254.  255
was chosen since 16 and 64 color images won't be affected at all.

Current Projects ----------------------------------------------------------

DONE!   - completed since last info letter
done?   - mostly done, bugs here and there or changes likely
IP-#    - In progress, or waiting on some other item.  Number is likely
          number of days of work left.  No number is unknown.
(blank) - Not being worked on right now.  In the queue.
OS      - Other stuff not in GS/GSX being worked on.
NOT     - cancelled items

Poz:    done? IREFs in the driver
        done? TIFF writing and reading library (with Gary)
              ESP 4.0 and GSX 2.0 plot compatibility
              (pickpt getting wrong info)
              Look into color display.
        IP    GS Project management

Curt:   done? Dorking with command structure
        IP    Get well
              (pickpt getting wrong info)

Dave:   done? Rasterop (bugs with left/right clipping, dropping runs)
        OS    (Sun4 port of ESP 4.0)

Shawn:  IP    Make important raster printer drivers take bitmap
        IP    Queue plot support
              Add RLC output to confuser
              ESP 4.0 and GSX 2.0 plot compatibility
        done? ESPLOT    (Will be modified as we go)

Gary:   done? TIFF writing and reading library (with Poz)
        IP    Writing stripped files
              bytemap to TIFF converter
              other converters

Alicia: done? config             (waiting for fine tuning)
        OS    (Sun4 port of ESP 4.0)

Michelle:
        done? QPLOT changes.
        OS    (ViewBase 4.0)

---------------------------------- End ------------------------------------

<font size="1"><a href="top">[back to top]</a></font>
<hr>
<a name="7">
Date: Mon, 7 Dec 92 10:23:13 EST
To: shannon, dmg, gam, smb, alicia, eh, mfb, jpr, cjk
Subject: Dev non-Release F of GSX 2.0

Release F is in /t (or t:) as gsx-f.zip.

Unzip it (after creating your GS directory) with:
    pkunzip -d t:gsx-f.zip

It will make subdirectories.

Here is the readmeor.die file which come with it:


                      GSX 2.0 Development Non-release F                     
                          "F is for Feature-Latent"                         
                                  7 Dec 92                                 
                                                                           
 New things:                                                                
    - Preliminary TIFF support:  reading and writing of 8,4, and 1 bit TIFF 
      images.                                                               
    - IREFs                                                                 
    - More or less final command structure                                  
    - Editing commands for main image                                       
                                                                            
 Known Bugs:                                                                
    - Editing commands for reference images don't work.                    
      (But the lisp is there...)                                           
    - IREF and TIFF support is still buggy.  Please note carefully any      
      strange occurances.                                                   
                                                                            
 The following is not included on this release (although much is complete): 
    - All of plotting                                                       

Enjoy! 

Poz 

<font size="1"><a href="top">[back to top]</a></font>
<hr>
<a name="8">
Subject: GSX rev C
To: shannon, dmg, gam, smb, alicia, eh, mfb, jpr, cjk, kgb,
	mbd (Mary Beth Dukes)
Date: Thu, 25 Mar 1993 11:51:01 -0500 (EST)

I am planning on making the next cut of GSX (C is for Chafe) for
Monday morning.  Because of this, I need all changes for this rev by
noon on Friday.

Deadline for revisions:   NOON FRIDAY.

Your for a better CAD Overlay,
poz

<font size="1"><a href="top">[back to top]</a></font>
<hr>
<a name="9">
Subject: Dangerous Grass
To: jjr (John J. Racz), joh (Jim Harrigan)
Date: Wed, 12 May 1993 21:57:24 -0500 (EDT)

In rev G, Dave fixed the funky garbage which showed up on the left of images
after crops.  He also fixed the strange stuff going on in the middle of the
image.  These are fixes which should be tested with rev G.

In addition, there is a disk labeled "Potentially Dangerous Grass" on my
computer.  This _may_ fix off-by-one pixel errors.  It may crash your
machine.  It may make you sterile.  Please give it a try (I'm sure you're
both psyched after that "sterile" quip).

Besides doing redit crops, do some plot testing with it.  If it don't work, 
write it up on paper (not database) and tell me.

poz

<font size="1"><a href="top">[back to top]</a></font>
<hr>
<a name="10">
Subject: Programming Update
To: development
Date: Mon, 15 Nov 1993 23:00:49 -0500 (EST)

I'd just thought I'd let you all know that I hate the Windows
GDI.  If I ever find the person or persons responsible for 
writing or designing it (if how it is implemented can be called
"designed") I am going to give them a sound thrashing.

Thank you.

Have a nice day.

poz

<font size="1"><a href="top">[back to top]</a></font>
<hr>
<a name="11">
Subject: CAD Overlay and RasterCore team status
To: dap@softdesk.com
Date: Fri, 15 Jul 1994 17:15:52 -0400 (EDT)

                      Development Lead Programmer Report
                                 15 Jul 94

Development Group: ICore and CAD Overlay Teams

Development Resources:      dmg, cjk, gam, ads, poz, mp, jmr, mfb, smb
Troy Testing Resources:     smr, gav, djk, mrb
Henniker Testing Resources:


LFX

   [complete]
       Bugfixes
       Solidified Installation of Template files
       Worked on Patch for Windows
       Added help commands

   [ongoing]
       More bug fixes

   [roadblocks]
       DMG worked Mon/Tuesday on G4 Library for Coned
       Need more full-time testers to ensure 3Q release

   [questions]
       What is the update of ESP 4.0 Windows going to be called:
          4.01, 4.10, 4.11, 13.13?


GSX Win 2.0

   [complete]
       Fixed problems in displaying 4-bit color images.
       Fixed problems cropping regions to rmasks.
       Fixed memory allocation for input lines in deskew.
       Cut source code tree for GSX Win.
       Fixed problem with histogram window when comem was enabled.

   [ongoing]
       Fix display of raster to be pixel accurate.  (For tiling of images).


ESP 4.0 Japanese Solaris 2.2

    [complete]
       Sent out a new translation kit for Japanese Solaris ESP 4.0.

    [ongoing]
       Still waiting to hear from KEL that all is well with that project.


ICore

   [complete]
      Welcomed Brad into our own little source code hell.

   [ongoing]
      Added memory management stuff (SmartHeap)
      Did more work for editing:  started adding line drawing.


R13 Port

   [ongoing]
      No progress this week since GSX takes priority


Plotting:  Translation of Oce demo plot pascal program for Electrabel

   [complete]
      given to testing


Plotting:  CC4 driver for Con Ed Viewbase (used for overviews)

   [ongoing]
      Will be started when Oce is complete


ConEd VBTools Update (Since John Anderson is on Vacation)

   [to do]
      CC4 driver complete by end of next week
      Rebuild viewer so that it uses CC4 files
      Resource file merge program
      Make new release disks


Miscellaneous

   [complete]

   [ongoing]
      JMR and MP doing more ConEd stuff (see JRA's status report).


General Road Blocks / Concerns:
      Our ancient revision of PVCS messes up date/time on Solaris.  We need
         to upgrade.  We hope to get an evaluation version of the most recent
         PVCS for DOS, Windows, and Solaris to see if it still works in our
         system.
      We need to get GNU C++ and install it on the Solaris machines,
         since Sun C++ is too expensive and will take too long to get
         licensed.


                                 - End -

</pre>

%StdFoamTotemContentEnd;
%StdFoamTotemBodyEnd;
%StdFoamTotemHTMLEnd;
