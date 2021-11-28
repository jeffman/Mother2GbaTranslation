$test_rom_file = "bin/m12test.gba"
$log_file      = "bin/test.log"
$sleep_time    = 60
$failure_text  = "FAIL"
$end_text      = "Done!"
$mgba_name     = "mgba-sdl"

If     ($IsWindows)            { $mgba_cmd = "bin/$mgba_name.exe" }
ElseIf ($IsLinux -or $IsMacOS) { $mgba_cmd = "bin/$mgba_name" }

"Building the test ROM..."
.\build.ps1 -t
if ($LASTEXITCODE -ne 0) { exit -1 }
Remove-Item -Path $log_file

"Starting the emulator..."
& $mgba_cmd -l 16 -C logLevel.gba.bios=0 -C logToFile=1 -C logFile=$log_file $test_rom_file &
if ($LASTEXITCODE -ne 0) { exit -1 }

"Sleeping for $sleep_time seconds..."
Start-Sleep $sleep_time

"Closing the emulator..."
Stop-Process -Name $mgba_name
if ($LASTEXITCODE -ne 0) { exit -1 }

$fails = Select-String -Path $log_file -Pattern $failure_text
if ($fails.count -ne 0) {
    "Test failures:"
    $fails
    exit -1
}

$end_session = Select-String -Path $log_file -Pattern $end_text
if ($end_session.count -eq 0) {
    "The tests did not run to completion!"
    exit -1
}

"No failures!"

exit 0
