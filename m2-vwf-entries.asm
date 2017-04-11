//==============================================================================
c980c_custom_codes:
push    {r1-r2,lr}
mov     r1,r7
mov     r2,r5
bl      customcodes_parse
ldr     r1,[r6]

// If 0, return [r6]+2; otherwise, return [r6]+r0
beq     @@next
add     r0,r0,r1
pop     {r1-r2,pc}
@@next:
add     r0,r1,2
pop     {r1-r2,pc}

//==============================================================================
c980c_weld_entry:
push    {r0-r3,lr}
mov     r0,r5
mov     r1,r7
bl      weld_entry
pop     {r0-r3,pc}

//==============================================================================
c8ffc_custom_codes:
push    {r2,r5,lr}
ldrb    r0,[r2]
mov     r5,r0
mov     r1,r2
mov     r2,r4
bl      customcodes_parse
cmp     r0,0
beq     @@next
mov     r2,r12
add     r0,r0,r2
strh    r0,[r4,0x14]
pop     {r2,r5}
add     sp,4
ldr     r1,=0x80C904D
bx      r1
@@next:
mov     r0,r5
cmp     r0,1
pop     {r2,r5,pc}
.pool


//==============================================================================
c8ffc_weld_entry:
push    {r0-r1,lr}
mov     r0,r4
mov     r1,r2
bl      weld_entry
pop     {r0-r1,pc}

//==============================================================================
c980c_resetx:
push    {r1,lr}
mov     r1,0
strh    r1,[r0,2]
pop     {r1}
bl      0x80C87D0
pop     {pc}

//==============================================================================
c980c_resetx_newline:
push    {lr}
strh    r0,[r5,0x2C]
strh    r4,[r5,0x2A]
strh    r4,[r5,2]
pop     {pc}

//==============================================================================
c980c_resetx_scroll:
push    {lr}
strh    r0,[r5,0x2C]
strh    r1,[r5,0x2A]
strh    r1,[r5,2]
pop     {pc}

//==============================================================================
c980c_resetx_other:
push    {lr}
strh    r0,[r5,0x2C]
strh    r2,[r5,0x2A]
strh    r2,[r5,2]
pop     {pc}

//==============================================================================
c980c_resetx_other2:
push    {lr}
mov     r2,0
strh    r2,[r5,0x2A]
strh    r2,[r5,2]
pop     {pc}

//==============================================================================
c980c_resetx_other3:
push    {lr}
mov     r1,0
strh    r1,[r5,0x2A]
strh    r1,[r5,2]
pop     {pc}

//==============================================================================
c980c_resetx_other4:
push    {lr}
strh    r0,[r5,0x2C]
strh    r6,[r5,0x2A]
strh    r6,[r5,2]
pop     {pc}

//==============================================================================
c87d0_clear_entry:
push    {lr}

// Reset X
mov     r1,0
strh    r1,[r0,2]

// Clear window
mov     r1,4
bl      clear_window

// Clobbered code
ldr     r4,=0x3005270
mov     r1,0x24
pop     {pc}
.pool


//==============================================================================
c9634_resetx:
push    {lr}
mov     r4,0
strh    r4,[r6,2]

// Clobbered code
strh    r5,[r1]
pop     {pc}

//==============================================================================
// Only render the (None) strings in the equip window if there's nothing equipped
c4b2c_skip_nones:
push    {r7,lr}
add     sp,-4
mov     r7,0

// Get the (none) pointer
mov     r0,r4
mov     r1,r10
mov     r2,0x2A
bl      0x80BE260
mov     r5,r0

// Check each equip slot
ldr     r6,=0x3001D40
ldr     r3,=0x3005264
ldrh    r0,[r3] // active party character
mov     r1,0x6C
mul     r0,r1
add     r6,r0,r6
add     r6,0x75
ldrb    r0,[r6]
cmp     r0,0
bne     @@next

// Weapon
mov     r0,r8
mov     r1,r5
mov     r2,0x6
mov     r3,0
str     r7,[sp]
bl      0x80C9634

@@next:
ldrb    r0,[r6,1]
cmp     r0,0
bne     @@next2

// Body
mov     r0,r8
mov     r1,r5
mov     r2,0x6
mov     r3,1
str     r7,[sp]
bl      0x80C9634

@@next2:
ldrb    r0,[r6,2]
cmp     r0,0
bne     @@next3

// Arms
mov     r0,r8
mov     r1,r5
mov     r2,0x6
mov     r3,2
str     r7,[sp]
bl      0x80C9634

@@next3:
ldrb    r0,[r6,3]
cmp     r0,0
bne     @@next4

