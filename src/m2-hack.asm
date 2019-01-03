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

.org 0x8AFED84 :: .incbin "data/m2-mainfont1-empty.bin"
.org 0x8B0F424 :: .incbin "data/m2-mainfont2-empty.bin"
.org 0x8B13424 :: .incbin "data/m2-mainfont3-empty.bin"
.org 0x8B088A4 :: .incbin "data/m2-shifted-cursor.bin"
.org 0x8B03384 :: .incbin "data/m2-header-bg.bin"

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
// BF858 hacks (goods window)
//---------------------------------------------------------

// Skip the tile-by-tile nonsense and use existing string printing subs
.org 0x80BFB08 :: mov r4,r0 :: nop
.org 0x80BFB10 :: b 0x80BFB34

.org    0x80BFB34
bl      bf858_goods
b       0x80BFB84 // Skip the remaining nonsense

// Skip the blank tile drawing after item names
.org 0x80BFBDA :: b 0x80BFBFA

// Only use as many tiles as needed in the tilemap for name headers
.org 0x80BFA52 :: bl bf858_name_header :: b 0x80BFA86

//---------------------------------------------------------
// C5500 hacks (equip window switching)
//---------------------------------------------------------

// Clear offense/defense changes when moving cursor
.org 0x80C5AA2 :: bl c5500_clear_up
.org 0x80C5B12 :: bl c5500_clear_down

// Don't draw equip icon
.org 0x80C5A1A :: nop
.org 0x80C5A28 :: nop

// Draw equipment window header
.org 0x80C55CE :: b 0x80C55F8
.org    0x80C55F8
mov     r4,r0
mov     r0,r9
bl      clear_window_header
mov     r0,r4
mov     r1,r6 // tilemap
mov     r2,r9 // vram
mov     r3,r7 // window
bl      print_equip_header
mov     r6,r0
b       0x80C5726

//---------------------------------------------------------
// C1FBC hacks (PSI window)
//---------------------------------------------------------

.org 0x80C203E :: mov r1,0x14 // new PSI name entry length
.org 0x80C2096 :: mov r1,0x14
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

// Disable newline if the text overflows
.org 0x80CA2FA :: nop

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
lsl     r0,r0,16
lsr     r7,r0,16
b       0x80C9788

//---------------------------------------------------------
// CA4BC hacks (scroll text)
//---------------------------------------------------------

.org 0x80CA55E :: bl ca4bc_erase_tile_short
.org 0x80CA60E :: bl ca4bc_copy_tile_up
.org 0x80CA626 :: bl ca4bc_erase_tile

//---------------------------------------------------------
// CAB90 hacks (print window header string)
//---------------------------------------------------------

.org    0x80CAB90
push    {lr}
lsl     r2,r2,3
lsl     r3,r3,3 // tiles to pixels
bl      print_window_header_string
add     r0,7
lsr     r0,r0,3 // pixels to tiles
pop     {pc}

//---------------------------------------------------------
// CABF8 hacks (print checkerboard string)
//---------------------------------------------------------

.org 0x80CABF8 :: push {r4-r7,lr}
.org    0x80CAC0C
mov     r7,0
add     sp,-4
b       @@print_checkerboard_check

@@print_checkerboard_skip:
add     r4,1

@@print_checkerboard_loop:
ldrb    r0,[r4]
sub     r0,0x50
mov     r1,r5
add     r2,r6,1
mov     r3,6
str     r3,[sp]
mov     r3,3
bl      print_character_to_ram
add     r6,r0,r6
add     r7,1
add     r4,1

@@print_checkerboard_check:
ldrb    r0,[r4,1]
cmp     r0,0xFF
bne     @@print_checkerboard_loop
ldrb    r0,[r4]
cmp     r0,0
bne     @@print_checkerboard_skip

add     r0,r6,7
lsr     r0,r0,3 // number of tiles used
add     sp,4
pop     {r4-r7,pc}

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
// D31F8 hacks (print money balance)
//---------------------------------------------------------

.org 0x80D327E
ldrb    r0,[r7]
bl      decode_character
mov     r1,r5
bl      print_character_to_window
b       0x80D32AC

.org 0x80D32B2 :: b 0x80D32B8

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
// D3560 hacks (print money balance)
//---------------------------------------------------------

.org 0x80D35BA
bl      decode_character
mov     r1,r5
bl      print_character_to_window
b       0x80D35EA

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
// B89EC hacks (print current cash balance)
//---------------------------------------------------------

