.gba
.open "m12.gba",0x8000000

//==============================================================================
// Relocation hacks
//==============================================================================

// Move the weird box font from 0xFCE6C
.org 0x80B3274 :: dw m2_font_relocate


//==============================================================================
// Font hacks
//==============================================================================

.org 0x8AFED84 :: .incbin "m2-mainfont1-empty.bin"
.org 0x8B0F424 :: .incbin "m2-mainfont2-empty.bin"
.org 0x8B13424 :: .incbin "m2-mainfont3-empty.bin"
.org 0x8B088A4 :: .incbin "m2-shifted-cursor.bin"

// Greek letters
.org 0x8B1B907 :: db 0x8B // alpha
.org 0x8B1B90A :: db 0x8C // beta
.org 0x8B1B90D :: db 0x8D // gamma
.org 0x8B1B910 :: db 0x8E // sigma
.org 0x8B1B913 :: db 0x8F // omega


//==============================================================================
// VWF hacks
//==============================================================================

// 32- to 16-bit access change for window flags
.org 0x80BE16A :: strh r2,[r4]
.org 0x80BE1FA :: strh r2,[r6]
.org 0x80BE222 :: strh r6,[r1]

// PSI class window size
.org    0x80B7820
mov     r1,4
mov     r2,1
mov     r3,6

//---------------------------------------------------------
// C0A5C hacks (status window)
//---------------------------------------------------------

.include "m2-status-initial.asm"
.include "m2-status-switch.asm"

//---------------------------------------------------------
// BAC18 hacks (status window switching)
//---------------------------------------------------------

.org 0x80BACFC :: bl bac18_redraw_status
.org 0x80BADE6 :: bl bac18_redraw_status
.org 0x80BACEE :: bl bac18_clear_psi
.org    0x80BADC8
bl      bac18_check_button
b       0x80BADD8

//---------------------------------------------------------
// BAEF8 hacks (equip window)
//---------------------------------------------------------

// Erase offense change
.macro erase_offense
    mov     r0,0xC
    mov     r1,0xB
    mov     r2,4
    bl      print_blankstr
.endmacro

.macro erase_defense
    mov     r0,0xC
    mov     r1,0xD
    mov     r2,4
    bl      print_blankstr
.endmacro

.org 0x80BB216 :: erase_offense
.org 0x80BB38C :: erase_offense
.org 0x80BB4C6 :: erase_offense
.org 0x80BB5FC :: erase_offense
.org 0x80BBAAE :: erase_offense
.org 0x80BBBF6 :: erase_offense
.org 0x80BBD54 :: erase_offense

// Erase defense change
.org 0x80BB226 :: erase_defense
.org 0x80BBABE :: erase_defense
.org 0x80BBC06 :: erase_defense
.org 0x80BBD64 :: erase_defense

// Erase offense/defense after changing equipment
.org 0x80BB3E2 :: bl baef8_reequip_erase
.org 0x80BB518 :: bl baef8_reequip_erase
.org 0x80BBB12 :: bl baef8_reequip_erase
.org 0x80BBC70 :: bl baef8_reequip_erase

//---------------------------------------------------------
// C5500 hacks (equip window switching)
//---------------------------------------------------------

// Clear offense/defense changes when moving cursor
.org 0x80C5AA2 :: bl c5500_clear_up
.org 0x80C5B12 :: bl c5500_clear_down

// Don't draw equip icon
.org 0x80C5A1A :: nop
.org 0x80C5A28 :: nop

//---------------------------------------------------------
// C1FBC hacks (PSI window)
//---------------------------------------------------------

.org 0x80C203E :: mov r1,0x14 // new PSI name entry length
.org 0x80C21B4 :: mov r1,0x14
.org 0x80C224A :: mov r1,0x14
.org 0x80C229E :: mov r1,0x14

// Draw PSI Rockin
.org    0x80C2192
mov     r2,r8
str     r2,[sp]
mov     r2,0xFD
lsl     r2,r2,1
add     r0,r6,r2
mov     r1,0x71
mov     r2,8
bl      print_string

//---------------------------------------------------------
// C239C hacks (print PSI name)
//---------------------------------------------------------

