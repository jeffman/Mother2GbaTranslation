[Environment]::CurrentDirectory = (Get-Location -PSProvider FileSystem).ProviderPath

#Region Variables
$input_rom_file     = "bin/m12fresh.gba"
$output_rom_file    = "bin/m12.gba"
$eb_rom_file        = "bin/eb.smc"
$working_dir        = "working"
$give_dir           = "working/m12-give-strings"
$src_dir            = "src"
$data_dir           = "src/data"
$give_new_dir       = "src/m12-give-strings"
$cast_roll_file     = "working/cast_roll.json"
$staff_credits_file = "working/staff_text.md"
$compiled_asm_file  = "src/m2-compiled.asm"
$includes_asm_file  = "m12-includes.asm"    # implicitly rooted in working_dir
$hack_asm_file      = "m2-hack.asm"         # implicitly rooted in src_dir

$input_c_files =
    "src/c/ext.c",
    "src/c/vwf.c",
    "src/c/locs.c",
    "src/c/credits.c",
    "src/c/goods.c",
    "src/c/fileselect.c",
    "src/c/status.c",
    "src/c/battle.c",
    "src/c/equip.c",
    "src/c/psi.c",
    "src/c/luminehall.c",
    "src/c/custom_codes.c"

$base_c_address         = 0x83755B8;
$scripttool_cmd         = "bin/ScriptTool/ScriptTool.dll"
$rendercastroll_cmd     = "bin/RenderCastRoll/RenderCastRoll.dll"
$renderstaffcredits_cmd = "bin/RenderStaffCredits/RenderStaffCredits.dll"
$gcc_cmd                = "arm-none-eabi-gcc"
$ld_cmd                 = "arm-none-eabi-ld"
$objdump_cmd            = "arm-none-eabi-objdump"
$readelf_cmd            = "arm-none-eabi-readelf"
$combined_obj_file      = "src/c/combined.o"
$linked_obj_file        = "src/c/linked.o"
$combine_script         = "src/c/combine.ld"
$link_script            = "src/c/link.ld"
$undefine_obj_file      = "src/c/ext.o"

If     ($IsWindows)            { $asm_cmd = "bin/armips.exe" }
ElseIf ($IsLinux -or $IsMacOS) { $asm_cmd = "bin/armips" }

$includes_sym_file   = [IO.Path]::ChangeExtension($includes_asm_file, "sym")
$output_rom_sym_file = [IO.Path]::ChangeExtension($output_rom_file, "sym")
$hack_sym_file       = [IO.Path]::ChangeExtension($hack_asm_file, "sym")

$scripttool_args =
    "-compile",
    "-main",
    "-misc",
    $working_dir,
    $eb_rom_file,
    $input_rom_file
    
$rendercastroll_args =
    $cast_roll_file,
    $data_dir
    
$renderstaffcredits_args =
    $staff_credits_file,
    $data_dir

$gcc_args =
    "-c",
    "-O1",
    "-fno-ipa-cp",
    "-fno-inline",
    "-march=armv4t",
    "-mtune=arm7tdmi",
    "-mthumb",
    "-ffixed-r12",
    "-mno-long-calls"

$combine_script_contents =
"SECTIONS { .text 0x$($base_c_address.ToString('X')) : { *(.text .rodata) } }"

$link_script_contents =
"SECTIONS { .text 0x$($base_c_address.ToString('X')) : { *(.text .data .rodata*) } }"
#EndRegion Variables

#Region Functions
class Symbol
{
    [string]$Name
    [int]$Value
    [int]$Size
    [bool]$IsLocal
    [bool]$IsGlobal
    [bool]$IsWeak
    [bool]$IsConstructor
    [bool]$IsWarning
    [bool]$IsIndirect
    [bool]$IsDebugging
    [bool]$IsDynamic
    [bool]$IsFunction
    [bool]$IsFile
    [bool]$IsObject
    [string]$Section
    [bool]$IsAbsolute
    [bool]$IsUndefined
}

class SectionInfo
{
    [string]$Name
    [int]$Address
    [int]$Offset
    [int]$Size
}

Function Get-Symbols ([string]$obj_file)
{
    return & $objdump_cmd -t $obj_file | ForEach-Object { New-Symbol $_ } | Where-Object { $_ -ne $null }
}