.org 0x80B8A06
mov     r2,r1
mov     r1,0x30 // right-align to 48 pixels
bl      format_cash_window
b       0x80B8A2E

.org 0x80B785C :: mov r0,0xC // allocate 2 extra bytes for cash window string
.org 0x80B786C :: mov r3,6   // make window 1 fewer tiles wide

//---------------------------------------------------------
// [68 FF] - clear window
//---------------------------------------------------------

.org m2_clearwindowtiles
push    {r4,lr}
mov     r4,r0

// Clear out the pixel data
bl      clear_window

// Reset the X/Y printing coordinates
mov     r0,0
strh    r0,[r4,0x2A]
strh    r0,[r4,0x2C]
pop     {r4,pc}

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

//---------------------------------------------------------
// BEB6C hacks (Goods sub-menu)
//---------------------------------------------------------

// When entering first sub-menu:
.org 0x80BEC5E :: nop // Don't clear upper letter tile
.org 0x80BEC6A :: nop // Don't clear lower letter tile
.org 0x80BF050 :: nop :: nop // Don't clear the window
.org 0x80BF0FE :: nop // Don't print upper letter tile
.org 0x80BF10E :: nop // Don't print lower letter tile
.org 0x80BF14C :: nop // Don't print upper equip tile
.org 0x80BF15C :: nop // Don't print lower equip tile

//---------------------------------------------------------
// C1C98 hacks (menu selection)
//---------------------------------------------------------

// Print the selection menu string
.org 0x80C1CA6
ldr     r7,=0x3005270
ldr     r6,=0x30051EC
ldr     r5,=0x3005228
bl      print_menu_string
ldr     r0,=0x3002500
mov     r10,r0
b       0x80C1D20
.pool

.org 0x80C8EFC
ldrh    r1,[r5,0x2C]
mov     r0,0
ldrh    r2,[r5,0x26]
mov     r3,r5
bl      print_blankstr_window
b       0x80C8FE8

//---------------------------------------------------------
// BCF00 hacks (number selection menu)
//---------------------------------------------------------

// Skip printing the first four columns of blank tiles
.org 0x80BCF88 :: nop
.org 0x80BCF98 :: nop
.org 0x80BCFA4 :: nop
.org 0x80BCFAE :: nop
.org 0x80BCFBA :: nop
.org 0x80BCFC6 :: nop
.org 0x80BCFD0 :: nop
.org 0x80BCFD8 :: nop

// Print dollar sign, zeroes, and 00 symbol
.org 0x80BCFDE
ldr     r1,=0x3005238
ldr     r0,[r1]          // Get window pointer
mov     r1,r9
bl      print_number_menu
b       0x80BD084
.pool

// Clear number selector row
.org 0x80BD096
// [r4 + 8] = window
ldr     r0,[r4,8]
bl      clear_number_menu
b       0x80BD122

// Clear border tiles

//---------------------------------------------------------
// C9444 hacks (print number selection menu)
//---------------------------------------------------------

// Print the proper character
.org 0x80C956C
push    {r2}
// r0 = digit, r6 = window
mov     r1,r6
bl      print_number_menu_current
pop     {r2}
ldr     r3,=0x3005228
ldr     r4,=0x30051EC
ldrh    r3,[r3]
b       0x080C959A
.pool

//---------------------------------------------------------
// Teleport window hacks
//---------------------------------------------------------

// Note that the teleport table pointer has 6 instances in the ROM,
// but we are only changing two of them in m12-teleport-names.json.
// This is because the other four pointers are used for accessing
// the teleport flag/coord data in the table instead of the text.
// We need a couple hacks to make this work...

.org 0x80C5E8A :: ldr r7,[pc,0xC8]  // This is used for text; load from one of the
                                    // pointers that we DID change (previously it
                                    // loaded from a pointer that we didn't change)

.org 0x80C5D8A
lsl     r1,r0,4                     // Text entries are now 16 bytes each, so multiply by 16
ldr     r7,[pc,0x1C4]               // ... to make room for loading r7 with the text pointer
add     r1,r1,r7
ldrb    r0,[r1]
ldr     r7,[pc,0x13C]               // The game uses r7 as the data pointer when looping back,
                                    // so let's sneak the data pointer in here before it loops

.org 0x80C5E96
lsl     r0,r1,4
nop
nop

