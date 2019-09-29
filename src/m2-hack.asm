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
.org 0x8B03964 :: .incbin "data/m2-header-bg-sigle-tile.bin"
.org 0x8B03D64 :: .incbin "data/m2-header-bg-sigle-tile.bin"
.org 0x8B03DE4 :: .incbin "data/m2-status-symbols.bin"

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
// Main window hacks
//---------------------------------------------------------

.org 0x80B7D9A :: bl b7d9a_main_window_manage_input
.org 0x80B7DD2 :: bl printCashWindow
//.org 0x80B8A36 :: bl initWindow_buffer //Money window
//.org 0x80B8A3C :: bl print_window_with_buffer
.org 0x80B8890 :: bl print_window_with_buffer :: bl b8894_printCashWindowAndStore //Main window + Cash Window out of Status menu
.org 0x80B8664 :: bl print_window_with_buffer :: bl b8894_printCashWindowAndStore //Main window + Cash Window out of PSI menu
.org 0x80B831A :: bl initWindow_buffer
.org 0x80B8320 :: bl b8320_statusWindowTextStore

//---------------------------------------------------------
// Overworld main window/PSI class window input management hacks
//---------------------------------------------------------

.org 0x80BEAA6 :: bl beaa6_fix_sounds
.org 0x80BEA88 :: bl bea88_fix_sounds

//---------------------------------------------------------
// Main battle window hacks
//---------------------------------------------------------

.org 0x80DC22A :: bl dc22a_load_buffer_battle

//---------------------------------------------------------
// PSI battle window hacks
//---------------------------------------------------------

.org 0x80E00C8 :: bl e02c6_print_target_store
.org 0x80E02C6 :: bl e02c6_print_target_store
.org 0x80E0762 :: bl initWindow_buffer
.org 0x80E0776 :: bl print_window_with_buffer
.org 0x80E07C2 :: bl clearWindowTiles_buffer
.org 0x80E0892 :: bl initWindow_buffer
.org 0x80E08A6 :: bl print_window_with_buffer
.org 0x80E0990 :: bl initWindow_buffer
.org 0x80E0A30 :: bl initWindow_buffer
.org 0x80E0A54 :: bl print_window_with_buffer
.org 0x80C24A2 :: bl printstr_hlight_buffer
.org 0x80C24B4 :: bl printstr_hlight_buffer
.org 0x80C24CC :: bl printstr_hlight_buffer
.org 0x80C2500 :: bl printstr_hlight_buffer
.org 0x80C2518 :: bl printstr_hlight_buffer
.org 0x80E08D8 :: bl e06ec_redraw_bash_psi_goods_defend

//---------------------------------------------------------
// BAC18 hacks (status window)
//---------------------------------------------------------

.org 0x80BAC46 :: nop :: nop
.org 0x80BAC6E :: bl bac6e_statusWindowNumbersInputManagement
.org 0x80BAD7E :: bl printstr_buffer
.org 0x80BAD88 :: bl initWindow_buffer
.org 0x80BAD92 :: bl initWindow_buffer
.org 0x80BACFC :: bl bac18_redraw_status_store
.org 0x80BADE6 :: bl bac18_redraw_status
.org 0x80BACEA :: bl bacea_status_psi_window
.org 0x80BACBA :: bl print_window_with_buffer
.org 0x80BACC4 :: bl initWindow_buffer
.org 0x80BAD1A :: bl clearWindowTiles_buffer
.org 0x80BADF6 :: bl initWindow_buffer
.org 0x80BACEE :: bl bac18_clear_psi
.org 0x80BADB0 :: bl badb0_status_inner_window
.org 0x80BADCC :: b 0x80BADD8

//---------------------------------------------------------
// Normal PSI window hacks
//---------------------------------------------------------

