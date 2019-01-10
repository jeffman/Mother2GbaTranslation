$pwd = Get-Location
$pwd = $pwd.Path

& dotnet build tools/ScriptTool -o "$([IO.Path]::Combine($pwd, "bin/ScriptTool"))"
if ($LASTEXITCODE -ne 0) { exit -1 }