// Other
mov     r0,r8
mov     r1,r5
mov     r2,0x6
mov     r3,3
str     r7,[sp]
bl      0x80C9634

@@next4:
mov     r0,0
mov     r10,r0
add     sp,4
pop     {r7,pc}
.pool


//==============================================================================
// Clears the equipment portion of the equip window
// r0 = window pointer
clear_equipment:
push    {r0-r2,lr}
add     sp,-16
mov     r1,r0
mov     r0,sp

ldrh    r2,[r1,0x22] // window X
add     r2,6         // horizontal offset
strh    r2,[r0]
ldrh    r2,[r1,0x24] // window Y
strh    r2,[r0,2]
ldrh    r2,[r1,0x26] // window width
sub     r2,6
strh    r2,[r0,0xC]
ldrh    r2,[r1,0x28] // window height
strh    r2,[r0,0xE]

ldr     r2,=0x44444444
str     r2,[r0,4]
ldr     r2,=0x30051EC
ldrh    r2,[r2]
strh    r2,[r0,8]

bl      clear_rect

add     sp,16
pop     {r0-r2,pc}
.pool


//==============================================================================
// Clear equipment and offense/defense when moving left/right on equip screen
// r6 = window pointer
c4b2c_clear_left:
mov     r0,r6
bl      clear_equipment

// Clear offense/defense
push    {r0-r2}
mov     r0,8
mov     r2,r0
mov     r1,0xB
bl      print_blankstr
add     r1,2
bl      print_blankstr
pop     {r0-r2}

// Clobbered code
strh    r1,[r3]
ldr     r0,=0x80C4F3B
bx      r0

c4b2c_clear_right:
mov     r0,r6
bl      clear_equipment

// Clear offense/defense
push    {r0-r2}
mov     r0,8
mov     r2,r0
mov     r1,0xB
bl      print_blankstr
add     r1,2
bl      print_blankstr
pop     {r0-r2}

// Clobbered code
strh    r1,[r3]
ldr     r0,=0x80C4EFF
bx      r0
.pool


//==============================================================================
// Clear PSI target window when moving left/right on PSI screen
c438c_moveright:
push    {r0-r1,lr}
ldr     r1,=0x3005230
ldr     r0,[r1,0x24] // PSI target window pointer
mov     r1,4
bl      clear_window
pop     {r0-r1}

// Clobbered code
add     r0,1
strh    r0,[r5,0x34]
pop     {pc}

c438c_moveleft:
push    {r0-r1,lr}
ldr     r1,=0x3005230
ldr     r0,[r1,0x24] // PSI target window pointer
mov     r1,4
bl      clear_window
pop     {r0-r1}

// Clobbered code
sub     r0,1
strh    r0,[r5,0x34]
pop     {pc}

c438c_moveup:
push    {r0-r1,lr}
ldr     r1,=0x3005230
ldr     r0,[r1,0x24] // PSI target window pointer
mov     r1,4
bl      clear_window
pop     {r0-r1}

// Clobbered code
sub     r0,1
strh    r0,[r5,0x36]
pop     {pc}

c438c_movedown:
push    {r0-r1,lr}
ldr     r1,=0x3005230
ldr     r0,[r1,0x24] // PSI target window pointer
mov     r1,4
bl      clear_window
pop     {r0-r1}

// Clobbered code
add     r0,1
strh    r0,[r5,0x36]
pop     {pc}
.pool


//==============================================================================
// Prints a string in the status window
c0a5c_printstr:
push    {r0-r2,lr}
mov     r0,r1
mov     r1,r2
mov     r2,r3
bl      print_string
pop     {r0-r2,pc}

//==============================================================================
// Prints an empty space instead of the "Press A for PSI info" string
c0a5c_psi_info_blank:
push    {lr}
mov     r0,5
mov     r1,0xF
mov     r2,0x14
bl      print_blankstr
pop     {pc}

//==============================================================================
// Redraws the status window (when exiting the PSI submenu, etc.)
bac18_redraw_status:
push    {r4,lr}

ldr     r4,=0x3005230
ldr     r4,[r4,0x18]

// Get the address of the status text
ldr     r0,=0x8B17EE4
ldr     r1,=0x8B17424
mov     r2,0x11
bl      0x80BE260

// Prepare the window for parsing
mov     r1,r0
mov     r0,r4
mov     r2,0
bl      0x80BE458

// Render text
mov     r0,r4
bl      0x80C8FFC

// Render numbers
mov     r0,r4
mov     r1,0
bl      0x80C0A5C

pop     {r4,pc}
.pool