.org 0x80B8C34 :: bl initWindow_buffer
.org 0x80B8C42 :: bl baec6_psi_window_print_buffer
.org 0x80B8C7E :: bl initWindow_buffer
.org 0x80B8C8C :: nop :: nop
.org 0x80B8CA8 :: bl initWindow_buffer
.org 0x80B8CAE :: bl print_window_with_buffer
.org 0x80B8CEA :: bl baec6_psi_window_print_buffer
.org 0x80B8D0C :: bl initWindow_buffer
.org 0x80B8D16 :: bl initWindow_buffer
.org 0x80B8D22 :: bl psiWindow_buffer
.org 0x80B8E44 :: bl initWindow_buffer
.org 0x80B8E62 :: bl baec6_psi_window_print_buffer
.org 0x80B9222 :: bl initWindow_buffer
.org 0x80B922E :: bl psiTargetWindow_buffer
.org 0x80B916E :: bl initWindow_buffer
.org 0x80B9174 :: bl print_window_with_buffer
.org 0x80B9238 :: bl initWindow_buffer
.org 0x80B9256 :: bl baec6_psi_window_print_buffer
.org 0x80BA9FA :: bl initWindow_buffer
.org 0x80BAA00 :: bl print_window_with_buffer
.org 0x80BAB64 :: bl initWindow_buffer
.org 0x80BABA6 :: bl printstr_hlight_buffer
.org 0x80BA8AC :: bl ba8ac_load_targets_print
.org 0x80B9100 :: bl initWindow_buffer
.org 0x80B910C :: bl initWindow_buffer
.org 0x80B9118 :: bl psiTargetWindow_buffer
.org 0x80B9122 :: bl initWindow_buffer
.org 0x80B9142 :: bl baec6_psi_window_print_buffer

//---------------------------------------------------------
// Class PSI window hacks
//---------------------------------------------------------

.org 0x80BAE1C :: bl print_window_with_buffer
.org 0x80BAEC6 :: bl baec6_psi_window_print_buffer
.org 0x80BAED4 :: bl baec6_psi_window_print_buffer
.org 0x80BAEE2 :: bl baec6_psi_window_print_buffer
.org 0x80BAEF0 :: bl baec6_psi_window_print_buffer

//---------------------------------------------------------
// Equip window generic hacks
//---------------------------------------------------------

.org 0x80B8074 :: mov r3,#0x12

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
mov     r2,0xFE
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
.org 0x80C23F0 :: bl printstr_hlight_pixels_buffer             // print rockin'
.org 0x80C2402 :: mov r0,3 :: lsl r0,r0,0x10                // pixel width of space
.org 0x80C242E :: mov r0,0x14                               // new PSI name entry length
.org    0x80C2448
bl      printstr_hlight_pixels_buffer // print PSI name
mov     r2,r1                      // record X width
add     r2,3                       // add a space
.org 0x80C2468 :: bl printstr_hlight_pixels_buffer

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
// C438C hacks (Inner PSI window input management + target window printing + header printing)
//---------------------------------------------------------

.org 0x80C495A :: bl c495a_status_target

//---------------------------------------------------------
// B8BBC hacks (PSI window)
//---------------------------------------------------------

//Do not redraw unless it is needed
.org 0x80B8CD2 :: bl b8cd2_psi_window

//Fix multiple sounds issue when going inside the psi window
.org 0x80B8D40 :: bl b8d40_psi_going_inner_window

//Sets up for the target window
.org 0x80B8DB4 :: bl b8db4_psi_inner_window

// Redraw main menu when exiting PSI target window
.org 0x80B8E3A :: bl b8bbc_redraw_menu_2to1

// Redraw main menu when entering PSI target window
.org 0x80B8CF8 :: bl b8bbc_redraw_menu_13to2 // 1 to 2
.org 0x80B920C :: bl b8bbc_redraw_menu_13to2_store // 3 to 2

//---------------------------------------------------------
// E06EC hacks (PSI window in battle)
//---------------------------------------------------------

//Sets up for the target window
.org 0x80E0854 :: bl e0854_psi_inner_window_battle

//Do not redraw unless it is needed
.org 0x80E079A :: bl e079a_battle_psi_window

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
// Change checkerboard printing to properly handle statuses
//---------------------------------------------------------

.org 0x80D68C2 :: bl dead_name
.org 0x80D6960 :: bl sick_name
.org 0x80D6A8A :: bl alive_name
.org 0x80D6B5E :: bl dead_name
.org 0x80D6BFA :: bl sick_name
.org 0x80D6DAC :: bl d6dac_alive_name

.org m2_stat_symb_checker :: .incbin "data/m2-status-symbols-checkerboard.bin"

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
// Equipment number printing in dialogue window
//---------------------------------------------------------

.org 0x80D37EC :: bl d37ec_print_number :: b 0x80D381C //Offense
.org 0x80D36D0 :: bl d37ec_print_number :: b 0x80D3700 //Defense

