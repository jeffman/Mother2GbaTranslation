// m2_custom_wram range:
// 00-03: saved tilebase
// 04-0F: pixel X values
// 10-13: temp LR copy
// 14:    goods dirty flag

m2_vwf:

//==============================================================================
// int get_tile_number(int x, int y)
//    In:
//        r0: x
//        r1: y
//    Out:
//        r0: tile number
//==============================================================================

.get_tile_number:
print   "m2vwf.get_tile_number:        $",pc

push    {r1-r5,lr}
ldr     r4,=#m2_coord_table
sub     r0,r0,#1
sub     r1,r1,#1
lsl     r2,r1,#0x1F
lsr     r2,r2,#0x1F
lsr     r1,r1,#1
lsl     r5,r1,#4
sub     r5,r5,r1
sub     r5,r5,r1
lsl     r5,r5,#2
lsl     r0,r0,#1
add     r4,r4,r0
add     r4,r4,r5
ldrh    r0,[r4,#0]
lsl     r2,r2,#5
add     r0,r0,r2
pop     {r1-r5,pc}


//==============================================================================
// int get_window_number(WINDOW* window)
//    In:
//        r0: window
//    Out:
//        r0: window number
//==============================================================================

.get_window_number:

push    {r1-r3,lr}
ldr     r1,=#0x3005230
mov     r2,#0

-
ldr     r3,[r1,#0]
cmp     r3,r0
beq     +
add     r1,r1,#4
add     r2,r2,#1
cmp     r2,#0xB
beq     +
b       -
+

mov     r0,r2
pop     {r1-r3,pc}


//==============================================================================
// void weld_entry(WINDOW* window, byte* chr, ushort* mapEntry)
//    In:
//        r0: address of window data
//            [r5 + 0x04]: start address of text being displayed
//            [r5 + 0x08]: same as above?
//            [r5 + 0x20]: window area (just width * height)
//            [r5 + 0x22]: window text area X
//            [r5 + 0x24]: window text area Y
//            [r5 + 0x26]: window width
//            [r5 + 0x28]: window height
//            [r5 + 0x2A]: relative text X
//            [r5 + 0x2C]: relative text Y
//            [r5 + 0x34]: cursor X
//            [r5 + 0x36]: cursor Y
//        r1: address of char to print
//        r2: address of map entry
//==============================================================================

// Notes:

// [0x30009F4] == current major window mode
//        00: none
//        01: main A menu
//        02: ?
//        03: talk
//        04: goods
//        05: psi
//        06: equip
//        07: check
//        08: status

// [0x30051EC] == current tile offset
// [0x3005228] == current text palette, << 0xC
// [0x3005230] == addresses of all 11 windows
// [0x3005270] == address of tilemap start in WRAM, can use this to figure out X and Y

// 80C9860
// 80CA440

//--------------------------------
.weld_entry:
print   "m2vwf.weld_entry:             $",pc
push    {r0-r7,lr}
add     sp,#-28

//--------------------------------
// Check which window we're on
mov     r5,r0
bl      .get_window_number
mov     r6,r0
cmp     r6,#0xB
bne     +
dw      $E801                // Break by means of invalid opcode
+

//--------------------------------
// Get the char
ldrb    r0,[r1,#0]
sub     r0,#0x50
bpl     +
mov     r0,#0x1F            // Replace char with ? if it's invalid
b       .char_custom
+
cmp     r0,#0x60
bcc     .char_custom
mov     r0,#0x1F

.char_custom:
str     r0,[sp,#0x0]
// [sp+0] = char

//--------------------------------
// Get the current X
ldr     r7,=#m2_custom_wram
add     r7,r7,#4
mov     r0,#0x22
ldrb    r1,[r5,r0]
mov     r0,#0x2A
ldrb    r2,[r5,r0]
add     r1,r1,r2
str     r1,[sp,#4]
lsl     r0,r1,#3
ldrb    r1,[r7,r6]
str     r1,[sp,#24]
add     r0,r0,r1             // Current pixel X
str     r0,[sp,#20]

// Get the current Y
mov     r2,#0x24
ldrb    r1,[r5,r2]
mov     r2,#0x2C
ldrb    r3,[r5,r2]
add     r1,r1,r3
str     r1,[sp,#8]
lsl     r1,r1,#3

//--------------------------------
// Print
ldr     r2,[sp,#0x0]
mov     r3,#0
bl      .print_character
str     r0,[sp,#12]

//--------------------------------
// Figure out new window coords
ldr     r0,[sp,#20]
ldr     r1,[sp,#12]
add     r0,r0,r1

// Store new window coords
lsr     r1,r0,#3
mov     r2,#0x22
ldrb    r2,[r5,r2]
sub     r1,r1,r2
mov     r2,#0x2A
strb    r1,[r5,r2]

// Store new pixel X
lsl     r0,r0,#29
lsr     r0,r0,#29
strb    r0,[r7,r6]

//--------------------------------
add     sp,#28
pop     {r0-r7,pc}


//=============================================================================
// void print_string(int x, int y, char* str)
// In:
//    r0: x (pixel)
//    r1: y (pixel)
//    r2: numerical string to print (ends with 0xFF)
//=============================================================================

.print_string:
print   "m2vwf.print_string:           $",pc
push    {r0-r7,lr}

//--------------------------------
mov     r3,#0
mov     r4,r2
mov     r5,r0

-
ldrb    r2,[r4,#1]
cmp     r2,#0xFF
bne     +
ldrb    r6,[r4,#0]
cmp     r6,#0
beq     .print_numerical_endcode

.print_numerical_invalid:
dw      $E801                // Break by means of invalid opcode

// Print the character
+
ldrb    r2,[r4,#0]
mov     r7,r0
sub     r2,#0x50
bl      .print_character
add     r0,r0,r7
add     r4,r4,#1
b       -

.print_numerical_endcode:
pop     {r0-r7,pc}


//==============================================================================
// void print_string_relative(int x, int y, char* str, WINDOW* window)
// In:
//    r2: relative x (tile)
//    r3: relative y (tile)
//    r1: str
//    r0: window
//==============================================================================

.print_string_relative:
push    {r0-r6,lr}

//--------------------------------
// Check the dirty flag
mov     r6,r0
bl      .get_dirty_flag
cmp     r0,#0
bne     +
mov     r0,r6

//--------------------------------
mov     r5,#0x22
ldrb    r4,[r0,r5]           // Window X
mov     r5,#0x24
ldrb    r5,[r0,r5]           // Window Y

lsl     r3,r3,#1
add     r2,r2,r4
add     r3,r3,r5
lsl     r2,r2,#3
lsl     r3,r3,#3

//--------------------------------
mov     r0,r2
mov     r2,r1
mov     r1,r3
bl      .print_string

+
//--------------------------------
pop     {r0-r6,pc}


//=============================================================================
// void print_character(int x, int y, int chr, int font)
// In:
//    r0: x (pixel)
//    r1: y (pixel)
//    r2: character
//    r3: font
//        0: main
//        1: saturn
//        2: tiny
// Out:
//    r0: virtual width
//=============================================================================

.print_character:
print   "m2vwf.print_character:        $",pc

push    {r1-r7,lr}
mov     r4,r8
mov     r5,r9
mov     r6,r10
mov     r7,r11
push    {r4-r7}
mov     r4,r12
push    {r4}
add     sp,#-24

mov     r10,r0
mov     r11,r1
mov     r12,r2
mov     r5,r3

//----------------------------------------
ldr     r3,=#0x30051EC
ldrh    r4,[r3,#0]           // Tile offset
add     r3,#0x3C
ldrh    r6,[r3,#0]           // Palette mask
add     r3,#0x48
ldr     r7,[r3,#0]           // Tilemap address
lsr     r0,r0,#3
lsr     r1,r1,#3
lsl     r1,r1,#5
add     r0,r0,r1
lsl     r0,r0,#1
add     r7,r7,r0             // Local tilemap address
mov     r8,r4

//----------------------------------------
ldr     r0,=#m2_widths_table
lsl     r1,r5,#2             // Font number * 4
ldr     r0,[r0,r1]
mov     r3,r12               // Character
lsl     r2,r3,#1
ldrb    r1,[r0,r2]           // Virtual width
mov     r9,r1
add     r2,r2,#1
ldrb    r0,[r0,r2]           // Render width
cmp     r0,#0
beq     +                    // Don't bother rendering a zero-width character
ldr     r2,=#m2_height_table
ldrb    r2,[r2,r5]
str     r2,[sp,#16]          // No more registers, gotta store this on the stack
mov     r3,sp
strb    r0,[r3,#9]
strb    r2,[r3,#12]
mov     r1,r10
lsl     r1,r1,#29
lsr     r1,r1,#29
strb    r1,[r3,#8]
mov     r1,#4
strb    r1,[r3,#10]
mov     r1,#0xF
strb    r1,[r3,#11]

//----------------------------------------
mov     r0,r10
mov     r1,r11
lsr     r0,r0,#3
lsr     r1,r1,#3
bl      .get_tile_number
add     r4,r0,r4
lsl     r0,r4,#5
mov     r1,#6
lsl     r1,r1,#0x18
add     r0,r0,r1             // VRAM address
str     r0,[sp,#0]

//----------------------------------------
ldr     r0,=#m2_font_table
lsl     r1,r5,#2
ldr     r0,[r0,r1]
mov     r1,r12
lsl     r1,r1,#5
add     r0,r0,r1             // Glyph address
str     r0,[sp,#4]

//----------------------------------------
// Render left portion
mov     r0,sp
bl      .print_left

//----------------------------------------
// Update the map
orr     r4,r6
mov     r1,r7
-
strh    r4,[r1,#0]
add     r4,#0x20
add     r1,#0x40
sub     r2,r2,#1
bne     -
add     r7,r7,#2

//----------------------------------------
// Now we've rendered the left portion;
// we need to determine whether or not to render the right portion
ldrb    r1,[r0,#8]           // VRAM x offset
str     r1,[sp,#20]          // No more registers, gotta store this on the stack
ldrb    r2,[r0,#9]           // Render width
add     r2,r1,r2
cmp     r2,#8
bls     +

// We still have more to render; figure out how much we already rendered
mov     r3,#8
sub     r3,r3,r1
strb    r3,[r0,#8]

// Allocate a new tile
mov     r0,r10
mov     r1,r11
lsr     r0,r0,#3
add     r0,r0,#1
lsr     r1,r1,#3
bl      .get_tile_number
add     r0,r8
mov     r4,r0
lsl     r0,r0,#5
mov     r1,#6
lsl     r1,r1,#0x18
add     r0,r0,r1
str     r0,[sp,#0]
mov     r0,sp
bl      .print_right

//----------------------------------------
// Update the map
orr     r4,r6
mov     r1,r7
ldr     r2,[sp,#16]
-
strh    r4,[r1,#0]
add     r4,#0x20
add     r1,#0x40
sub     r2,r2,#1
bne     -
add     r7,r7,#2

//----------------------------------------
// Now we've rendered the left and right portions;
// we need to determin whether or not to do a final
// right portion for super wide characters
ldr     r1,[sp,#20]          // Original pixel X offset
ldrb    r2,[r0,#9]           // Render width
add     r2,r1,r2             // Right side of glyph
cmp     r2,#16
bls     +

// We have one more chunk to render; figure out how much we already rendered
mov     r3,#16
sub     r3,r3,r1
strb    r3,[r0,#8]

// Allocate a new tile
mov     r0,r10
mov     r1,r11
lsr     r0,r0,#3
add     r0,r0,#2
lsr     r1,r1,#3
bl      .get_tile_number
add     r0,r8
mov     r4,r0
lsl     r0,r0,#5
mov     r1,#6
lsl     r1,r1,#0x18
add     r0,r0,r1
str     r0,[sp,#0]
mov     r0,sp
bl      .print_right

//----------------------------------------
// Update the map
orr     r4,r6
mov     r1,r7
ldr     r2,[sp,#16]
-
strh    r4,[r1,#0]
add     r4,#0x20
add     r1,#0x40
sub     r2,r2,#1
bne     -
add     r7,r7,#2

//----------------------------------------
+
mov     r0,r9
add     sp,#24
pop     {r4}
mov     r12,r4
pop     {r4-r7}
mov     r8,r4
mov     r9,r5
mov     r10,r6
mov     r11,r7
pop     {r1-r7,pc}


//=============================================================================
// void print_left(void* structPointer)
//=============================================================================

// In:
// r0: struct pointer
// [r0+0]: VRAM address
// [r0+4]: glyph address
// [r0+8]: VRAM x offset (byte)
// [r0+9]: render width (byte)
// [r0+10]: background index (byte)
// [r0+11]: foreground index (byte)
// [r0+12]: height in tiles (byte)
// [r0+13]: <unused> (3 bytes)

.print_left:
print   "m2vwf.print_left:             $",pc

push    {r0-r7,lr}
mov     r7,r0

//----------------------------------------
ldr     r6,[r7,#0]           // VRAM address
ldr     r3,[r7,#4]           // Glyph address
ldrb    r4,[r7,#12]          // Height in tiles

.print_left_loop:
mov     r5,#8
-
ldr     r0,[r6,#0]           // 4BPP VRAM row
ldrb    r1,[r7,#11]          // Foreground index
bl      .reduce_bit_depth    // Returns r0 = 1BPP VRAM row
ldrb    r1,[r7,#9]           // Glyph render width
mov     r2,#32
sub     r2,r2,r1
ldrb    r1,[r3,#0]           // Glyph row
lsl     r1,r2                // Cut off the pixels we don't want to render
lsr     r1,r2
ldrb    r2,[r7,#8]           // X offset
lsl     r1,r2
lsl     r1,r1,#0x18
lsr     r1,r1,#0x18
orr     r0,r1
ldrb    r1,[r7,#10]
ldrb    r2,[r7,#11]
bl      .expand_bit_depth
str     r0,[r6,#0]
add     r6,r6,#4
add     r3,r3,#1
sub     r5,r5,#1
bne     -
mov     r0,#0x1F
lsl     r0,r0,#5
add     r6,r0,r6
add     r3,#8
sub     r4,r4,#1
bne     .print_left_loop

//----------------------------------------
pop     {r0-r7,pc}


//=============================================================================
// void print_right(void* structPointer)
//=============================================================================

// In:
// r0: struct pointer
// [r0+0]: VRAM address
// [r0+4]: glyph address
// [r0+8]: glyph x offset (byte)
// [r0+9]: render width (byte)
// [r0+10]: background index (byte)
// [r0+11]: foreground index (byte)
// [r0+12]: height in tiles (byte)
// [r0+13]: <unused> (3 bytes)

.print_right:
print   "m2vwf.print_right:            $",pc

push    {r0-r7,lr}
mov     r7,r0

//----------------------------------------
ldr     r6,[r7,#0]           // VRAM address
ldr     r3,[r7,#4]           // Glyph address
ldrb    r4,[r7,#12]          // Height in tiles

.print_right_loop:
mov     r5,#8
-
ldr     r0,[r6,#0]           // 4BPP VRAM row
ldrb    r1,[r7,#11]          // Foreground index
bl      .reduce_bit_depth    // Returns r0 = 1BPP VRAM row
ldrb    r1,[r7,#9]           // Glyph render width
mov     r2,#32
sub     r2,r2,r1
ldrb    r1,[r3,#0]           // Glyph row
lsl     r1,r2                // Cut off the pixels we don't want to render
lsr     r1,r2
ldrb    r2,[r7,#8]           // X offset
lsr     r1,r2
lsl     r1,r1,#0x18
lsr     r1,r1,#0x18
orr     r0,r1
ldrb    r1,[r7,#10]
ldrb    r2,[r7,#11]
bl      .expand_bit_depth
str     r0,[r6,#0]
add     r6,r6,#4
add     r3,r3,#1
sub     r5,r5,#1
bne     -
mov     r0,#0x1F
lsl     r0,r0,#5
add     r6,r0,r6
add     r3,#8
sub     r4,r4,#1
bne     .print_right_loop

//----------------------------------------
pop     {r0-r7,pc}


//==============================================================================
// void erase_tile(int x, int y)
// In:
//    r0: x
//    r1: y
//==============================================================================

.erase_tile:
push    {r0-r2,lr}

//--------------------------------
bl      .get_tile_number
ldr     r1,=#0x30051EC
ldrh    r1,[r1,#0]           // Tile offset
add     r0,r0,r1
mov     r2,#6
lsl     r2,r2,#0x18
lsl     r0,r0,#5
add     r0,r0,r2

ldr     r1,=#0x44444444      // Empty row of pixels
str     r1,[r0,#0]
str     r1,[r0,#4]
str     r1,[r0,#8]
str     r1,[r0,#12]
str     r1,[r0,#16]
str     r1,[r0,#20]
str     r1,[r0,#24]
str     r1,[r0,#28]

//--------------------------------
pop     {r0-r2,pc}


//==============================================================================
// void erase_tile_short(int x, int y, WINDOW* window)
// In:
//    r4: (x << 16), relative
//    r8: y, relative
//    r6: window
//==============================================================================

.erase_tile_short:

push    {r0-r2,r4,lr}

//--------------------------------
// Get the window X and Y
mov     r0,#0x22
ldrb    r1,[r6,r0]           // Window X
mov     r0,#0x24
ldrb    r2,[r6,r0]           // Window Y

lsr     r4,r4,#16
add     r0,r1,r4             // Absolute X
mov     r1,r8
add     r1,r1,r2             // Absolute Y

bl      .erase_tile

//--------------------------------
// Clobbered code
pop     {r0-r2,r4}
strh    r0,[r5,#0]
mov     r0,r12

//--------------------------------
pop     {pc}


//==============================================================================
// void erase_tile_short2(int x, int y, WINDOW* window)
// In:
//    r2: (x << 16), relative
//    r7: y, relative
//    r4: window
//==============================================================================

.erase_tile_short2:

push    {r0-r3,lr}

//--------------------------------
// Get the window X and Y
mov     r0,#0x22
ldrb    r1,[r4,r0]           // Window X
mov     r0,#0x24
ldrb    r3,[r4,r0]           // Window Y

lsr     r2,r2,#16
add     r0,r1,r2             // Absolute X
add     r1,r3,r7             // Absolute Y

bl      .erase_tile

//--------------------------------
// Clobbered code
pop     {r0-r3}
strh    r0,[r5,#0]
lsl     r1,r6,#0x10

//--------------------------------
pop     {pc}


//==============================================================================
// void erase_tile_main(TILEDATA* tileData)
// In:
//    r12: tile data address
//==============================================================================

.erase_tile_main:
print   "m2vwf.erase_tile_main:        $",pc

push    {r2,lr}

//--------------------------------
// Figure out X and Y based on the tile data address
ldr     r1,=#0x3005270
ldr     r0,[r1,#0]           // Tilemap base
mov     r1,r12
sub     r0,r1,r0
lsr     r1,r0,#1
lsl     r0,r1,#27
lsr     r0,r0,#27            // X
lsr     r1,r1,#5             // Y
bl      .erase_tile

// This only gets called once per character, ie, once for every two tiles vertically
// So we need to erase the next tile down as well
add     r1,r1,#1
bl      .erase_tile

//--------------------------------
// Clobbered code
ldrh    r1,[r7,#0]
add     r0,r6,r1
pop     {r2,pc}


//==============================================================================
// void copy_tile(TILEDATA* source, TILEDATA* dest)
// In:
//    r7: source
//    r5: dest
//    r10: 3005270
//==============================================================================

.copy_tile:
push    {r0-r6,lr}
mov     r0,r8
mov     r1,r9
mov     r2,r10
push    {r0-r2}

//--------------------------------
mov     r0,r10
mov     r3,#0x1F
ldr     r2,[r0,#0]           // Tilemap base

sub     r1,r7,r2
lsr     r0,r1,#1
mov     r4,r0
and     r0,r3                // Source X
lsr     r1,r4,#5             // Source Y
bl      .get_tile_number
ldr     r4,=#0x30051EC
mov     r10,r4
ldr     r4,[r4,#0]
mov     r8,r4
add     r6,r0,r4             // Source tile number
lsl     r6,r6,#5

sub     r1,r5,r2
lsr     r0,r1,#1
mov     r2,r0
and     r0,r3                // Dest X
lsr     r1,r2,#5             // Dest Y
bl      .get_tile_number
add     r2,r0,r4             // Dest tile number
mov     r9,r2
lsl     r2,r2,#5

// Add the VRAM base
mov     r1,#6
lsl     r3,r1,#0x18
add     r1,r6,r3
add     r2,r2,r3

// Copy the tile
ldr     r0,[r1,#0]
str     r0,[r2,#0]
ldr     r0,[r1,#4]
str     r0,[r2,#4]
ldr     r0,[r1,#8]
str     r0,[r2,#8]
ldr     r0,[r1,#12]
str     r0,[r2,#12]
ldr     r0,[r1,#16]
str     r0,[r2,#16]
ldr     r0,[r1,#20]
str     r0,[r2,#20]
ldr     r0,[r1,#24]
str     r0,[r2,#24]
ldr     r0,[r1,#28]
str     r0,[r2,#28]

// Erase the old tile
ldr     r0,=#0x44444444      // Empty row of pixels
str     r0,[r1,#0]
str     r0,[r1,#4]
str     r0,[r1,#8]
str     r0,[r1,#12]
str     r0,[r1,#16]
str     r0,[r1,#20]
str     r0,[r1,#24]
str     r0,[r1,#28]

//--------------------------------
// Clobbered code: original game copies
// tile data always; we only want it under certain conditions
ldr     r0,=#0x1FF
mov     r1,r8                // Tile offset
add     r0,r0,r1             // Blank tile number
ldrh    r2,[r7,#0]
lsl     r1,r2,#20
lsr     r1,r1,#20            // Source tile number
ldrh    r3,[r5,#0]
lsl     r2,r3,#20
lsr     r2,r2,#20            // Dest tile number

// If we're copying from non-blank to blank, we need to
// update the dest tile data
cmp     r1,r0
beq     +
cmp     r2,r0
bne     +

// Update tile data
mov     r1,r9                // Dest tile number
mov     r3,r10
add     r3,#0x3C
ldrh    r2,[r3,#0]           // Palette mask
orr     r1,r2
strh    r1,[r5,#0]
+

//--------------------------------
pop     {r0-r2}
mov     r8,r0
mov     r9,r1
mov     r10,r2
pop     {r0-r6,pc}


//==============================================================================
// byte reduce_bit_depth(int pixels)
// In:
//    r0: row of 4BPP pixels
//    r1: foreground index
// Out:
//    r0: row of 1BPP pixels
//==============================================================================

.reduce_bit_depth:
push    {r1-r6,lr}
mov     r3,r0
mov     r0,#0
mov     r4,#0xF
mov     r5,#1
mov     r6,#28

//--------------------------------
-
mov     r2,r3
lsr     r2,r6
and     r2,r4
cmp     r1,r2
bne     +
orr     r0,r5
+
sub     r6,r6,#4
bmi     +
lsl     r0,r0,#1
b       -

//--------------------------------
+
pop     {r1-r6,pc}


//==============================================================================
// int expand_bit_depth(byte pixels)
// In:
//    r0: row of 1BPP pixels
//    r1: background index
//    r2: foreground index
// Out:
//    r0: row of 4BPP pixels
//==============================================================================

.expand_bit_depth:
push    {r1-r6,lr}
mov     r3,r0
mov     r0,#0
mov     r5,#1
mov     r6,#7

//--------------------------------
-
mov     r4,r3
lsr     r4,r6
and     r4,r5
bne     +
orr     r0,r1
b       .next
+
orr     r0,r2
.next:
sub     r6,r6,#1
bmi     +
lsl     r0,r0,#4
b       -

//--------------------------------
+
pop     {r1-r6,pc}


//==============================================================================
// void save_tilebase(int tilebase)
// In:
//    r0: tilebase
//==============================================================================

.save_tilebase:
print   "m2vwf.save_tilebase:          $", pc
push    {r5,lr}
ldr     r5,[sp,#8]
mov     lr,r5
ldr     r5,[sp,#4]
str     r5,[sp,#8]
pop     {r5}
add     sp,#4
push    {r1}

//--------------------------------
ldr     r1,=#m2_custom_wram
str     r0,[r1,#0]

//--------------------------------
// Clobbered code
str     r0,[r4,#4]
ldr     r5,=#0x84001600
str     r5,[r4,#8]

//--------------------------------
pop     {r1}
pop     {pc}


//==============================================================================
// void x_reset0()
// In:
//    r1: window address
//==============================================================================

.x_reset0:
push    {r1-r3,lr}

//--------------------------------
// Get the window number
mov     r0,r1
bl      .get_window_number

//--------------------------------
// Clear the window
mov     r0,r1
bl      .clear_window

//--------------------------------
// Clobbered code
mov     r0,#0
str     r0,[r1,#0x18]
strh    r0,[r1,#0x2C]

//--------------------------------
pop     {r1-r3,pc}


//==============================================================================
// void x_reset1()
// In:
//    r5: window address
//==============================================================================

.x_reset1:
push    {r1-r2,lr}

//--------------------------------
// Get the window number
mov     r0,r5
bl      .get_window_number

//--------------------------------
// Reset the pixel X
ldr     r1,=#m2_custom_wram
add     r2,r0,r1
mov     r1,#0
strb    r1,[r2,#4]

//--------------------------------
// Clobbered code
ldrh    r0,[r5,#0x2C]
sub     r0,#2

//--------------------------------
pop     {r1-r2,pc}


//==============================================================================
// void x_reset2()
// In:
//    r5: window address
//==============================================================================

.x_reset2:
push    {r1-r2,lr}

//--------------------------------
// Get the window number
mov     r0,r5
bl      .get_window_number

//--------------------------------
// Reset the pixel X
ldr     r1,=#m2_custom_wram
add     r2,r0,r1
mov     r1,#0
strb    r1,[r2,#4]

//--------------------------------
// Clobbered code
ldrh    r0,[r5,#0x2C]
add     r0,#2

//--------------------------------
pop     {r1-r2,pc}


//==============================================================================
// void x_reset3()
// In:
//    r3: window address
//==============================================================================

.x_reset3:
push    {r1-r2,lr}

//--------------------------------
// Get the window number
mov     r0,r3
bl      .get_window_number

//--------------------------------
// Clear the window
mov     r0,r3
bl      .clear_window

//--------------------------------
// Clobbered code
mov     r0,#0
str     r0,[r3,#0x18]
strh    r0,[r3,#0x2C]

//--------------------------------
pop     {r1-r2,pc}


//==============================================================================
// void x_reset4()
// In:
//    r5: window address
//==============================================================================

.x_reset4:
push    {r1-r3,lr}
mov     r3,r0

//--------------------------------
// Get the window number
mov     r0,r5
bl      .get_window_number

//--------------------------------
// Reset the pixel X
ldr     r1,=#m2_custom_wram
add     r2,r0,r1
mov     r1,#0
strb    r1,[r2,#4]

//--------------------------------
// Clobbered code
mov     r0,r3
mov     r6,r0
ldr     r4,=#0x3005228
pop     {r1-r3,pc}


//==============================================================================
// void x_reset5()
// In:
//    r5: window address
//==============================================================================

.x_reset5:
push    {r1-r3,lr}
mov     r3,r0

//--------------------------------
// Get the window number
mov     r0,r5
bl      .get_window_number

//--------------------------------
// Reset the pixel X
ldr     r1,=#m2_custom_wram
add     r2,r0,r1
mov     r1,#0
strb    r1,[r2,#4]

//--------------------------------
// Clobbered code
pop     {r1-r3}
ldrb    r0,[r3,#0]
sub     r0,#6
pop     {pc}


//==============================================================================
// void x_resetall()
// In:
//    r6: window address
//==============================================================================

.x_resetall:
push    {lr}

//--------------------------------
// Reset the pixel X
ldr     r5,=#m2_custom_wram
mov     r0,#0
str     r0,[r5,#4]
str     r0,[r5,#8]
str     r0,[r5,#12]

//--------------------------------
// Clobbered code
strh    r0,[r6,#0x32]
pop     {pc}


//==============================================================================
// void clear_window(*WINDOW window)
// In:
//    r0: window address
//==============================================================================

.clear_window:
print   "m2vwf.clear_window:           $",pc

push    {r0-r7,lr}

//--------------------------------
// Reset the X coordinate
mov     r2,r0
bl      .get_window_number
ldr     r1,=#m2_custom_wram
add     r1,r0,r1
mov     r0,#0
strb    r0,[r1,#4]
mov     r0,r2

//--------------------------------
// Erase each tile
mov     r1,r8
push    {r1}
ldr     r1,=#0x44444444
mov     r8,r1

mov     r7,#0x22
ldrb    r6,[r0,r7]           // Window X
mov     r7,#0x24
ldrb    r2,[r0,r7]           // Window Y
mov     r7,#0x26
ldrb    r3,[r0,r7]           // Window width
add     r3,r3,r6             // Window right
mov     r7,#0x28
ldrb    r4,[r0,r7]           // Window height
add     r4,r4,r2             // Window bottom
ldr     r7,=#0x30051EC
ldrh    r7,[r7,#0]           // Tile offset

//--------------------------------
.clear_loop:
mov     r5,r6
-
mov     r0,r5
mov     r1,r2
bl      .get_tile_number
add     r0,r0,r7
lsl     r0,r0,#5
mov     r1,#6
lsl     r1,r1,#0x18
add     r0,r0,r1
mov     r1,r8
str     r1,[r0,#0]
str     r1,[r0,#4]
str     r1,[r0,#8]
str     r1,[r0,#12]
str     r1,[r0,#16]
str     r1,[r0,#20]
str     r1,[r0,#24]
str     r1,[r0,#28]
add     r5,r5,#1
cmp     r5,r3
bcc     -
add     r2,r2,#1
cmp     r2,r4
bcc     .clear_loop

//--------------------------------
pop     {r1}
mov     r8,r1
pop     {r0-r7,pc}


//==============================================================================
// void clear_tilemap(*WINDOW window)
// In:
//    r0: window address
//==============================================================================

.clear_tilemap:
push    {r0-r7,lr}

//--------------------------------
ldr     r1,=#0x30051EC
ldrh    r6,[r1,#0]           // Palette mask
add     r1,#0x3C
ldrh    r5,[r1,#0]           // Tile offset
orr     r6,r5
ldr     r5,=#0x1FF
add     r6,r6,r5             // Blank value to copy to tilemap

add     r1,#0x48
ldr     r1,[r1,#0]           // Tilemap address
mov     r7,#0x22
ldrb    r2,[r0,r7]           // Window X
mov     r7,#0x24
ldrb    r3,[r0,r7]           // Window Y
mov     r7,#0x26
ldrb    r4,[r0,r7]           // Width
mov     r7,#0x28
ldrb    r5,[r0,r7]           // Height

//--------------------------------
// Advance to the appropriate position in the tilemap
lsl     r0,r3,#5
add     r0,r0,r2
lsl     r0,r0,#1
add     r1,r0,r1

//--------------------------------

mov     r7,#0

.clear_tilemap_loop:
cmp     r7,r5
bcs     .clear_tilemap_finished
mov     r3,#0
mov     r2,r1

-
cmp     r3,r4
bcs     +
strh    r6,[r2,#0]
add     r2,r2,#2
add     r3,r3,#1
b       -

+
add     r1,r1,#0x40
add     r7,r7,#1
b       .clear_tilemap_loop

//--------------------------------
.clear_tilemap_finished:
pop     {r0-r7,pc}


//==============================================================================
// void string_width(char* chr, byte font)
// In:
//    r0: chr
//    r1: font
// Out:
//    r0: width (pixels)
//    r1: chars read
//==============================================================================
 
.string_width:
print   "m2vwf.string_width:           $",pc

push    {r2-r5,lr}

ldr     r2,=#m2_widths_table
lsl     r1,r1,#2             // Font number * 4
ldr     r2,[r2,r1]
mov     r4,#0
mov     r5,#0

-
ldrb    r3,[r0,#1]
cmp     r3,#0xFF
beq     +
ldrb    r3,[r0,#0]
sub     r3,#0x50
lsl     r3,r3,#1
ldrb    r1,[r2,r3]           // Virtual width
add     r4,r4,r1
add     r0,r0,#1
add     r5,r5,#1
b       -
+

mov     r0,r4
mov     r1,r5
pop     {r2-r5,pc}


//==============================================================================
// void main(WINDOW* window, char* chr, TILEDATA* tileData)
// In:
//    r5: window
//    r7: chr
//    r8: tileData
//==============================================================================

.main:
print   "m2vwf.main:                   $",pc

push    {r5,lr}
ldr     r5,[sp,#8]
mov     lr,r5
ldr     r5,[sp,#4]
str     r5,[sp,#8]
pop     {r5}
add     sp,#4
push    {r0-r2}

//--------------------------------
mov     r0,r5
mov     r1,r7
mov     r2,r8
bl      .weld_entry

//--------------------------------
pop     {r0-r2}
pop     {pc}


//==============================================================================
// void main_redraw(WINDOW* window)
// In:
//    r0: window
//==============================================================================

.main_redraw:
print   "m2vwf.main_redraw:            $",pc
push    {r0-r5,lr}

//--------------------------------
// Get the address of the main menu window
ldr     r5,=#0x3005230
ldr     r0,[r5,#0]
mov     r4,r0

// Get its text address
ldr     r1,[r0,#4]

// Draw it
mov     r2,#0
bl      $80BE458
mov     r0,r4
bl      $80C8FFC

//--------------------------------
// Get the address of the cash window
ldr     r0,[r5,#4]
mov     r4,r0

// Get its text address
ldr     r1,[r0,#4]

// Draw it
mov     r2,#0
bl      $80BE458
mov     r0,r4
bl      $80C8FFC

//--------------------------------
// Clobbered code
pop     {r0-r5}
bl      $80BD7AC
pop     {pc}


//==============================================================================
// void status(WINDOW* window, char* chr, TILEDATA* tileData)
// In:
//    r4: window
//    r2: chr
//    r5: tileData
//==============================================================================

.status:
print   "m2vwf.status:                 $",pc

push    {r5,lr}
ldr     r5,[sp,#8]
mov     lr,r5
ldr     r5,[sp,#4]
str     r5,[sp,#8]
pop     {r5}
add     sp,#4
push    {r0-r2}

//--------------------------------
mov     r0,r4
mov     r1,r2
mov     r2,r5
bl      .weld_entry

//--------------------------------
pop     {r0-r2}
pop     {pc}


//==============================================================================
// void goods(char* chr, TILEDATA* tileData)
// In:
//    r3: chr
//    r6: tileData
//==============================================================================

.goods:
print   "m2vwf.goods:                  $",pc

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
bl      .get_dirty_flag
cmp     r0,#1
bne     +

// Just get the string width instead (don't need to render)
mov     r0,r3
mov     r1,#0
bl      .string_width
add     r3,r3,r1
b       .goods_skip

+
//--------------------------------
// Get x and y from tilebase
mov     r0,r6
bl      .get_coords

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
bl      .print_character
add     r6,r0,r6
add     r0,r0,r7
add     r5,r5,#1
b       -

+
mov     r3,r5
mov     r0,r6
pop     {r6,r7}

//--------------------------------
.goods_skip:

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
// void goods2(char* chr, TILEDATA* tileData)
// In:
//    r3: chr
//    r6: tileData
//==============================================================================

.goods2:
print   "m2vwf.goods2:                 $",pc

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
bl      .get_dirty_flag
cmp     r0,#1
bne     +

// Just get the string width instead (don't need to render)
mov     r0,r3
mov     r1,#0
bl      .string_width
add     r3,r3,r1
b       .goods2_skip

+
//--------------------------------
// Get x and y from tilebase
mov     r0,r6
bl      .get_coords

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
bl      .print_character
add     r6,r0,r6
add     r0,r0,r7
add     r5,r5,#1
b       -

+
mov     r3,r5
mov     r0,r6
pop     {r6,r7}

//--------------------------------
.goods2_skip:

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
// void goods_highlight(WINDOW* window, char* chr, int itemIndex)
// In:
//    r0: window
//    r1: chr
//    r9: itemIndex (based at 0)
// Out:
//    r2: new tile X
//==============================================================================

.goods_highlight:
print   "m2vwf.goods_highlight:        $",pc

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
// void get_dirty_flag(WINDOW* window)
// In:
//    r0: window
// Out:
//    r0: flag
//==============================================================================

.get_dirty_flag:

push    {r1,lr}

ldr     r1,=#m2_custom_wram
add     r1,#0x14
bl      .get_window_number
ldrb    r0,[r1,r0]

pop     {r1,pc}


//==============================================================================
// void set_dirty_flag(WINDOW* window, byte value)
// In:
//    r0: window
//    r1: value
//==============================================================================

.set_dirty_flag:

push    {r0-r2,lr}

ldr     r2,=#m2_custom_wram
add     r2,#0x14
bl      .get_window_number
strb    r1,[r2,r0]

pop     {r0-r2,pc}


//==============================================================================
// void goods_clean()
//==============================================================================

.goods_clean:
print   "m2vwf.goods_clean:            $",pc

push    {lr}

mov     r0,r7
mov     r1,#1
bl      .set_dirty_flag

ldr     r0,=#0x3002504 // Clobbered code
ldrh    r1,[r0,#0]

pop     {pc}


//==============================================================================
// void goods_dirty1()
//==============================================================================

.goods_dirty1:
print   "m2vwf.goods_dirty1:           $",pc

push    {r1,lr}

// Set the dirty flag
mov     r0,r7
mov     r1,#0
bl      .set_dirty_flag

// Clear the window
mov     r0,r7
bl      .clear_window

// Clobbered code
ldrh    r0,[r4,#0]
sub     r0,#0x1

pop     {r1,pc}


//==============================================================================
// void goods_dirty2()
//==============================================================================

.goods_dirty2:
print   "m2vwf.goods_dirty2:           $",pc

push    {r0,lr}

// Set the dirty flag
mov     r0,r7
mov     r1,#0
bl      .set_dirty_flag

// Clear the window
mov     r0,r7
bl      .clear_window

// Clobbered code
pop     {r0}
add     r0,#0x1
mov     r1,r9
pop     {pc}


//==============================================================================
// void goods_dirty3()
//==============================================================================

.goods_dirty3:
print   "m2vwf.goods_dirty3:           $",pc

push    {r2-r3,lr}
mov     r2,r0
mov     r3,r1

// Set the dirty flag
ldr     r0,=#0x3005240
ldr     r0,[r0,#0]
mov     r2,r1
mov     r1,#0
bl      .set_dirty_flag

mov     r0,r2
mov     r1,r3

// Clobbered code
ldrb    r0,[r0,#0]
strh    r0,[r1,#0]

pop     {r2-r3,pc}


//==============================================================================
// void goods_dirty4()
//==============================================================================

.goods_dirty4:
print   "m2vwf.goods_dirty4:           $",pc

push    {r1,lr}

// Set the dirty flag
mov     r0,r7
mov     r1,#0
bl      .set_dirty_flag

// Clobbered code
mov     r6,#0
mov     r8,r6

pop     {r1,pc}


//==============================================================================
// void goods_dirty5()
//==============================================================================

.goods_dirty5:
print   "m2vwf.goods_dirty5:           $",pc

push    {r0,lr}

// Check the dirty flag
bl      .get_dirty_flag
cmp     r0,#0
bne     +

// It's dirty, so erase the window
pop     {r0}
bl      $80CA834
pop     {pc}

+
pop     {r0,pc}


//==============================================================================
// void goods_dirty6()
//==============================================================================

.goods_dirty6:
print   "m2vwf.goods_dirty6:           $",pc

push    {r1,lr}

// Set the dirty flag
mov     r0,r7
mov     r1,#0
bl      .set_dirty_flag

// Clobbered code
mov     r0,#0
strh    r0,[r7,#0x32]

pop     {r1,pc}


//==============================================================================
// void goods_redraw()
//==============================================================================

.goods_redraw:
print   "m2vwf.goods_redraw:           $",pc

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
bl      .clear_window

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


//==============================================================================
// void psi_clean1()
//==============================================================================

.psi_clean1:
print   "m2vwf.psi_clean1:             $",pc

push    {r0-r1,lr}

// Clobbered code
bl      $80BAE98                // render the PSI window

// Unset the dirty flag
mov     r1,r5                   // = #0x3005230
ldr     r0,[r1,#0x1C]           // PSI window address
mov     r1,#1
bl      .set_dirty_flag

pop     {r0-r1,pc}


//==============================================================================
// void psi_clear1()
//==============================================================================

.psi_clear1:
print   "m2vwf.psi_clear1:             $",pc

push    {r0-r1,lr}

// Check the dirty flag
bl      .get_dirty_flag

// If it's clean, don't erase
cmp     r0,#0
bne     +

// Clobbered code -- clear the window
pop     {r0-r1}
bl      $80CA834
pop     {pc}

+
pop     {r0-r1,pc}


//==============================================================================
// void psi_help_clean1()
//==============================================================================

.psi_help_clean1:
print   "m2vwf.psi_help_clean1:        $",pc

push    {r0-r1,r4,lr}

// Clobbered code
mov     r4,r0
bl      $80C8BE4                // render the PSI help window

// Unset the dirty flag
mov     r0,r4
mov     r1,#1
bl      .set_dirty_flag

pop     {r0-r1,r4,pc}


//==============================================================================
// void psi_help_clear1()
//==============================================================================

.psi_help_clear1:
print   "m2vwf.psi_help_clear1:        $",pc

push    {r0-r1,lr}

// Check the dirty flag
bl      .get_dirty_flag

// If it's clean, don't erase
cmp     r0,#0
bne     +

// Clobbered code -- clear the window
pop     {r0-r1}
bl      $80BE458
pop     {pc}

+
pop     {r0-r1,pc}


//==============================================================================
// void cursor_dirty1()
//==============================================================================

.cursor_dirty1:
print   "m2vwf.cursor_dirty1:          $",pc

push    {lr}

// Set the dirty flag
bl      .set_all_dirty_flags

// Clobbered code
strh    r0,[r5,#0x36]
mov     r1,#0x36

pop     {pc}


//==============================================================================
// void set_all_dirty_flags()
//==============================================================================

.set_all_dirty_flags:
print   "m2vwf.set_all_dirty_flags:    $",pc

push    {r0-r1,lr}
ldr     r0,=#m2_custom_wram
add     r0,#0x14
mov     r1,#0
str     r1,[r0,#0]
str     r1,[r0,#4]
str     r1,[r0,#8]
pop     {r0-r1,pc}


//==============================================================================
// void get_coords(TILEMAP* map)
// In:
//    r0: tilemap
// Out:
//    r0: x (pixel)
//    r1: y (pixel)
//==============================================================================

.get_coords:
print   "m2vwf.get_coords:             $",pc

push    {r2-r3,lr}

ldr     r1,=#0x3005270
ldr     r3,[r1,#0]
sub     r1,r0,r3
lsl     r2,r1,#26
lsr     r0,r2,#24
lsr     r2,r1,#6
lsl     r1,r2,#3

pop     {r2-r3,pc}


//==============================================================================
// void menu_select(WINDOW* window, char* chr, TILEDATA* tileData)
// In:
//    r4: window
//    r6: chr
//    r3: tileData
//==============================================================================

.menu_select:
print   "m2vwf.menu_select:            $",pc

push    {r5,lr}
ldr     r5,[sp,#8]
mov     lr,r5
ldr     r5,[sp,#4]
str     r5,[sp,#8]
pop     {r5}
add     sp,#4
push    {r0-r2}

//--------------------------------
mov     r0,r4
mov     r1,r2
mov     r2,r5
bl      .weld_entry

//--------------------------------
pop     {r0-r2}
pop     {pc}


//==============================================================================
// void selection_menu(WINDOW* window, char* chr, TILEDATA* tileData)
// In:
//    r4: window
//    r3: chr
//    r12: tileData
//==============================================================================

.selection_menu:
print   "m2vwf.selection_menu:         $",pc
push    {r0-r2,lr}

//--------------------------------
mov     r0,r4
mov     r1,r3
mov     r2,r12
bl      .weld_entry

//--------------------------------
pop     {r0-r2,pc}


//==============================================================================
// void ppcost_once(WINDOW* window)
// In:
//    r0: window
//==============================================================================

.ppcost_once:
print    "m2vwf.ppcost_once:            $",pc

// Need to copy LR to somewhere other than the stack
push    {r1,r3}
ldr     r3,=#m2_custom_wram
mov     r1,lr
str     r1,[r3,#0x10]
pop     {r1,r3}

// Check [r0 + 0x30]: if it's 0xFFFF, then we've already drawn the window
push    {r1,r2}
mov     r1,#0x30
ldsh    r2,[r0,r1]
mov     r1,#1
neg     r1,r1
cmp     r1,r2
pop     {r1,r2}
beq     +
bl      $80C9634

+
// Get back LR
push    {r1,r3}
ldr     r3,=#m2_custom_wram
ldr     r1,[r3,#0x10]
mov     lr,r1
pop     {r1,r3}
mov     pc,lr


//==============================================================================
// void ppcost_once2(WINDOW* window)
// In:
//    r0: window
//==============================================================================

// This one might be more unreliable -- maybe find a better way to do it
// if it causes problems

.ppcost_once2:
print    "m2vwf.ppcost_once2:           $",pc

// Need to copy LR to somewhere other than the stack
push    {r1,r3}
ldr     r3,=#m2_custom_wram
mov     r1,lr
str     r1,[r3,#0x10]
pop     {r1,r3}

// Check [r0 + 0x80]: if it's 0xFFFF, then we've already drawn the window
push    {r1,r2}
mov     r1,#0x80
ldsh    r2,[r0,r1]
mov     r1,#1
neg     r1,r1
cmp     r1,r2
pop     {r1,r2}
beq     +
bl      $80C9634

+
// Get back LR
push    {r1,r3}
ldr     r3,=#m2_custom_wram
ldr     r1,[r3,#0x10]
mov     lr,r1
pop     {r1,r3}
mov     pc,lr