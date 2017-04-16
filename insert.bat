@echo off

echo Copying fresh ROM...
copy /Y m12fresh.gba m12.gba

:: Assemble includes
echo Assembling includes...
pushd working
..\armips.exe m12-includes.asm -sym includes-symbols.sym
popd

:: Compile all C and ASM code
echo Compiling and assembling...
pushd compiled
Amalgamator\Amalgamator\bin\Debug\Amalgamator.exe -r m12.gba -c 0x8100000 -d "../" -i vwf.c ext.c
popd
if errorlevel 1 (pause && goto :eof)

SymbolTableBuilder\SymbolTableBuilder\bin\Debug\symbols.exe m12.sym armips-symbols.sym working/includes-symbols.sym

echo Success!