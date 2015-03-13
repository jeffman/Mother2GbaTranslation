arch gba.thumb

//==============================================================================
// Relocation hacks
//==============================================================================

// Move the werird box font from 0xFCE6C
org $80B3274; dd m2_font_relocate

// Ness mom test
org $808F6B0; dd m2_nessmom

//==============================================================================
// Font hacks
//==============================================================================

org $8AFED84; incbin m2-mainfont1-empty.bin
org $8B0F424; incbin m2-mainfont2-empty.bin
org $8B13424; incbin m2-mainfont3-empty.bin

//==============================================================================
// Control code hacks
//==============================================================================

org $80CA2BC; bl m2_customcodes.check_main
org $80C90A2; bl m2_customcodes.check_status

//==============================================================================
// VWF hacks
//==============================================================================

org $80C96F0; push {lr}; bl m2_vwf.print_string_relative; pop {pc}

// Main entry
org $80CA448; push {lr}; bl m2_vwf.main; b $80CA46C

// Status entry
org $80C9116; push {lr}; bl m2_vwf.status; b $80C9144

// Menu select entry
org $80B7FC6; bl m2_vwf.print_string_relative

// Selection menu entry
org $80C1CE0
bl      m2_customcodes.check_selection_menu
b       $80C1D10
bl      m2_vwf.selection_menu
b       $80C1D0A

org $80C1D18; bne $80C1CE6

// Disable coordinate incrementing
org $80CA48E; nop // X

// Disable menu redrawing
org $80B7E4E; nop; nop // Talk
org $80B81FA; nop; nop // Check

// Save the current tilebase
org $80BDA44; push {lr}; bl m2_vwf.save_tilebase

// Pixel-X resets
org $80BE4E0; bl m2_vwf.x_reset0 // Menu window
org $80BE45E; bl m2_vwf.x_reset3 // Cash window
org $80C9854; bl m2_vwf.x_reset1
org $80C9CBE; bl m2_vwf.x_reset2
org $80C9D5C; bl m2_vwf.x_reset2
org $80CA1FC; bl m2_vwf.x_reset2
org $80CA270; bl m2_vwf.x_reset1
org $80CA30A; bl m2_vwf.x_reset2
org $80CA332; bl m2_vwf.x_reset1
org $80C8F26; bl m2_vwf.x_reset4 // Newline after a menu selection

// Erase a tile
org $80CA560; bl m2_vwf.erase_tile_short // short, one-liner windows
org $80C8F2A; bl m2_vwf.erase_tile_main // main version

// Copy a tile upwards
org $80CA60E; bl m2_vwf.copy_tile

// Re-draw the status screen after exiting the PSI sub-menu
org $80BACFC; bl m2_formatting.status_redraw

//==============================================================================
// Formatting hacks
//==============================================================================

// Cash window
org $80B785C; mov r0,#0xC // allocate 3 extra bytes for our positioning code
org $80B8A08; bl m2_formatting.format_cash
org $80B8A24; b $80B8A2E // skip the game's adding the $ and double-zero to the cash window

// Status window
org $80CA78A; mov r0,#0x60 // integer-to-char change 
org $80CA7AC; mov r2,#0x69 // integer-to-char change
org $80CA7EC; sub r1,#0xA0 // integer-to-char change

incsrc m2-status-initial.asm
incsrc m2-status-switch.asm

// Make the PSI type window bigger
org $80B7820; mov r1,#4 // X
org $80B7824; mov r3,#6 // width

// Greek letters
org $8B1B907; db $8B // alpha
org $8B1B90A; db $8C // beta
org $8B1B90D; db $8D // gamma
org $8B1B910; db $8E // sigma
org $8B1B913; db $8F // omega

// PSI stuff
org $80C21E4; bl m2_vwf.print_string_relative
org $80C21C4; bl m2_vwf.print_string_relative
org $80C2258; bl m2_vwf.print_string_relative
org $80C2270; bl m2_vwf.print_string_relative
org $80C22AC; bl m2_vwf.print_string_relative
org $80C22C4; bl m2_vwf.print_string_relative
org $80C203E; mov r1,#0x12 // new entry length
org $80C21B4; mov r1,#0x12
org $80C224A; mov r1,#0x12
org $80C229E; mov r1,#0x12

// PSI Rockin
org $80C2192; mov r3,#8 // Y
org $80C219E
mov     r2,#0x71
bl      m2_formatting.status1

//==============================================================================
// Data files
//==============================================================================

org $8B2C000

// Box font relocation
m2_font_relocate:
incbin m2-font-relocate.bin

// Co-ordinate table
m2_coord_table:
incbin m2-coord-table.bin

// EB fonts
m2_font_table:
dd     m2_font_main
dd     m2_font_saturn

m2_font_main:
incbin m2-font-main.bin

m2_font_saturn:
incbin m2-font-saturn.bin

// EB font heights
m2_height_table:
db     $02, $02, $01, $00    // last byte for alignment

// EB font widths
m2_widths_table:
dd     m2_widths_main
dd     m2_widths_saturn

m2_widths_main:
incbin m2-widths-main.bin

m2_widths_saturn:
// tba

// Ness mom test
m2_nessmom:
print "m2-nessmom: $", pc
incbin m2-nessmom.bin

// Misc text
org $8B17EE4; incbin m2-misctext-offsets.bin
org $8B40000; incbin m2-misctext.bin

// Menu choices
org $8B19A64; incbin m2-menuchoices-offsets.bin
org $8B41000; incbin m2-menuchoices.bin

// PSI names
incsrc m2-psinames.asm
org $8B42000; incbin m2-psinames.bin

//==============================================================================
// Misc
//==============================================================================

org $2027FC0
m2_custom_wram:

//==============================================================================
// Code files
//==============================================================================

org $80FCE6C
incsrc m2-vwf.asm
incsrc m2-formatting.asm
incsrc m2-customcodes.asm