//---------------------------------------------------------
// Remove continuous printing of outer equip window and also
// remove continuous printing of Offense and Defense numbers
// in both outer and innermost equipment windows
//---------------------------------------------------------

.org 0x80C518E :: bl c518e_outer_equip
.org 0x80BAF60 :: bl baf60_outer_equip_setup
.org 0x80BAFC8 :: bl bafc8_outer_equip_attack_defense
.org 0x80BB26E :: bl bb990_inner_equip_attack_defense_setup //Weapon
.org 0x80BB730 :: bl bb990_inner_equip_attack_defense_setup //Body
.org 0x80BB860 :: bl bb990_inner_equip_attack_defense_setup //Arms
.org 0x80BB990 :: bl bb990_inner_equip_attack_defense_setup //Other
.org 0x80BB6B2 :: bl bb6b2_inner_equip_attack_defense_weapon
.org 0x80BB64E :: bl bb64e_inner_equip_attack_defense_none_weapon
.org 0x80BB80E :: bl bbe7c_inner_equip_attack_defense_defensive_equipment //Body Offense/Defense printing
.org 0x80BB93E :: bl bbe7c_inner_equip_attack_defense_defensive_equipment //Arms Offense/Defense printing
.org 0x80BBE7C :: bl bbe7c_inner_equip_attack_defense_defensive_equipment //Other Offense/Defense printing
.org 0x80BBDDE :: bl bbe7c_inner_equip_attack_defense_defensive_equipment //Defensive equipment Offense/Defense none printing

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
// B9ECC hacks (Fixes inventory when out of selecting a party member to give food to via B button)
//---------------------------------------------------------
.org 0x80B9ECC
bl b9ecc_get_print_inventory_window

//---------------------------------------------------------
// BA48E hacks (Fixes inventory when out of Give via text)
//---------------------------------------------------------
.org 0x80BA48E
bl ba48e_get_print_inventory_window

//---------------------------------------------------------
// B9F96 hacks (Fixes main window after consuming an item)
//---------------------------------------------------------
.org 0x80B9F96
bl _reprint_first_menu

//---------------------------------------------------------
// B9CF8 hacks (Fixes main window after an item prints a dialogue)
//---------------------------------------------------------
.org 0x80B9CF8
bl _reprint_first_menu

//---------------------------------------------------------
// B9C88 hacks (Fixes main window after an equippable item prints a dialogue)
//---------------------------------------------------------
.org 0x80B9C88
bl _reprint_first_menu

//---------------------------------------------------------
// BA52C hacks (Fixes main window after giving an item)
//---------------------------------------------------------
.org 0x80BA52C
bl _reprint_first_menu

//---------------------------------------------------------
// BA44E hacks (Fixes main window after not being able to give an item)
//---------------------------------------------------------
.org 0x80BA44E
bl _reprint_first_menu

//---------------------------------------------------------
// BA7BE hacks (Fixes main window after calling the help function)
//---------------------------------------------------------
.org 0x80BA7BE
bl ba7be_reprint_first_menu

//---------------------------------------------------------
// B9AA2 hacks (Fixes main window after exiting the item action window)
//---------------------------------------------------------
.org 0x80B9AA2
bl b9aa2_reprint_first_menu

//---------------------------------------------------------
// C6BA2 hacks (Fixes main window after exiting the Stored Goods window)
//---------------------------------------------------------
.org 0x80C6BA2
bl c6ba2_reprint_first_menu

//---------------------------------------------------------
// BCEB0 hacks (Fixes main window after exiting the pickup menu)
//---------------------------------------------------------
.org 0x80BCEB0
bl _reprint_first_menu

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

//Remove subtract from player name printing
.org 0x80EEB94 :: mov r2,r3

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
// wvf_skip hacks
//---------------------------------------------------------
.org 0x80B8C2A :: bl b8c2a_set_proper_wvf_skip_and_window_type //Fixes bug of M2GBA
.org 0x80BE45A :: bl be45a_set_proper_wvf_skip
.org 0x80BE4CA :: bl be4ca_set_proper_wvf_skip_goods_battle_window

//---------------------------------------------------------
// PSI Rockin in battle text
//---------------------------------------------------------
.org 0x80D3984 :: cmp r0,#3 //Now "PSI " is 4 letters long, not 2
.org 0x80D399E :: sub r0,#4 //Subtract from r0 the length of "PSI "

