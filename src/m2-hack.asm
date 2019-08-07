.gba
.open "../bin/m12.gba",0x8000000

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
mov     r1,#0x10 //Tiles to clear
mov     r2,#0x10 //x
mov     r3,#0x11 //y
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

// Saturn text welding entry
.org    0x80CA39A
bl      weld_entry_saturn

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
.org 0x80CA6DC :: mov r2,0x69 // nine
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

// Saturn weld entry
.org    0x80D2F1A
bl      weld_entry_saturn

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

// Saturn weld entry
.org    0x80D301A
bl      weld_entry_saturn

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
// B96B8 hacks (Selected item action menu)
//---------------------------------------------------------

.org 0x80B998E :: bl b998e_get_itemstring_x

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
.org 0x80DB110 :: bl dae9c_king_0_the
.org 0x80DB156 :: bl db156_party_0_the //Not needed anymore, but is a good measure
.org 0x80DAE30 :: bl db04c_theflag :: nop :: nop
.org 0x80DAE9C :: bl dae9c_king_0_the
.org 0x80DAEDA :: bl daeda_party_0_the //Not needed anymore, but is a good measure
.org 0x80EC93C :: bl ec93c_party_0_the //Leveling up - Not needed anymore, but is a good measure
.org 0x80DCD5C :: bl dcd5c_theflag :: nop :: nop
.org 0x80DB08E :: bl db08e_theflagflag
.org 0x80DAE3A :: bl db08e_theflagflag
.org 0x80DCD66 :: bl db08e_theflagflag
.org 0x80C9C58 :: bl c9c58_9f_ad_minThe
.org 0x80C9C84 :: bl c9c58_9f_ad_minThe
.org 0x80CA442 :: bl ca442_store_letter

// Ignore the hard-coded Japanese "and cohorts"
.org 0x80DB0E6 :: b 0x80DB0FE

// Update musical note value (for Ness' Nightmare)
.org 0x80DAF12 :: cmp r0,0xAC

//---------------------------------------------------------
// BEB6C hacks (Goods inner menu)
//---------------------------------------------------------

.org 0x80BEB6C
push    {lr}
bl      goods_inner_process
pop     {pc}

//---------------------------------------------------------
// BF858 hacks (Goods outer menu)
//---------------------------------------------------------

.org 0x80BF858
push    {lr}
mov     r1,0
mov     r2,0
bl      goods_outer_process
pop     {pc}

//---------------------------------------------------------
// C0420 hacks (Goods outer menu for Tracy)
//---------------------------------------------------------

.org 0x80C0420
push    {lr}
mov     r1,1
mov     r2,0
bl      goods_outer_process
pop     {pc}

