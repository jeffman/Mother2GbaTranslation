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
lsr     r1,r0,16
lsl     r0,r0,16
lsr     r7,r0,16
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
// void print_space(WINDOW* window)
// In:
//    r0: window pointer
//==============================================================================

// - prints a space character to window
print_space:
push    {r0-r3,lr}
add     sp,-4
mov     r1,0x50
str     r1,[sp,0]
mov     r1,sp
bl      weld_entry
add     sp,4
pop     {r0-r3,pc}
