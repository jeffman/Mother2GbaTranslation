//==============================================================================
c980c_custom_codes:
push    {r1-r2,lr}
mov     r1,r7
mov     r2,r5
bl      customcodes_parse
ldr     r1,[r6]

// If 0, return [r6]+2; otherwise, return [r6]+r0
cmp     r0,#0
beq     @@next
cmp     r0,#0
bge     @@continue //If -1, then set this to 0
mov     r0,#0
@@continue:
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
strb    r1,[r0,2]
pop     {r1}
bl      0x80C87D0
pop     {pc}

//==============================================================================
c980c_resetx_newline:
push    {lr}
strh    r0,[r5,0x2C]
strh    r4,[r5,0x2A]
strb    r4,[r5,2]
pop     {pc}

//==============================================================================
c980c_resetx_scroll:
push    {lr}
strh    r0,[r5,0x2C]
strh    r1,[r5,0x2A]
strb    r1,[r5,2]
pop     {pc}

//==============================================================================
c980c_resetx_other:
push    {lr}
strh    r0,[r5,0x2C]
strh    r2,[r5,0x2A]
strb    r2,[r5,2]
pop     {pc}

//==============================================================================
c980c_resetx_other2:
push    {lr}
mov     r2,0
strh    r2,[r5,0x2A]
strb    r2,[r5,2]
pop     {pc}

//==============================================================================
c980c_resetx_other3:
push    {lr}
mov     r1,0
strh    r1,[r5,0x2A]
strb    r1,[r5,2]
pop     {pc}

//==============================================================================
c980c_resetx_other4:
push    {lr}
strh    r0,[r5,0x2C]
strh    r6,[r5,0x2A]
strb    r6,[r5,2]
pop     {pc}

//==============================================================================
c87d0_clear_entry:
push    {lr}

// Reset X
mov     r1,0
strb    r1,[r0,2]

// Clear window
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
strb    r4,[r6,2]

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
push    {r0-r4,lr}
add     sp,-4
mov     r3,r0
ldr     r0,=0x44444444
str     r0,[sp]
ldrh    r0,[r3,0x22]
add     r0,6
ldrh    r1,[r3,0x24]
ldrh    r2,[r3,0x26]
sub     r2,6
ldrh    r3,[r3,0x28]
bl      clear_rect
add     sp,4
pop     {r0-r4,pc}
.pool


//==============================================================================
// Clear equipment and offense/defense when moving left/right on equip screen
// r6 = window pointer
c4b2c_clear_left:
mov     r0,r6
bl      clear_equipment

// Clear offense/defense
push    {r0-r3}
mov     r0,8
mov     r1,0xB
mov     r2,8
bl      print_blankstr
mov     r0,8
mov     r1,0xD
mov     r2,8
bl      print_blankstr
pop     {r0-r3}

// Clobbered code
strh    r1,[r3]
ldr     r0,=0x80C4F3B
bx      r0

c4b2c_clear_right:
mov     r0,r6
bl      clear_equipment

// Clear offense/defense
push    {r0-r3}
mov     r0,8
mov     r1,0xB
mov     r2,8
bl      print_blankstr
mov     r0,8
mov     r1,0xD
mov     r2,8
bl      print_blankstr
pop     {r0-r3}

// Clobbered code
strh    r1,[r3]
ldr     r0,=0x80C4EFF
bx      r0
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
push    {r0-r3,lr}
mov     r0,5
mov     r1,0xF
mov     r2,0x14
bl      print_blankstr
pop     {r0-r3,pc}

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
bl      initWindow_buffer

// Render text
mov     r0,r4
bl      statusWindowText