//---------------------------------------------------------
// C7CA4 hacks (Shop)
//---------------------------------------------------------
.org 0x80C7CA4
mov     r0,r8 //Window
ldr     r1,[sp,#0xC] //Items in shop
mov     r2,#0 //y_offset | r3 already has the item total for this window
bl      shop_print_items //Print the items
b       0x80C7E12 //Avoid the game's printing by jumping it

//---------------------------------------------------------
// BFE74 hacks (Goods outer menu for Give)
//---------------------------------------------------------
.org 0x80BFE74
push    {lr}
mov     r1,#1
mov     r2,#1
bl      goods_outer_process
pop     {pc}

//---------------------------------------------------------
// BA61C hacks (Fixes inventory when out of Give via B button)
//---------------------------------------------------------
.org 0x80BA61C
bl ba61c_get_print_inventory_window

//---------------------------------------------------------
// BA48E hacks (Fixes inventory when out of Give via text)
//---------------------------------------------------------
.org 0x80BA48E
bl ba48e_get_print_inventory_window

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
// EEB1A (load player name)
//---------------------------------------------------------

.org 0x80EEB1A
bl      eeb1a_player_name //Call the new routine
b       0x80EEB7A //Do the rest of the original routine

//---------------------------------------------------------
// End of battle hacks
//---------------------------------------------------------

.org 0x80cb936
bl      cb936_battle_won //Removes the game's ability to read the script instantly out of a won battle

.org 0x80a1f8c
bl      a1f8c_set_script_reading //Change the game's ability to read the script instantly a bit

.org 0x80b7702
bl      b7702_check_script_reading //Change the newly set value slowly and make it 0 when it's safe

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

//---------------------------------------------------------
// Carpainter's timing fix
//---------------------------------------------------------
.org 0x802A75F :: db 0x30 //Add 8 extra frames before the game can start reading again.

//---------------------------------------------------------
// Teleport header fix
//---------------------------------------------------------
.org 0x80C5DE0 :: bl c65da_clean_print //To:
.org 0x80C5E30 :: bl c6190_clean_print //Number on first entering the menu
.org 0x80C6190 :: bl c6190_clean_print //Number on page change
.org 0x80C5E04 :: nop :: strh r0,[r4,#0] :: add r4,#2 :: nop ::nop //Remove extra tile

//---------------------------------------------------------
// Stored Goods header fix
//---------------------------------------------------------
.org 0x80C656C :: mov r2,#0x10 :: mov r3,#0x11 :: bl c6570_clean_print_change_pos :: b 0x80C65C0 //Changes position and cleans tiles for Stored Goods
.org 0x80C65DA :: bl c65da_clean_print //Number on first entering the menu
.org 0x80C6996 :: bl c65da_clean_print //Number on page change

//---------------------------------------------------------
// Call header fix
//---------------------------------------------------------
.org 0x80BD26A :: bl c6190_clean_print //Call:

//---------------------------------------------------------
// Fix windows printing too many tiles due to not going off of pixels, but off of characters
//---------------------------------------------------------
.org 0x80C0B28 :: bl c0b28_fix_char_tiles //Status window
.org 0x80C009E :: bl c009e_fix_char_tiles //Give window
.org 0x80C4BD6 :: bl c4bd6_fix_char_tiles //Equip window
.org 0x80C42E0 :: bl c42e0_fix_char_tiles //Outer PSI window
.org 0x80C3FD8 :: bl c42e0_fix_char_tiles //Inner PSI window
.org 0x80C4448 :: bl c4448_fix_char_tiles //Inner PSI window - part 2
.org 0x80DBF36 :: bl c009e_fix_char_tiles //Battle menu window

//---------------------------------------------------------
// Proper dollar and 00 symbols for [9C FF]
//---------------------------------------------------------
.org 0x80B8AA0 :: mov r0,#0x54 //Dollar
.org 0x80B8AA6 :: mov r0,#0x56 //00

//---------------------------------------------------------
// Names hacks
//---------------------------------------------------------
//Change location of the names to allow 5-letter long characters and 6 letters long food, rockin and king
//Direct reference change
.org 0x80C98F8 :: dw m2_paula_name
.org 0x80C9908 :: dw m2_jeff_name
.org 0x80C9918 :: dw m2_poo_name
.org 0x80C9928 :: dw m2_food
.org 0x80C9938 :: dw m2_rockin
.org 0x80C9BC0 :: dw m2_king_name //Control Code for printing its name
.org 0x80DB134 :: dw m2_king_name //Action user related
.org 0x80DAEB8 :: dw m2_king_name //Action target related
.org 0x80133E8 :: dw m2_king_name //Cast Roll
.org 0x80C2368 :: dw m2_rockin
.org 0x80C2424 :: dw m2_rockin
.org 0x80C24E0 :: dw m2_rockin
.org 0x80D39AC :: dw m2_rockin

//Change the way the characters' names are called. Instead of number * 6, it's now number * 7
.org 0x80D6A72 :: lsl r1,r4,#3 :: sub r1,r1,r4 :: nop
.org 0x80D6948 :: lsl r1,r4,#3 :: sub r1,r1,r4 :: nop
.org 0x80D28B8 :: lsl r0,r6,#3 :: sub r0,r0,r6 :: nop
.org 0x80C4BC4 :: lsl r1,r0,#3 :: sub r1,r1,r0 :: nop
.org 0x80DB14A :: lsl r0,r1,#3 :: sub r0,r0,r1 :: nop
.org 0x80DAECE :: lsl r0,r1,#3 :: sub r0,r0,r1 :: nop
.org 0x80D336C :: lsl r0,r1,#3 :: sub r0,r0,r1 :: nop
.org 0x80D339C :: lsl r0,r1,#3 :: sub r0,r0,r1 :: nop
.org 0x80D33C4 :: lsl r1,r0,#3 :: sub r1,r1,r0 :: nop
.org 0x80D2EE2 :: lsl r1,r0,#3 :: sub r1,r1,r0 :: nop
.org 0x80BAB8A :: lsl r1,r5,#3 :: sub r1,r1,r5 :: nop
.org 0x80D6D96 :: lsl r1,r2,#3 :: sub r1,r1,r2 :: nop
.org 0x80D7096 :: lsl r1,r2,#3 :: sub r1,r1,r2 :: nop
.org 0x80EC92C :: lsl r0,r2,#3 :: sub r0,r0,r2 :: nop
.org 0x80B9C00 :: lsl r0,r2,#3 :: sub r0,r0,r2 :: nop
.org 0x80D68AA :: lsl r1,r4,#3 :: sub r1,r1,r4 :: nop
.org 0x80D6BE0 :: lsl r1,r4,#3 :: sub r1,r1,r4 :: nop
.org 0x80B9FAC :: lsl r0,r1,#3 :: sub r0,r0,r1 :: nop
.org 0x80B93F0 :: lsl r0,r1,#3 :: sub r0,r0,r1 :: nop
.org 0x80B9FE6 :: lsl r0,r7,#3 :: sub r0,r0,r7 :: nop
.org 0x80B932C :: lsl r1,r0,#3 :: sub r0,r1,r0 :: nop
.org 0x80C0B14 :: lsl r1,r0,#3 :: sub r1,r1,r0 :: nop
.org 0x80C008C :: lsl r1,r0,#3 :: sub r1,r1,r0 :: nop
.org 0x80C42CE :: lsl r1,r0,#3 :: sub r1,r1,r0 :: nop
.org 0x8013652 :: lsl r0,r1,#3 :: sub r0,r0,r1 :: nop
.org 0x80B9CB2 :: lsl r0,r1,#3 :: sub r0,r0,r1 :: nop
.org 0x80BA086 :: lsl r0,r1,#3 :: sub r0,r0,r1 :: nop
.org 0x80C97C0 :: lsl r4,r1,#3 :: sub r4,r4,r1 :: nop
.org 0x80B9316 :: lsl r0,r1,#3 :: sub r0,r0,r1 :: nop
.org 0x80D6B44 :: lsl r1,r4,#3 :: sub r1,r1,r4 :: nop
.org 0x80D6E3A :: lsl r1,r4,#3 :: sub r1,r1,r4 :: nop
.org 0x80D6ED0 :: lsl r1,r4,#3 :: sub r1,r1,r4 :: nop
.org 0x80C3FC6 :: lsl r1,r0,#3 :: sub r1,r1,r0 :: nop
.org 0x80C4436 :: lsl r1,r0,#3 :: sub r1,r1,r0 :: nop

//Change the way the characters' names are called. Instead of number * 6, it's now number * 7. These ones already received an lsl of 1 beforehand.
.org 0x80C0AC8 :: lsl r1,r1,#2 :: sub r1,r1,r5
.org 0x80C4B84 :: lsl r1,r1,#2 :: sub r1,r1,r5
.org 0x80C3F88 :: lsl r1,r1,#2 :: sub r1,r1,r5
.org 0x80C43FC :: lsl r1,r1,#2 :: sub r1,r1,r3
.org 0x80C0040 :: lsl r1,r1,#2 :: sub r1,r1,r3
.org 0x80C4296 :: lsl r1,r1,#2 :: sub r1,r1,r3
.org 0x80DBEFA :: lsl r2,r2,#2 :: sub r2,r2,r4
.org 0x80BEFCA :: lsl r1,r1,#2 :: sub r1,r1,r3
.org 0x80BFA3A :: lsl r1,r1,#2 :: sub r1,r1,r4

.org 0x80BD9AA :: add r0,r5,#7
.org 0x80BD9BA :: mov r1,#0xE
.org 0x80BD9CC :: add r6,#0x15

//Load proper addresses
.org 0x80C98C4 :: bl c98c4_load_1d7
.org 0x80C98CC :: mov r4,#0xEF
.org 0x80C98D4 :: bl c98d4_load_1e5

//Rockin's
.org 0x80C2196 :: mov r2,#0xFE

//Name writing
.org 0x80020B6 :: bl _2352_load_1d7
.org 0x80020C6 :: mov r0,#0xEF
.org 0x80020D6 :: bl _2372_load_1e5
.org 0x80020E8 :: add r0,#0xC0
.org 0x80020F8 :: add r0,#0x80
.org 0x8002108 :: add r0,#0x40

.org 0x80020AC :: mov r0,#5
.org 0x80020BC :: mov r0,#5
.org 0x80020CC :: mov r0,#5
.org 0x80020DC :: mov r0,#5

//Name loading
.org 0x8002214 :: bl _2352_load_1d7
.org 0x8002224 :: mov r0,#0xEF
.org 0x8002234 :: bl _2372_load_1e5
.org 0x8002246 :: mov r0,#0xF6
.org 0x8002258 :: mov r0,#0xFA
.org 0x800226A :: mov r0,#0xFE

.org 0x800220A :: mov r0,#5
.org 0x800221A :: mov r0,#5
.org 0x800222A :: mov r0,#5
.org 0x800223A :: mov r0,#5

//Name Reset change
.org 0x8002352 :: bl _2352_load_1d7
.org 0x8002362 :: mov r0,#0xEF
.org 0x8002372 :: bl _2372_load_1e5
.org 0x8002384 :: add r0,#0xC0
.org 0x8002394 :: add r0,#0x80
.org 0x80023A4 :: add r0,#0x40

.org 0x8002348 :: mov r0,#5
.org 0x8002358 :: mov r0,#5
.org 0x8002368 :: mov r0,#5
.org 0x8002378 :: mov r0,#5

//Change the maximum name size
.org 0x80DB154 :: mov r1,#7
.org 0x80DAED8 :: mov r1,#7
.org 0x80B9FB6 :: mov r1,#7
.org 0x80B9C0A :: mov r1,#7
.org 0x80B9320 :: mov r1,#7
.org 0x80B9CBC :: mov r1,#7
.org 0x80B9FF2 :: mov r1,#7
.org 0x80B93FA :: mov r1,#7
.org 0x80B9334 :: mov r1,#7
.org 0x80D28C6 :: mov r1,#7
.org 0x80BA090 :: mov r1,#7
.org 0x80EC93A :: mov r1,#7

.org 0x80B9FEE :: sub r1,#7

.org 0x80121DC :: cmp r2,#4
.org 0x8013672 :: cmp r5,#4
.org 0x80C0B0A :: cmp r2,#4 //Status window header
.org 0x80C4BBC :: cmp r2,#4 //Equip window header
.org 0x80C42C6 :: cmp r2,#4 //Outer PSI window header
.org 0x80C3FBE :: cmp r2,#4 //Inner PSI window header
.org 0x80C442E :: cmp r2,#4 //Inner PSI window - part 2 header
.org 0x80C0082 :: cmp r5,#4 //Give window header
.org 0x80DBF28 :: cmp r0,#4 //Battle menu window header
.org 0x80C97E2 :: cmp r1,#6
.org 0x80DAF3A :: cmp r0,#6
.org 0x80D33BC :: cmp r2,#6

//Default options auto-setup routine.
.org 0x80CB2F2 :: bl cb2f2_hardcoded_defaults :: b 0x80CB434

//Remove japanese name's storing and loading
.org 0x80C7524 :: nop
.org 0x80C752C :: nop
.org 0x80C76A2 :: mov r5,#0xFF
.org 0x80C76D0 :: mov r5,#0xFF
.org 0x80C76EA :: nop
.org 0x80C76F2 :: nop
.org 0x80C76FA :: nop
.org 0x80C7864 :: nop
.org 0x80C786C :: nop
.org 0x80C79C0 :: nop
.org 0x80D3AAE :: mov r0,#0xFF

//Select File name length
.org 0x8001F22 :: cmp r4,#4
.org 0x8001F3A :: cmp r4,#4

//Naming screen name length
.org 0x8004F54 :: mov r2,#5 //Ness
.org 0x8004F78 :: mov r0,#5 :: str r0,[sp,#0x18] :: bl _4f7c_window_selector //Paula
.org 0x8004F9C :: mov r0,#5 //Jeff
.org 0x8004FC0 :: mov r1,#5 //Poo

//Black bar hacks - Need to replace the position windows point at and move the >
//.org 0x80BD9DE :: mov r2,#0x16 //Ness
//.org 0x80BD9EA :: mov r2,#0x1B //Paula
//.org 0x80BD9F6 :: mov r2,#0x16 //Jeff
//.org 0x80BDA02 :: mov r2,#0x1B //Poo


//==============================================================================
// File select hacks
//==============================================================================

// Main file select window resize
.org 0x82B79BC :: dw 0x1C       // new window width
.org 0x8003998 :: mov r0,1      // new window x
.org 0x8003F92 :: mov r0,1
.org 0x80053DC :: mov r0,1
.org 0x8003A04 :: mov r0,1
.org 0x8003B40 :: mov r0,0x10   // new cursor x
.org 0x86DB070 :: .incbin "data/m2-fileselect-template.bin"

.org 0x86D9808
.incbin "data/m2-fileselect-tileset.bin"

// Formatting
.org 0x80021E8 :: bl format_file_string
.org 0x8002284 :: bl format_file_string

// Printing
.org 0x80038CC :: mov r2,0x40 :: bl wrapper_file_string
.org 0x80038DE :: mov r2,0x40 :: bl wrapper_file_string
.org 0x80038F2 :: mov r2,0x40 :: bl wrapper_file_string

// Bump file select cursor up by 3 pixels
.org 0x8003844 :: add r0,r5,1

// File select options
.org 0x8004092 :: bl _4092_print_window //Printing
.org 0x80041D4 :: bl _41D4_cursor_X //New cursor's X

//Text Speed options
.org 0x8003BBC :: bl _4092_print_window //Printing
.org 0x82B79D0 :: dw 0x10 //new window width
.org 0x86DB0FC :: .incbin "data/m2-textspeed-template.bin"

//Text Flavour options
.org 0x8003D8A :: bl _4092_print_window //Printing
.org 0x8003D86 :: mov r1,#4 //new window Y
.org 0x8003DB6 :: mov r1,#4
.org 0x8003E0C :: mov r1,#4
.org 0x8003E8C :: mov r1,#4
.org 0x8003EF8 :: mov r1,#4
.org 0x80053F2 :: mov r1,#4
.org 0x82B79E4 :: dw 0xF //new window width
.org 0x82B79E8 :: dw 0x10 //new window height
.org 0x86DB1F8 :: .incbin "data/m2-flavour-template.bin"

//Delete
.org 0x8004410 :: mov r1,#3 :: mov r2,#0x15 :: bl wrapper_delete_string
.org 0x800441E :: bl _4092_print_window //Printing
.org 0x82B7AFC :: dw 0x15 //new window width
.org 0x86DBE8C :: .incbin "data/m2-delete-template.bin"

//Copy
.org 0x8004294 :: bl _4298_print_window //Printing - 1 slot available
.org 0x80042BA :: bl _4092_print_window //Printing - 2 slots available
.org 0x8004268 :: mov r2,#0x2 :: bl wrapper_copy_string

//==============================================================================
// Data files
//==============================================================================

.org m2_default_names
.incbin "data/m2-default-names.bin"

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
.definelabel m2_old_paula_name      ,0x3001F16
.definelabel m2_paula_name          ,0x3001F17
.definelabel m2_old_jeff_name       ,0x3001F1C
.definelabel m2_jeff_name           ,0x3001F1E
.definelabel m2_old_poo_name        ,0x3001F22
.definelabel m2_poo_name            ,0x3001F25
.definelabel m2_old_king_name       ,0x3001F28
.definelabel m2_king_name           ,0x3001F2C
.definelabel m2_old_food            ,0x3001F30
.definelabel m2_food                ,0x3001F34
.definelabel m2_old_rockin          ,0x3001F3A
.definelabel m2_rockin              ,0x3001F3C
.definelabel m2_old_japanese_name   ,0x3001F42
.definelabel m2_cstm_last_printed   ,0x3001F4F
.definelabel m2_player1             ,0x3001F50
.definelabel m2_script_readability  ,0x3004F08
.definelabel m2_active_window_pc    ,0x3005264
.definelabel m2_setup_naming_mem    ,0x8001D5C
.definelabel m2_soundeffect         ,0x8001720
.definelabel m2_copy_names_perm_mem ,0x8002088
.definelabel m2_reset_names         ,0x8002318
.definelabel m2_copy_name_perm_mem  ,0x80023C0
.definelabel m2_main_menu_handler   ,0x80023F8
.definelabel m2_change_naming_space ,0x8004E08
.definelabel m2_copy_name_temp_mem  ,0x8004E34
.definelabel m2_insert_default_name ,0x8005708
.definelabel m2_enable_script       ,0x80A1F6C
.definelabel m2_sub_a334c           ,0x80A334C
.definelabel m2_sub_a3384           ,0x80A3384
.definelabel m2_get_selected_item   ,0x80A469C
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
.definelabel m2_formatnumber        ,0x80CA65C
.definelabel m2_clearwindowtiles    ,0x80CA834
.definelabel m2_menuwindow          ,0x80C1C98
.definelabel m2_resetwindow         ,0x80BE490
.definelabel m2_hpwindow_up         ,0x80D3F0C
.definelabel m2_curhpwindow_down    ,0x80D41D8
.definelabel m2_div                 ,0x80F49D8
.definelabel m2_remainder           ,0x80F4A70
.definelabel m2_items               ,0x8B1D62C
.definelabel m2_default_names       ,0x82B9330

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

.close
