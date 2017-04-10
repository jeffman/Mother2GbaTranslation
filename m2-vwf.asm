//==============================================================================
// void weld_entry(WINDOW* window, byte* chr)
//    In:
//        r0: address of window data
//        r1: address of char to print
//==============================================================================

//--------------------------------
weld_entry:
push    {r0-r5,lr}

// Check for valid character value
mov     r4,r0
ldrb    r0,[r1,0]
sub     r0,0x50
bpl     @@next
mov     r0,0x1F
b       @@valid

@@next:
cmp     r0,0x60
bcc     @@valid
cmp     r0,0x64
bcc     @@invalid
cmp     r0,0x6D
bcs     @@invalid
b       @@valid

@@invalid:
mov     r0,0x1F

@@valid:

// Calculate X coord
ldrh    r1,[r4,0x22]  // window_X
mov     r5,r1
ldrh    r2,[r4,0x2A]  // text_X
add     r1,r1,r2
lsl     r1,r1,3
ldrh    r2,[r4,2]     // pixel_X
add     r1,r1,r2      // screen pixel X

// Calculate Y coord
ldrh    r2,[r4,0x24]  // window_Y
ldrh    r3,[r4,0x2C]  // text_Y
add     r2,r2,r3
lsl     r2,r2,3

// Print
push    {r1-r3}
add     sp,-4
mov     r3,0xF
str     r3,[sp]
mov     r3,0          // font
bl      print_character
add     sp,4
pop     {r1-r3}

// Store new X coords
add     r0,r0,r1      // new screen pixel_X
lsr     r1,r0,3
sub     r1,r1,r5      // new text_X
strh    r1,[r4,0x2A]
lsl     r0,r0,29
lsr     r0,r0,29      // new pixel_X
strh    r0,[r4,2]

pop     {r0-r5,pc}


//=============================================================================
// void print_string(char* str, int x, int y)
// In:
//    r0: address of string to print
//    r1: x (pixel)
//    r2: y (pixel)
// Out:
//    r0: number of characters printed
//    r1: number of pixels printed
//=============================================================================

print_string:
push    {r2-r6,lr}

mov     r5,0
mov     r6,r1
mov     r4,r0
@@prev:
ldrb    r0,[r4,1]
cmp     r0,0xFF
beq     @@end
ldrb    r0,[r4,0]
sub     r0,0x50

push    {r1-r3}
add     sp,-4
mov     r3,0xF
str     r3,[sp]
mov     r3,0
bl      print_character
add     sp,4
pop     {r1-r3}

add     r1,r0,r1
add     r4,1
add     r5,1
b       @@prev

@@end:
mov     r0,r5
sub     r1,r1,r6
pop     {r2-r6,pc}


//=============================================================================
// void print_string_hlight_pixels(WINDOW* window, char* str, int x,
//                                       int y, bool highlight)
// In:
//    r0: window
//    r1: address of string to print
//    r2: x (pixel)
//    r3: y (pixel)
//    sp: highlight
// Out:
//    r0: number of characters printed
//    r1: number of pixels printed
//=============================================================================

print_string_hlight_pixels:
// Copied from C96F0
// Basically it's the exact same subroutine, only in pixels instead of tiles
push    {r4-r7,lr}
mov     r7,r8
push    {r7}
mov     r6,r1
ldr     r1,[sp,0x18]
lsl     r1,r1,0x10
mov     r7,0
ldr     r5,=0x3005228
ldrh    r4,[r5,0]
lsl     r4,r4,0x10
asr     r4,r4,0x1C
mov     r8,r4
lsr     r4,r1,0x10
mov     r12,r4
asr     r1,r1,0x10
add     r1,r8
lsl     r1,r1,0xC
strh    r1,[r5,0]
ldrh    r1,[r0,0x22]
lsl     r1,r1,3
add     r1,r1,r2
ldrh    r2,[r0,0x24]
lsl     r2,r2,3
add     r2,r2,r3
mov     r0,r6
bl      print_string
mov     r7,r0
ldrh    r0,[r5,0]
lsl     r0,r0,0x10
asr     r0,r0,0x1C
mov     r4,r12
lsl     r3,r4,0x10
asr     r3,r3,0x10
sub     r0,r0,r3
lsl     r0,r0,0xC
strh    r0,[r5,0]
lsl     r0,r7,0x10
asr     r0,r0,0x10
pop     {r3}
mov     r8,r3
pop     {r4-r7}
pop     {r2}
bx      r2
.pool


//==============================================================================
// void clear_window(WINDOW* window, int bgIndex)
// In:
//    r0: window pointer
//    r1: background index
//==============================================================================

// - clears all VWF-ified tiles in a window
clear_window:
push    {r0-r3,lr}
add     sp,-16
mov     r3,r0
mov     r0,sp
ldr     r2,=0x30051EC
ldrh    r2,[r2,0] // tile offset
strh    r2,[r0,8]
ldr     r2,=0x11111111
mul     r1,r2
str     r1,[r0,4] // empty row of pixels

