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

push    {r1-r6,lr}
mov     r6,#0
ldr     r3,=#m2_custom_wram
add     r3,r3,#4
mov     r4,r0

// Get the window number
mov     r0,r2
//bl      m2_vwf.get_window_number

//--------------------------------
// 60 FF XX: Add XX pixels to the renderer
cmp     r4,#0x60
bne     +
mov     r6,#3

// Get the current X offset
ldrb    r4,[r3,r0]

// Get the current X tile
mov     r5,#0x2A
ldrb    r5,[r2,r5]

lsl     r5,r5,#3
add     r4,r4,r5             // Current X location (in pixels)

// Get the value to add
ldrb    r5,[r1,#2]           // Control code parameter
add     r4,r4,r5             // New X location

// Store the pixel offset of the new location
.store_x:
lsl     r5,r4,#29
lsr     r5,r5,#29
strb    r5,[r3,r0]

// Store the X tile of the new location
lsr     r4,r4,#3
mov     r5,#0x2A
strb    r4,[r2,r5]
b       .parse_end

+

//--------------------------------
// 5F FF XX: Set the X value of the renderer
cmp     r4,#0x5F
bne     +
mov     r6,#3

// Get the new X value
ldrb    r4,[r1,#2]
b       .store_x

+


//--------------------------------
.parse_end:
mov     r0,r6
pop     {r1-r6,pc}