//---------------------------------------------------------
// Flyover hacks
//---------------------------------------------------------

//Notes
//Flyover entries are made of 16 bits codes. Codes with the first byte between 0 and 9 are special cases.
//01 XX = Position at X tile XX (Changed to Position at X pixel XX)
//02 XX = Position at Y tile XX
//09 00 = END
//80 XX = Print character XX

//Flyover pointer remapping
.org 0x873112c :: dw flyovertextYear //The year is 199x
.org 0x8731130 :: dw flyovertextOnett //Onett, a small town in eagleland
.org 0x8731134 :: dw flyovertextNess //Ness's House
.org 0x8731138 :: dw flyovertextWinters //Winters, a small country to the north
.org 0x873113C :: dw flyovertextSnow //Snow Wood Boarding House
.org 0x8731140 :: dw flyovertextDalaam //Dalaam, in the Far East
.org 0x8731144 :: dw flyovertextPoo //The palace of Poo\nThe Crown Prince
.org 0x8731148 :: dw flyovertextLater //Later that night...

//Flyover remapping
.org 0x80B3482 :: bl largevwf :: b 0x80B348E

// Weld the odd-numbered flyover letters
.org 0x80B3254 :: bl flyoverweld :: nop

// Make it so the entire possible tileset is used
.org 0x80AE568 :: mov r0,#8
.org 0x80AE56E :: mov r0,#7
.org 0x80AE57A :: mov r1,#0x80 //Start at 0x100 instead of 0x120

// Change the [01 XX] flyover code to pixels from left of screen
.org 0x80B332C :: b 0x80B3334

// Alter the flyover palette so the borders don't show (orig 0x739C)
.org 0x80FCE50 :: .byte 0x00,0x00

//Insert the font
.org 0x80B3274 :: dw m2_font_big

//Print all 16 rows
.org 0x80B3262 :: cmp r7,0xF

//Print all 16 columns
.org 0x80B325C :: cmp r6,7

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


//---------------------------------------------------------
// Movement code hacks
//---------------------------------------------------------
// Censor the spanking sound in Pokey's house
.org 0x8027BCB :: db 70 // Add 30 extra frames before the sound plays
.org 0x8027BD1 :: dh 84 // Replace sound effect

// Carpainter's timing fix
.org 0x802A75F :: db 0x30 //Add 8 extra frames before the game can start reading again.

//==============================================================================
// File select hacks
//==============================================================================

// Main file select window resize
.org 0x82B79BC :: dw 0x1C       // new window width
.org 0x8003998 :: mov r0,1      // new window x
.org 0x8003F92 :: mov r0,1
.org 0x80053DC :: mov r0,1
.org 0x8003A04 :: bl _3a04_highlight_file //Changes window position and makes sure the file is properly highlighted
.org 0x8003B40 :: mov r0,0x10   // new cursor x
.org 0x86DB070 :: .incbin "data/m2-fileselect-template.bin"

.org 0x86D9808
.incbin "data/m2-fileselect-tileset.bin"

// Formatting
.org 0x80021E8 :: bl format_file_string
.org 0x8002284 :: bl format_file_string

//Load the pixels in fileselect_pixels_location
.org 0x80038C0 :: bl _38c0_load_pixels

// Printing
.org 0x80038CC :: mov r2,0x40 :: bl wrapper_first_file_string
.org 0x80038DE :: mov r2,0x40 :: bl wrapper_first_file_string
.org 0x80038F2 :: mov r2,0x40 :: bl wrapper_first_file_string :: bl _38f8_store_pixels

// Bump file select cursor up by 3 pixels - Not needed now that the text is 3 pixels lower
//.org 0x8003844 :: add r0,r5,1

// File select options
.org 0x8003F78 :: bl _3f78_highlight_file //Keeps highlight consistent when changing palette in the text flavour window
.org 0x8004072 :: bl _40e2_cursor_X //Removing highlight position
.org 0x8004080 :: mov r3,#4 //Remove highlight of 4 tiles maximum
.org 0x8004092 :: bl _4092_print_window_store //Printing + storing pixels
.org 0x80040E2 :: bl _40e2_cursor_X //Highlight position
.org 0x80040F4 :: mov r3,#4 //Print highlight of 4 tiles maximum
.org 0x80041D4 :: bl _41d4_cursor_X //New cursor's X