//==============================================================================
// Clears the PSI window when switching classes
// r5 = 0x3005230
bac18_clear_psi:
push    {r0,lr}
ldr     r0,[r5,0x20] // PSI class window pointer
ldrb    r0,[r0]
mov     r1,0x10
and     r0,r1
cmp     r0,0
beq     @@next

// If flag 0x10 is set, clear the PSI window
ldr     r0,[r5,0x1C] // PSI window
mov     r1,4
bl      clear_window

@@next:
// Clobbered code
pop     {r0}
lsl     r0,r0,0x10
asr     r4,r0,0x10
pop     {pc}

//==============================================================================
// Only clear+redraw the PSI help if a button has been pressed
bac18_check_button:
push    {lr}
ldr     r0,=0x3002500
ldrh    r0,[r0]
cmp     r0,0
beq     @@next

// Clear window
ldr     r0,[r5,0x28]
mov     r1,r2
mov     r2,0
bl      0x80BE458

// Render window
ldr     r0,[r5,0x28]
bl      0x80C8BE4

@@next:
pop     {pc}
.pool

//==============================================================================
// Clear offense/defense changes when switching in equip select window
c5500_clear_up:
push    {r1-r2,lr}
mov     r0,0xD
mov     r1,0xB
mov     r2,0x3
bl      print_blankstr
add     r1,2
bl      print_blankstr

// Clobbered code
sub     r0,r3,1
strh    r0,[r7,0x36]
pop     {r1-r2,pc}

c5500_clear_down:
push    {r0-r2,lr}
mov     r0,0xD
mov     r1,0xB
mov     r2,0x3
bl      print_blankstr
add     r1,2
bl      print_blankstr

// Clobbered code
pop     {r0-r2}
add     r0,1
strh    r0,[r7,0x36]
pop     {pc}

//==============================================================================
// Clear offense/defense when re-equipping (or un-equipping) something
baef8_reequip_erase:
push    {r1,lr}
mov     r0,8
mov     r1,0xB
mov     r2,4
bl      print_blankstr
add     r1,2
bl      print_blankstr

// Clobbered code
pop     {r1}
mov     r0,2
strh    r0,[r1]
pop     {pc}

//==============================================================================
// Redraw main menu when exiting PSI target window
b8bbc_redraw_menu_2to1:
push    {r1-r4,lr}
add     sp,-4

// Copied from 80B7A74
mov     r0,0
str     r0,[sp]
ldr     r0,=0x3005230
ldr     r0,[r0] // main menu window pointer
ldr     r1,[r0,4] // text pointer
mov     r2,5
mov     r3,2
mov     r4,r0
bl      0x80BE4C8
mov     r0,r4
bl      0x80C8BE4

// Clobbered code (restore the window borders, etc.)
mov     r0,1
bl      0x80BD7AC

add     sp,4
pop     {r1-r4,pc}
.pool

//==============================================================================
// Redraw main menu when entering PSI target window
b8bbc_redraw_menu_13to2:
push    {r1-r4,lr}
add     sp,-4

// Copied from 80B7A74
mov     r0,0
str     r0,[sp]
ldr     r0,=0x3005230
ldr     r0,[r0] // main menu window pointer
ldr     r1,[r0,4] // text pointer
mov     r2,5
mov     r3,2
mov     r4,r0
bl      0x80BE4C8
mov     r0,r4
bl      0x80C8BE4

// Clobbered code (restore the window borders, etc.)
mov     r0,1
bl      0x80BD7F8

add     sp,4
pop     {r1-r4,pc}
.pool

//==============================================================================
// Print a space before the Greek letter
d3934_print_space:
push    {lr}
mov     r0,r4
bl      print_space

// Clobbered code
ldrb    r1,[r3,1]
lsl     r0,r1,1
pop     {pc}

//==============================================================================
// Copy a tile up one line
// r4: (x << 16) (relative)
// r5: dest tilemap
// r6: window
// r7: source tilemap
// r8: y (dest, relative)
// r10: 3005270
ca4bc_copy_tile_up:
push    {r4-r7,lr}

// Four cases:
// 1) copy blank to blank
// 2) copy blank to non-blank
// 3) copy non-blank to blank
// 4) copy non-blank to non-blank

// 1) we don't have to do anything: pixels are blank for source and dest,
//    and the tilemap won't change either
// 2) we have to erase dest pixels and set dest tilemap to 0xE2FF
// 3) we have to copy source pixels to dest pixels and set dest tilemap
//    to the proper tile index
// 4) we only have to copy the source pixels to dest pixels

