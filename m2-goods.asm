bf858_goods:
push    {lr}

// Only render on button press
ldr     r0,=0x3002504  // for some reason 3002500 is already cleared when opening the window,
                       // but 3002504 seems to be a copy of what it used to be?
ldrb    r0,[r0]
cmp     r0,0
beq     @@bf858_goods_end

lsl     r2,r5,15
lsr     r0,r2,31
mov     r2,11
mul     r0,r2
add     r0,r0,1   // r2 = X tile, 1 or 12 depending on the column
lsr     r1,r5,17  // r3 = Y tile
lsl     r1,r1,1
mov     r2,11
mov     r3,r7
push    {r0-r1}
bl      print_blankstr_window
pop     {r0-r1}
mov     r2,r0
lsr     r3,r1,1

// Check for equip
ldrh    r0,[r7,0x3C]
add     r0,r8
add     r0,1
lsl     r0,r0,0x18
lsr     r0,r0,0x18
push    {r2,r3}
bl      0x80BC670
pop     {r2,r3}
lsl     r0,r0,0x18
lsr     r0,r0,0x18
cmp     r0,1
bne     @@noequip
add     r2,r2,1
@@noequip:
add     sp,-4     // Need to push a 0 for the call to m2_printstr
mov     r0,0
str     r0,[sp]
mov     r0,r7     // Window pointer
mov     r1,r4     // String pointer
bl      0x80C9634 // m2_printstr
add     sp,4
@@bf858_goods_end:
pop     {pc}
.pool