ldrh    r1,[r3,0x22] // window X
strh    r1,[r0,0]
ldrh    r1,[r3,0x24] // window Y
strh    r1,[r0,2]
ldrh    r1,[r3,0x26] // window width
strh    r1,[r0,0xC]
ldrh    r1,[r3,0x28] // window height
strh    r1,[r0,0xE]

bl      clear_rect

add     sp,16
pop     {r0-r3,pc}
.pool


//==============================================================================
// void clear_rect(CLEAR_RECT_STRUCT* data)
// In:
//    r0: data pointer
//       [r0+0x00]: x
//       [r0+0x02]: y
//       [r0+0x04]: empty row of pixels
//       [r0+0x08]: tile offset
//       [r0+0x0C]: width
//       [r0+0x0E]: height
//==============================================================================

// - clears a rectangle

clear_rect:
push    {r0-r6,lr}

ldrh    r1,[r0,0xC] // width
ldrh    r2,[r0,0xE] // height
ldrh    r6,[r0,0]   // initial X
mov     r3,0 // current row
@@outer_start:
cmp     r3,r2
bge     @@end
mov     r4,0 // current col
@@prev:
cmp     r4,r1
bge     @@inner_end
bl      clear_tile_internal
ldrh    r5,[r0,0]
add     r5,r5,1
strh    r5,[r0,0]
add     r4,r4,1
b       @@prev
@@inner_end:
ldrh    r5,[r0,2]
add     r5,r5,1
strh    r5,[r0,2]
mov     r5,r6
strh    r5,[r0,0]
add     r3,r3,1
b       @@outer_start

@@end:
pop     {r0-r6,pc}


//==============================================================================
// void clear_tile_internal(CLEAR_STRUCT* data)
// In:
//    r0: data pointer
//       [r0+0x00]: x
//       [r0+0x02]: y
//       [r0+0x04]: empty row of pixels
//       [r0+0x08]: tile offset
//==============================================================================

// - clears a VWF tile at (x,y)

clear_tile_internal:
push    {r0-r3,lr}

mov     r3,r0
ldrh    r0,[r3,0]
ldrh    r1,[r3,2]
push    {r1-r3}
bl      get_tile_number
pop     {r1-r3}
ldrh    r1,[r3,8]
add     r0,r0,r1
lsl     r1,r0,5
mov     r0,6
lsl     r0,r0,24
add     r1,r0,r1 // VRAM dest address
add     r0,r3,4 // source address
ldr     r2,=0x1000008 // set the fixed source address flag + copy 8 words
swi     0xC // CpuFastSet

pop     {r0-r3,pc}
.pool


//==============================================================================
// void print_blankstr(int x, int y, int width)
// In:
//    r0: x (tile)
//    r1: y (tile)
//    r2: width (tile)
//==============================================================================

// - prints a blank string at (x,y) of width tiles
print_blankstr:
push    {r0-r5,lr}
add     sp,-16
mov     r4,r0
mov     r0,sp

strh    r4,[r0,0]
strh    r1,[r0,2]
ldr     r1,=0x44444444
str     r1,[r0,4]
ldr     r1,=0x30051EC
ldrh    r1,[r1,0]
str     r1,[r0,8]
strh    r2,[r0,0xC]
mov     r2,2
strh    r2,[r0,0xE]
bl      clear_rect

add     sp,16
pop     {r0-r5,pc}
.pool


//==============================================================================
// void print_space(WINDOW* window)
// In:
//    r0: window pointer
//==============================================================================

// - prints a space character to window
print_space:
push    {r0-r1,lr}
add     sp,-4
mov     r1,0x50
str     r1,[sp,0]
mov     r1,sp
bl      weld_entry
add     sp,4
pop     {r0-r1,pc}


//==============================================================================
// void copy_tile(int x1, int y1, int x2, int y2)
// In:
//    r0,r1: x1,y1
//    r2,r3: x2,y2
//==============================================================================

// - copies a tile from (x1,y1) to (x2,y2)
copy_tile:
push    {r0-r4,lr}

// Get the source and dest tile numbers @@next offset
push    {r1-r3}
bl      get_tile_number
pop     {r1-r3}
mov     r4,r0
mov     r0,r2
mov     r1,r3
push    {r1-r3}
bl      get_tile_number
pop     {r1-r3}
mov     r3,r0
ldr     r0,=0x30051EC
ldrh    r1,[r0,0]
add     r0,r1,r4 // source tile
add     r1,r1,r3 // dest tile

// Get VRAM addresses
mov     r2,6
lsl     r2,r2,0x18 // VRAM tile base
lsl     r0,r0,5
lsl     r1,r1,5
add     r0,r0,r2 // VRAM source address
add     r1,r1,r2 // VRAM dest address

// Copy
mov     r2,8
swi     0xC

pop     {r0-r4,pc}
.pool


//==============================================================================
// void copy_tile_up(int x, int y)
// In:
//    r0,r1: x,y
//==============================================================================

// - copies a tile upward by one line (16 pixels)
copy_tile_up:
push    {r2-r3,lr}
sub     r3,r1,2
mov     r2,r0
bl      copy_tile
pop     {r2-r3,pc}