.org 0x80C5F2C
lsl     r0,r1,4
nop
nop

.org 0x80C620C
lsl     r0,r1,4
nop
nop

//==============================================================================
// Data files
//==============================================================================

.org 0x8B2C000

// Box font relocation
m2_font_relocate:
.incbin "data/m2-font-relocate.bin"

// Co-ordinate table
m2_coord_table:
.incbin "data/m2-coord-table.bin"

// EB fonts
m2_font_table:
dw      m2_font_main
dw      m2_font_saturn
dw      m2_font_big
dw      m2_font_battle
dw      m2_font_tiny

m2_font_main:
.incbin "data/m2-font-main.bin"
m2_font_saturn:
.incbin "data/m2-font-saturn.bin"
m2_font_big:
.incbin "data/m2-font-big.bin"
m2_font_battle:
.incbin "data/m2-font-battle.bin"
m2_font_tiny:
.incbin "data/m2-font-tiny.bin"

// EB font dimensions
m2_font_widths:
db      2, 2, 2, 1, 1
.align 4

m2_font_heights:
db      2, 2, 2, 2, 1
.align 4

// EB font widths
m2_widths_table:
dw      m2_widths_main
dw      m2_widths_saturn
dw      m2_widths_big
dw      m2_widths_battle
dw      m2_widths_tiny

m2_widths_main:
.incbin "data/m2-widths-main.bin"
m2_widths_saturn:
.incbin "data/m2-widths-saturn.bin"
m2_widths_big:
.incbin "data/m2-widths-big.bin"
m2_widths_battle:
.incbin "data/m2-widths-battle.bin"
m2_widths_tiny:
.incbin "data/m2-widths-tiny.bin"

m2_bits_to_nybbles:
.incbin "data/m2-bits-to-nybbles.bin"

m2_nybbles_to_bits:
.incbin "data/m2-nybbles-to-bits.bin"

m2_enemy_attributes:
.incbin "data/m2-enemy-attributes.bin"


//==============================================================================
// Existing subroutines/data
//==============================================================================

.definelabel m2_ness_goods          ,0x3001D54
.definelabel m2_ness_exp            ,0x3001D70
.definelabel m2_ness_maxhp          ,0x3001D84
.definelabel m2_ness_curhp          ,0x3001D86
.definelabel m2_ness_maxpp          ,0x3001D8C
.definelabel m2_ness_curpp          ,0x3001D8E
.definelabel m2_paula_goods         ,0x3001DC0
.definelabel m2_jeff_goods          ,0x3001E2C
.definelabel m2_poo_goods           ,0x3001E98
.definelabel m2_ness_name           ,0x3001F10
.definelabel m2_paula_name          ,0x3001F16
.definelabel m2_jeff_name           ,0x3001F1C
.definelabel m2_poo_name            ,0x3001F22
.definelabel m2_king_name           ,0x3001F28
.definelabel m2_food                ,0x3001F30
.definelabel m2_rockin              ,0x3001F3A
.definelabel m2_player1             ,0x3001F50
.definelabel m2_active_window_pc    ,0x3005264
.definelabel m2_soundeffect         ,0x8001720
.definelabel m2_psitargetwindow     ,0x80B8AE0
.definelabel m2_isequipped          ,0x80BC670
.definelabel m2_swapwindowbuf       ,0x80BD7AC
.definelabel m2_strlookup           ,0x80BE260
.definelabel m2_initwindow          ,0x80BE458
.definelabel m2_statuswindow_numbers,0x80C0A5C
.definelabel m2_psiwindow           ,0x80C1FBC
.definelabel m2_drawwindow          ,0x80C87D0
.definelabel m2_printstr            ,0x80C9634
.definelabel m2_printstr_hlight     ,0x80C96F0
.definelabel m2_printnextch         ,0x80C980C
.definelabel m2_scrolltext          ,0x80CA4BC
.definelabel m2_clearwindowtiles    ,0x80CA834
.definelabel m2_menuwindow          ,0x80C1C98
.definelabel m2_resetwindow         ,0x80BE490

//==============================================================================
// Code files
//==============================================================================

.org 0x80FCE6C
.include "syscalls.asm"
.include "m2-vwf.asm"
.include "m2-vwf-entries.asm"
.include "m2-formatting.asm"
.include "m2-customcodes.asm"
.include "m2-compiled.asm"
.include "m2-goods.asm"

.close