//Text Speed options
.org 0x8003BBC :: bl _4092_print_window_store //Printing + storing pixels
.org 0x8003FA2 :: bl _4092_print_window
.org 0x8003F8C :: mov r3,#4 //Print highlight of 4 tiles maximum
.org 0x8003E86 :: bl _3e86_special_setup //Avoid printing when not necessary
.org 0x8003EF2 :: bl _3e86_special_setup //Avoid printing when not necessary
.org 0x82B79D0 :: dw 0x10 //new window width
.org 0x86DB0FC :: .incbin "data/m2-textspeed-template.bin"

//Text Flavour options
.org 0x8003D8A :: bl _4092_print_window_store //Printing + storing pixels
.org 0x8003D86 :: mov r1,#4 //new window Y
.org 0x8003DB6 :: mov r1,#4
.org 0x8003E0C :: mov r1,#4
.org 0x8003E8C :: mov r1,#4
.org 0x8003EF8 :: mov r1,#4
.org 0x80053F2 :: mov r1,#4
.org 0x82B79E4 :: dw 0xF //new window width
.org 0x82B79E8 :: dw 0x10 //new window height
.org 0x8003DCE :: bl _3dce_fix_out_of_text_flavour
.org 0x86DB1F8 :: .incbin "data/m2-flavour-template.bin"

//Delete
.org 0x8004410 :: mov r1,#3 :: mov r2,#0x15 :: bl wrapper_delete_string
.org 0x800441E :: bl _4092_print_window_store //Printing + storing pixels
.org 0x82B7AFC :: dw 0x15 //new window width
.org 0x86DBE8C :: .incbin "data/m2-delete-template.bin"

//Copy
.org 0x8004294 :: bl _4294_print_window_store //Printing - 1 slot available
.org 0x80042BA :: bl _4092_print_window_store //Printing + storing pixels
.org 0x8004268 :: mov r2,#0x2 :: bl wrapper_copy_string

//Descriptions and Names
.org 0x80053F6 :: bl _53f6_fix_out_of_description
.org 0x8004ED2 :: bl wrapper_name_string //Printing names
.org 0x8004EDC :: bl _4edc_print_window_store //Printing + storing pixels
.org 0x86DB2B8 :: .incbin "data/m2-descriptions-template.bin"
.org 0x82B7A00 :: dw 0x86DB2B8 //Point all the descriptions + names to the same template
.org 0x82B7A14 :: dw 0x86DB2B8
.org 0x82B7A28 :: dw 0x86DB2B8
.org 0x82B7A3C :: dw 0x86DB2B8
.org 0x82B7A50 :: dw 0x86DB2B8
.org 0x82B7A64 :: dw 0x86DB2B8

//Alphabets
.org 0x80051A4 :: bl _4092_print_window_store //Printing + storing pixels - CAPITAL
.org 0x8004EA2 :: bl _4092_print_window_store //Printing + storing pixels - small
.org 0x82B7A8C :: dw 0x86DB5C4
.org 0x86DB5C4 :: .incbin "data/m2-alphabet-template.bin"
.org 0x8005222 :: bl setupCursorAction
.org 0x8005382 :: bl setupCursorMovement
.org 0x800538A :: bl setupCursorPosition //Cursor position
.org 0x800536C :: bl setupCursorPosition //Cursor position
.org 0x82B8FFC :: .incbin "data/m2-alphabet-table.bin"
.org 0x8002322 :: bl _2322_setup_windowing

//Summary
.org 0x80054F2 :: mov r2,#5 :: bl wrapper_name_summary_string //Printing Ness' name
.org 0x8005502 :: mov r2,#5 :: bl wrapper_name_summary_string //Printing Paula's name
.org 0x8005512 :: mov r2,#5 :: bl wrapper_name_summary_string //Printing Jeff's name
.org 0x8005522 :: mov r2,#5 :: bl wrapper_name_summary_string //Printing Poo's name
.org 0x800555C :: nop :: nop //Sends to a bunch of 0xFF
.org 0x800556A :: nop :: nop //Sends to a bunch of 0xFF
.org 0x8005530 :: mov r0,#0x11 //New x for King's name
.org 0x8005536 :: bl wrapper_name_summary_string //Printing King's name
.org 0x8005578 :: bl wrapper_count_pixels_to_tiles :: mov r2,#6 :: mov r4,#0x17 :: sub r0,r4,r0 //Count length of Food's name in tiles
.org 0x8005588 :: bl wrapper_name_summary_string //Printing Food's name
.org 0x8005596 :: bl wrapper_count_pixels_to_tiles :: mov r2,#6 :: sub r4,r4,r0 //Count length of Thing's name in tiles
.org 0x80055A6 :: bl wrapper_name_summary_string //Printing Thing's name
.org 0x80055B0 :: bl _4092_print_window_store //Printing + storing pixels
.org 0x80056F0 :: add r0,#0x90 //New cursor's X
.org 0x86DBC6C :: .incbin "data/m2-summary-template.bin"