// Check blank by comparing tilemap with 0xE2FF
// 0xE2FF is already stored to [sp+(# of regs pushed * 4)]
ldr     r0,[sp,20]
ldrh    r1,[r7]
ldrh    r2,[r5]

cmp     r1,r0
bne     @@next
cmp     r2,r0
bne     @@blank_to_nonblank

// Case 1: blank to blank
b       @@end

@@next:
cmp     r2,r0
bne     @@nonblank_to_nonblank

// Case 3: non-blank to blank
@@nonblank_to_blank:

    // Copy pixels up
    ldrh    r0,[r6,0x22]
    lsl     r0,r0,16
    add     r0,r0,r4
    lsr     r0,r0,16 // x
    ldrh    r1,[r6,0x24]
    add     r1,r8 // dest y
    mov     r4,r1
    add     r1,2 // source y
    bl      copy_tile_up

    // Set proper tilemap
    mov     r1,r4 // dest y
    push    {r1-r3}
    bl      get_tile_number
    pop     {r1-r3}
    ldr     r1,=0x30051EC
    ldrh    r2,[r1]
    add     r0,r0,r2 // dest tile number
    ldrh    r1,[r1,0x3C] // 0xE000
    orr     r0,r1
    strh    r0,[r5]
    b       @@end

// Case 2: blank to non-blank
@@blank_to_nonblank:

    // Set dest tilemap to 0xE2FF
    strh    r0,[r5]

// Case 4: non-blank to non-blank
@@nonblank_to_nonblank:

    // Copy pixels up
    ldrh    r0,[r6,0x22]
    lsl     r0,r0,16
    add     r0,r0,r4
    lsr     r0,r0,16 // x
    ldrh    r1,[r6,0x24]
    add     r1,r8 // dest y
    add     r1,2 // source y
    bl      copy_tile_up
    b       @@end

@@end:
pop     {r4-r7,pc}
.pool

//==============================================================================
// Erase tile (for short windows)
// r2: 100
// r4: (x << 16) (relative)
// r5: dest tilemap
// r6: window
// r8: y (dest, relative)
ca4bc_erase_tile_short:
push    {lr}
add     sp,-12

// Clobbered code
orr     r0,r1 // 0xE2FF
strh    r0,[r5] // dest tilemap

// We need to erase the pixels
ca4bc_erase_tile_common:
mov     r0,sp
strh    r2,[r0,8] // tile offset
ldr     r2,=0x44444444
str     r2,[r0,4] // empty row of pixels
ldrh    r2,[r6,0x22]
lsl     r2,r2,16
add     r2,r2,r4
lsr     r2,r2,16 // x
ldrh    r1,[r6,0x24]
add     r1,r8 // y
strh    r2,[r0]
strh    r1,[r0,2]
bl      clear_tile_internal

add     sp,12
pop     {pc}
.pool

//==============================================================================
// Erase tile
ca4bc_erase_tile:
push    {lr}
add     sp,-12

// Clobbered code
ldrh    r1,[r1]
strh    r1,[r5]

// We need to erase the pixels
ldr     r2,=0x30051EC
ldrh    r2,[r2]
b       ca4bc_erase_tile_common
.pool

//==============================================================================
// Clear PSI window when scrolling through classes
e06ec_clear_window:
push    {r0-r1,lr}
ldr     r0,=0x3002500
ldrh    r0,[r0]
cmp     r0,0
beq     @@next
ldr     r0,=0x3005230
ldr     r0,[r0,0x1C]
mov     r1,4
bl      clear_window

@@next:
pop     {r0-r1}

// Clobbered code
lsl     r0,r0,0x10
asr     r4,r0,0x10
pop     {pc}
.pool

//==============================================================================
// Redraw PSI command when exiting PSI subwindow
e06ec_redraw_psi:
push    {r0-r3,lr}

// Clear old tiles
mov     r0,2
mov     r1,3
mov     r2,1
bl      print_blankstr

// Render PSI string
add     sp,-4
ldr     r0,=0x80DC1EC // address of PSI string pointer
ldr     r1,[r0] // PSI string pointer
ldr     r0,=0x3005230
ldr     r0,[r0] // window pointer
mov     r2,1 // highlight
str     r2,[sp]
mov     r2,1
mov     r3,1
bl      0x80C96F0 // render string
add     sp,4

// Clobbered code
pop     {r0-r3}
bl      0x80BD7F8 // restore tilemaps
pop     {pc}
.pool

//==============================================================================
// Redraw Bash/Do Nothing and PSI commands when exiting PSI ally target subwindow
e06ec_redraw_bash_psi:
push    {r0-r3,lr}
add     sp,-4

