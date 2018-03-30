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

BG0 is one of four tilemaps for the GBA display. This one in particular has the background map layer. (BG1 has the foreground layer.) Each square in the grid is a **reference** to a specific **tile**, plus some attributes (palette and flip flags). (I might refer to "grid" and "tilemap" interchangeably.)

Note the **map address** and **tile number**: 6000762 and 11A, respectively.

Now go to the Tiles 2 tab:

![Tiles 2][tiles2]

This is where the tile data itself is stored. I've highlighted the same `Y` tile. It says here that the tile number is 51A instead of 11A; don't worry about that. There's a 0x400 tile offset because BG0 is configured to point to the Tiles 2 section of tile data, which means it skips over the 0x400 tiles in Tiles 1. (I might refer to tile data as a "tileset".)

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

### Locating tileset data

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

> How do you tell that it's doing a DMA transfer? Anytime you see a write to 40000D4-40000DC, that's how you know: those are special I/O register addresses for DMA transfers. _-- M. Tenda_

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
```

In `r2`, we see `8575B2C`. That looks like a ROM address to me! Remember to subtract `8000000` to translate it into an offset into a ROM file.

So, we now suspect that the tile data for Fourside is located at `8575B2C`, or 0x575B2C in the ROM file. We can test that theory by trying to decomp that area manually and seeing if the uncompressed result is what we expect.

Load up a decomp tool (such as [NL's compressor](https://www.romhacking.net/utilities/511/)) and try decompressing from that location in the MOTHER 1+2 ROM.

![Nintenlord's thing][nl]

> While you're here, select "Length (compressed)" and run it again. You should get __0x35DC__. Note this down for later.

Open the output file in any tile editor (such as [Tile Molester](https://www.romhacking.net/utilities/109/)) and switch it to GBA mode (4bpp linear reversed):

![That Looks Right To Me][tile-molester]

So now we know where the tile data is compressed in the ROM. And Knowing Is Half The Battle

### Editing the tileset

We _could_, maybe, just change the `Y` to an `I`, but in general you need to be careful about changing existing tiles. We only want the `Y` in Monotoly to change. If there are other `Y`s on the map, we don't want to affect those. So it'd be safer to use one of the blank tiles near the end. I'm going to use one 

> I think Monotoly is the only thing that uses that `Y` tile. The Bakery has its own separate chunk of tiles that use a separate `Y`. But it's Good to be safe. _-- M. Tenda_

I'm going to pick the second-last tile (corresponding to index 0x3FE, since there are 0x400 tiles total and they are indexed from 0 to 0x3FF). I'm avoiding using the last tile because I'm superstitious about the game assigning special meaning to a value of 0x3FF.

So let's just draw an `I` using the same colors as the Monotoly `Y`:

![][tile-molester2]

Save and go back to the compressor program. Move the tileset file to the input and create a new file for the output. Set the offsets to 0 and select Compress:

![][compress]

Click Run to compress the file.

It's important now to see whether or not the new file is __bigger than the original__. This will almost always be the case. We said before that the original compressed size was 0x35DC. The size of the compressed file is 13784, or 0x35D8 bytes. Somehow the size went down, so in this case we're all good.

But sometimes the file is larger and we need to be careful, so I'm going to assume for the purpose of the tutorial that the new file is indeed larger than the original and discuss what to do about it.

### Relocating tilesets

Compressed data is tightly packed in the ROM; if you try to reinsert a recompressed block that's even one byte larger than the original, it'll overwrite the data that follows.

On the other hand, there's plenty of free space in the ROM. From about 0xB2C000 to 0xF00000 is about 4MB of unused ROM space. For the tutorial, let's just stick it at 0xB2C000. Go ahead and copy in the contents of the new compressed file to that spot in the ROM with your favorite hex editor.

That'll put the data into the ROM, but we need to update the pointer to it. The game still thinks the tileset is located at 0x575B2C; we need to make it think it's at 0xB2C000 instead.

Go back into the debugger. You should still be at the point where we figured out the tileset address. If not, get back to that point. Here's what it looks like again:

![][decomp-breakpoint2]

The goal now is to figure out how `r0` became that value. This will involve a bit of backtracking through the code. We concluded earlier that it was coming from `r2` (the `mov r0,r2` instruction means "copy `r2`'s value into `r0`"). Going up a bit further, we see:

```
mov r8,r0
ldr r2,[r0]
```

Working backwards, we can see that `r2` is being loaded from the memory address in `r0`; and the value in `r0` is being copied from `r8` immediately beforehand. Fortunately `r8` hasn't changed since then, so we can look there to find a memory address: __82DB7D4__. Sure enough, if we navigate to 0x2DB7D4 in a hex editor (or you could even go to 82DB7D4 directly in the debugger), we see the following four bytes:

```
2C 5B 57 08
```

Words are stored in little-endian order, meaning the four bytes are ordered from least significant to most significant. Which means that those four bytes, when read as a 32-bit word, form a value 0x8575B2C -- the address of the Fourside tileset!

> Jeffman is showing you the slow, smart way to find tileset pointers. But I, M. Tenda, prefer the fast way. Instead of backtracking through the code, simply search for `2C 5B 57 08` using a hex editor and you'll find the address right away! _-- M. Tenda_

All we need to do, then, is update that address to point to the new tileset. Replace those four bytes with `00 C0 B2 08`. Close and reload the debugger (it's not smart enough to pick up the change we made to copy in the new tileset). Play up to the Monotoli building again, and it should say... Monotoly?!

Ah... We haven't updated the tilemap yet! It's still pointing to the `Y` tile; we need to make it point to the new `I` tile instead.

### Locating tilemaps

We're going to use the exact same strategy as before to find the tilemap data. In the debugger, go back to the BG0 window and find the square we want to change. (It might be slightly different from my screenshots because the game moves the tilemap around depending on where you walk.) Note the map address. For me, it's 6000762. If you navigate there in the debugger's hex editor, you'll see `1A 51`. Every square in the tilemap uses two bytes. The tile number, palette index, and flip flags are all encoded in those two bytes. The low 10 bits hold the tile number. So to figure out where the game pulls the tile number from, it suffices to put a write value breakpoint on the `1A` location:

> `[6000762]=01Ah`

Resume the game and walk around. You might have to walk a bit off-screen and come back to the Monotoly. The breakpoint should eventually trigger:

![][break3]

It's storing something to `r6`, and we see that `r6` has a value of `40000D4`, which tells us it's another DMA transfer. When I open the DMA registers window, I see that it's copying from 0x2028030 to 0x6000740; since the value we're interested in was at 0x6000762, then logically it's being copied from `2028030 + (6000762 - 6000740) = 2028052`. Going there in the hex editor, we find the `1A 51` we're looking for.

Since it's coming from another RAM address, we need to do another breakpoint to figure out where it's coming from in the ROM:

> `[2028052]=01Ah`

Walk around some more until the breakpoint triggers. Mine triggers here:

![][break4]

The 0x511A came from `r0` in the `strh` instruction. Before that, `r0` was loaded from `r0`. (Yes, it's allowed to use the same register as both the source address and the destination.)

Scrolling up a bit... Wow, this one's really complicated! It's gonna be a nightmare to trace this backwards. A better choice might be to set a conditional breakpoint on the `ldrh` instruction that'll trigger when `[r0]` is `1A`. Highlight the `ldrh r0,[r0]` instruction and press Ctrl+B, and use this breakpoint:

> `0800CF80,[r0]=01Ah`

The `,` means that it's an execution breakpoint rather than a read or write breakpoint; the `0800CF80` is the location of the `ldrh` instruction we want to trigger on; and the stuff after the `,` is the condition that must be met for the breakpoint to trigger.

Resume the game and walk around some more until it triggers. When it breaks this time, it'll be before `r0` gets overwritten and we'll be able to see the address it's loading from. For me it's __0x2010252__. Going there in the hex editor, we see the `1A 51` we're looking for.

Repeat that all again with the new memory location: set a breakpoint for `[2010252]=01Ah` and walk around until it triggers. Finally it hits a decompression instruction. If I execute the `bx` instruction like before, I get here:

![][decomp-breakpoint3]

I want the source address, which _was_ in `r0` but is no longer there since the `swi` instruction overwrote it. Looking backwards:

```
ldr r1,[sp,#0x28]
add r3,r1,r6
ldr r0,=#0x3003858
ldrh r2,[r0]
cmp r3,r2
bge #0x800CD86
ldr r4,[sp,#0x2C]
ldr r0,[sp,#0x18]
add r1,r4,r0
ldr r0,=#0x30037C8
ldrh r0,[r0]
cmp r1,r0
blt #0x800CDCC
... 0x800CDCC:
mul r1,r2
add r1,r1,r3
lsl r1,r1,#0x2
ldr r2,#0x2000004
add r0,r1,r2
ldr r0,[r0]
ldr r4,=#0x2008004
add r1,r1,r4
ldr r4,[r1]
ldr r1,[r5]
bl #0x80F47C8
```

It's a lot, but it's all there! Going backwards, I see `r0` being overwritten by itself. Before that, `r0` is obtained from `r1` and `r2`, where `r2` is easily seen to be `0x2000004`.

What's `r1`? Looking back some more, it's obtained from itself, `r2`, and `r3`. Going back some more, `r1` is obtained from `r4` and `r0`, which both come from `ldr rX,[sp,Y]` -- those are easy to figure out. `r2` is loaded from 0x3003858. And `r3` is obtained from `r1` and `r6`, where `r1` came from another `ldr rX,[sp,Y]` load and `r6` hasn't changed at all.

`sp` is the stack pointer (currently 0x3007D44), and it's also an alias for `r13`. The pane at the bottom right is the stack. If you can follow all of that stuff, you'll eventually figure out what `r0` was:

```
ldr r1,[sp,#0x28]        // r1 = 0x15
add r3,r1,r6             // r3 = 0x15 + r6 = 0x16
ldr r0,=#0x3003858
ldrh r2,[r0]             // r2 = 0x23
cmp r3,r2
bge #0x800CD86           // false; r3 is less than r2
ldr r4,[sp,#0x2C]        // r4 = 0xB
ldr r0,[sp,#0x18]        // r0 = 0
add r1,r4,r0             // r1 = 0xB + 0 = 0xB
ldr r0,=#0x30037C8
ldrh r0,[r0]             // r0 = 0x23
cmp r1,r0                // true; r1 is less than r0
blt #0x800CDCC
... 0x800CDCC:
mul r1,r2                // r1 = 0xB * 0x23 = 0x181
add r1,r1,r3             // r1 = 0x181 + 0x16 = 0x197
lsl r1,r1,#0x2           // r1 = r1 * 4 = 0x65C
ldr r2,#0x2000004
add r0,r1,r2             // r0 = 0x65C + 0x2000004 = 0x2000660
ldr r0,[r0]              // r0 = 0x855FACC
ldr r4,=#0x2008004
add r1,r1,r4             // r1 = 0x65C + 0x2008004 = 0x2008660
ldr r4,[r1]              // r4 = 0x856B7F8
ldr r1,[r5]              // r1 = 0x2010200
bl #0x80F47C8
```

So we traced it back to 0x855FACC. Let's try decompressing that area with the Nintenlord thing:

![][nl2]

> Don't forget to note the compressed size: 0x58 bytes

Open the resulting file in a hex editor. What's that at location 0x52?

![][tilemap]

It's the tile we wanted! So we got it right: we just need to change this value, recompress the file, insert it into the ROM, and we should be done.

> I noticed that the file size is 0x80 or 128 bytes, and each entry uses 2 bytes. That makes 64 entries. Assuming this represents a square block, that means the block is 8 by 8 tiles. In EarthBound the blocks are only 4 by 4 tiles... I wonder why they changed it? _-- M. Tenda_

We picked tile 0x3FE, so replace that `1A 51` with `FE 53`. Save and recompress the file, perhaps as `m12-fourside-tilemap-c.bin`. Mine ended up being 0x58 bytes still. But we'll go through the exercise again of repointing it.

We inserted the tileset at 0xB2C000 and it was roughly 0x3600 bytes long. Let's put the tilemap at 0xB30000. Do that with your hex editor.

What's left is to update the address. Notice how the address came from RAM instead of ROM. Maybe it'd be easier to just search for the address (0x855FACC, or `CC FA 55 08`) in the ROM. That brings us to...

![][cant-find]

> Oh No, _-- M. Tenda_

Great, looks like we have some more backtracking to do!

The address was loaded from 0x2000660. So an appropriate breakpoint would be:

> `[2000660]=0CCh`

Set that breakpoint and resume the game, and walk around some more until it triggers. I had to enter and exit the building to trigger it:

![][break5]

`stmia r2!,{r0}`, according to [this](http://problemkaputt.de/gbatek.htm#thumbopcodesmemorymultipleloadstorepushpopandldmstm), means "store `r0` to `r2` and increment `r2`". Looking a few instructions up, we can deduce that

```
r0 = r0 + r1
   = [r2] + r1
   = [r2] + [r0+8]
   = [r2] + [r10+8]
   = [r2] + [0x82DB7DC]
   = [r2] + 0x8557F2C
```

We don't directly know what `r2` was before since it got overwritten with the address we want, but we can figure out what it was anyway: the current value is 0x855FACC, which was the sum of `[r2]` and 0x8557F2C, therefore it had a value of 0x7BA0. _That's_ the value we need to change. (We don't want to change the 0x8557F2C in the ROM because it looks like the game is using that as a base pointer for other things, but we only want to change this one thing.)

Set another breakpoint:

> `[2000660]=0A0h`

Enter and exit the building again to trigger the breakpoint:

![][break6]

`CpuSet` is just a memory copy routine. It's like a slow version of DMA. Like the decomp routine, it increments the source and destination registers (`r0` and `r1` respectively) so let's execute the `bx` instruction to see if we can figure out what `r0` was before the routine:

![][break7]

It looks like:

```
r0 = [r5+8] + 4
   = [r10+8] + 4
   = [0x82DB7DC] + 4
   = 0x8557F2C + 4
   = 0x8557F30
```

If you go to 0x557F30 in a hex editor, you'll see a whole list of words; these are __offsets__ to the compressed tilemap data, whose base is 0x557F2C. (If you look at 0x557F2C, you'll see `0x4CA`, which denotes the number of entries in this list.)

So all we need to do is find the 0x7BA0 in the list and change it to (0xB30000 - 0x557F2C = 0x5D80D4), or `D4 80 5D 00`:

![][tilemap-offset]

That should be it! We're finally done! Save the ROM, restart the debugger and see if it's changed:

![][monotoli]

All that work just for one little tile! But hopefully I've done all the heavy lifting already; there should be enough information here to deduce how map sectors, tiles, tilesets, and even palettes are stored in the ROM so that you can apply a more systematic approach to map editing.

### Incorporating into the project

So far this has all been one big toy example to try in isolation from the rest of the translation project. To actually put map changes into the hack is a bit different. Instead of manually copying stuff into the ROM with a hex editor, we'll add stuff to the main hack code file.

Most of the data files for the hack are stored in the 0xB2C000 - 0xF00000 ROM area. In the file `m2-hack.asm`, near the end, you'll see a bunch of data files being copied to 0xB2C000. We're going to add the edited, compressed file as a new data file here.

Let's call the edited, compressed file `m2-tileset-fourside-c.bin`. Add these lines to that section:

```
m2_tileset_fourside:
.incbin "m2-tileset-fourside-c.bin:"
```

> Here, `m2_tileset_fourside` is called a _label_. When we run the assembler, each label will be resolved to a physical address. We don't necessarily need to know what the address will be, as the assembler will let us use the label in place of a numerical value. _-- M. Tenda_

That'll put the data into the ROM, but we also need to update the pointer to it. We already tracked the location of the address to 0x2DB7D4. Go to the part of m2-hack.asm _right before_ the `.org 0x8B2C000`, and add this:

```
.org 0x82DB7D4 :: dw m2_tileset_fourside
```

That tells the assembler to `d`efine a `w`ord at 0x2DB7D4, with whatever value corresponds to the `m2_tileset_fourside` label.

Do something similar for the tilemap, and then you're done! (You can use labels in arithmetic expressions, i.e. you can do `dw m2_tilemap_fourside - 0x8557F2C` to store the tilemap offset.)

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
[tile-molester2]: tile-molester2.png
[compress]: compress.png
[break3]: break3.png
[break4]: break4.png
[decomp-breakpoint3]: decomp-breakpoint3.png
[nl2]: nl2.png
[tilemap]: tilemap.png
[cant-find]: cant-find.png
[break5]: break5.png
[break6]: break6.png
[break7]: break7.png
[tilemap-offset]: tilemap-offset.png
[monotoli]: monotoli.png