//==============================================================================
// Overworld player name alphabet
//==============================================================================
//Player name printing - character is added
.org 0x80C75B4 :: bl c75b4_overworld_naming_top_printing :: b 0x80C777A

//Player name printing - character is deleted via add
.org 0x80C780E :: bl c780e_overworld_naming_top_printing :: b 0x80C789A

//Player name printing - character is deleted via backspace
.org 0x80C74CC :: bl c74cc_overworld_naming_top_printing :: b 0x80C755A

//Player name printing - menu is re-entered after the name has been inserted once
.org 0x80C6CC6 :: bl c6cc6_overworld_naming_top_printing :: b 0x80C6D5E

//Player name alphabet - cursor movement
.org 0x80C6F24 :: bl c6f24_overworld_alphabet_movement :: b 0x80C7340

//Alphabet - switching support - removal of unused alphabet
.org 0x80C7380 :: nop :: nop :: nop :: mov r0,r9 :: cmp r0,#0 :: beq 0x80C741A :: nop :: nop :: cmp r0,#1

//Print CAPITAL alphabet only if needed
.org 0x80C7394 :: bl c7394_CAPITAL_overworld_alphabet :: b 0x80C73B8

//Print small alphabet
.org 0x80C73B8 :: nop :: mov r0,r9 :: cmp r0,#2

//Print small alphabet only if needed
.org 0x80C73C0 :: bl c73c0_small_overworld_alphabet :: b 0x80C73E2

//Choose character table based on alphabet loaded in
.org 0x80C7578 :: bl c7578_load_letters

//==============================================================================
// Title screen hacks
//==============================================================================

.definelabel m2_title_sequence_00, 0x80117E0
.definelabel m2_title_sequence_01, 0x8011802
.definelabel m2_title_sequence_02, 0x801182A
.definelabel m2_title_sequence_03, 0x8011858
.definelabel m2_title_sequence_04, 0x80118FA
.definelabel m2_title_sequence_05, 0x80118FE
.definelabel m2_title_sequence_06, 0x801195C
.definelabel m2_title_sequence_07, 0x8011972
.definelabel m2_title_sequence_08, 0x80119BA
.definelabel m2_title_sequence_09, 0x80119DE
.definelabel m2_title_sequence_0A, 0x8011A02
.definelabel m2_title_sequence_0B, 0x8011A1A
.definelabel m2_title_sequence_0C, 0x8011A80
.definelabel m2_title_sequence_0D, 0x8011A8A
.definelabel m2_title_sequence_0E, 0x8011AAA
.definelabel m2_title_sequence_0F, 0x8011B58
.definelabel m2_title_sequence_10, 0x8011B66
.definelabel m2_title_sequence_11, 0x8011B76

// m2_title_background_pal_copyright:   File has two palettes separated by six palettes
//                                      worth of nullspace. First palette is the copyright palette,
//                                      last palette is a placeholder for the glow palette
// m2_title_background_pal_glow:        20 frames, glow effect
// m2_title_text_pal_animated:          14 frames, white horizontal line scrolling top to bottom
// m2_title_text_pal_static:            1 frame, white text on black background

// BG0 will be used for the B, the glow, and copyright info
// OAM will be used for the other letters

// Background palette RAM layout:
// [0]:    copyright
// [1-6]:  (blank)
// [7]:    glow
// [8]:    B
// [9-15]: (blank)

// Frame states (BG0), from EarthBound:
// Start    Duration    State
// --------------------------
// 0        g           Black
// g        1           1/32 grey B
// g+1      2           2/32 grey B
// g+3      2           3/32 grey B
// g+5      2           4/32 grey B
// g+7      2           5/32 grey B
// g+9      2           6/32 grey B
// g+11     2           7/32 grey B
// g+13     2           8/32 grey B
// g+15     2           9/32 grey B
// g+17     2           10/32 grey B
// g+19     2           11/32 grey B
// g+21     2           12/32 grey B
// g+23     2           13/32 grey B
// g+25     2           14/32 grey B
// g+27     2           15/32 grey B
// g+29     1           16/32 grey B
// g+30     2           17/32 grey B

