# Map editing

There are no map editors for MOTHER 1+2. This is a quick guide to do map editing manually.

## Prerequisites

* no$gba debugger: [Download the debug version](http://problemkaputt.de/gba.htm) (v2.8f or newer)
* A save file from the part of the game you want to change. Karmacalypse has posted a bunch [here](http://starmen.net/forum/Community/PKHack/MOTHER-1-2-translation-VWF-edition/2233160).

## Setting up the debugger

I'm assuming the reader hasn't used this kind of debugger before. Open up no$gba. Before starting anything, there's some setting changes I like to use:

* Options -> Emulation setup
  * Autosave options (bottom)
  * GBA Mode/Colors: poppy (most similar to other emulators)
  * Emulation speed: don't change it for now, but I find it useful sometimes to set it to 2x, or unlimited MHZ disaster if I'm waiting for a cutscene to finish
  * Sound Output Mode: none (I find the sound annoying and distracting while debugging)
  * Execute games in: small window in debugscreen (I don't like the little popup window)
* Debug tab
  * Disassembler Syntax: Native ARM (personal preference)
* Files tab
  * SAV/SNA File Format: raw (this makes it compatible with save files from other emulators)

Go to File -> Cartridge menu (Filename), and select a MOTHER 1+2 ROM. I'll be using an unmodified Japanese ROM for this since map editing isn't text-based.

Right after it loads, click somewhere in the main debugger window. The game should pause. This is called a __break__: all systems are completely paused and it'll show you the exact CPU instruction you paused on.

![Debugger in a break state][break]

__Breaks__ are really important because they're the tool that we're going to use to locate map data.

Next, import your save file. Close the debugger and go to the no$gba folder. You'll find a BATTERY folder; this is where it stores save files. You can copy in save files from Karmacalypse's archive, for instance. The filename should match the ROM name, except for the extension, which should be .sav.

Open your debugger again and reload the ROM; your save file should show up. Start playing to the point where you're in the room whose map you want to edit.

Note that no$gba has save states as well (it calls them snapshots). Also note that they're not portable: a snapshot you make on your computer won't work on another computer because it hard-codes ROM paths into the snapshot itself.

## Maps

### Orientation

I'll use the Monotoly building in Fourside as an example; we need to change the `Y` to an `I`.

![Monotoly building][monotoly]

Go to Window -> BG Maps -> BG0 and put your mouse over a map tile you want to change:

![BG0][bg0]

BG0 is one of four tilemaps for the GBA display. This one in particular has the background map layer. (BG1 has the foreground layer.) Each square in the grid is a **reference** to a specific **tile**, plus some attributes (palette and flip flags).

Note the **map address** and **tile number**: 6000762 and 11A, respectively.

Now go to the Tiles 2 tab:

![Tiles 2][tiles2]

This is where the tile data itself is stored. I've highlighted the same `Y` tile. It says here that the tile number is 51A instead of 11A; don't worry about that. There's a 0x400 tile offset because BG0 is configured to point to the Tiles 2 section of tile data, which means it skips over the 0x400 tiles in Tiles 1.

In general, there might be two ways to edit the map: edit the "grid" in BG0 so that a square will reference a different tile than it did before, perhaps with a different palette or flip flags; or go into the tile data itself and change the bitmap data for those tiles. Or sometimes a combination of both.

For the Monotoly change, there's already a letter `I` in the tile data, so luckily we only need to change the tile reference to point to an `I` instead of a `Y`.

### Making changes

Everything we just saw came from the video RAM of the GBA. You could edit the values in RAM _if you want_, just to see how it would look. Go back to the main debugger window and click on the bottom pane (the one that looks like a hex editor). Press Ctrl+G and type _06000762h_ and then Enter. Change the 1A to 8C, and start playing the game again:

![Changed to an I, but the color is wrong!][monotoli-wrong-color]

Uh oh, the color is wrong. This is because the `I` tile we picked uses different colors than the `Y` tile. Can we use a different palette to make it look right? Go to the Palettes tab in the other window:

![Palettes tab][palettes]

BG0 is restricted to using background palettes. (Foreground palettes are for sprites only.) Each row is a palette; there are 16 of them, and each one has 16 colors. And it doesn't look like any other palette has the colors we need, so we can't solve the color problem by switching palettes.

Darn -- that means we have to make a new `I` tile with the right colors.

Remember that the change we just made was only in RAM. We still need to trace it back to the ROM. Since we need to edit the tile data as well as the grid data, let's do the tile data first.

### Tracing tile data

How do we figure out where it corresponds to in the ROM so that we can edit it? We use __breakpoints__. A __breakpoint__ is a signal to the debugger to __break__ at a particular __point__ during the execution of the game.

What's neat about no$gba is that it lets you define a breakpoint whenever a particular piece of memory is read from, written to, or changed to a specific value. What we want to do is define a breakpoint that will break whenever the Tiles 2 section of video RAM is written to.

If you go back to Tiles 2 and highlight the `Y` tile, you'll see a tile address. This is the location of the data for that tile in RAM. In this case it's 600A340.

Let's set a breakpoint for it. Go back to the main debugger window and press Ctrl+B. Type this and press enter:

> `[0600A340]!!`

The square brackets mean that it's a memory location. The `!!` means "any write". (You can use `?` for "any read" and `!` for "a write that changes the value".)

The game won't reload the tile data until you change rooms, so resume the same and walk into the Monotoly building. The debugger should break:

![Breakpoint hit!][break2]

The code in the window is important. Immediately before the highlighted instruction is `str r5,[r4,8h]`. `str` is a _memory write_ instruction; it wrote the value of `r0` (which is a _register_ -- you can see its value to the upper-right: 6008000) to memory location `[r4+8h]`, which is 40000D4+8 = 40000DC.

For small, isolated memory writes, the game uses these `str` instructions. But there's quite a bit of tile data to be transferred into RAM here. It would be really slow for the CPU to copy each byte in a loop.

What's actually going on here is a __DMA transfer__. DMA stands for direct memory access; it's a common hardware feature that allows the system to quickly do bulk memory transfers without burning CPU cycles. It's not important to go into detail here about how the GBA DMA works. All we need is the __source__ and __destination__ addresses.

> How do you tell that it's doing a DMA transfer? Anytime you see a write to 40000D4-40000DC, that's how you know: those are special I/O register addresses for DMA transfers. _~ M. Tenda_

Go to Window -> I/O map -> DMA registers:

![DMA registers][io-map]

Look at DMA3 at the bottom-right. (It'll almost always be DMA3.) The first two fields are the source and destination addresses, respectively. Great, so we found the tile data: it's at 2010000!

Wait... that's not a ROM address! According to the [GBA memory map](http://problemkaputt.de/gbatek.htm#gbamemorymap), 2xxxxxx is still a RAM address! So it's doing a DMA copy from RAM to other RAM?!

Yes, it's true. The reason for this is that the tile data is __compressed__ in the ROM. The game can't (or just doesn't, for some reason) decompress tile data directly to video RAM: it buffers it into working RAM first, and then does a DMA copy to video RAM. So now we need to set a breakpoint that catches writes to that area.

Set a breakpoint for `[2010000]!!` and resume the game. Walk out of the building to make the game reload the tiles.

... Ah... nothing happened? It hit our old breakpoint but not the new one we just made.

I think this is due to a bug in no$gba. For some reason it doesn't catch `!!`-style breakpoints when decompressing. But it does catch specific-value-type breakpoints.

If you're still at the DMA breakpoint, go to 2010000 (Ctrl+G) in the bottom window. You'll see a bunch of `00` and then some `33` (beginning at 2010020). If you resume the game and walk back into the building, you'll see the `33` area change to `FF`. Nice! Now we know that when the `FF` area changes back to `33` -- which is when we leave the building and go back to Fourside -- that's when we want a breakpoint.

Set up the following breakpoint:

> `[02010020]=033h`

This tells the debugger to break when the value `0x33` gets written to `2010020`. That's where we expect to catch the game decompressing the tile data from the ROM into working RAM.

Resume the game and exit the building (go into the building first if you're not there already). The new breakpoint gets hit here:

![Finally][decomp-breakpoint]

`swi 11h` means software interrupt 0x11. `0x11` corresponds to one of the GBA's decompression routines. `r0` is the source address and `r1` is the destination.

We're _almost_ there. `swi 11h` updates the source and destination registers after executing, but we're interested in what they were _before_ executing. Press F3 to run the next instruction: `bx r14`, which is basically a return-to-caller instruction. That brings you here:

![Actually finally][decomp-breakpoint2]

The previous few lines before the highlighted one are:

```
mov r0,r2
mov r1,r5
bl 80F47E4
```

This roughly means:

```
source = contents of r2
destination = contents of r5
call decomp(source, destination)
````

In `r2`, we see `8575B2C`. That looks like a ROM address to me! Remember to subtract `8000000` to translate it into an offset into a ROM file.

So, we now suspect that the tile data for Fourside is located at `8575B2C`, or 0x575B2C in the ROM file. We can test that theory by trying to decomp that area manually and seeing if the uncompressed result is what we expect.

Load up a decomp tool (such as [NL's compressor](https://www.romhacking.net/utilities/511/)) and try decompressing from that location in the MOTHER 1+2 ROM.

![Nintenlord's thing][nl]

Open the output file in any tile editor (such as [Tile Molester](https://www.romhacking.net/utilities/109/)) and switch it to GBA mode (4bpp linear reversed):

![That Looks Right To Me][tile-molester]

So now we know where the tile data is compressed in the ROM. And Knowing Is Half The Battle

(work in progress; to be continued)

[break]: break.png
[monotoly]: monotoly.png
[bg0]: bg0.png
[tiles2]: tiles2.png
[monotoli-wrong-color]: monotoli-wrong-color.png
[palettes]: palettes.png
[break2]: break2.png
[io-map]: io-map.png
[decomp-breakpoint]: decomp-breakpoint.png
[decomp-breakpoint2]: decomp-breakpoint2.png
[nl]: nl.png
[tile-molester]: tile-molester.png