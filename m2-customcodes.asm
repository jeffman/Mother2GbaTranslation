//==============================================================================
// void parse(int code, char* parserAddress, WINDOW* window)
// In:
//    r0: code
//    r1: parser address
//    r2: window
// Out:
//    r0: control code length (0 if not matched)
//==============================================================================

customcodes_parse:

push    {r1-r5,lr}
mov     r3,0
mov     r4,r0

//--------------------------------
// 60 FF XX: Add XX pixels to the renderer
cmp     r4,0x60
bne     @@next

// 60 FF should be treated as a renderable code
push    {r0-r3}
mov     r0,r2
bl      handle_first_window
pop     {r0-r3}

mov     r3,3

// Get the current X offset
ldrh    r4,[r2,2]

// Get the current X tile
ldrh    r5,[r2,0x2A]

lsl     r5,r5,3
add     r4,r4,r5             // Current X location (in pixels)

// Get the value to add
ldrb    r5,[r1,2]           // Control code parameter
add     r4,r4,r5             // New X location

// Store the pixel offset of the new location
@@store_x:
lsl     r5,r4,29
lsr     r5,r5,29
strh    r5,[r2,2]

// Store the X tile of the new location
lsr     r4,r4,3
strh    r4,[r2,0x2A]
b       @@end

@@next:

//--------------------------------
// 5F FF XX: Set the X value of the renderer
cmp     r4,0x5F
bne     @@next2

// 5F FF should be treated as a renderable code
push    {r0-r3}
mov     r0,r2
bl      handle_first_window
pop     {r0-r3}

mov     r3,3

// Get the new X value
ldrb    r4,[r1,2]
b       @@store_x

@@next2:

//--------------------------------
// 5E FF XX: Load value into memory
cmp     r4,0x5E
bne     @@end
mov     r3,3

// Get the argument
ldrb    r4,[r1,2]
cmp     r4,1
bne     @@end

// 01: load enemy plurality
ldr     r1,=0x2025038
ldrb    r1,[r1] // number of enemies at start of battle
cmp     r1,4
blt     @@small
mov     r1,3
@@small:
mov     r0,r1 // the jump table is 1-indexed
mov     r4,r3
bl      0x80A334C // store to window memory
mov     r3,r4

//--------------------------------
@@end:
mov     r0,r3
pop     {r1-r5,pc}
.pool
