rm "Earthbound - The Giygas Chronicles.gba"
copy /Y m12fresh.gba m12.gba
ScriptTool\ScriptToolGui\bin\debug\ScriptTool -compile -main -misc working eb.smc m12.gba
armips.exe m12-hack.asm -sym armips-symbols.sym
pushd working
..\armips.exe m12-includes.asm

popd

insert.exe
SymbolTableBuilder\SymbolTableBuilder\bin\Debug\symbols.exe m12.sym m12-symbols.sym armips-symbols.sym

rename m12.gba "Earthbound - The Giygas Chronicles.gba"
pause
