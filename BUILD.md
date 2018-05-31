# Building

The build for this is unfortunately really complicated. Use this file to
describe the build process.

## Overview

Starting from a bare repository, you need to do the following things to get
a translated MOTHER 1+2 ROM:

1. Get an original MOTHER 1+2 ROM and EarthBound ROM (not provided here).
    1. Name the MOTHER 1+2 ROM `m12fresh.gba` and place it in the repository
       folder.
    2. Name the EarthBound ROM `eb.smc` and put it in the same folder.
2. Download [armips](https://buildbot.orphis.net/armips/) and copy `armips.exe` to the repository folder
3. Build the build (see below).
4. Build the script (see below).
5. Build the hack and insert it into the ROM (see below).

## Building the build

This only has to be done once, assuming you're not making changes to the
build tools.

You will need Visual Studio to build the build. The Community edition is free:

https://www.visualstudio.com/vs/community/

Download and install that. Then, for each of the following solution files,

1. ScriptTool\ScriptTool.sln
2. SymbolTableBuilder\SymbolTableBuilder.sln
3. compiled\Amalgamator\Amalgamator.sln

do the following:

1. Open the .sln file with Visual Studio
2. In the Solution Explorer pane, right-click the solution and "Restore
   NuGet Packages"
3. Once that finishes, right-click the solution again and "Build Solution"

## Building the script

"The script" refers to the translation files in the `working` folder.

You will use ScriptTool.exe (one of the things you built earlier) to build the
script. It will be located in ScriptTool\ScriptTool\bin\Debug\ScriptTool.exe.

This is a command-line tool. Syntax:

`ScriptTool.exe -compiled -main -misc <working folder path>`

There's no batch file for this, although I ought to make one. You will have to
run this every time you make a change to the script.

## Building the hack

After the script is built, you need to build the hack code and insert it into
the MOTHER 1+2 ROM file. This is taken care of by `insert.bat`; it will generate a file called `m12.gba` with everything ready.

There's another one-time pre-requisite to take care of before you can run it.

### C code

Some of the hack code is written in C and cross-compiled to ARM with GCC.
In addition to armips described above, you will need to install this
GCC toolchain:

[gcc-arm-none-eabi-7-2017-q4-major-win32](https://developer.arm.com/open-source/gnu-toolchain/gnu-rm/downloads)

It was at version 7-2017-q4-major at the time of writing, but I imagine newer
versions work just fine. Download and run the installer linked above. Make sure
you add the path to your environment variable.