.org 0x80C23AA :: lsr r2,r2,0xD                             // tiles-to-pixels
.org 0x80C23AE :: lsr r6,r3,0xD                             // tiles-to-pixels
.org 0x80C23CE :: bl c239c_print_psi :: nop :: nop :: nop
.org 0x80C23DA :: add r4,17                                 // pixel width of "PSI "
.org 0x80C23F0 :: bl print_string_hlight_pixels             // print rockin'
.org 0x80C2402 :: mov r0,3 :: lsl r0,r0,0x10                // pixel width of space
.org 0x80C242E :: mov r0,0x14                               // new PSI name entry length
.org    0x80C2448
bl      print_string_hlight_pixels // print PSI name
mov     r2,r1                      // record X width
add     r2,3                       // add a space
.org 0x80C2468 :: bl print_string_hlight_pixels

//---------------------------------------------------------
// C438C hacks (PSI window cursor movement)
//---------------------------------------------------------

.org 0x80C4580 :: bl c438c_moveup
.org 0x80C4642 :: bl c438c_movedown
.org 0x80C4768 :: bl c438c_moveright
.org 0x80C48B2 :: bl c438c_moveleft

//---------------------------------------------------------
// PSI target window hacks
//---------------------------------------------------------

// PSI target length hack
.org 0x80B8B12 :: mov r0,0x14
.org 0x80C24EE :: mov r1,0x14

// Fix PSI target offset calculation
.org 0x80B8B08
mov     r1,100
mul     r1,r2
nop
nop

// Make PP cost use correct number values
.org    0x80CA732
add     r1,0x60

// Make PP cost use the correct space value if there's only one digit
.org    0x80CA712
mov     r0,0x50

//---------------------------------------------------------
// B8BBC hacks (PSI window)
//---------------------------------------------------------

// Redraw main menu when exiting PSI target window
.org 0x80B8E3A :: bl b8bbc_redraw_menu_2to1

// Redraw main menu when entering PSI target window
.org 0x80B8CF8 :: bl b8bbc_redraw_menu_13to2 // 1 to 2
.org 0x80B920C :: bl b8bbc_redraw_menu_13to2 // 3 to 2

//---------------------------------------------------------
// C4B2C hacks (Equip window render)
//---------------------------------------------------------

// Start equipment at the 6th tile instead of 5th
.org 0x80C4C96 :: mov r2,6 // Weapon
.org 0x80C4D1C :: mov r2,6 // Body
.org 0x80C4DA4 :: mov r2,6 // Arms
.org 0x80C4E2C :: mov r2,6 // Other

// Only render (None) if necessary
.org    0x80C4C0C
bl      c4b2c_skip_nones
b       0x80C4C58

// Don't render equip symbols
.org 0x80C4CD0 :: nop
.org 0x80C4CDE :: nop
.org 0x80C4D58 :: nop
.org 0x80C4D66 :: nop
.org 0x80C4DE0 :: nop
.org 0x80C4DEE :: nop
.org 0x80C4E68 :: nop
.org 0x80C4E76 :: nop

// Widen the who/where/etc window
.org 0x80B77B4 :: mov r3,5
.org 0x80BA9E2 :: mov r3,5

//---------------------------------------------------------
// C4B2C hacks (Equip window loop)
//---------------------------------------------------------

.org 0x80C4F80 :: bl c4b2c_clear_left
.org 0x80C4F84 :: bl c4b2c_clear_right

//---------------------------------------------------------
// C980C hacks (main character printing)
//---------------------------------------------------------

// Reset pixel X during scroll
.org 0x80C9858 :: bl c980c_resetx_newline
.org 0x80C9BF0 :: bl c980c_resetx_scroll
.org 0x80C9D18 :: bl c980c_resetx_newline
.org 0x80CA336 :: bl c980c_resetx_newline

// Reset pixel X during a newline
.org    0x80C9CC4
bl      c980c_resetx_newline

// Other reset X
.org 0x80C9D62 :: bl c980c_resetx_other
.org 0x80C9D76 :: bl c980c_resetx_other2
.org 0x80C9EEC :: bl c980c_resetx_other3
.org 0x80C9F34 :: bl c980c_resetx_other3
.org 0x80CA204 :: bl c980c_resetx_other4
.org 0x80CA274 :: bl c980c_resetx_other4
.org 0x80CA30E :: bl c980c_resetx_newline

// Custom codes check
.org    0x80CA2BC
bl      c980c_custom_codes

// Reset pixel X when redrawing the window
.org    0x80CA2E6
bl      c980c_resetx