# Converts a symbol from objdump's string representation to a rich object representation
$symbol_regex = "(?'value'[0-9a-fA-F]{8})\s(?'flags'.{7})\s(?'section'\S+)\s+(?'size'[0-9a-fA-F]{8})\s(?'name'\S+)"
Function New-Symbol([string]$symbol_string)
{
    if ($symbol_string -match $symbol_regex)
    {
        $symbol = [Symbol]::new()
        $symbol.Name = $Matches.name
        $symbol.Value = [int]::Parse($Matches.value, [System.Globalization.NumberStyles]::HexNumber)
        $symbol.Size = [int]::Parse($Matches.size, [System.Globalization.NumberStyles]::HexNumber)
        $symbol.Section = $Matches.section
        $symbol.IsAbsolute = $symbol.Section -eq "*ABS*"
        $symbol.IsUndefined = $symbol.Section -eq "*UND*"

        $flags = $Matches.flags
        $symbol.IsLocal = $flags.Contains("l") -or $flags.Contains("!")
        $symbol.IsGlobal = $flags.Contains("g") -or $flags.Contains("!")
        $symbol.IsWeak = $flags.Contains("w")
        $symbol.IsConstructor = $flags.Contains("C")
        $symbol.IsWarning = $flags.Contains("W")
        $symbol.IsIndirect = $flags.Contains("I")
        $symbol.IsDebugging = $flags.Contains("d")
        $symbol.IsDynamic = $flags.Contains("D")
        $symbol.IsFunction = $flags.Contains("F")
        $symbol.IsFile = $flags.Contains("f")
        $symbol.IsObject = $flags.Contains("O")

        return $symbol
    }
    else
    {
        return $null
    }
}

Function Get-SymfileSymbols([string]$symbol_file)
{
    return Get-Content $symbol_file | ForEach-Object { New-SymfileSymbol $_ } | Where-Object { $null -ne $_ }
}

$symfile_symbol_regex = "(?'value'[0-9a-fA-F]{8})\s+(?'name'(?>\.|@@|[a-zA-Z0-9_])[a-zA-Z0-9_]+):{0,1}(?'size'[0-9a-fA-F]+){0,1}"
Function New-SymfileSymbol([string]$symbol_string)
{
    if ($symbol_string -match $symfile_symbol_regex)
    {
        $symbol = [Symbol]::new()
        $symbol.Name = $Matches.name
        $symbol.Value = [int]::Parse($Matches.value, [System.Globalization.NumberStyles]::HexNumber)

        if ($null -ne $Matches.size)
        {
            $symbol.Size = [int]::Parse($Matches.size, [System.Globalization.NumberStyles]::HexNumber)
        }
        else
        {
            $symbol.Size = 0
        }

        $symbol.IsLocal = $symbol.Name.StartsWith("@@")
        $symbol.IsGlobal = -not $symbol.Name.StartsWith(".") -and -not $symbol.IsLocal

        return $symbol
    }
    else
    {
        return $null
    }
}

function Get-SectionInfo([string]$object_file)
{
    $hash = @{}
    & $readelf_cmd -S $object_file | ForEach-Object {
        $section = New-Section $_
        if ($null -ne $section)
        {
            $hash[$section.Name] = $section
        }
    }
    return $hash
}

$section_regex = "\s?\[\s?\d+]\s(?'name'\S+)\s+\S+\s+(?'address'[0-9a-fA-F]+)\s(?'offset'[0-9a-fA-F]+)\s(?'size'[0-9a-fA-F]+)"
function New-Section([string]$section_string)
{
    if ($section_string -match $section_regex)
    {
        $section = [SectionInfo]::new()
        $section.Name = $Matches.name
        $section.Address = [int]::Parse($Matches.address, [System.Globalization.NumberStyles]::HexNumber)
        $section.Offset = [int]::Parse($Matches.offset, [System.Globalization.NumberStyles]::HexNumber)
        $section.Size = [int]::Parse($Matches.size, [System.Globalization.NumberStyles]::HexNumber)

        return $section
    }
    else
    {
        return $null
    }
}
#EndRegion Functions

<#
This is a complicated build script that does complicated things, but it's
that way for a reason.

- We want to use ASM and C code files simultaneously
- The ASM code defines symbols that we want to reference from C
- The C code defines symbols that we want to reference from ASM
- The game text defines symbols that we want to reference from C

The ASM and C code therefore depend on each other. The way around this catch-22
is to separate the compiling and linking stages of the C code.

