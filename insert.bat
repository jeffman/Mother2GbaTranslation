
ScriptTool\ScriptToolGui\bin\debug\ScriptTool -compile -main -misc working eb.smc m12.gba
copy /Y m12fresh.gba m12.gba
armips.exe m12-hack.asm -sym armips-symbols.sym
armips.exe m12-gfx.asm


pushd working
..\armips.exe m12-includes.asm

popd
xkas m12.gba m1.asm
insert.exe
SymbolTableBuilder\SymbolTableBuilder\bin\Debug\symbols.exe m12.sym m12-symbols.sym armips-symbols.sym

pause
