$pwd = Get-Location
$pwd = $pwd.Path

& dotnet build tools/ScriptTool -o "$([IO.Path]::Combine($pwd, "bin/ScriptTool"))"
if ($LASTEXITCODE -ne 0) { exit -1 }
& dotnet build tools/RenderCastRoll -o "$([IO.Path]::Combine($pwd, "bin/RenderCastRoll"))"
if ($LASTEXITCODE -ne 0) { exit -1 }
& dotnet build tools/SetDefaultNames -o "$([IO.Path]::Combine($pwd, "bin/SetDefaultNames"))"
if ($LASTEXITCODE -ne 0) { exit -1 }
& dotnet build tools/RenderStaffCredits -o "$([IO.Path]::Combine($pwd, "bin/RenderStaffCredits"))"
if ($LASTEXITCODE -ne 0) { exit -1 }