1) Compile the game text

    Inputs:
    - Text/script files

    Outputs:
    - BIN files containing compiled text data
    - ASM files that relocate text pointers (m12-includes.asm)

2) Assemble output from step 1

    Inputs:
    - Output from step 1
    - Fresh M12 ROM file

    Outputs:
    - ROM file with text inserted and repointed
    - m12-includes.sym file containing generated symbols (e.g. individual strings from m12-other.json)

3) Compile C code

    Inputs:
    - C files

    Outputs:
    - O files (one for each C file)

    Remarks:
    - All symbols not defined in the C code itself must be marked extern. We will link it
      in a later step. This includes the string symbols from step 2.
    - Due to an assembler limitation, extern symbols cannot contain capital letters.
    - There's a weird quirk with the linker that requires extra care when using external
      functions. You need to declare them as extern AND implement them using the ((naked))
      attribute, e.g.

      (in a header file) extern int m2_drawwindow(WINDOW* window);
        (in a code file) int __attribute__((naked)) m2_drawwindow(WINDOW* window) {}

      See: http://stackoverflow.com/a/43283331/1188632

      This will cause a duplicate definition of the function symbol, since it's *really*
      defined in the ASM files somewhere, but we're redefining it again in C. So we also need
      to "undefine" these symbols later on when linking.

      To make it a bit easier to do all that, place all such implementations in ext.c.

4) First link stage

    Inputs:
    - O files from step 3
    - Base address

    Outputs:
    - Single O file positioned to the base address
    - m2-compiled.asm, containing C symbol definitions

    Remarks:
    - This is an incremental link; there will still be undefined symbols.
    - However, with this combined O file, the code layout will not change and we can now
      define symbols from the C code to be used in the ASM code.
    - The symbols will be passed to the assembler next, so export them as an ASM file
      with one ".definelabel" entry for each defined symbol. They need to be halfword-aligned.
      This file is called "m2-compiled.asm" by default and is referenced by m2-hack.asm.
    - Exclude the symbols defined in ext.c from m2-compiled.asm.

5) Assemble ASM code

    Inputs:
    - m2-hack.asm
    - m2-compiled.asm
    - All other ASM and data files from src/ (but not the generated ones from working/)
    - M12 ROM file from step 2

    Outputs:
    - M12 ROM file with all ASM code and data included
    - m2-hack.sym with all symbols defined thusfar

6) Generate final linker script

    Inputs:
    - Base address (same as step 4)
    - m2-hack.sym (from step 5)
    - m12-includes.sym (from step 2)

    Outputs:
    - Linker script file

    Remarks:
    - The linker script must define each symbol that's still undefined; if everything is
      happy at this point, then they should all be contained within the two input SYM files.

7) Final link stage

    Inputs:
    - O file from step 4
    - Linker script from step 6

    Outputs:
    - Single O file with all symbols defined

8) Copy code to ROM

    Inputs:
    - O file from step 7
    - M12 ROM file from step 5

    Outputs:
    - M12 ROM file with all code and data included

9) Build final symbol file

    Inputs:
    - m2-hack.sym
    - m12-includes.sym

    Outputs:
    - m12.sym

    Remarks:
    - This is just the input files concatenated (and sorted for convenience).
#>

$timer = [System.Diagnostics.StopWatch]::StartNew()

# ------------------------- COMPILE GAME TEXT -----------------------
"Copying $input_rom_file to $output_rom_file..."
Copy-Item -Path $input_rom_file -Destination $output_rom_file

"Compiling game text..."
& dotnet $scripttool_cmd $scripttool_args
if ($LASTEXITCODE -ne 0) { exit -1 }

"Copying give strings to src folder..."
Copy-Item -Path $give_dir -Destination $give_new_dir -Recurse

"Pre-rendering cast roll..."
& dotnet $rendercastroll_cmd $rendercastroll_args
if ($LASTEXITCODE -ne 0) { exit -1 }

"Pre-rendering staff credits..."
& dotnet $renderstaffcredits_cmd $renderstaffcredits_args
if ($LASTEXITCODE -ne 0) { exit -1 }

# ------------------------ ASSEMBLE GAME TEXT -----------------------
"Assembling game text..."
& $asm_cmd -root $working_dir -sym $includes_sym_file $includes_asm_file
if ($LASTEXITCODE -ne 0) { exit -1 }

# ----------------------------- COMPILE C ---------------------------
$obj_files = @()