// Welding entry
.org    0x80CA448
bl      c980c_weld_entry
b       0x80CA46C

// Disable X coordinate incrementing
.org    0x80CA48E
nop

//---------------------------------------------------------
// C8FFC hacks (main string printing)
//---------------------------------------------------------

// Custom codes check
.org    0x80C90A2
bl      c8ffc_custom_codes

// Welding entry
.org    0x80C9114
bl      c8ffc_weld_entry
b       0x80C9144

// Integer-to-char changes
.org 0x80CA67C :: mov r3,0x50 // space
.org 0x80CA69C :: mov r2,0x60 // zero
.org 0x80CA78A :: mov r0,0x60 // zero
.org 0x80CA7AC :: mov r2,0x69 // nine
.org 0x80CA7EC :: sub r1,0xA0

//---------------------------------------------------------
// C87D0 hacks (draw blank window)
//---------------------------------------------------------

.org    0x80C87DC
bl      c87d0_clear_entry

//---------------------------------------------------------
// C9634 hacks (string printing)
//---------------------------------------------------------

.org    0x80C967E
bl      c9634_resetx

//---------------------------------------------------------
// C96F0 hacks (string printing with highlight)
//---------------------------------------------------------

.org    0x80C9714
lsl     r3,r3,1 // change from row coords to tile coords
ldrh    r1,[r0,0x22]
add     r1,r1,r2
lsl     r1,r1,3 // r1 = tile_x * 8
ldrh    r2,[r0,0x24]
add     r2,r2,r3
lsl     r2,r2,3 // r2 = tile_y * 8
mov     r0,r6
bl      print_string
mov     r7,r0
b       0x80C9788

//---------------------------------------------------------
// CA4BC hacks (scroll text)
//---------------------------------------------------------

.org 0x80CA55E :: bl ca4bc_erase_tile_short
.org 0x80CA60E :: bl ca4bc_copy_tile_up
.org 0x80CA626 :: bl ca4bc_erase_tile

//---------------------------------------------------------
// D2E94 hacks (print party character name)
//---------------------------------------------------------

.org    0x80D2F24
mov     r1,r6
mov     r2,r7
mov     r0,r4
bl      weld_entry
b       0x80D2F52

// Disable X increment
.org 0x80D2F5A :: nop

//---------------------------------------------------------
// D2FA0 hacks (print item)
//---------------------------------------------------------

.org    0x80D3044
mov     r0,r4
mov     r1,r6
bl      weld_entry
b       0x80D3072

// Disable X increment
.org 0x80D307A :: nop

//---------------------------------------------------------
// D30C4 hacks (print number)
//---------------------------------------------------------

.org    0x80D314A
mov     r0,r5
mov     r1,r7
bl      weld_entry
b       0x80D3178

// Disable X increment
.org 0x80D3180 :: nop

//---------------------------------------------------------
// D332C hacks (print name)
//---------------------------------------------------------

.org    0x80D34E8
mov     r0,r5
mov     r1,r4
bl      weld_entry
b       0x80D3514

// Disable X increment
.org 0x80D351A :: nop

// Don't print [1E 20] after the name if there are multiple people
.org 0x80D3418 :: b 0x80D348C

//---------------------------------------------------------
// D3934 hacks (print PSI name)
//---------------------------------------------------------

.org 0x80D39BA :: mov r0,0x14 // PSI name length

// Weld entry
.org    0x80D39E2
mov     r0,r4
mov     r1,r5
bl      weld_entry
b       0x80D3A14

// Print a space before the Greek letter
.org 0x80D39D4 :: bl d3934_print_space

// Battle command hacks
.org 0x8B1F4C8 :: db 0x11 // Extend command window width two tiles (Normal)
.org 0x8B1F4CC :: db 0x16 // Extend command window width two tiles (Paula paralyzed leader)
.org 0x80D7A56 :: mov r1,4 // Move PSI class window left one tile
.org 0x80D7A5A :: mov r3,6 // Extend PSI class window width one tile
.org 0x80DC038 :: add r5,0x30 // String address calculation
.org 0x80DC0A8 :: add r1,0x60 // String address calculation

.org 0x80DC27C :: lsl r1,r2,4 :: nop // String address calculation
.org 0x80DC2AC :: lsl r1,r2,4 :: nop // String address calculation

.org 0x80DCC36 :: mov r2,2 // "to X" position
.org 0x80DCCE0 :: mov r2,2 // "to the Front Row" position

