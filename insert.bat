
ScriptTool\ScriptToolGui\bin\debug\ScriptTool -compile -main -misc working m12fresh.gba m12.gba
copy /Y m12fresh.gba m12.gba
armips.exe m2-hack.asm -sym armips-symbols.sym
armips.exe m2-gfx.asm


pushd working
..\armips.exe m12-includes.asm

popd
SymbolTableBuilder\SymbolTableBuilder\bin\Debug\symbols.exe m12.sym m12-symbols.sym armips-symbols.sym

pause