// Clear old tiles
mov     r0,2
mov     r1,1
mov     r2,1
bl      print_blankstr
add     r1,2
bl      print_blankstr

// We need to figure out whether to draw Bash or Do Nothing
// If [0x2025122] == 2, draw Do Nothing; else, draw Bash
// We'll never draw Shoot because Jeff doesn't use PSI
ldr     r0,=0x2025122
ldrh    r0,[r0]
cmp     r0,2
beq     @@donothing
ldr     r0,=0x80DBFB0
b       @@next
@@donothing:
ldr     r0,=0x80DC108
@@next:
ldr     r1,[r0]
ldr     r0,=0x3005230
ldr     r0,[r0] // window pointer
mov     r2,0 // no highlight
str     r2,[sp]
mov     r2,1
mov     r3,0
bl      0x80C96F0 // render string

// Render PSI string
ldr     r0,=0x80DC1EC // address of PSI string pointer
ldr     r1,[r0] // PSI string pointer
ldr     r0,=0x3005230
ldr     r0,[r0] // window pointer
mov     r2,1 // highlight
str     r2,[sp]
mov     r2,1
mov     r3,1
bl      0x80C96F0 // render string
add     sp,4

// Clobbered code
pop     {r0-r3}
bl      0x80BD7F8 // restore tilemaps
pop     {pc}
.pool

//==============================================================================
// Print "PSI "
c239c_print_psi:
push    {lr}
add     sp,-4
mov     r2,0
str     r2,[sp]
mov     r2,r4
lsl     r3,r3,3 // tiles-to-pixels
bl      print_string_hlight_pixels
add     sp,4
pop     {pc}

//==============================================================================
// Use new pointer for user/target strings
ebfd4_user_pointer:
push    {lr}
mov     r4,0x4C
lsl     r4,r4,4
add     r0,r0,r4
mov     r5,r0
lsl     r4,r1,0x10
asr     r4,r4,0x10
mov     r1,r2
mov     r2,r4
bl      0x80F4C78
add     r0,r4,r5
mov     r1,0
strb    r1,[r0]
mov     r1,0xFF
strb    r1,[r0,1]
pop     {pc}

ec004_user_pointer:
push    {r1}
ldr     r1,[sp,4]
mov     lr,r1
pop     {r1}
add     sp,4
ldr     r0,=0x3005220
ldr     r0,[r0]
mov     r1,0x4C
lsl     r1,r1,4
add     r0,r0,r1
bx      lr

ec010_target_pointer:
push    {lr}
mov     r4,0x50
lsl     r4,r4,4
add     r0,r0,r4
mov     r5,r0
lsl     r4,r1,0x10
asr     r4,r4,0x10
mov     r1,r2
mov     r2,r4
bl      0x80F4C78
add     r0,r4,r5
mov     r1,0
strb    r1,[r0]
mov     r1,0xFF
strb    r1,[r0,1]
pop     {pc}

ec046_target_pointer:
push    {r1}
ldr     r1,[sp,4]
mov     lr,r1
pop     {r1}
add     sp,4
ldr     r0,[r0]
mov     r1,0x50
lsl     r1,r1,4
add     r0,r0,r1
bx      lr

c980c_user_pointer:
ldr     r1,[r0]
mov     r0,0x4C
lsl     r0,r0,4
add     r1,r0,r1
ldr     r0,[r5,0x1C]
bx      lr

c980c_target_pointer:
ldr     r0,[r0]
mov     r7,0x50
lsl     r7,r7,4
add     r0,r0,r7
bx      lr
.pool

//==============================================================================
// Add a space between enemy name and letter in multi-enemy fights
dcd00_enemy_letter:
sub     r0,0x90
strb    r0,[r5,1]
mov     r0,0x50
strb    r0,[r5]
bx      lr

dae00_enemy_letter:
sub     r0,0x90
strb    r0,[r4,1]
mov     r0,0x50
strb    r0,[r4]
bx      lr

//==============================================================================
// "The" flag checks
db04c_theflag:
push    {r4,lr}

// Clobbered code: get enemy string pointer
lsl     r4,r2,1
bl      0x80BE260
mov     r1,r0
mov     r0,sp
add     r0,8

// Check for "The" flag
ldr     r3,=m2_enemy_attributes
ldrb    r3,[r3,r4] // "The" flag
cmp     r3,0
beq     @@next

// Write "The " before the enemy name
ldr     r2,=0x50959884
str     r2,[r0]
add     r0,4

@@next:
pop     {r4,pc}
.pool
