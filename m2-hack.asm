arch gba.thumb

//==============================================================================
// Relocation hacks
//==============================================================================

// Move the weird box font from 0xFCE6C
org $80B3274; dd m2_font_relocate


//==============================================================================
// Font hacks
//==============================================================================

org $8AFED84; incbin m2-mainfont1-empty.bin
org $8B0F424; incbin m2-mainfont2-empty.bin
org $8B13424; incbin m2-mainfont3-empty.bin
org $8B088A4; incbin m2-shifted-cursor.bin

// Greek letters
org $8B1B907; db $8B // alpha
org $8B1B90A; db $8C // beta
org $8B1B90D; db $8D // gamma
org $8B1B910; db $8E // sigma
org $8B1B913; db $8F // omega


//==============================================================================
// VWF hacks
//==============================================================================

// 32- to 16-bit access change for window flags
org $80BE16A; strh r2,[r4,#0]
org $80BE1FA; strh r2,[r6,#0]
org $80BE222; strh r6,[r1,#0]

//---------------------------------------------------------
// C980C hacks
//---------------------------------------------------------

// Custom codes check
org     $80CA2BC
bl      m2_vwf_entries.c980c_custom_codes

// Clear pixel X
org     $80CA2E6
bl      m2_vwf_entries.c980c_resetx

// Welding entry
org     $80CA448
bl      m2_vwf_entries.c980c_weld_entry
b       $80CA46C

// Disable X coordinate incrementing
org     $80CA48E
nop

//---------------------------------------------------------
// C87D0 hacks
//---------------------------------------------------------
org     $80C87DC
bl      m2_vwf_entries.c87d0_clear_entry


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
// tbd

m2_bits_to_nybbles:
incbin m2-bits-to-nybbles.bin

m2_nybbles_to_bits:
incbin m2-nybbles-to-bits.bin


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
incsrc m2-vwf-entries.asm
incsrc m2-formatting.asm
incsrc m2-customcodes.asm