// --- Animation 3 (full title screen) ---
.org 0x82D6B64 :: dh 0x008A   // Enable 8-bit BG0

// Initializer hacks:

    // Point to new compressed palettes
    .org 0x801147C
    dw m2_title_text_pal_animated + 4
    dw m2_title_text_pal_static + 4
    dw m2_title_background_pal_copyright + 4
    dw m2_title_background_pal_glow + 4

    // The new palettes have different sizes (8, 20, 14, 1 palettes respectively), so encode the proper buffer pointers
    .org 0x801146C
    dw 0x2011500
    dw 0x2011780
    dw 0x2011940
    dw 0x2011960

    // Expand the null area after the fifth palette buffer (gives us 0x2A0 bytes of nullspace
    // starting at 0x2011B60)
    .org 0x8011490 :: dw 0x85000128

    // Define the proper expected uncompressed sizes
    .org 0x801141E :: mov r5,4 :: neg r5,r5
    .org 0x8011422 :: ldr r2,[r0,r5]
    .org 0x801142C :: ldr r2,[r0,r5]
    .org 0x8011436 :: ldr r2,[r0,r5]
    .org 0x8011440 :: ldr r2,[r0,r5]

    // Point to custom initializer routine
    .org 0x82D6B78 :: dw title_initializer + 1

// Setup hacks:

    // Fade BG0 instead of OBJ
    .org 0x80117E6 :: mov r0,0xC1

    // Point to sequence hacks
    .org 0x8011798 :: dw title_sequence_00
    .org 0x801179C :: dw title_sequence_01
    .org 0x80117A4 :: dw title_sequence_03
    .org 0x80117A8 :: dw title_sequence_04
    .org 0x80117AC :: dw title_sequence_05
    .org 0x80117B4 :: dw title_sequence_07
    .org 0x80117B8 :: dw title_sequence_08
    .org 0x80117BC :: dw title_sequence_09
    .org 0x80117C4 :: dw title_sequence_0B
    .org 0x80117C8 :: dw title_sequence_0C
    .org 0x80117CC :: dw title_sequence_0D
    .org 0x80117D0 :: dw title_sequence_0D
    .org 0x80117D4 :: dw title_sequence_0D
    .org 0x80117D8 :: dw title_sequence_0D

    // Clamp initial X values for text
    .org 0x80116F0 :: bl title_setup_clamp

    // Show all eight text sprites from the start
    .org 0x8011B94 :: mov r6,7
    .org 0x8011BAC :: b 0x8011BDC

    // Allocate space for nine sprites
    .org 0x80113F8 :: mov r0,0xC8

    // Relocate stuff from after the sprite data
    .org 0x8011634 :: mov r1,0xB2
    .org 0x8011640 :: mov r2,0xC2
    .org 0x801164E :: mov r1,0xBE
    .org 0x801165C :: mov r7,0xC2
    .org 0x8011662 :: mov r5,0xC3
    .org 0x8011674 :: mov r3,0xB2
    .org 0x801167C :: mov r4,0xB3
    .org 0x8011696 :: mov r0,0xBE
    .org 0x8011838 :: mov r1,0xB6

// Commit hacks:

    // Commit all things on every sequence
    .org 0x8011500 :: b 0x8011516

// --- Animation 5 (quick title screen) ---
.org 0x82D6BD4 :: dh 0x008A   // Enable 8-bit BG0
.org 0x82D6BE0 :: dh 0x1100   // Disable BG1

.org 0x801170C :: dw m2_title_text_constants
.org 0x8011710 :: dw m2_title_text_constants + 12
.org 0x8011714 :: dw m2_title_text_constants + 12 + 32
.org 0x8011718 :: dw m2_title_text_constants + 12 + 32 + 32
.org 0x801171C :: dw m2_title_text_constants + 12 + 32 + 32 + 32
.org 0x870F580 :: .incbin "data/m2-title-background.bin"
.org 0x8711280 :: .incbin "data/m2-title-text.bin"
.org 0x87126CC :: .incbin "data/m2-title-background-pal-empty.bin"
.org 0x87128EC :: .incbin "data/m2-title-background-map.bin"
.org 0x8712E68 :: .incbin "data/m2-title-text-oam.bin"
.org 0x8712F10 :: .incbin "data/m2-title-text-oam-entries.bin"

