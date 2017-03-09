m2_customcodes:

//==============================================================================
// void parse(int code, char* parserAddress, WINDOW* window)
// In:
//    r0: code
//    r1: parser address
//    r2: window
// Out:
//    r0: control code length (0 if not matched)
//==============================================================================

.parse:

push    {r1-r5,lr}
mov     r3,#0
mov     r4,r0

//--------------------------------
// 60 FF XX: Add XX pixels to the renderer
cmp     r4,#0x60
bne     +
mov     r3,#3

// Get the current X offset
ldrh    r4,[r2,#2]

// Get the current X tile
ldrh    r5,[r2,#0x2A]

lsl     r5,r5,#3
add     r4,r4,r5             // Current X location (in pixels)

// Get the value to add
ldrb    r5,[r1,#2]           // Control code parameter
add     r4,r4,r5             // New X location

// Store the pixel offset of the new location
.store_x:
lsl     r5,r4,#29
lsr     r5,r5,#29
strh    r5,[r2,#2]

// Store the X tile of the new location
lsr     r4,r4,#3
strh    r4,[r2,#0x2A]
b       .parse_end

+

//--------------------------------
// 5F FF XX: Set the X value of the renderer
cmp     r4,#0x5F
bne     +
mov     r3,#3

// Get the new X value
ldrb    r4,[r1,#2]
b       .store_x

+


//--------------------------------
.parse_end:
mov     r0,r3
pop     {r1-r5,pc}
