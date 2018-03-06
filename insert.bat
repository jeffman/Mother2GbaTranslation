
del "Mother 1+2 English.gba"
C:\m12tools\tools\epidgin\ScriptTool\ScriptToolGui\bin\debug\ScriptTool -compile -main -misc C:\m12tools\tools\epidgin\working C:\m12tools\tools\epidgin\ScriptTool\ScriptToolGui\bin\debug\m12fresh.gba C:\m12tools\tools\epidgin\ScriptTool\ScriptToolGui\bin\debug\m12.gba
copy /Y m12fresh.gba m12.gba
armips.exe m2-hack.asm -sym armips-symbols.sym
pushd working
..\armips.exe m12-includes.asm
popd
SymbolTableBuilder\SymbolTableBuilder\bin\Debug\symbols.exe m12.sym m12-symbols.sym armips-symbols.sym
rename m12.gba "Mother 1+2 English.gba"
pause