//==============================================================================
// Move stuff around in order to make space for the code
//==============================================================================

.org 0x82D92D4 :: dw moved_graphics_table :: dw moved_graphics_table + 0x1CD2C
.org 0x82D9BBC :: dw moved_graphics_table + 0x26618 :: dw moved_graphics_table + 0x3F818

//==============================================================================
// Data files
//==============================================================================

.org m2_default_names
.incbin "data/m2-default-names.bin"

.org 0x8B1BA88

m2_overworld_alphabet_table:
.incbin "data/m2-overworld-alphabet-table.bin"

.org 0x8B2C000

//This table MUST be 4-bytes padded
moved_graphics_table:
.incbin "data/moved-graphics-table.bin"

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
.incbin "data/bigfont.bin"
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
.incbin "data/largewidths.bin"
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

flyovertextYear:
.incbin "data/flyovertextYear.bin"

flyovertextOnett:
.incbin "data/flyovertextOnett.bin"

flyovertextNess:
.incbin "data/flyovertextNess.bin"

flyovertextWinters:
.incbin "data/flyovertextWinters.bin"

flyovertextSnow:
.incbin "data/flyovertextSnow.bin"

flyovertextDalaam:
.incbin "data/flyovertextDalaam.bin"

flyovertextPoo:
.incbin "data/flyovertextPoo.bin"

flyovertextLater:
.incbin "data/flyovertextLater.bin"

m2_coord_table_file:
.incbin "data/m2-coord-table-file-select.bin"

.align 4

m2_title_background_pal_copyright:
dw 0x100 :: .incbin "data/m2-title-background-pal-copyright.c.bin"

m2_title_background_pal_glow:
dw 0x280 :: .incbin "data/m2-title-background-pal-glow.c.bin"

m2_title_text_pal_animated:
dw 0x1C0 :: .incbin "data/m2-title-text-pal-animated.c.bin"

m2_title_text_pal_static:
dw 0x20 :: .incbin "data/m2-title-text-pal-static.c.bin"

.align 4

m2_title_text_constants:
.incbin "data/m2-title-text-constants.bin"

//==============================================================================
// Existing subroutines/data
//==============================================================================

.definelabel overworld_buffer       ,0x200C000
.definelabel m2_ness_data           ,0x3001D54
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
.definelabel m2_psi_exist           ,0x300525C
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
.definelabel m2_setup_window        ,0x80BD844
.definelabel m2_strlookup           ,0x80BE260
.definelabel m2_initwindow          ,0x80BE458
.definelabel m2_statuswindow_numbers,0x80C0A5C
.definelabel m2_psiwindow           ,0x80C1FBC
.definelabel m2_drawwindow          ,0x80C87D0
.definelabel m2_print_window        ,0x80C8BE4
.definelabel m2_printstr            ,0x80C9634
.definelabel m2_printstr_hlight     ,0x80C96F0
.definelabel m2_printnextch         ,0x80C980C
.definelabel m2_scrolltext          ,0x80CA4BC
.definelabel m2_formatnumber        ,0x80CA65C
.definelabel m2_clearwindowtiles    ,0x80CA834
.definelabel m2_menuwindow          ,0x80C1C98
.definelabel m2_setupwindow         ,0x80BE188
.definelabel m2_resetwindow         ,0x80BE490
.definelabel m2_sub_d3c50           ,0x80D3C50
.definelabel m2_hpwindow_up         ,0x80D3F0C
.definelabel m2_curhpwindow_down    ,0x80D41D8
.definelabel m2_sub_d6844           ,0x80D6844
.definelabel m2_setupbattlename     ,0x80DCD00
.definelabel m2_stat_symb_checker   ,0x8B0EDA4
.definelabel vblank                 ,0x80F47E4
.definelabel m2_div                 ,0x80F49D8
.definelabel m2_remainder           ,0x80F4A70
.definelabel m2_items               ,0x8B1D62C
.definelabel m2_default_names       ,0x82B9330
.definelabel m2_psi_print_table     ,0x8B2A9C0
.definelabel m2_title_teardown      ,0x8000C28

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
.include "m2-flyover.asm"
.include "m2-title.asm"

.close
