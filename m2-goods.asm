m2_goods:

//==============================================================================
// void entry(char* chr, TILEDATA* tileData)
// In:
//    r3: chr
//    r6: tileData
//==============================================================================

.entry:
print   "m2goods.entry:                $",pc

push    {lr}

//--------------------------------
// Check if the item is equipped
push    {r1-r3}
mov     r0,r8
add     r0,r0,#1
bl      $80BC670
pop     {r1-r3}
cmp     r0,#0
beq     +

// Write the equip symbol
push    {r2}
mov     r0,r10
ldrh    r0,[r0,#0]          // tile offset (0x100)
ldr     r1,=#0x8B1B6AC      // equip tile number (0x1DE)
ldrh    r1,[r1,#0]
add     r0,r0,r1
mov     r1,r9
ldrh    r2,[r1,#0]          // mask (0xE000)
mov     r1,r2
orr     r1,r0
strh    r1,[r6,#0]
mov     r1,r6
add     r1,#0x40
add     r0,#0x20
orr     r0,r2
strh    r0,[r1,#0]

add     r6,r6,#2
lsl     r0,r4,#0x10
ldr     r4,=#0xFFFF0000
add     r0,r0,r4
lsr     r4,r0,#0x10

pop     {r2}

+
//--------------------------------
// Check if the dirty flag is set
mov     r0,r7
bl      m2_vwf.get_dirty_flag
cmp     r0,#1
bne     +

// Just get the string width instead (don't need to render)
mov     r0,r3
mov     r1,#0
bl      m2_vwf.string_width
add     r3,r3,r1
b       .entry_skip

+
//--------------------------------
// Get x and y from tilebase
mov     r0,r6
bl      m2_vwf.get_coords

//--------------------------------
// Print string
push    {r6,r7}
mov     r6,#0
mov     r5,r3
mov     r3,#0

-
ldrb    r2,[r5,#1]
cmp     r2,#0xFF
beq     +

ldrb    r2,[r5,#0]
sub     r2,#0x50
mov     r7,r0
bl      m2_vwf.print_character
add     r6,r0,r6
add     r0,r0,r7
add     r5,r5,#1
b       -

+
mov     r3,r5
mov     r0,r6
pop     {r6,r7}

//--------------------------------
.entry_skip:

// Advance r4 and r6
sub     r1,r0,#1
asr     r0,r0,#3
add     r1,r0,#1

ldr     r2,=#0xFFFF0000

-
cmp     r1,#0
beq     +

lsl     r0,r4,#0x10
add     r0,r0,r2
lsr     r4,r0,#0x10
add     r6,r6,#2
sub     r1,r1,#1
b       -

+
pop     {pc}


//==============================================================================
// void entry2(char* chr, TILEDATA* tileData)
// In:
//    r3: chr
//    r6: tileData
//==============================================================================

.entry2:
print   "m2goods.entry2:               $",pc

push    {r5,lr}

//--------------------------------
// Check if the item is equipped
push    {r1-r3}
mov     r0,r8
add     r0,r0,#1
bl      $80BC670
pop     {r1-r3}
cmp     r0,#0
beq     +

// Write the equip symbol
push    {r2}
ldr     r0,=#0x30051EC
ldrh    r0,[r0,#0]          // tile offset (0x100)
ldr     r1,=#0x8B1B6AC      // equip tile number (0x1DE)
ldrh    r1,[r1,#0]
add     r0,r0,r1
mov     r1,r9
ldrh    r2,[r1,#0]          // mask (0xE000)
mov     r1,r2
orr     r1,r0
strh    r1,[r6,#0]
mov     r1,r6
add     r1,#0x40
add     r0,#0x20
orr     r0,r2
strh    r0,[r1,#0]

add     r6,r6,#2
pop     {r2}

+
//--------------------------------
// Check if the dirty flag is set
mov     r0,r7
bl      m2_vwf.get_dirty_flag
cmp     r0,#1
bne     +

// Just get the string width instead (don't need to render)
mov     r0,r3
mov     r1,#0
bl      m2_vwf.string_width
add     r3,r3,r1
b       .entry2_skip

+
//--------------------------------
// Get x and y from tilebase
mov     r0,r6
bl      m2_vwf.get_coords

//--------------------------------
// Print string
push    {r6,r7}
mov     r6,#0
mov     r5,r3
mov     r3,#0

-
ldrb    r2,[r5,#1]
cmp     r2,#0xFF
beq     +

ldrb    r2,[r5,#0]
sub     r2,#0x50
mov     r7,r0
bl      m2_vwf.print_character
add     r6,r0,r6
add     r0,r0,r7
add     r5,r5,#1
b       -

+
mov     r3,r5
mov     r0,r6
pop     {r6,r7}

//--------------------------------
.entry2_skip:

// Advance r6
sub     r1,r0,#1
asr     r0,r0,#3
add     r1,r0,#1

-
cmp     r1,#0
beq     +
add     r6,r6,#2
sub     r1,r1,#1
b       -

+
pop     {r5,pc}


//==============================================================================
// void highlight(WINDOW* window, char* chr, int itemIndex)
// In:
//    r0: window
//    r1: chr
//    r9: itemIndex (based at 0)
// Out:
//    r2: new tile X
//==============================================================================

.highlight:
print   "m2goods.highlight:            $",pc

// Clobbered code
str     r1,[sp,#0]

//--------------------------------
push    {r0,r4,lr}
mov     r4,r0
mov     r0,r9
add     r0,#1
push    {r1-r3}
bl      $80BC670
pop     {r1-r3}
cmp     r0,#0
beq     +

// Advance the X coord by 1 tile
add     r2,#1

+
mov     r0,r4
//--------------------------------
// Clobbered code
mov     r1,r6
pop     {r0,r4,pc}


//==============================================================================
// void clean()
//==============================================================================

.clean:
print   "m2goods.clean:                $",pc

push    {lr}

mov     r0,r7
mov     r1,#1
bl      m2_vwf.set_dirty_flag

ldr     r0,=#0x3002504 // Clobbered code
ldrh    r1,[r0,#0]

pop     {pc}


//==============================================================================
// void dirty1()
//==============================================================================

.dirty1:
print   "m2goods.dirty1:               $",pc

push    {r1,lr}

// Set the dirty flag
mov     r0,r7
mov     r1,#0
bl      m2_vwf.set_dirty_flag

// Clear the window
mov     r0,r7
bl      m2_vwf.clear_window

// Clobbered code
ldrh    r0,[r4,#0]
sub     r0,#0x1

pop     {r1,pc}


//==============================================================================
// void dirty2()
//==============================================================================

.dirty2:
print   "m2goods.dirty2:               $",pc

push    {r0,lr}

// Set the dirty flag
mov     r0,r7
mov     r1,#0
bl      m2_vwf.set_dirty_flag

// Clear the window
mov     r0,r7
bl      m2_vwf.clear_window

// Clobbered code
pop     {r0}
add     r0,#0x1
mov     r1,r9
pop     {pc}


//==============================================================================
// void dirty3()
//==============================================================================

.dirty3:
print   "m2goods.dirty3:               $",pc

push    {r2-r3,lr}
mov     r2,r0
mov     r3,r1

// Set the dirty flag
ldr     r0,=#0x3005240
ldr     r0,[r0,#0]
mov     r2,r1
mov     r1,#0
bl      m2_vwf.set_dirty_flag

mov     r0,r2
mov     r1,r3

// Clobbered code
ldrb    r0,[r0,#0]
strh    r0,[r1,#0]

pop     {r2-r3,pc}


//==============================================================================
// void dirty4()
//==============================================================================

.dirty4:
print   "m2goods.dirty4:               $",pc

push    {r1,lr}

// Set the dirty flag
mov     r0,r7
mov     r1,#0
bl      m2_vwf.set_dirty_flag

// Clobbered code
mov     r6,#0
mov     r8,r6

pop     {r1,pc}


//==============================================================================
// void dirty5()
//==============================================================================

.dirty5:
print   "m2goods.dirty5:               $",pc

push    {r0,lr}

// Check the dirty flag
bl      m2_vwf.get_dirty_flag
cmp     r0,#0
bne     +

// It's dirty, so erase the window
pop     {r0}
bl      $80CA834
pop     {pc}

+
pop     {r0,pc}


//==============================================================================
// void dirty6()
//==============================================================================

.dirty6:
print   "m2goods.dirty6:               $",pc

push    {r1,lr}

// Set the dirty flag
mov     r0,r7
mov     r1,#0
bl      m2_vwf.set_dirty_flag

// Clobbered code
mov     r0,#0
strh    r0,[r7,#0x32]

pop     {r1,pc}


//==============================================================================
// void redraw()
//==============================================================================

.redraw:
print   "m2goods.redraw:               $",pc

push    {r0-r7,lr}

//--------------------------------
// Set the dirty flag
ldr     r0,=#0x3005240
ldr     r0,[r0,#0]
ldr     r2,=#m2_custom_wram
add     r2,#0x14
mov     r4,#0
strb    r4,[r2,r0]

//--------------------------------
// Clear window
ldr     r0,=#0x3005240
ldr     r0,[r0,#0]
mov     r5,r0
bl      m2_vwf.clear_window

//--------------------------------
// Redraw the goods window
ldr     r0,=#0x3005264
ldrb    r1,[r0,#0]      // get character number
mov     r0,#0x6C
mul     r1,r0
ldr     r0,=#0x3001D54
add     r1,r0,r1        // inventory pointer
mov     r0,r5
mov     r5,r1
mov     r4,r0
mov     r2,#8
strb    r2,[r0,#1]      // need to set this flag for some reason
bl      $80BEB6C

//--------------------------------
// Redraw the highlighted item

// Get the item index from the cursor coords
add     r4,#0x34
ldrh    r1,[r4,#0]      // X
add     r6,r1,#0
cmp     r1,#0xB
bne     +
mov     r1,#1
+
ldrh    r0,[r4,#2]      // Y
mov     r7,r0
lsl     r0,r0,#1
add     r0,r0,r1        // item index

// Check if the item is equipped
push    {r0-r3}
add     r0,#1
bl      $80BC670
cmp     r0,#0
pop     {r0-r3}
beq     +
add     r6,#1
+

// Get the item number
lsl     r2,r0,#1
ldrh    r2,[r5,r2]      // item number

// Get the item's text address
ldr     r0,=#0x8B1AF94
ldr     r1,=#0x8B1A694
bl      $80BE260        // r0 = address

// Draw the text
add     sp,#-4
mov     r1,#1
str     r1,[sp,#0]
mov     r1,r0
sub     r4,#0x34
mov     r0,r4
add     r2,r6,#1
mov     r3,r7
bl      $80C9634
add     sp,#4

//--------------------------------
// Clobbered code
pop     {r0-r7}
bl      $80C8BE4

pop     {pc}