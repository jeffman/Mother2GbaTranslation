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
print   "m2customcodes.parse:          $",pc

push    {r1-r6,lr}
mov     r6,#0
ldr     r3,=#m2_custom_wram
add     r3,r3,#4
mov     r4,r0

// Get the window number
mov     r0,r2
bl      m2_vwf.get_window_number

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


//==============================================================================
// void check_main(byte code, char* parserAddress, WINDOW* window)
// In:
//    r0: code
//    r7: parser address
//    r5: window
//==============================================================================

.check_main:

push    {r1-r3,lr}

//--------------------------------
mov     r1,r7
mov     r2,r5
bl      .parse
cmp     r0,#0
bne     +
mov     r0,#2
+

//--------------------------------
// Clobbered code
ldr     r3,[r6,#0]
add     r3,r3,r0
mov     r0,r3

//--------------------------------
pop     {r1-r3,pc}


//==============================================================================
// void check_status(char* parserAddress, WINDOW* window)
// In:
//    r2: parser address
//    r4: window
//==============================================================================

.check_status:
push    {lr}
ldrb    r0,[r2,#0]
cmp     r0,#1
bne     +

pop     {r0}
mov     lr,r0
ldr     r0,=#0x80C90A9
bx      r0

+

//--------------------------------
push    {r0-r2}
mov     r1,r2
mov     r2,r4
bl      .parse
mov     r7,r0
cmp     r0,#0
pop     {r0-r2}
bne     +

// It wasn't one of our codes, so let the game continue checking
pop     {r7}
mov     lr,r7
ldr     r7,=#0x80C90CD
bx      r7
+

//--------------------------------
mov     r0,r12
add     r0,r0,r7
str     r0,[r4,#0x14]
pop     {r7}
mov     lr,r7
ldr     r7,=#0x80C904D
bx      r7


//==============================================================================
// void check_selection_menu(char* parserAddress, WINDOW* window)
// In:
//    r3: parser address
//    r4: window
//==============================================================================

.check_selection_menu:

push    {r0-r2,lr}

//--------------------------------
ldrb    r0,[r3,#0]
mov     r1,r3
mov     r2,r4
bl      .parse
cmp     r0,#0
bne     +
mov     r0,#2
+
add     r3,r3,r0

//--------------------------------
pop     {r0-r2,pc}