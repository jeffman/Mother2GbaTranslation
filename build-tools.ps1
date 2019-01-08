$pwd = Get-Location
$pwd = $pwd.Path

& dotnet build tools/ScriptTool -o "$([IO.Path]::Combine($pwd, "bin/ScriptTool"))"
if ($LASTEXITCODE -ne 0) { exit -1 }

& dotnet build tools/SymbolTableBuilder -o "$([IO.Path]::Combine($pwd, "bin/SymbolTableBuilder"))"
if ($LASTEXITCODE -ne 0) { exit -1 }
