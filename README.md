### MOTHER 2 Translation for the GBA
This is a work-in-progress translation patch for MOTHER 2 on the GBA.

### Discord
Our Discord server is pretty active: https://discord.gg/ADXS5Ub

### Hasn't it been done?
There are at least two other projects that translate the MOTHER 2 side of the game:
- Mato's menu text translation: [here](http://mother12.earthboundcentral.com/)
- TheZunar123's full translation (in progress): [here](http://earthboundcentral.com/forum/viewtopic.php?f=3&t=526) and [here](http://forum.starmen.net/forum/Games/Mother2/Mother-2-Fan-Translation/page/1/)

### Why start another project?
Neither of the above projects use a true variable-width-font (VWF) to render text. A VWF would look much better and would make the game more enjoyable.

Adding a VWF is hard, however. Mato explains [here](http://earthboundcentral.com/2011/04/a-look-at-the-mother-2-side/) why it's generally a very difficult task to fully translate the game, let alone to insert a VWF.

A long time ago (before the release of the [MOTHER 3 Fan Translation](http://mother3.fobby.net)), I started working on a proof-of-concept VWF for MOTHER 2 on the GBA. It worked, but it quickly became apparent that the amount of hacking required would be huge; window-rendering functions contain a ton of repeated code and some of it is downright non-sensical.

A few years after that, I tried it again from scratch with the intent of having a more organized codebase. It went much better, but I was soon limited by not having any translated dialogue, rather than not having a VWF; I couldn't test much of my VWF code without any English text inserted into the ROM.

### Now what?
This project aims to both complete the VWF codebase and to provide a tool for translating the game's dialogue. My new intent is to bring the hack to a state where I can just sit down and translate text efficiently in my spare time with a graphical tool. Not only that, but having such a tool means that other people can contribute!

### Status
The core of the VWF is complete. But it needs to be implemented in dozens of different places in the game's code. I've finished many of them, but there are probably still many more. Pretty much all of the game's text still needs to be translated too.

Some screenshots:

![](./screenshots/itshappening2.png) ![](./screenshots/itshappening4.png) ![](./screenshots/itshappening5.png) ![](./screenshots/m2-status2.png)

### Dependencies
If you want to just use the graphical tool to help with the translation, you just need .NET 4.5.1. If you want to actually compile the hack code and test it out, you will need [armips](https://github.com/Kingcom/armips). The game also crashes horribly 99% of the time in its current state, so there's no point in trying it.

### Compiling
That said, if you do want to try compiling this thing:

1. One-time setup
    1. Find a MOTHER 1+2 GBA ROM, name it `m12fresh.gba`, and copy it to the root of the repository. Mine has a SHA-1 hash `F27336B9C96CA2D06C34E07A61A78538DEAC32B3`.
    2. Only if you need to decompile stuff from EarthBound: repeat the above step for the EarthBound SNES ROM, named `eb.smc`, SHA-1 hash `D67A8EF36EF616BC39306AA1B486E1BD3047815A`. You can probably get away with any EB ROM that's unheadered.
    3. Build `ScriptTool`: open `ScriptTool/ScriptTool.sln` in Visual Studio and build the solution in Debug mode. This is a tool that compiles all of the JSON files from `working/` into ASM and BIN files. There's also a GUI tool to help with editing the main script file. You might have to right-click the solution in Visual Studio and 'Restore NuGet Packages'.
        * **Important**: re-build ScriptTool if you change between master and compiled-vwf!
    4. Repeat the above step for `SymbolTableBuilder`.
    5. If you're on the compiled-vwf branch:
        1. Build `compiled/Amalgamator/Amalgamator.sln`.
        2. Grab the latest release of [armips](https://github.com/Kingcom/armips/releases) and copy `armips.exe` to the repository root.
        3. Download and install [GNU Arm Embedded Toolchain](https://developer.arm.com/open-source/gnu-toolchain/gnu-rm/downloads) (anything newer than 6-2017-q1-update should work). Make sure it ends up in your PATH environment variable (the installer should take care of this).
2. Building the ROM
    1. Run `insert.bat`. This will generate `m12.gba` in the repository root, which has everything compiled and inserted.
