m2_vwf_entries:

//==============================================================================
.c980c_custom_codes:
push    {r1-r2,lr}
mov     r1,r7
mov     r2,r5
bl      m2_customcodes.parse
ldr     r1,[r6,#0]

// If 0, return [r6]+2; otherwise, return [r6]+r0
beq     +
add     r0,r0,r1
pop     {r1-r2,pc}
+
add     r0,r1,#2
pop     {r1-r2,pc}

//==============================================================================
.c980c_weld_entry:
push    {r0-r1,lr}
mov     r0,r5
mov     r1,r7
bl      m2_vwf.weld_entry
pop     {r0-r1,pc}

//==============================================================================
.c8ffc_custom_codes:
push    {r2,r5,lr}
ldrb    r0,[r2,#0]
mov     r5,r0
mov     r1,r2
mov     r2,r4
bl      m2_customcodes.parse
cmp     r0,#0
beq     +
mov     r2,r12
add     r0,r0,r2
strh    r0,[r4,#0x14]
pop     {r2,r5}
add     sp,#4
ldr     r1,=#0x80C904D
bx      r1
+
mov     r0,r5
cmp     r0,#1
pop     {r2,r5,pc}

//==============================================================================
.c8ffc_weld_entry:
push    {r0-r1,lr}
mov     r0,r4
mov     r1,r2
bl      m2_vwf.weld_entry
pop     {r0-r1,pc}

//==============================================================================
.c980c_resetx:
push    {r1,lr}
mov     r1,#0
strh    r1,[r0,#2]
pop     {r1}
bl      $80C87D0
pop     {pc}

//==============================================================================
.c980c_resetx_newline:
push    {lr}
strh    r0,[r5,#0x2C]
strh    r4,[r5,#0x2A]
strh    r4,[r5,#2]
pop     {pc}


//==============================================================================
.c87d0_clear_entry:
push    {lr}

// Reset X
mov     r1,#0
strh    r1,[r0,#2]

// Clear window
mov     r1,#4
bl      m2_vwf.clear_window

// Clobbered code
ldr     r4,=#0x3005270
mov     r1,#0x24
pop     {pc}

//==============================================================================
.c9634_resetx:
push    {lr}
mov     r4,#0
strh    r4,[r6,#2]

// Clobbered code
strh    r5,[r1,#0]
pop     {pc}

//==============================================================================
// Only render the (None) strings in the equip window if there's nothing equipped
.c4b2c_skip_nones:
push    {r7,lr}
add     sp,#-4
mov     r7,#0

// Get the (none) pointer
mov     r0,r4
mov     r1,r10
mov     r2,#0x2A
bl      $80BE260
mov     r5,r0

// Check each equip slot
ldr     r6,=#0x3001D40
ldr     r3,=#0x3005264
ldrh    r0,[r3,#0] // active party character
mov     r1,#0x6C
mul     r0,r1
add     r6,r0,r6
add     r6,#0x75
ldrb    r0,[r6,#0]
cmp     r0,#0
bne     +

// Weapon
mov     r0,r8
mov     r1,r5
mov     r2,#0x6
mov     r3,#0
str     r7,[sp,#0]
bl      $80C9634

+
ldrb    r0,[r6,#1]
cmp     r0,#0
bne     +

// Body
mov     r0,r8
mov     r1,r5
mov     r2,#0x6
mov     r3,#1
str     r7,[sp,#0]
bl      $80C9634

+
ldrb    r0,[r6,#2]
cmp     r0,#0
bne     +

// Arms
mov     r0,r8
mov     r1,r5
mov     r2,#0x6
mov     r3,#2
str     r7,[sp,#0]
bl      $80C9634

+
ldrb    r0,[r6,#3]
cmp     r0,#0
bne     +

// Other
mov     r0,r8
mov     r1,r5
mov     r2,#0x6
mov     r3,#3
str     r7,[sp,#0]
bl      $80C9634

+
mov     r0,#0
mov     r10,r0
add     sp,#4
pop     {r7,pc}

//==============================================================================
// Clears the equipment portion of the equip window
// r0 = window pointer
.clear_equipment:
push    {r0-r2,lr}
add     sp,#-16
mov     r1,r0
mov     r0,sp

ldrh    r2,[r1,#0x22] // window X
add     r2,#6         // horizontal offset
strh    r2,[r0,#0]
ldrh    r2,[r1,#0x24] // window Y
strh    r2,[r0,#2]
ldrh    r2,[r1,#0x26] // window width
sub     r2,#6
strh    r2,[r0,#0xC]
ldrh    r2,[r1,#0x28] // window height
strh    r2,[r0,#0xE]

ldr     r2,=#0x44444444
str     r2,[r0,#4]
ldr     r2,=#0x30051EC
ldrh    r2,[r2,#0]
strh    r2,[r0,#8]

bl      m2_vwf.clear_rect

add     sp,#16
pop     {r0-r2,pc}


//==============================================================================
// Clear equipment and offense/defense when moving left/right on equip screen
// r6 = window pointer
.c4b2c_clear_left:
mov     r0,r6
bl      .clear_equipment

// Clear offense/defense
push    {r0-r2}
mov     r0,#8
mov     r2,r0
mov     r1,#0xB
bl      m2_vwf.print_blankstr
add     r1,#2
bl      m2_vwf.print_blankstr
pop     {r0-r2}

// Clobbered code
strh    r1,[r3,#0]
ldr     r0,=#0x80C4F3B
bx      r0

.c4b2c_clear_right:
mov     r0,r6
bl      .clear_equipment

// Clear offense/defense
push    {r0-r2}
mov     r0,#8
mov     r2,r0
mov     r1,#0xB
bl      m2_vwf.print_blankstr
add     r1,#2
bl      m2_vwf.print_blankstr
pop     {r0-r2}

// Clobbered code
strh    r1,[r3,#0]
ldr     r0,=#0x80C4EFF
bx      r0

//==============================================================================
// Clear PSI target window when moving left/right on PSI screen
.c438c_moveright:
push    {r0-r1,lr}
ldr     r1,=#0x3005230
ldr     r0,[r1,#0x24] // PSI target window pointer
mov     r1,#4
bl      m2_vwf.clear_window
pop     {r0-r1}

// Clobbered code
add     r0,#1
strh    r0,[r5,#0x34]
pop     {pc}

.c438c_moveleft:
push    {r0-r1,lr}
ldr     r1,=#0x3005230
ldr     r0,[r1,#0x24] // PSI target window pointer
mov     r1,#4
bl      m2_vwf.clear_window
pop     {r0-r1}

// Clobbered code
sub     r0,#1
strh    r0,[r5,#0x34]
pop     {pc}

.c438c_moveup:
push    {r0-r1,lr}
ldr     r1,=#0x3005230
ldr     r0,[r1,#0x24] // PSI target window pointer
mov     r1,#4
bl      m2_vwf.clear_window
pop     {r0-r1}

// Clobbered code
sub     r0,#1
strh    r0,[r5,#0x36]
pop     {pc}

.c438c_movedown:
push    {r0-r1,lr}
ldr     r1,=#0x3005230
ldr     r0,[r1,#0x24] // PSI target window pointer
mov     r1,#4
bl      m2_vwf.clear_window
pop     {r0-r1}

// Clobbered code
add     r0,#1
strh    r0,[r5,#0x36]
pop     {pc}

//==============================================================================
// Prints a string in the status window
.c0a5c_printstr:
push    {r0-r2,lr}
mov     r0,r1
mov     r1,r2
mov     r2,r3
bl      m2_vwf.print_string
pop     {r0-r2,pc}

//==============================================================================
// Prints an empty space instead of the "Press A for PSI info" string
.c0a5c_psi_info_blank:
push    {lr}
mov     r0,#5
mov     r1,#0xF
mov     r2,#0x14
bl      m2_vwf.print_blankstr
pop     {pc}

//==============================================================================
// Redraws the status window (when exiting the PSI submenu, etc.)
.bac18_redraw_status:
push    {r4,lr}

ldr     r4,=#0x3005230
ldr     r4,[r4,#0x18]

// Get the address of the status text
ldr     r0,=#0x8B17EE4
ldr     r1,=#0x8B17424
mov     r2,#0x11
bl      $80BE260

// Prepare the window for parsing
mov     r1,r0
mov     r0,r4
mov     r2,#0
bl      $80BE458

// Render text
mov     r0,r4
bl      $80C8FFC

// Render numbers
mov     r0,r4
mov     r1,#0
bl      $80C0A5C

pop     {r4,pc}

//==============================================================================
// Clears the PSI window when switching classes
// r5 = 0x3005230
.bac18_clear_psi:
push    {r0,lr}
ldr     r0,[r5,#0x20] // PSI class window pointer
ldrb    r0,[r0,#0]
mov     r1,#0x10
and     r0,r1
cmp     r0,#0
beq     +

// If flag 0x10 is set, clear the PSI window
ldr     r0,[r5,#0x1C] // PSI window
mov     r1,#4
bl      m2_vwf.clear_window

+
// Clobbered code
pop     {r0}
lsl     r0,r0,#0x10
asr     r4,r0,#0x10
pop     {pc}

//==============================================================================
// Only clear+redraw the PSI help if a button has been pressed
.bac18_check_button:
push    {lr}
ldr     r0,=#0x3002500
ldrh    r0,[r0,#0]
cmp     r0,#0
beq     +

// Clear window
ldr     r0,[r5,#0x28]
mov     r1,r2
mov     r2,#0
bl      $80BE458

// Render window
ldr     r0,[r5,#0x28]
bl      $80C8BE4

+
pop     {pc}

//==============================================================================
// Clear offense/defense changes when switching in equip select window
.c5500_clear_up:
push    {r1-r2,lr}
mov     r0,#0xD
mov     r1,#0xB
mov     r2,#0x3
bl      m2_vwf.print_blankstr
add     r1,#2
bl      m2_vwf.print_blankstr

// Clobbered code
sub     r0,r3,#1
strh    r0,[r7,#0x36]
pop     {r1-r2,pc}

.c5500_clear_down:
push    {r0-r2,lr}
mov     r0,#0xD
mov     r1,#0xB
mov     r2,#0x3
bl      m2_vwf.print_blankstr
add     r1,#2
bl      m2_vwf.print_blankstr

// Clobbered code
pop     {r0-r2}
add     r0,#1
strh    r0,[r7,#0x36]
pop     {pc}

//==============================================================================
// Clear offense/defense when re-equipping (or un-equipping) something
.baef8_reequip_erase:
push    {r1,lr}
mov     r0,#8
mov     r1,#0xB
mov     r2,#4
bl      m2_vwf.print_blankstr
add     r1,#2
bl      m2_vwf.print_blankstr

// Clobbered code
pop     {r1}
mov     r0,#2
strh    r0,[r1,#0]
pop     {pc}