// Render numbers
mov     r0,r4
ldrh    r1,[r0,#0]
ldr     r2,=#0xFBFF
and     r1,r2
strh    r1,[r0,#0]
mov     r1,0
bl      statusNumbersPrint

pop     {r4,pc}
.pool

//==============================================================================
// Redraws the status window (when exiting the PSI menu) and stores it
bac18_redraw_status_store:
push    {lr}
bl      bac18_redraw_status
bl      store_pixels_overworld
pop     {pc}
.pool

//==============================================================================
// Calls m2_soundeffect only if we're going in either talk or check
beaa6_fix_sounds:
push    {lr}
mov     r1,r10
add     r1,r1,r4
mov     r2,r5
add     r2,#0x42
ldrb    r2,[r2,#0] //Is this the status window? If not, then do the sound
cmp     r2,#0
beq     @@sound
cmp     r1,#0
beq     @@sound
cmp     r1,#4
bne     @@end
@@sound:
bl      m2_soundeffect
@@end:
pop     {pc}

//==============================================================================
// Loads the buffer up in battle
dc22a_load_buffer_battle:
push    {lr}
mov     r9,r0
ldr     r3,[r5,#0]
bl      load_pixels_overworld
push    {r0-r3}
swi     #5
pop     {r0-r3}
pop     {pc}

//==============================================================================
// Calls m2_soundeffect only if we're out of the main menu
bea88_fix_sounds:
push    {lr}
mov     r2,r5
add     r2,#0x42
ldrb    r2,[r2,#0] //Is this the status window? If not, then we may not want to do the sound
cmp     r2,#0
bne     @@sound
ldrb    r2,[r5,#3] //If we are printing, then don't do the sound
mov     r1,#1
and     r1,r2
cmp     r1,#0
beq     @@end
@@sound:
bl      m2_soundeffect
@@end:
pop     {pc}

//==============================================================================
// Only if the character changed store the buffer - called when reading inputs
bac6e_statusWindowNumbersInputManagement:
push    {lr}
ldr     r2,=#m2_active_window_pc
ldrb    r2,[r2,#0]
push    {r2}
bl      statusWindowNumbers
pop     {r2}
ldr     r1,=#m2_active_window_pc
ldrb    r1,[r1,#0]
cmp     r1,r2
beq     @@end
bl      store_pixels_overworld

@@end:
pop     {pc}

//==============================================================================
//Prints the attack target choice menu and stores the buffer
e02c6_print_target_store:
push    {lr}
bl      printTargetOfAttack
bl      store_pixels_overworld
pop     {pc}

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
ldr     r1,=#0x2012000
bl      clear_window_buffer

@@next:
// Clobbered code
pop     {r0}
lsl     r0,r0,0x10
asr     r4,r0,0x10
pop     {pc}

//==============================================================================
// Clear offense/defense when re-equipping (or un-equipping) something
baef8_reequip_erase:
push    {r0-r3,lr}
mov     r0,8
mov     r1,0xB
mov     r2,4
bl      print_blankstr
mov     r0,8
mov     r1,0xD
mov     r2,4
bl      print_blankstr

// Clobbered code
pop     {r0-r3}
mov     r0,2
strh    r0,[r1]
pop     {pc}

//==============================================================================
// Redraw main menu when exiting PSI target window
b8bbc_redraw_menu_2to1:
push    {r1-r4,lr}
add     sp,-4

swi #5

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
bl      print_window_with_buffer

swi #5

// Clobbered code (restore the window borders, etc.)
mov     r0,1
bl      m2_swapwindowbuf

add     sp,4
pop     {r1-r4,pc}
.pool

//==============================================================================
// Redraw main menu when exiting PSI window from using a PSI and stores the buffer
b8bbc_redraw_menu_13to2_store:
push    {lr}
bl      b8bbc_redraw_menu_13to2
mov     r3,r9
cmp     r3,#0
beq     @@end //store only if we're exiting the menu
bl      store_pixels_overworld
@@end:
pop     {pc}

//==============================================================================
// Redraw main menu when entering PSI target window
b8bbc_redraw_menu_13to2:
push    {r1-r4,lr}
add     sp,-4

swi #5

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
bl      print_window_with_buffer

swi #5

// Clobbered code (restore the window borders, etc.)
mov     r0,1
bl      0x80BD7F8

add     sp,4
pop     {r1-r4,pc}
.pool

//==============================================================================
// Print a space before the Greek letter
d3934_print_space:
push    {r2-r3,lr}
mov     r0,r4
bl      print_space
pop     {r2-r3}

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
    mov     r6,r0
    bl      copy_tile_up

    // Set proper tilemap
    mov     r0,r6 // dest x
    mov     r1,r4 // dest y
    bl      get_tile_number
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
push    {r0-r1,lr}

// Clobbered code
orr     r0,r1 // 0xE2FF
strh    r0,[r5] // dest tilemap

// We need to erase the pixels
ca4bc_erase_tile_common:
ldrh    r2,[r6,0x22]
lsl     r2,r2,16
add     r2,r2,r4
lsr     r0,r2,16 // x
ldrh    r1,[r6,0x24]
add     r1,r8 // y
ldr     r2,=0x44444444
bl      clear_tile

pop     {r0-r1,pc}
.pool

//==============================================================================
// Erase tile
ca4bc_erase_tile:
push    {r0-r1,lr}

// Clobbered code
ldrh    r1,[r1]
strh    r1,[r5]

// We need to erase the pixels
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
ldr     r0,=#0x3005230
ldr     r1,=#0x2012000
ldr     r0,[r0,0x1C]
bl      clear_window_buffer

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

mov     r0,#1
mov     r1,#2
mov     r2,#2
bl      printBattleMenu

// Clobbered code
pop     {r0-r3}
bl      0x80BD7F8 // restore tilemaps
pop     {pc}
.pool

//==============================================================================
// Redraw Bash/Do Nothing and PSI commands when exiting PSI ally target subwindow
e06ec_redraw_bash_psi:
push    {r0-r3,lr}
mov     r0,#1
mov     r1,#3
mov     r2,#2
bl      printBattleMenu

// Clobbered code
pop     {r0-r3}
bl      0x80BD7F8 // restore tilemaps
pop     {pc}
.pool

//==============================================================================
// Redraw Bash/Do Nothing, PSI commands, Goods and Defend when choosing enemy target
e06ec_redraw_bash_psi_goods_defend:
push    {lr}
push    {r0-r3}
ldr     r2,=#0x8B204E4 //Is this an offensive PSI which needs a target? If so, redraw the background window
ldr     r1,=#0x8B2A9B0
ldr     r0,[r6,#0x1C]
ldr     r0,[r0,#0x10]
ldrh    r3,[r0,#2]
lsl     r3,r3,#4
add     r0,r3,r1
ldrh    r3,[r0,#4]
lsl     r0,r3,#1
add     r0,r0,r3
lsl     r0,r0,#2
add     r3,r0,r2
ldrb    r0,[r3,#1]
cmp     r0,#1
beq     @@keep
cmp     r0,#3
bne     @@notOffensive //Otherwise, do not do it
@@keep:
ldrb    r0,[r3]
cmp     r0,#0
bne     @@notOffensive

mov     r0,#3
mov     r1,#3
mov     r2,#2
bl      printBattleMenu

@@notOffensive:

pop     {r0-r3}

bl      0x80C2480 //Prints the target
pop     {pc}
.pool

//==============================================================================
//Calls the funcion which loads the targets in and then stores the buffer
ba8ac_load_targets_print:
push    {lr}
ldr     r2,=#0x20248AC
ldrh    r2,[r2,#0]
push    {r2}
bl      0x80BAA80
pop     {r2}
cmp     r2,#0
bne     @@end //Store the buffer to vram only if the target window was printed.
bl      store_pixels_overworld
@@end:
pop     {pc}


//==============================================================================
// Print "PSI "
c239c_print_psi:
push    {lr}
add     sp,-4
mov     r2,0
str     r2,[sp]
mov     r2,r4
lsl     r3,r3,3 // tiles-to-pixels
bl      printstr_hlight_pixels_buffer
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
push    {lr}
bl      custom_user_pointer
ldr     r0,[r5,0x1C]
pop     {pc}

c980c_target_pointer:
ldr     r0,[r0]
mov     r7,0x50
lsl     r7,r7,4
add     r0,r0,r7
bx      lr
.pool

//==============================================================================
// Add a space between enemy name and letter in multi-enemy fights for the selection window. Called only by enemies.
dcd00_enemy_letter:
push    {r1-r2,lr}
ldrb    r1,[r5,#0]
cmp     r1,#1 //In case the name has a "The " at the beginning, remove it
bne     @@end
mov     r2,sp
add     r2,#0xC //Get where the writing stack for the name starts
sub     r5,r5,#4
@@cycle: //The removed and shifted everything by 4 bytes
ldr     r1,[r2,#4]
str     r1,[r2,#0]
add     r2,#4
cmp     r2,r5
ble     @@cycle

@@end:
sub     r5,r5,#2 //The the flag must be accounted for. It moves the pointer by 2, so we put it back
sub     r0,0x90
strb    r0,[r5,#1] //Put the letter near the enemy writing space
mov     r0,#0x50 //Store the space
strb    r0,[r5]
mov     r0,#0 //Store the the flag as 0
strb    r0,[r5,#4]
pop     {r1-r2,pc}
.pool

//==============================================================================
// Add a space between enemy name and letter in multi-enemy fights for 9F FF and AD FF. Only enemies call this.
dae00_enemy_letter:
push    {r1-r2,lr}
ldrb    r1,[r4,#0]
cmp     r1,#1 //In case the name has a "The " at the beginning, remove it
bne     @@end
mov     r2,sp
add     r2,#0xC //Get where the writing stack for the name starts
sub     r4,r4,#4
@@cycle: //The removed and shifted everything by 4 bytes
ldr     r1,[r2,#4]
str     r1,[r2,#0]
add     r2,#4
cmp     r2,r4
ble     @@cycle

@@end:
sub     r4,r4,#2 //The the flag must be accounted for. It moves the pointer by 2, so we put it back
sub     r0,0x90
strb    r0,[r4,#1] //Put the letter near the enemy writing space
mov     r0,#0x50 //Store the space
strb    r0,[r4]
mov     r0,#0 //Store the the flag as 0
strb    r0,[r4,#4]
pop     {r1-r2,pc}
.pool

//==============================================================================
// "The" flag checks for the Target window. It will always be lowercase, this makes things much simpler because it will never be changed due to the character printed before it, unlike how it happens with 9F FF and AD FF.
dcd5c_theflag:
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

// Write "the " before the enemy name
ldr     r2,=0x509598A4
str     r2,[r0]
add     r0,4

@@next:
pop     {r4,pc}
.pool

//==============================================================================
// "The" flag checks for AD FF and 9F FF
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

//==============================================================================
db08e_theflagflag: //Puts a flag at the end of the name that is 1 if the has been added. 0 otherwise. (called right after db04c_theflag or dcd5c_theflag)
push    {r3,lr}
bl      0x80DAEEC
pop     {r3}
add     r0,#2
strb    r3,[r0,#0]
mov     r3,r0
pop     {pc}
.pool

//==============================================================================
dae9c_king_0_the: //King is different than the other chosen ones, it's needed to operate on the stack before it goes to the proper address because its branch reconnects with the enemies' routine.
push    {r1,lr}
ldmia   [r0]!,r2,r3 //Loads and stores King's name
stmia   [r1]!,r2,r3
pop     {r0}
bl      _add_0_end_of_name
pop     {pc}

_get_pointer_to_stack: //r0 has the value r1 will have
push    {r1,lr}
mov     r1,r0
ldr     r0,=#0x3005220
ldr     r0,[r0,#0]
lsl     r1,r1,#4
add     r0,r0,r1 //Writing stack address
pop     {r1,pc}

_add_0_end_of_name: //assumes r0 has the address to the stack. Stores 0 after the end of the name.
push    {r1,lr}
@@cycle: //Get to the end of the name
ldrb    r1,[r0,#0]
cmp     r1,#0
beq     @@end_of_cycle
@@keep_going:
add     r0,#1
b       @@cycle
@@end_of_cycle:
ldrb    r1,[r0,#1]
cmp     r1,#0xFF
bne     @@keep_going
mov     r1,#0 //Store 0 after the 0xFF00
strb    r1,[r0,#2]
pop     {r1,pc}
//==============================================================================
daeda_party_0_the:
push    {lr}
bl      0x80DB01C
mov     r0,#0x50
bl      _get_pointer_to_stack
bl      _add_0_end_of_name
pop     {pc}

//==============================================================================
ec93c_party_0_the:
push    {lr}
bl      0x80EC010
mov     r0,#0x50
bl      _get_pointer_to_stack
bl      _add_0_end_of_name
pop     {pc}

//==============================================================================
db156_party_0_the:
push    {lr}
bl      0x80DB02C
mov     r0,#0x4C
bl      _get_pointer_to_stack
bl      _add_0_end_of_name
pop     {pc}

//==============================================================================
c9c58_9f_ad_minThe: //Routine that changes The to the and viceversa if need be for 9F FF and for AD FF
push    {r2,lr}
ldr     r0,=#0x3005220
cmp     r4,#0x9F //If this is 9F, then load the user string pointer
bne     @@ad_setup
bl      custom_user_pointer //Load the user string pointer
b       @@common

@@ad_setup: //If this is AD, then load the target string pointer
push    {r7}
bl      c980c_target_pointer //Load the target string pointer
pop     {r7}
mov     r1,r0

@@common:
mov     r2,#0

@@cycle:
ldrb    r0,[r1,r2]
cmp     r0,#0xFF
beq     @@next //Find its end
add     r2,#1
b       @@cycle

@@next:
add     r2,#1
ldrb    r0,[r1,r2]
cmp     r0,#1 //Does this string have the the flag? If it does not, then proceed to the end
bne     @@end
ldr     r2,=0x50959884 //Does this string have "The "? If it does, check if it ends instantly.
ldr     r0,[r1,#0]
cmp     r0,r2
beq     @@next_found_the
sub     r0,r0,r2 //Does this string have "the "? If it does not, then it's a character. Proceed to the end.
cmp     r0,#0x20
bne     @@end

@@next_found_the: //A starting "The " or "the " has been found
mov     r2,#0xFF
lsl     r2,r2,#8 //r2 has 0xFF00
ldrh    r0,[r1,#4] //Load the next two bytes after "The " or "the "
cmp     r0,r2 //If they're the same as r2, then it's a character. End this here.
beq     @@end
ldr     r0,=m2_cstm_last_printed
ldrb    r0,[r0,#0]
cmp     r0,#0x70 //Is the previous character an @?
beq     @@Maius
mov     r0,#0xA4 //Change The to the
strb    r0,[r1,#0]
b       @@end
@@Maius:
mov     r0,#0x84 //Ensure it is The
strb    r0,[r1,#0]

@@end:
ldr     r0,[r6,#0] //Clobbered code
add     r0,#2
pop     {r2,pc}
.pool

//==============================================================================
ca442_store_letter:
push    {r1,lr}
ldr     r1,=m2_cstm_last_printed
ldrb    r0,[r7,#0]
strb    r0,[r1,#0]
lsl     r0,r0,#1
pop     {r1,pc}

//==============================================================================
custom_user_pointer: //Routine that gives in r1 the user string pointer
ldr     r1,[r0,#0]
mov     r0,#0x4C
lsl     r0,r0,#4
add     r1,r0,r1
bx      lr

//==============================================================================
// r0 = window
// r9 = item index
// Return: r2 = x location for item string (relative to window location)
// Can use: r1, r3, r5
b998e_get_itemstring_x:
push    {lr}
mov     r5,r0

// r2 = cursor_x + 1 + (is_equipped(current_item_index) ? 1 : 0)
mov     r0,r9
add     r0,1
bl      m2_isequipped
ldrh    r1,[r5,0x34] // cursor_x
add     r0,r0,r1
add     r2,r0,1

mov     r0,r5
pop     {pc}
.pool

//==============================================================================
//Loads the player's name properly
eeb1a_player_name:
push    {lr}
mov     r2,#0x18 //Maximum amount of characters in the name
ldr     r1,=m2_player1 //Player's name new location
mov     r3,#0

@@continue_cycle: //Count the amount of characters
cmp     r3,r2
bge     @@exit_cycle
add     r0,r1,r3
ldrb    r0,[r0,#0]
cmp r0,#0xFF
beq     @@exit_cycle
add     r3,#1
b       @@continue_cycle

@@exit_cycle:
mov     r4,r3 //Store the amount of characters in r4

bl      0x80A322C //Clobbered code: load at which letter the routine is
lsl     r1,r4,#0x10
lsl     r0,r0,#0x10
cmp     r1,r0
blt     @@ended
bl      0x80A322C

mov     r3,#1
ldr     r1,=m2_player1 //Player's name new location. The routine starts from 1 because the original routine had a flag before the name, so we subtract 1 to the address we look at in order to avoid skipping a character
sub     r1,r1,r3
lsl     r0,r0,#0x10
asr     r0,r0,#0x10
add     r1,r1,r0
ldrb    r0,[r1,#0]
b       @@next

@@ended:
mov     r0,#0

@@next: //Do the rest of the routine
pop     {pc}
.pool

//==============================================================================
//These three hacks remove the game's ability to read the script instantly out of a won battle

cb936_battle_won: //Called at the end of a battle if it is won
push    {lr}
ldr     r0,=m2_script_readability //Remove the ability to instantly read the script
mov     r1,#8
strb    r1,[r0,#0]

ldr     r0,=#0x3000A6C //Clobbered code
mov     r1,#0
pop     {pc}

.pool

//==============================================================================

b7702_check_script_reading: //Makes the game wait six extra frames before being able to read the script out of battle
push    {lr}
ldr     r0,=m2_script_readability
ldrb    r1,[r0,#0]
cmp     r1,#2 //If the value is > 2, then lower it
ble     @@next
sub     r1,r1,#1
strb    r1,[r0,#0]
b       @@end

@@next:
cmp     r1,#2 //If the value is 2, change it to 0 and allow reading the script
bne     @@end
mov     r1,#0
strb    r1,[r0,#0]

@@end:
mov     r7,r10 //Clobbered code
mov     r6,r9
pop     {pc}
.pool

//==============================================================================

a1f8c_set_script_reading: //Changes the way the game sets the ability to read the script
push    {lr}
ldrb    r1,[r0,#0]
cmp     r1,#8 //If this particular flag is set, then don't do a thing. Allows to make it so the game waits before reading the script.
beq     @@next
mov     r1,#0
strb    r1,[r0,#0]
b       @@end

@@next:
mov     r1,#0

@@end:
pop     {pc}

.pool

//==============================================================================
//Hacks that load specific numbers for the new names
_2352_load_1d7:
mov     r0,#0xEB
lsl     r0,r0,#1
add     r0,r0,#1
bx      lr

_2372_load_1e5:
mov     r0,#0xF2
lsl     r0,r0,#1
add     r0,r0,#1
bx      lr

c98c4_load_1d7:
mov     r4,#0xEB
lsl     r4,r4,#1
add     r4,r4,#1
bx      lr

c98d4_load_1e5:
mov     r4,#0xF2
lsl     r4,r4,#1
add     r4,r4,#1
bx      lr

//==============================================================================
//Fast routine that uses the defaults and stores them. Original one is a nightmare. Rewriting it from scratch. r1 has the target address. r5 has 0.
cb2f2_hardcoded_defaults:
push    {lr}
mov     r0,#0x7E //Ness' name
strb    r0,[r1,#0]
mov     r2,#0x95
strb    r2,[r1,#1]
strb    r2,[r1,#0xF]
mov     r0,#0xA3
strb    r0,[r1,#2]
strb    r0,[r1,#3]
mov     r4,#0xFF
lsl     r5,r4,#8
strh    r5,[r1,#4]
add     r1,#7
mov     r0,#0x80 //Paula's name
strb    r0,[r1,#0]
strb    r0,[r1,#0xE]
mov     r3,#0x91
strb    r3,[r1,#1]
strb    r3,[r1,#4]
mov     r0,#0xA5
strb    r0,[r1,#2]
mov     r0,#0x9C
strb    r0,[r1,#3]
strb    r5,[r1,#5]
strb    r4,[r1,#6]
add     r1,#7
mov     r0,#0x7A //Jeff's name
strb    r0,[r1,#0]
mov     r0,#0x95
strb    r0,[r1,#1]
mov     r0,#0x96
strb    r0,[r1,#2]
strb    r0,[r1,#3]
strh    r5,[r1,#4]
add     r1,#7
strb    r4,[r1,#4]
mov     r4,#0x9F //Poo's name
strb    r4,[r1,#1]
strb    r4,[r1,#2]
strb    r5,[r1,#3]
add     r1,#7
mov     r0,#0x7B //King's name
strb    r0,[r1,#0]
mov     r0,#0x99
strb    r0,[r1,#1]
mov     r0,#0x9E
strb    r0,[r1,#2]
mov     r0,#0x97
strb    r0,[r1,#3]
strh    r5,[r1,#4]
add     r1,#8
mov     r0,#0x83 //Steak's name
strb    r0,[r1,#0]
mov     r0,#0xA4
strb    r0,[r1,#1]
strb    r2,[r1,#2]
strb    r3,[r1,#3]
mov     r3,#0x9B
strb    r3,[r1,#4]
mov     r2,#0xFF
strb    r5,[r1,#5]
strb    r2,[r1,#6]
add     r1,#8
mov     r0,#0x82 //Rockin's name
strb    r0,[r1,#0]
strb    r4,[r1,#1]
mov     r0,#0x93
strb    r0,[r1,#2]
strb    r3,[r1,#3]
mov     r0,#0x99
strb    r0,[r1,#4]
mov     r0,#0x9E
strb    r0,[r1,#5]
strh    r5,[r1,#6]
mov     r2,#1
mov     r5,#0

pop     {pc}

//==============================================================================
//Routine for window headers that fixes the issue character - tiles
fix_char_tiles:
push    {lr}
lsl     r0,r2,#1
lsl     r1,r2,#2
add     r1,r1,r0 //Multiply r2 (character count) by 6
lsr     r0,r1,#3 //Divide by 8
lsl     r0,r0,#3 //Re-multiply by 8
cmp     r0,r1 //Can it stay in r0 pixels? (Was this a division by 8 without remainder?)
beq     @@next
add     r0,#8 //If it cannot stay in x tiles, add 1 to the amount of tiles needed

@@next:
lsr     r0,r0,#3 //Get the amount of tiles needed
cmp     r0,r2 //If it's not the same amout as the characters...
beq     @@end
sub     r0,r2,r0
lsl     r0,r0,#1
sub     r6,r6,r0 //Remove the amount of extra tiles

@@end:
pop     {pc}

//==============================================================================
//Specific fix_char_tiles routine - Status window
c0b28_fix_char_tiles:
push    {lr}
bl      fix_char_tiles
ldr     r0,[r4,#0] //Clobbered code
add     r0,#0xB3
pop     {pc}

//==============================================================================
//Specific fix_char_tiles routine - Give window
c009e_fix_char_tiles:
push    {lr}
mov     r2,r5
bl      fix_char_tiles
ldr     r2,=#0x30051EC //Clobbered code
ldrh    r0,[r2]
pop     {pc}

//==============================================================================
//Specific fix_char_tiles routine - Equip window
c4bd6_fix_char_tiles:
push    {lr}
mov     r6,r7
bl      fix_char_tiles
mov     r7,r6
ldr     r2,=#0x30051EC //Clobbered code
ldrh    r0,[r2]
pop     {pc}

.pool
//==============================================================================
//Specific fix_char_tiles routine - Outer PSI window
c42e0_fix_char_tiles:
push    {lr}
bl      fix_char_tiles
mov     r2,r9 //Clobbered code
ldrh    r0,[r2,#0]
pop     {pc}

//==============================================================================
//Specific fix_char_tiles routine - Inner PSI window - part 2
c4448_fix_char_tiles:
push    {lr}
bl      fix_char_tiles
mov     r2,r8 //Clobbered code
ldrh    r0,[r2,#0]
pop     {pc}

//==============================================================================
//Routine which clears the header and THEN makes it so the string is printed
c6190_clean_print:
push    {lr}
push    {r0-r3}
mov     r1,#6 //Number of tiles to clean
bl      clear_window_header
pop     {r0-r3}
bl      0x80CAB90
pop     {pc}

//==============================================================================
//Routine which clears the header and THEN makes it so the string is printed
c65da_clean_print:
push    {lr}
push    {r0-r3}
mov     r1,#3 //Number of tiles to clean
bl      clear_window_header
pop     {r0-r3}
bl      0x80CAB90
pop     {pc}

//==============================================================================
//Routine which clears the header and THEN makes it so the string is printed
_0x10_clean_print:
push    {lr}
push    {r0-r3}
mov     r1,#0x10 //Number of tiles to clean
bl      clear_window_header
pop     {r0-r3}
bl      0x80CAB90
pop     {pc}

//==============================================================================
//Routine which calls the header clearer and changes the position of Stored Goods in the arrangement
c6570_clean_print_change_pos:
push    {lr}
bl      _0x10_clean_print
ldr     r2,=#0x230 //Change starting position
mov     r0,r2 //Clobbered code
ldrh    r3,[r4,#0]
add     r0,r0,r3
mov     r2,r8
ldrh    r1,[r2,#0]
orr     r0,r1
mov     r2,#0

@@cycle: //Print 9 tiles in the arrangement
lsl     r0,r0,#0x10
lsr     r0,r0,#0x10
mov     r1,r0
add     r0,r1,#1
strh    r1,[r5,#0]
add     r5,#2
add     r2,#1
cmp     r2,#9
bne     @@cycle

pop     {pc}

.pool

//==============================================================================
//Routine which gives the address to the party member's inventory
get_inventory_selected:
push    {r3,lr}
ldr     r0,=#0x30009FB //Load source pc
ldrb    r0,[r0,#0]
ldr     r3,=#0x3001D40 //Get inventory
mov     r2,#0x6C
mul     r0,r2
add     r3,#0x14
add     r0,r0,r3
pop     {r3,pc}

//==============================================================================
//Routine which gets the address to the selected party member's inventory and then prints it
get_print_inventory_window:
push    {r0-r4,lr}
bl      get_inventory_selected
mov     r1,r0 //Inventory
ldr     r0,[r4,#0x10] //Window

ldr     r3,=m2_active_window_pc //Change the pc of the window so m2_isequipped can work properly
ldr     r2,[r3,#0]
lsl     r2,r2,#0x10
asr     r2,r2,#0x10
push    {r2}
ldr     r2,=#0x30009FB //Load source pc
ldrb    r2,[r2,#0]
str     r2,[r3,#0] //Store it

mov     r2,#0 //No y offset
bl      goods_print_items //Print the inventory

pop     {r2}
ldr     r3,=m2_active_window_pc //Restore pc of the window
lsl     r2,r2,#0x10
asr     r2,r2,#0x10
str     r2,[r3,#0]

pop     {r0-r4,pc}

//==============================================================================
//Specific Routine which calls get_print_inventory_window
ba48e_get_print_inventory_window:
push    {lr}
push    {r4}
ldr     r4,=#0x3005230
bl      get_print_inventory_window //Prints old inventory
pop     {r4}
bl      0x80BD7F8 //Copies old arrangements, this includes the highlight
pop     {pc}

//==============================================================================
//Specific Routine which calls get_print_inventory_window
b9ecc_get_print_inventory_window:
push    {lr}
push    {r4}
ldr     r4,=#0x3005230
bl      get_print_inventory_window //Prints old inventory
pop     {r4}
bl      0x80BD7F8 //Copies old arrangements, this includes the highlight
pop     {pc}

//==============================================================================
//Specific Routine which calls get_print_inventory_window
ba61c_get_print_inventory_window:
push    {r5,lr}
mov     r5,r7
bl      get_print_inventory_window //Prints old inventory
bl      0x80BD7F8 //Copies old arrangements, this includes the highlight
pop     {r5,pc}

.pool

//==============================================================================
//Reprints both the Main window and the Cash window if need be
generic_reprinting_first_menu:
push    {lr}
push    {r0-r6}
add     sp,#-8
ldr     r6,=#0x3005078 //Make sure the game expects only the right amount of lines to be written (so only 1)
ldrb    r4,[r6,#0]
str     r4,[sp,#4]
mov     r4,#0
strb    r4,[r6,#0]
ldr     r4,=#0x3005230 //Window generic address

//Main window
mov     r2,#1
ldr     r0,[r4,#0] //Main window place in ram
ldrb    r0,[r0,#0]
and     r2,r0
cmp     r2,#0
beq     @@cash //Check if window is enabled before printing in it

ldr     r0,=#0x8B17EE4
ldr     r1,=#0x8B17424
ldr     r3,=m2_psi_exist //Flag which if not 0xFF means no one has PSI
ldrb    r3,[r3,#0]
cmp     r3,#0xFF
beq     @@psiNotFound
mov     r2,#0
b       @@keep_going
@@psiNotFound:
mov     r2,#1
@@keep_going:
bl      m2_strlookup //Load the proper menu string based on m2_psi_exist
mov     r1,#0
str     r1,[sp,#0]
mov     r1,r0
ldr     r0,[r4,#0]
mov     r2,#5
mov     r3,#2
bl      0x80BE4C8 //Let it do its things
ldr     r0,[r4,#0]
bl      0x80C8BE4 //Print text in the window

@@cash:
//Cash
mov     r2,#1
ldr     r0,[r4,#4] //Cash window place in ram
ldrb    r0,[r0,#0]
and     r2,r0
cmp     r2,#0
beq     @@end //Check if window is enabled before printing in it

ldr     r2,=#0x300130C
ldr     r0,[r2,#0]
mov     r1,#2
orr     r0,r1
str     r0,[r2,#0]
ldr     r0,=#0x3001D40
mov     r1,#0xD2
lsl     r1,r1,#3
add     r0,r0,r1
ldr     r0,[r0,#0] //Load the money
ldr     r5,=#0x3005200
ldr     r1,[r5,#0]
mov     r2,r1 //Load the string address
mov     r1,#0x30 //Padding
bl      format_cash_window
ldr     r0,[r4,#4]
ldr     r1,[r5,#0]
mov     r2,#0
bl      m2_initwindow //Let it do its things
ldr     r0,[r4,#4]
bl      0x80C8BE4 //Print text in the window

@@end:
ldr     r4,[sp,#4]
strb    r4,[r6,#0] //Restore expected amount of lines to be written
add     sp,#8
pop     {r0-r6}
pop     {pc}

.pool

//==============================================================================
//Specific (But still very generic) call to generic_reprinting_first_menu which then calls swapwindowbuf as expected from the game
_reprint_first_menu:
push    {lr}
bl      generic_reprinting_first_menu
mov     r0,#1
bl      m2_swapwindowbuf
pop     {pc}

//==============================================================================
//Specific call to generic_reprinting_first_menu which then calls a DMA transfer of the old arrangement
c6ba2_reprint_first_menu:
push    {lr}
bl      generic_reprinting_first_menu
mov     r0,#1
bl      0x80BD7F8
pop     {pc}

//==============================================================================
//Specific call to b9aa2_special_string, needed for the help function
ba7be_reprint_first_menu:
push    {lr}
bl      b9aa2_special_string
ldr     r1,=#0x40000D4
ldr     r0,=#0x3005200
pop     {pc}

//==============================================================================
//Specific call to b9aa2_special_string, needed for when you exit the item action function
b9aa2_reprint_first_menu:
push    {lr}
bl      b9aa2_special_string
mov     r0,#1
bl      0x80BD7F8
pop     {pc}

//==============================================================================
//Setup which only prints either "Check" or "PSI \n Check" in the main window. Needed in order to avoid the not-needed options popping in the item window for 2-3 frames
b9aa2_special_string:
push    {lr}
push    {r0-r5}
add     sp,#-68
ldr     r5,=#0x3005078 //Make sure the game expects only the right amount of lines to be written (so only 1)
ldrb    r4,[r5,#0]
str     r4,[sp,#4]
mov     r4,#0
strb    r4,[r5,#0]
ldr     r4,=#0x3005230 //Window generic address

//Main window
mov     r2,#1
ldr     r0,[r4,#0] //Main window place in ram
ldrb    r0,[r0,#0]
and     r2,r0
cmp     r2,#0
beq     @@end //Check if window is enabled before printing in it

ldr     r1,=m2_psi_exist
ldrb    r1,[r1,#0]
add     r0,sp,#8
bl      setupShortMainMenu //Get shortened menu string
mov     r1,#0
str     r1,[sp,#0]
add     r1,sp,#8
ldr     r0,[r4,#0]
mov     r2,#5
mov     r3,#2
bl      0x80BE4C8 //Let it do its things
ldr     r0,[r4,#0]
bl      0x80C8BE4 //Print text in the window

@@end:
ldr     r4,[sp,#4]
strb    r4,[r5,#0] //Restore expected amount of lines to be written
add     sp,#68
pop     {r0-r5}
pop     {pc}

.pool

//==============================================================================
//Makes it sure the outer PSI window of the PSI Overworld menu prints the PSIs only once
b8cd2_psi_window:
push    {lr}
ldrb    r1,[r0,#3] //Checks vwf_skip
mov     r2,#1
and     r2,r1
cmp     r2,#1
beq     @@do_not_print
mov     r2,#1 //Goes on as usual and sets vwf_skip to true
orr     r2,r1
strb    r2,[r0,#3]
bl      clearWindowTiles_buffer
pop     {pc}

@@do_not_print: //Doesn't print in the PSI window
ldr     r1,=#m2_active_window_pc
mov     r2,#0
ldsh    r1,[r1,r2]
push    {r1} //Stores the active window pc
bl      0x80C3F28 //Input management function
pop     {r1} //Restores the active window pc
cmp     r0,#0 //Are we changing the window we're in? If this is 0, we're not
beq     @@no_change_in_window
lsl     r0,r0,#0x10 //If r0 is 0xFFFFFFFF, then we're exiting the window
lsr     r5,r0,#0x10 //Set up r5 properly
b       @@goToInner

@@no_change_in_window:
mov     r5,#0
ldr     r0,=#m2_active_window_pc
mov     r2,#0
ldsh    r0,[r0,r2] //Has the main character changed?
cmp     r0,r1
beq     @@keep
ldr     r0,[r4,#0x1C] //If it has, set wvf_skip to false
mov     r2,#0
strb    r2,[r0,#3]
pop     {r0}
add     r0,#0xA
bx      r0

@@goToInner:
ldr     r0,[r4,#0x1C] //Stores false in vwf_skip, which means the window will be printed
mov     r2,#0
strb    r2,[r0,#3]

@@keep:
ldr     r7,=#m2_active_window_pc //The game sets this up in the code we jump, so we need to set it up here
pop     {r0}
add     r0,#0x18
bx      r0 //Jump to the next useful piece of code

.pool

//==============================================================================
//Makes it sure the outer PSI window of the PSI Status menu prints the PSIs only once
bacea_status_psi_window:
push    {lr}
ldrh    r2,[r0,#0x36]
push    {r2} //Stores the cursor's Y position
bl      0x80BE53C //Input management function
push    {r0} //Stores the input
ldr     r0,[r5,#0x20] //Loads vwf_skip
ldrb    r1,[r0,#3]
mov     r2,#1
and     r2,r1
cmp     r2,#1 //Checks if true
beq     @@do_not_print
mov     r2,#1 //Sets vwf_skip to true and proceeds as usual
orr     r2,r1
strb    r2,[r0,#3]
pop     {r0}
pop     {r2}
pop     {pc}

@@do_not_print:
pop     {r0}
cmp     r0,#0 //If the input is > 0, then we're entering one of the submenus (Offensive, Healing, etc.)
bgt     @@goToInner
cmp     r0,#0
beq     @@noAction
lsl     r0,r0,0x10 //If the input is 0xFFFFFFFF we're exiting the window. Sets r4 up and vwf_skip to false, then exits the routine.
asr     r4,r0,0x10
ldr     r0,[r5,#0x20]
mov     r2,#0
strb    r2,[r0,#3]
pop     {r0}
pop     {r0}
add     r0,#4
bx      r0

@@noAction:
mov     r4,#0
pop     {r1}
ldr     r0,[r5,#0x20]
ldrh    r2,[r0,#0x36]
cmp     r1,r2 //Checks if the cursor's Y position is the same as it was before
beq     @@noActionAtAll
mov     r2,#0 //If it's not, then sets vwf_skip to false
strb    r2,[r0,#3]
@@noActionAtAll:
b       @@end //Goes to the end of the routine

@@goToInner:
lsl     r0,r0,0x10 //Properly stores the output into r4 and, since we're going into the inner window, sets vwf_skip to false
asr     r4,r0,0x10
ldr     r0,[r5,#0x20]
mov     r2,#0
strb    r2,[r0,#3]
pop     {r0}

@@end:
pop     {r0}
add     r0,#0x3E
bx      r0 //Jump to the next useful piece of code

//==============================================================================
//Makes it sure the outer PSI window of the PSI battle menu prints the PSIs only once
//It's the same as the one above, but the bottom exit is different
e079a_battle_psi_window:
push    {lr}
ldrh    r2,[r0,#0x36]
push    {r2} //Stores the cursor's Y position
bl      0x80BE53C //Input management function
push    {r0} //Stores the input
ldr     r0,[r5,#0x20] //Loads vwf_skip
ldrb    r1,[r0,#3]
mov     r2,#1
and     r2,r1
cmp     r2,#1 //Checks if true
beq     @@do_not_print
mov     r2,#1 //Sets vwf_skip to true and proceeds as usual
orr     r2,r1
strb    r2,[r0,#3]
pop     {r0}
pop     {r2}
pop     {pc}

@@do_not_print:
pop     {r0}
cmp     r0,#0 //If the input is > 0, then we're entering one of the submenus (Offensive, Healing, etc.)
bgt     @@goToInner
cmp     r0,#0
beq     @@noAction
lsl     r0,r0,0x10 //If the input is 0xFFFFFFFF we're exiting the window. Sets r4 up and vwf_skip to false, then exits the routine.
asr     r4,r0,0x10
ldr     r0,[r5,#0x20]
mov     r2,#0
strb    r2,[r0,#3]
pop     {r0}
pop     {r0}
add     r0,#4
bx      r0

@@noAction:
mov     r4,#0
pop     {r1}
ldr     r0,[r5,#0x20]
ldrh    r2,[r0,#0x36]
cmp     r1,r2 //Checks if the cursor's Y position is the same as it was before
beq     @@noActionAtAll
mov     r2,#0 //If it's not, then sets vwf_skip to false
strb    r2,[r0,#3]
@@noActionAtAll:
b       @@end //Goes to the end of the routine

@@goToInner:
lsl     r0,r0,0x10 //Properly stores the output into r4 and, since we're going into the inner window, sets vwf_skip to false
asr     r4,r0,0x10
ldr     r0,[r5,#0x20]
mov     r2,#0
strb    r2,[r0,#3]
pop     {r0}

@@end:
pop     {r0}
add     r0,#0x36
bx      r0 //Jump to the next useful piece of code

//==============================================================================
//Makes it sure the inner PSI window of the PSI status menu prints the descriptions only once
//It also sets things up to make it so the target window is only printed once
badb0_status_inner_window:
push    {lr}
ldrh    r1,[r0,#0x36] //Stores the cursor's Y of the window
push    {r1}
ldrh    r1,[r0,#0x34] //Stores the cursor's X of the window
push    {r1}
bl      PSITargetWindowInput //Input management, target printing and header printing function. Now the function takes the cursor's Y and X as arguments too in the stack
lsl     r0,r0,#0x10
lsr     r4,r0,#0x10 //Properly stores the output into r4

ldr     r1,=#0x8B2A9B0 //Clobbered code
ldr     r0,[r5,#0x1C]
add     r0,#0x42
ldrb    r0,[r0,#0]
lsl     r0,r0,#4
add     r1,#0xC
add     r0,r0,r1
ldr     r2,[r0,#0]

ldr     r0,[r5,#0x1C]
ldrh    r1,[r0,#0x34]
ldr     r3,[sp,#0]
cmp     r1,r3 //Checks if the cursor's X changed
bne     @@ChangedPosition
ldr     r3,[sp,#4] //If it did not, checks if the cursor's Y changed
ldrh    r1,[r0,#0x36]
cmp     r1,r3
beq     @@print

@@ChangedPosition:
ldr     r0,[r5,0x28] //Sets wvf_skip to false
mov     r1,#0
strb    r1,[r0,#3]

@@print: //Description printing
ldr     r0,[r5,0x28]
ldrb    r1,[r0,#3]
mov     r3,#1
and     r1,r3
cmp     r1,#0 //Checks if vwf_skip is false
bne     @@end
mov     r1,r2 //If it is, prints the PSI description
mov     r2,0
bl      initWindow_buffer //Initializes the PSI description window
ldr     r0,[r5,0x28]
bl      print_window_with_buffer //Prints the PSI description window
bl      store_pixels_overworld
ldr     r0,[r5,0x28]
ldrb    r1,[r0,#3] //Sets vwf_skip to true
mov     r3,#1
orr     r1,r3
strb    r1,[r0,#3]

@@end:
ldr     r0,=#0xFFFF //Are we exiting this window?
cmp     r4,r0
bne     @@ending

//If we are, set vwf_skip to false for both the description window and the target window
ldr     r0,[r5,0x28] //Description window
mov     r2,#0
strb    r2,[r0,#3]
ldr     r0,[r5,0x24] //Target window
strb    r2,[r0,#3]

@@ending:
pop     {r0}
pop     {r0}
pop     {r0}
add     r0,#0x18
bx      r0 //Jump to the next useful piece of code

.pool

//==============================================================================
//Fixes issue with sounds when going from the PSI window to the inner PSI window
b8d40_psi_going_inner_window:
push    {lr}
bl      PSITargetWindowInput
bl      store_pixels_overworld
pop     {pc}

//==============================================================================
//It sets things up to make it so the target window is only printed once
b8db4_psi_inner_window:
push    {lr}
ldrb    r1,[r0,#3]
push    {r1}
ldrh    r1,[r0,#0x36] //Stores the cursor's Y of the window
push    {r1}
ldrh    r1,[r0,#0x34] //Stores the cursor's X of the window
push    {r1}
bl      PSITargetWindowInput //Input management, target printing and header printing function. Now the function takes the cursor's Y and X as arguments too in the stack
pop     {r2}
ldr     r3,[r4,0x24] //Target window
ldrh    r1,[r3,#0x34] //Stores the cursor's X of the window
cmp     r1,r2
bne     @@store_buffer_first
pop     {r2}
ldrh    r1,[r3,#0x36] //Stores the cursor's Y of the window
cmp     r1,r2
bne     @@store_buffer_second
pop     {r2}
mov     r1,#1
and     r1,r2
cmp     r1,#1
beq     @@continue
b       @@store_buffer

@@store_buffer_first:
pop     {r2}
@@store_buffer_second:
pop     {r2}
@@store_buffer:
cmp     r0,#0
bne     @@continue
bl      store_pixels_overworld

@@continue:
cmp     r0,#0
beq     @@ending

mov     r2,#0 //Sets vwf_skip to false since the window is changed
ldr     r1,[r4,0x24] //Target window
strb    r2,[r1,#3]

@@ending:
pop     {pc}

.pool

//==============================================================================
//It sets things up to make it so the target window is only printed once
e0854_psi_inner_window_battle:
push    {lr}
ldrb    r1,[r0,#3]
push    {r1}
ldrh    r1,[r0,#0x36] //Stores the cursor's Y of the window
push    {r1}
ldrh    r1,[r0,#0x34] //Stores the cursor's X of the window
push    {r1}
bl      PSITargetWindowInput //Input management, target printing and header printing function. Now the function takes the cursor's Y and X as arguments too in the stack
pop     {r2}
ldr     r3,[r4,0x24] //Target window
ldrh    r1,[r3,#0x34] //Stores the cursor's X of the window
cmp     r1,r2
bne     @@store_buffer_first
pop     {r2}
ldrh    r1,[r3,#0x36] //Stores the cursor's Y of the window
cmp     r1,r2
bne     @@store_buffer_second
pop     {r2}
mov     r1,#1
and     r1,r2
cmp     r1,#1
beq     @@continue
b       @@store_buffer

@@store_buffer_first:
pop     {r2}
@@store_buffer_second:
pop     {r2}
@@store_buffer:
cmp     r0,#0
bne     @@continue
bl      store_pixels_overworld_psi_window

@@continue:
cmp     r0,#0
beq     @@ending

mov     r2,#0 //Sets vwf_skip to false since the window is change
ldr     r1,[r5,0x24] //Target window
strb    r2,[r1,#3]

@@ending:
pop     {pc}

.pool

//==============================================================================
_4092_print_window:
push    {lr}
push    {r0-r4}
bl      print_windows
pop     {r0-r4}
bl      0x800341C
pop     {pc}

//==============================================================================
_4294_print_window_store:
push    {lr}
push    {r0-r4}
ldr     r2,[sp,#0x20]
bl      print_windows
bl      store_pixels
pop     {r0-r4}
mov     r2,#0
mov     r3,#0
pop     {pc}

//==============================================================================
//X cursor for the Options submenu position
_position_X_Options:
push {lr}

cmp     r0,#1
bne     @@next1
mov     r0,#5
b       @@end
@@next1:
cmp     r0,#6
bne     @@next2
mov     r0,#11
b       @@end
@@next2:
cmp     r0,#11
bne     @@next3
mov     r0,#15
b       @@end
@@next3:
mov     r0,#20

@@end:
pop {pc}

//==============================================================================
//Sets X for highlighting the Options submenu in the File Select window
_40e2_cursor_X:
push    {lr}
mov     r0,r1
bl      _position_X_Options
sub     r1,r0,#3
mov     r0,#2
pop     {pc}

//==============================================================================
//Sets X cursor for the Options submenu in the File Select window
_41d4_cursor_X:
push    {lr}
bl      _position_X_Options
lsl     r0,r0,#3
pop     {pc}

//==============================================================================
//Makes sure Paula's window is loaded properly since the name length has been changed to 5 and the game previously used the 4 to load the window too
_4f7c_window_selector:
push    {lr}
mov     r0,#4
mov     r10,r0
ldr     r1,=#0x82B7FF8
pop     {pc}

.pool

//==============================================================================
//Prints and stores the PSI window in the PSI menu
baec6_psi_window_print_buffer:
push    {lr}
bl      psiWindow_buffer
bl      store_pixels_overworld
pop     {pc}

//==============================================================================
//Loads the buffer in if entering another window from the main window
b7d9a_main_window_manage_input:
push    {lr}
bl      0x80BE53C
cmp     r0,#0
beq     @@end
cmp     r0,#0
blt     @@end
bl      load_pixels_overworld
push    {r0-r2}
swi     #5
pop     {r0-r2}

@@end:
pop     {pc}

//==============================================================================
//Prints the target window if and only if the cursor's position changed in this input management function
c495a_status_target:
push    {r4,lr}
ldr     r1,=#0x3005230
ldr     r4,[r1,#0x24] //Loads the target window
ldr     r3,[sp,#0x30]
ldrh    r2,[r5,#0x34]
cmp     r2,r3 //Has the cursor's X changed?
bne     @@Updated
ldr     r3,[sp,#0x34] //If not, has the cursor's Y changed?
ldrh    r2,[r5,#0x36]
cmp     r2,r3
beq     @@printing

@@Updated:
mov     r2,#0 //If the cursor's position changed, set vwf_skip to false
strb    r2,[r4,#3]

@@printing:
ldrb    r1,[r4,#0x3]
mov     r2,#1
and     r2,r1
cmp     r2,#0 //Checks if vwf_skip is false
bne     @@end
ldrb    r1,[r4,#0x3] //If it is, sets vwf_skip to true, clears the window and updates the target window
mov     r2,#1
orr     r2,r1
strb    r2,[r4,#0x3]
mov     r3,r0
mov     r0,r4
ldr     r1,=#0x2012000
mov     r4,r3
bl      clear_window_buffer
mov     r0,r4
bl      psiTargetWindow_buffer

@@end:
pop     {r4,pc}

//==============================================================================
//Makes sure m2_initwindow properly sets vwf_skip to false
be45a_set_proper_wvf_skip:
push    {lr}
mov     r3,r0
mov     r0,#0
strb    r0,[r3,#3]
pop     {pc}


//==============================================================================
//Makes sure this initialization routine properly sets vwf_skip to false. This fixes an issue where due to a background the Goods window in battle might have not be printed
be4ca_set_proper_wvf_skip_goods_battle_window:
push    {lr}
mov     r4,#0
strb    r4,[r0,#3]

mov     r12,r0 //Clobbered code
mov     r4,r1
pop     {pc}

//==============================================================================
//Makes sure the window type is set to 0 for the inner PSI overworld menu window. Fixes an issue in M2GBA.
b8c2a_set_proper_wvf_skip_and_window_type:
push    {lr}
strb    r1,[r0,#1]
bl      initWindow_buffer
pop     {pc}


//==============================================================================
//Fix the random garbage issue for the alphabet for good
_2322_setup_windowing:
push    {lr}
bl      0x8012460 //Default code which sets up the names by copying memory which can be random
push    {r0-r1}
ldr     r0,=#m2_cstm_last_printed  //Set the window flag to 0 so no issue can happen
mov     r1,#0
strb    r1,[r0,#0]
pop     {r0-r1}
pop     {pc}

.pool

//==============================================================================
//Loads the vram into the buffer, it's called each time there is only the main file_select window active (a good way to set the whole thing up)
_38c0_load_pixels:
push    {lr}
ldr     r3,=#0x40000B0 //DMA transfer 0
ldr     r0,=#0x6008000 //Source
str     r0,[r3]
ldr     r0,=#0x2015000 //Target
str     r0,[r3,#4]
ldr     r0,=#0x84001200 //Store 0x4800 bytes
str     r0,[r3,#8]
ldr     r0,[r3,#8]
ldr     r3,[r5,#0]
mov     r0,#0x84
lsl     r0,r0,#2
pop     {pc}

//==============================================================================
//Stores the buffer into the vram. This avoids screen tearing.
store_pixels:
push    {r0-r1,lr}
ldr     r1,=#0x40000B0 //DMA transfer 0
ldr     r0,=#0x2015000 //Source
str     r0,[r1]
ldr     r0,=#0x6008000 //Target
str     r0,[r1,#4]
ldr     r0,=#0x94001200 //Store 0x4800 bytes
str     r0,[r1,#8]
ldr     r0,[r1,#8]
pop     {r0-r1,pc}

//==============================================================================
//Specific routine which calls store_pixels for the main file_select window
_38f8_store_pixels:
push    {lr}
bl      store_pixels
ldr     r1,[r5,#0]
mov     r3,#0xC
pop     {pc}

//==============================================================================
//Generic routine which prints a window and then stores the pixels of all the other windows. It's called once, after all the other windows (which will use _4092_print_window) have printed.
_4092_print_window_store:
push    {lr}
bl      _4092_print_window
bl      store_pixels
pop     {pc}

//==============================================================================
//Routine for the top part of the screen only. Used in order to make printing the names less CPU intensive when naming the characters 
_4edc_print_window_store:
push    {lr}
bl      _4092_print_window
push    {r0-r1}
ldr     r1,=#0x40000B0 //DMA transfer 0
ldr     r0,=#0x2015000 //Source
str     r0,[r1]
ldr     r0,=#0x6008000 //Target
str     r0,[r1,#4]
ldr     r0,=#0x94000200 //Store 0x800 bytes
str     r0,[r1,#8]
ldr     r0,[r1,#8]
pop     {r0-r1}
pop     {pc}

//==============================================================================
//Loads and prints the text lines for the file select main window
_setup_file_strings:
push    {r4-r5,lr}
add     sp,#-8
ldr     r5,=#0x3000024
ldr     r2,[r5,#0]
ldr     r4,[r2,#4]
str     r4,[sp,#4] //Save this here
mov     r4,#0
str     r4,[r2,#4]
mov     r0,#0
bl      0x8002170 //Routine which loads the save corresponding to r0
mov     r0,#1
bl      0x8002170
mov     r0,#2
bl      0x8002170
ldr     r3,[r5,#0]
mov     r0,#0x84
lsl     r0,r0,#2
add     r3,r3,r0
str     r4,[sp,#0]
mov     r0,#2
mov     r1,#1
mov     r2,#0x40
bl      wrapper_file_string_selection
ldr     r3,[r5,#0]
ldr     r0,=#0x454
add     r3,r3,r0
str     r4,[sp,#0]
mov     r0,#2
mov     r1,#3
mov     r2,#0x40
bl      wrapper_file_string_selection
ldr     r3,[r5,#0]
mov     r0,#0xD3
lsl     r0,r0,#3
add     r3,r3,r0
str     r4,[sp,#0]
mov     r0,#2
mov     r1,#5
mov     r2,#0x40
bl      wrapper_file_string_selection
mov     r0,#1
mov     r1,#0
mov     r2,#0
bl      0x800341C
ldr     r2,[r5,#0]
ldr     r4,[sp,#4]
str     r4,[r2,#4] //Restore this
add     sp,#8
pop     {r4-r5,pc}

.pool

//==============================================================================
//Prints a digit to the dialogue window
d37ec_print_number:
push    {lr}
bl      decode_character
mov     r1,r5
bl      print_character_to_window
pop     {pc}

//==============================================================================
//Makes it sure the outer equip menu prints the window only when needed
baf60_outer_equip_setup:
push    {lr}
ldr     r1,=#m2_active_window_pc
ldrb    r1,[r1,#0]
push    {r1} //Stores the active_window_pc
bl      equipReadInput //Input management function
pop     {r1}
cmp     r0,#0 //Has an action happened? (Are we entering/exiting the menu?)
beq     @@check_character_change

ldr     r1,[r6,#0x18] //Main equip window - If it has, then set vwf_skip to false for both the equipment numbers window and the main equipment window
mov     r2,#0
strb    r2,[r1,#3]
ldr     r1,[r6,#0x14] //Offense and Defense window
strb    r2,[r1,#3]
b       @@end

@@check_character_change:
ldr     r2,=#m2_active_window_pc
ldrb    r2,[r2,#0] //Has the character changed?
cmp     r2,r1
beq     @@end
ldr     r1,[r6,#0x14] //Offense and Defense window - If it has, then set vwf_skip to false for the equipment numbers window
mov     r2,#0
strb    r2,[r1,#3]

@@end:
pop     {pc}

//==============================================================================
//Prints the outer equip window only when needed - makes it so 0x80C4EB0 takes the previous m2_active_window_pc as a function parameter
c518e_outer_equip:
push    {lr}
ldr     r1,[sp,#0x1C]
lsl     r1,r1,#0x18
lsr     r1,r1,#0x18
ldr     r2,=#m2_active_window_pc
ldrb    r2,[r2,#0]
cmp     r1,r2 //Has the active_window_pc changed?
beq     @@printing
mov     r2,#0 //If it has, then reprint the window
strb    r2,[r0,#3]

@@printing:
ldrb    r1,[r0,#3]
mov     r2,#1
and     r2,r1
cmp     r2,#1
beq     @@skip //Check if vwf_skip is false

mov     r2,#1 //If it is, print and set it to true
orr     r2,r1
strb    r2,[r0,#3]
bl      0x80C4B2C //Prints the equip menu

@@skip:
pop     {pc}

//==============================================================================
//Prints the numbers in the offense/defense window for the outer equip window only when needed
bafc8_outer_equip_attack_defense:
push    {lr}
ldr     r1,[r6,#0x14] //Offense and Defense window
ldrb    r2,[r1,#3]
mov     r3,#1
and     r3,r2
cmp     r3,#1 //Is vwf_skip false?
beq     @@skip
cmp     r5,#0 //If it is, then print, but only if no action was performed
bne     @@skip

mov     r3,#1 //Set vwf_skip to true and continue as usual
orr     r3,r2
strb    r3,[r1,#3]
lsl     r0,r0,#0x18 //Clobbered code
lsr     r0,r0,#0x18
pop     {pc}

@@skip:
mov     r5,r7
add     r5,#0x12 //Setup r5 just like the code skipped does
pop     {r0}
mov     r1,#0xF1
lsl     r1,r1,#1
add     r0,r0,r1 //Jump to 0x80BB1AE
bx      r0

.pool

//==============================================================================
//Prints defense number and then sotres the buffer
bb1aa_printstr_store:
push    {lr}
mov     r3,#0
push    {r3}
mov     r3,#1
bl      printstr_buffer
bl      store_pixels_overworld
pop     {r3}
pop     {pc}

//==============================================================================
//Set things up so the numbers for Offense and Defense for the innermost equipment window is only printed when needed
bb990_inner_equip_attack_defense_setup:
push    {lr}
ldr     r1,=#0x3005200
ldr     r1,[r1,#0xC] //Window's item list
mov     r2,#0x36
ldsh    r2,[r0,r2] //Window's Y cursor
add     r1,r1,r2
ldrb    r1,[r1,#0] //Selected item
push    {r1}
bl      0x80C5500 //Input management function - returns the currently selected item
pop     {r1}
cmp     r1,r0 //Has the currently selected item changed?
bne     @@refresh

ldr     r1,=#0x3005230 //If not, check if A has been pressed
ldr     r1,[r1,#0x10]
ldr     r2,=#0xFFFF
ldrh    r3,[r1,#0x32] //If A has been pressed this becomes 0xFFFF
cmp     r2,r3
bne     @@end

@@refresh:
ldr     r1,=#0x3005230 //Set wvf_skip to false
ldr     r1,[r1,#0x14]
mov     r2,#0
strb    r2,[r1,#3]

@@end:
pop     {pc}

//==============================================================================
//Prints the numbers for Offense and Defense for the innermost window only if needed - Valid weapons
bb6b2_inner_equip_attack_defense_weapon:
push    {lr}
mov     r1,r9
ldr     r1,[r1,#0x14]
ldrb    r0,[r1,#3]
mov     r2,#1
and     r2,r0
cmp     r2,#1 //Is vwf_skip false?
beq     @@skip

mov     r2,#1 //If it is, set vwf_skip to true, clear the numbers' space and proceed normally
orr     r2,r0
strb    r2,[r1,#3]
bl      clear_offense_defense_inner_equip
mov     r1,r8
mov     r2,#0
pop     {pc}

@@skip:
mov     r5,r7 //Otherwise skip some code
add     r5,#0x12
mov     r4,#0
pop     {r0}
add     r0,#0x62 //Go to 0x80BB718
bx      r0

//==============================================================================
//Prints the numbers for Offense and Defense for the innermost window only if needed - None in weapons
bb64e_inner_equip_attack_defense_none_weapon:
push    {lr}
mov     r1,r9
ldr     r1,[r1,#0x14]
ldrb    r0,[r1,#3]
mov     r2,#1
and     r2,r0
cmp     r2,#1 //Is vwf_skip false?
beq     @@skip

mov     r2,#1 //If it is, set vwf_skip to true, clear the numbers' space and proceed normally
orr     r2,r0
strb    r2,[r1,#3]
bl      clear_offense_defense_inner_equip
mov     r3,r8 //This is where this differs from the routine above
mov     r1,#0
pop     {pc}

@@skip:
mov     r5,r7 //Otherwise skip some code
add     r5,#0x12
mov     r4,#0
pop     {r0}
add     r0,#0xC6 //Go to 0x80BB718 - The routine differs here too
bx      r0

//==============================================================================
//Prints the numbers for Offense and Defense for the innermost window only if needed - Defensive equipment
bbe7c_inner_equip_attack_defense_defensive_equipment:
push    {lr}
ldr     r1,=#0x3005230
ldr     r1,[r1,#0x14]
ldrb    r0,[r1,#3]
mov     r2,#1
and     r2,r0
cmp     r2,#1 //Is vwf_skip false?
beq     @@skip

mov     r2,#1 //If it is, set vwf_skip to true, clear the numbers' space and proceed normally
orr     r2,r0
strb    r2,[r1,#3]
bl      clear_offense_defense_inner_equip
mov     r4,#0
strb    r4,[r7,#0x15]
pop     {pc}

@@skip:
pop     {r0} //Otherwise go to the routine's end
ldr     r0,=#0x80BBEC7 //End of routine
bx      r0

//==============================================================================
//Clears the rightmost part of the Offense/Defense window for the innermost equipment menu
clear_offense_defense_inner_equip:
push    {lr}
mov     r0,0xD
mov     r1,0xB
mov     r2,0x3
bl      print_blankstr
mov     r0,0xD
mov     r1,0xD
mov     r2,0x3
bl      print_blankstr
pop     {pc}

.pool

//==============================================================================
//Fixes issue with file select menu not printing after going back to it from the alphabet
_53f6_fix_out_of_description:
push    {lr}
bl      0x800341C
bl      _setup_file_strings
mov     r0,#3
mov     r1,#0xA
mov     r2,#1
bl      _4092_print_window //Prints the text speed menu
mov     r0,#0xF
mov     r1,#4
mov     r2,#2
bl      _4092_print_window //Prints the text flavour menu
bl      store_pixels
pop     {pc}

//==============================================================================
//Fixes issue with the option submenu (if it's there) and the file select menu after going back to the text speed window from the text flavour window
_3dce_fix_out_of_text_flavour:
push    {lr}
bl      0x8003F44
mov     r0,#0
ldsh    r0,[r5,r0] //Checks whether or not to print the option menu
cmp     r0,#0
blt     @@end

mov     r0,#4
mov     r1,#7
mov     r2,#0xE
bl      _4092_print_window //Prints the option menu

@@end:
bl      _setup_file_strings
bl      store_pixels
pop     {pc}

//==============================================================================
//Fixes text reprinting when pressing up or down in the text flavour window
_3e86_special_setup:
push    {lr}
push    {r0-r2}
ldr     r0,=#m2_cstm_last_printed
ldrb    r2,[r0,#0]
mov     r1,#0x80
orr     r1,r2
strb    r1,[r0,#0]
pop     {r0-r2}
bl      0x8003F44
pop     {pc}

//==============================================================================
//Highlights all of the file string with the proper palette
_highlight_file:
push    {lr}
mov     r0,#2
ldr     r1,=#0x3000024 //Load in r1 the y co-ordinate
ldr     r1,[r1,#0]
ldr     r1,[r1,#8]
lsl     r1,r1,#1
add     r1,#1
mov     r2,#0
mov     r3,r4
bl      setPaletteOnFile
pop     {pc}

.pool

//==============================================================================
//File highlighting for the up-down arrows in the text flavour window
_3f78_highlight_file:
push    {lr}
bl      _highlight_file
mov     r0,#4 //Clobbered code
ldsh    r2,[r4,r0]
pop     {pc}

//==============================================================================
//File highlighting for when a file is selected
_3a04_highlight_file:
push    {lr}
bl      _highlight_file
mov     r0,#1 //Clobbered code
mov     r1,#0
pop     {pc}

//==============================================================================
//A Press
c75b4_overworld_naming_top_printing:
push    {lr}
ldr     r0,=#m2_player1
mov     r1,r2
str     r3,[sp,#0x24]
bl      player_name_printing_registration
pop     {pc}

//==============================================================================
//B Press
c780e_overworld_naming_top_printing:
push    {lr}
ldr     r1,=#0x3005230
ldr     r1,[r1,#0x0C]
ldr     r0,=#m2_player1
bl      player_name_printing_registration
pop     {pc}

//==============================================================================
//Backspace
c74cc_overworld_naming_top_printing:
push    {lr}
ldr     r1,=#0x3005230
ldr     r1,[r1,#0x0C]
ldr     r0,=#m2_player1
bl      player_name_printing_registration
pop     {pc}

//==============================================================================
//Re-enter the menu
c6cc6_overworld_naming_top_printing:
push    {lr}
mov     r2,r0
mov     r0,r1
mov     r1,r2
bl      player_name_printing_registration
str     r0,[sp,#0x24]
mov     r9,r0
pop     {pc}

//==============================================================================
//Cursor movement of overworld alphabet
c6f24_overworld_alphabet_movement:
push    {lr}
mov     r0,r7
ldr     r1,=#0x3002500
add     r1,#0x18
bl      setupCursorMovement_Overworld_Alphabet
mov     r9,r0
ldr     r2,=#0x3002500
pop     {pc}

.pool

//==============================================================================
//Generic alphabet printing routine. Uses the default code. r0 is the alphabet and r1 is the alphabet string to print if need be
print_alphabet_if_needed:
push    {lr}
ldr     r2,[sp,#0x2C]
cmp     r2,r0 //Is the alphabet loaded different from the one we're going in?
beq     @@end

str     r0,[sp,#0x2C] //If it is, print the new alphabet
ldr     r5,=#0x3005230 //Default printing code
ldr     r4,[r5,#0x10] //Window
mov     r2,r1 //String to load
ldr     r0,=#0x8B17EE4 //String
ldr     r1,=#0x8B17424
bl      m2_strlookup
mov     r1,r0
mov     r0,r4
mov     r2,#0
bl      m2_initwindow
ldr     r0,[r5,#0x10]
bl      0x80C8FFC //Print alphabet

@@end:
pop     {pc}

//==============================================================================
//Loads stuff up for the small alphabet and calls print_alphabet_if_needed
c73c0_small_overworld_alphabet:
push    {lr}
mov     r0,#1 //Alphabet 1, small
mov     r1,#0x62 //String 0x62, small alphabet
bl      print_alphabet_if_needed
pop     {pc}

//==============================================================================
//Loads stuff up for the CAPITAL alphabet and calls print_alphabet_if_needed
c7394_CAPITAL_overworld_alphabet:
push    {lr}
mov     r0,#0 //Alphabet 0, CAPITAL
mov     r1,#0x63 //String 0x63, CAPITAL alphabet
bl      print_alphabet_if_needed
pop     {pc}

//==============================================================================
//Loads the proper letter table based on the loaded alphabet
c7578_load_letters:
push    {lr}
ldr     r2,=#m2_overworld_alphabet_table //Letter table
ldr     r0,[sp,#0x28]
cmp     r0,#1
bne     @@generic_end
mov     r0,#0x90 //If this is the small alphabet, go to its alphabet
add     r2,r2,r0

@@generic_end:
mov     r3,#0x36 //Clobbered code
pop     {pc}

.pool

//==============================================================================
//Prints the cash window and then stores the buffer to vram
b8894_printCashWindowAndStore:
push    {lr}
bl      printCashWindow
bl      store_pixels_overworld
pop     {pc}

//==============================================================================
//UNUSED
bac46_statusWindowNumbersStore:
push    {lr}
bl      statusWindowNumbers
bl      store_pixels_overworld
pop     {pc}

//==============================================================================
//Prints the status text and numbers in the buffer, then loads it in vram
b8320_statusWindowTextStore:
push    {lr}
push    {r0}
bl      statusWindowText
pop     {r0}
mov     r1,#0
bl      statusNumbersPrint
bl      store_pixels_overworld
pop     {pc}

//==============================================================================
//Loads the vram into the buffer, it's called each time there is only the main file_select window active (a good way to set the whole thing up)
load_pixels_overworld:
push    {r0-r1,lr}
ldr     r1,=#0x40000C8 //DMA transfer 2
ldr     r0,=#0x6002000 //Source
str     r0,[r1]
ldr     r0,=#overworld_buffer //Target
str     r0,[r1,#4]
ldr     r0,=#0xA4001000 //Store 0x4000 bytes - When HBlank and in words of 32 bits
str     r0,[r1,#8]
ldr     r0,[r1,#8]
pop     {r0-r1,pc}

//==============================================================================
//Stores the buffer into the vram. This avoids screen tearing.
store_pixels_overworld:
push    {r0-r1,lr}
ldr     r1,=#0x40000C8 //DMA transfer 2
ldr     r0,=#overworld_buffer //Source
str     r0,[r1]
ldr     r0,=#0x6002000 //Target
str     r0,[r1,#4]
ldr     r0,=#0x94001000 //Store 0x4000 bytes - When VBlank and in words of 32 bits
str     r0,[r1,#8]
ldr     r0,[r1,#8]
pop     {r0-r1,pc}

//==============================================================================
//Stores the buffer into the vram. This avoids screen tearing.
store_pixels_overworld_psi_window:
push    {r0-r1,lr}
ldr     r1,=#0x40000C8 //DMA transfer 2
ldr     r0,=#overworld_buffer //Source
str     r0,[r1]
ldr     r0,=#0x6002000 //Target
str     r0,[r1,#4]
ldr     r0,=#0x94000800 //Store 0x1800 bytes - When VBlank and in words of 32 bits
str     r0,[r1,#8]
ldr     r0,[r1,#8]
pop     {r0-r1,pc}

//==============================================================================
//Prints the sick tiles and then the names
sick_name:
push    {lr}
push    {r0-r3}
bl      0x80CAC70 //Purple tiles
mov     r4,r0
pop     {r0-r3}
bl      0x80CABF8 //Name
mov     r0,r4
pop     {pc}

//==============================================================================
//Prints the dead tiles and then the names
dead_name:
push    {lr}
push    {r0-r3}
bl      0x80CACE8 //Red tiles
mov     r4,r0
pop     {r0-r3}
bl      0x80CABF8 //Name
mov     r0,r4
pop     {pc}

//==============================================================================
//Prints the alive tiles and then the names - right after the normal status is restored
d6dac_alive_name:
push    {r7,lr}
mov     r7,r5
bl      alive_name
pop     {r7,pc}

//==============================================================================
//Prints the alive tiles and then the names
alive_name:
push    {r4,lr}
push    {r5}
mov     r5,r2
push    {r0-r3}
mov     r0,r7
mov     r1,#0x4D
mov     r2,r5
mov     r3,#0x12
bl      0x80CAD60 //The 1st alive tile
mov     r0,r7
mov     r1,#0x4D
mov     r2,#1
add     r2,r2,r5
mov     r3,#0x12
bl      0x80CAD60 //The 2nd alive tile
mov     r0,r7
mov     r1,#0x4D
mov     r2,#2
add     r2,r2,r5
mov     r3,#0x12
bl      0x80CAD60 //The 3rd alive tile
mov     r0,r7
mov     r1,#0x4D
mov     r2,#3
add     r2,r2,r5
mov     r3,#0x12
bl      0x80CAD60 //The 4th alive tile
mov     r0,r7
mov     r1,#0x4D
mov     r2,#4
add     r2,r2,r5
mov     r3,#0x12
bl      0x80CAD60 //The 5th alive tile
mov     r4,#5
pop     {r0-r3}
pop     {r5}
bl      0x80CABF8 //Name
mov     r0,r4
pop     {r4,pc}

.pool