.org 0x80E079E :: bl e06ec_clear_window
.org 0x80E0888 :: bl e06ec_redraw_psi
.org 0x80E0A16 :: bl e06ec_redraw_bash_psi

//---------------------------------------------------------
// BD918 hacks (battle setup)
//---------------------------------------------------------

// Longest enemy name is 24 letters + 2 for the end code, for 26 total
// We might have "The " later on, so make that 30
// " and its cohorts" makes that 46
// Let's round it to a nice 64: we need to allocate that many bytes for user
// and target strings on the heap. The game only allocates 16 each.
// Goal: allocate an extra 128 bytes and fix all the offsets to the user/target
// strings. We'll store the user string at +0x4C0 and the target string at +0x500.
.org 0x80BD97A :: mov r0,0xA8 // malloc an extra 128 bytes for longer user/target strings

// Fix user/target pointers
.org 0x80C9942 :: bl c980c_user_pointer
.org 0x80C9954 :: bl c980c_target_pointer
.org 0x80EBFDC :: bl ebfd4_user_pointer :: b 0x80EBFFA
.org 0x80EC004 :: push {lr} :: bl ec004_user_pointer
.org 0x80EC018 :: bl ec010_target_pointer :: b 0x80EC038
.org 0x80EC046 :: push {lr} :: bl ec046_target_pointer

// Length fixes
.org 0x80DAE02 :: add sp,-0x40
.org 0x80DAE08 :: mov r2,0x3E
.org 0x80DAE38 :: mov r2,0x3A
.org 0x80DAEA2 :: mov r1,0x3E
.org 0x80DAEDE :: add sp,0x40

.org 0x80DB04E :: add sp,-0x40
.org 0x80DB058 :: mov r2,0x3E
.org 0x80DB08C :: mov r2,0x3A
.org 0x80DB116 :: mov r1,0x3E
.org 0x80DB15A :: add sp,0x40

.org 0x80DCD02 :: add sp,-0x40
.org 0x80DCD0C :: mov r2,0x3C
.org 0x80DCD64 :: mov r2,0x3A
.org 0x80DCDA2 :: mov r1,0x3E
.org 0x80DCDA8 :: add sp,0x40

// Add a space between enemy name and letter
.org 0x80DCD94 :: bl dcd00_enemy_letter
.org 0x80DCD9A :: strb r0,[r5,2]
.org 0x80DCD9E :: strb r0,[r5,3]

.org 0x80DAE7E :: bl dae00_enemy_letter
.org 0x80DAE84 :: strb r0,[r4,2]
.org 0x80DAE88 :: strb r0,[r4,3]

.org 0x80DB0CE :: bl dae00_enemy_letter
.org 0x80DB0D2 :: strb r5,[r4,2]
.org 0x80DB0D6 :: strb r0,[r4,3]

// "The" flag checks
.org 0x80DB084 :: bl db04c_theflag :: nop :: nop

// Ignore the hard-coded Japanese "and cohorts"
.org 0x80DB0E6 :: b 0x80DB0FE


//==============================================================================
// Data files
//==============================================================================

.org 0x8B2C000

// Box font relocation
m2_font_relocate:
.incbin "m2-font-relocate.bin"

// Co-ordinate table
m2_coord_table:
.incbin "m2-coord-table.bin"

// EB fonts
m2_font_table:
dw     m2_font_main
dw     m2_font_saturn

m2_font_main:
.incbin "m2-font-main.bin"

m2_font_saturn:
.incbin "m2-font-saturn.bin"

// EB font heights
m2_height_table:
db     0x02, 0x02, 0x01, 0x00    // last byte for alignment

// EB font widths
m2_widths_table:
dw     m2_widths_main
dw     m2_widths_saturn

m2_widths_main:
.incbin "m2-widths-main.bin"

m2_widths_saturn:
// tbd

m2_bits_to_nybbles:
.incbin "m2-bits-to-nybbles.bin"

m2_nybbles_to_bits:
.incbin "m2-nybbles-to-bits.bin"

m2_enemy_attributes:
.incbin "m2-enemy-attributes.bin"


//==============================================================================
// Code files
//==============================================================================

.org 0x80FCE6C
.include "m2-vwf.asm"
.include "m2-vwf-entries.asm"
.include "m2-formatting.asm"
.include "m2-customcodes.asm"

.close