# Invoke gcc on each file individually so that we can specify the output file
foreach ($input_c_file in $input_c_files)
{
    $obj_file = [IO.Path]::ChangeExtension($input_c_file, "o")
    $obj_files += $obj_file

    "Compiling $input_c_file..."
    & $gcc_cmd $gcc_args -o $obj_file $input_c_file
    if ($LASTEXITCODE -ne 0) { exit -1 }
}

# ----------------------------- 1ST LINK ----------------------------
"Writing $combine_script..."
$combine_script_contents | Out-File -FilePath $combine_script

"Linking $obj_files..."
& $ld_cmd -i -T $combine_script -o $combined_obj_file $obj_files
if ($LASTEXITCODE -ne 0) { exit -1 }

"Reading symbols from $combined_obj_file..."
$combined_symbols = Get-Symbols $combined_obj_file
if ($LASTEXITCODE -ne 0) { exit -1 }

"Reading symbols from $undefine_obj_file..."
$ext_symbols = Get-Symbols $undefine_obj_file
if ($LASTEXITCODE -ne 0) { exit -1 }

"Exporting C symbols to $compiled_asm_file..."
$ext_symbols_names = $ext_symbols | Where-Object { $_.IsFunction -and $_.IsGlobal -and (-not $_.IsUndefined) } | ForEach-Object { $_.Name }
$exported_symbols = $combined_symbols | Where-Object { $_.IsFunction -and $_.IsGlobal -and (-not $_.IsUndefined) -and ($ext_symbols_names -notcontains $_.Name) }
$exported_symbols | Sort-Object -Property Name | ForEach-Object { ".definelabel $($_.Name),0x$($_.Value.ToString("X"))" } | Set-Content -Path $compiled_asm_file

# ------------------------ ASSEMBLE HACK CODE -----------------------
"Assembling $hack_asm_file..."
& $asm_cmd -root $src_dir -sym $hack_sym_file $hack_asm_file
if ($LASTEXITCODE -ne 0) { exit -1 }

# ------------------- GENERATE FINAL LINKER SCRIPT ------------------
"Writing $link_script..."
$hack_symbols = Get-SymfileSymbols "$([IO.Path]::Combine($src_dir, $hack_sym_file))"
$includes_symbols = Get-SymfileSymbols "$([IO.Path]::Combine($working_dir, $includes_sym_file))"
$asm_symbols = ($hack_symbols + $includes_symbols) | Where-Object { $_.IsGlobal }
$asm_symbols_names = $asm_symbols | ForEach-Object { $_.Name }

foreach ($ext_symbols_name in $ext_symbols_names)
{
    if ($asm_symbols_names -notcontains $ext_symbols_name)
    {
        Write-Host "Error: Undefined external symbol $ext_symbols_name"
        exit -1
    }
}

Set-Content -Path $link_script -Value $link_script_contents
$asm_symbols | ForEach-Object { Add-Content -Path $link_script -Value "$($_.Name) = 0x$($_.Value.ToString("X"));" }

# ---------------------------- FINAL LINK ---------------------------
"Linking to $linked_obj_file..."
& $ld_cmd -T $link_script -o $linked_obj_file $combined_obj_file
if ($LASTEXITCODE -ne 0) { exit -1 }

# -------------------- COPY COMPILED C CODE TO ROM ------------------
"Copying compiled code to $output_rom_file..."
$sections = Get-SectionInfo $linked_obj_file
if ($LASTEXITCODE -ne 0) { exit -1 }
$text_section = $sections[".text"]
$linked_bytes = [IO.File]::ReadAllBytes($linked_obj_file)
$rom_bytes = [IO.File]::ReadAllBytes($output_rom_file)
[System.Array]::Copy($linked_bytes, $text_section.Offset, $rom_bytes, $text_section.Address - 0x8000000, $text_section.Size)
[IO.File]::WriteAllBytes($output_rom_file, $rom_bytes)

# -------------------------- GENERATE SYMBOLS -----------------------
"Generating $output_rom_sym_file..."
($hack_symbols + $includes_symbols) | Sort-Object Name | ForEach-Object { "$($_.Value.ToString("X8")) $($_.Name)" } | Set-Content $output_rom_sym_file

"Finished compiling $output_rom_file in $($timer.Elapsed.TotalSeconds.ToString("F3")) s"

Remove-Item -Path $give_new_dir -Recurse

exit 0
