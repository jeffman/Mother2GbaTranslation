m2_formatting:


//==============================================================================
// http://en.wikipedia.org/wiki/Double_dabble
// int bin_to_bcd(int binary)
// In:
//    r0: binary number
// Out:
//    r0: BCD-coded number
//    r1: amount of digits used
//==============================================================================

.bin_to_bcd:

push    {r2-r7,lr}
mov     r2,r8
mov     r3,r9
push    {r2-r3}

lsl     r0,r0,#5
mov     r1,#0
mov     r3,#27
mov     r4,#3
lsl     r4,r4,#8
lsl     r5,r4,#4
lsl     r6,r5,#4
lsl     r7,r6,#12
mov     r9,r7
lsl     r7,r6,#8
mov     r8,r7
lsl     r7,r6,#4

//--------------------------------
-

// Ones
lsl     r2,r1,#28
lsr     r2,r2,#28
cmp     r2,#5
bcc     +
add     r1,r1,#3
+

// Tens
lsl     r2,r1,#24
lsr     r2,r2,#28
cmp     r2,#5
bcc     +
add     r1,#0x30
+

// Hundreds
lsl     r2,r1,#20
lsr     r2,r2,#28
cmp     r2,#5
bcc     +
add     r1,r1,r4
+

// Thousands
lsl     r2,r1,#16
lsr     r2,r2,#28
cmp     r2,#5
bcc     +
add     r1,r1,r5
+

// Ten-thousands
lsl     r2,r1,#12
lsr     r2,r2,#28
cmp     r2,#5
bcc     +
add     r1,r1,r6
+

// Hundred-thousands
lsl     r2,r1,#8
lsr     r2,r2,#28
cmp     r2,#5
bcc     +
add     r1,r1,r7
+

// Millions
lsl     r2,r1,#4
lsr     r2,r2,#28
cmp     r2,#5
bcc     +
add     r1,r8
+

// Ten-millions
lsr     r2,r2,#28
cmp     r2,#5
bcc     +
add     r1,r9
+

// Shift
lsl     r1,r1,#1
tst     r0,r0
bpl     +
add     r1,r1,#1
+
lsl     r0,r0,#1
sub     r3,r3,#1
bne     -
mov     r0,r1

//--------------------------------
// Check how many digits are used
mov     r3,#1
-
lsr     r1,r1,#4
beq     +
add     r3,r3,#1
b       -
+

//--------------------------------
mov     r1,r3
pop     {r2-r3}
mov     r8,r2
mov     r9,r3
pop     {r2-r7,pc}


//==============================================================================
// int bcd_to_bin(int bcd)
// In:
//    r0: BCD-coded number
// Out:
//    r0: binary number
//==============================================================================

.bcd_to_bin:

push    {r1-r4,lr}
mov     r1,#0
mov     r2,#10
mov     r3,#1

//--------------------------------
// Ones
lsl     r4,r0,#28
lsr     r4,r4,#28
mul     r4,r3
add     r1,r1,r4
mul     r3,r2

// Tens
lsl     r4,r0,#24
lsr     r4,r4,#28
mul     r4,r3
add     r1,r1,r4
mul     r3,r2

// Hundreds
lsl     r4,r0,#20
lsr     r4,r4,#28
mul     r4,r3
add     r1,r1,r4
mul     r3,r2

// Thousands
lsl     r4,r0,#16
lsr     r4,r4,#28
mul     r4,r3
add     r1,r1,r4
mul     r3,r2

// Ten-thousands
lsl     r4,r0,#12
lsr     r4,r4,#28
mul     r4,r3
add     r1,r1,r4
mul     r3,r2

// Hundred-thousands
lsl     r4,r0,#8
lsr     r4,r4,#28
mul     r4,r3
add     r1,r1,r4
mul     r3,r2

// Millions
lsl     r4,r0,#4
lsr     r4,r4,#28
mul     r4,r3
add     r1,r1,r4
mul     r3,r2

// Ten-millions
lsr     r4,r0,#28
mul     r4,r3
add     r1,r1,r4

//--------------------------------
mov     r0,r1
pop     {r1-r4,pc}


//==============================================================================
// ushort format_cash(int amount, char* output, int digits)
// In:
//    r0: amount
//    r1: output string
//    r2: digits
// Out:
//    r0: = digits - (digits rendered) - 1
//==============================================================================

.format_cash:
print   "m2formatting.format_cash:     $", pc
push    {r1-r7,lr}
mov     r4,r1
mov     r6,r2

//--------------------------------
// Figure out how many digits we need
bl      .bin_to_bcd
mov     r5,r1
mov     r7,r1

// The window is 56 pixels wide:
// each digit uses 6 pixels, the $ sign uses 6, and the
// double-zero uses 8
mov     r2,#42 // = 56 - 6 - 8
lsl     r3,r1,#2
add     r3,r3,r1
add     r1,r1,r3 // r1 *= 6
sub     r1,r2,r1 // r1 = 42 - r1

// Store the control code to the output
mov     r2,#0x5F
strb    r2,[r4,#0]
mov     r2,#0xFF
strb    r2,[r4,#1]
strb    r1,[r4,#2]

// Store the dollar sign
mov     r2,#0x54
strb    r2,[r4,#3]
add     r4,r4,#4

// Store the digits to the output
mov     r2,#8
sub     r2,r2,r5
lsl     r2,r2,#2
lsl     r0,r2                // Now the number is pushed to the left of the register

-
lsr     r1,r0,#28            // Get the left-most digit
add     r1,#0x60             // Integer-to-char
strb    r1,[r4,#0]
add     r4,r4,#1
lsl     r0,r0,#4
sub     r5,r5,#1
bne     -

// Store the double-zero sign
mov     r1,#0x56
strb    r1,[r4,#0]

// Store the end code
mov     r1,#0
strb    r1,[r4,#1]
mov     r1,#0xFF
strb    r1,[r4,#2]

//--------------------------------
sub     r5,r6,r7
sub     r0,r5,#1
pop     {r1-r7,pc}


//==============================================================================
// void status1(int x, int y, char* str)
// In:
//    r2: x (pixel)
//    r3: y (pixel)
//    r1: str
//==============================================================================

.status1:
print   "m2formatting.status1:         $",pc
push    {r0-r2,lr}
mov     r0,r2
mov     r2,r1
mov     r1,r3
bl      m2_vwf.print_string
pop     {r0-r2,pc}


//==============================================================================
// void status_clear(WINDOW* window)
// In:
//    r10: window address
//==============================================================================

.status_clear:
print   "m2_formatting.status_clear:   $",pc

push    {r0-r4,lr}
ldr     r4,=#.status_clear_areas

//--------------------------------
.status_clear_loop:
ldrb    r0,[r4,#0]           // Top-left X
cmp     r0,#0xFF
beq     +
ldrb    r1,[r4,#1]           // Top-left Y
ldrb    r2,[r4,#2]           // Bottom-right X
ldrb    r3,[r4,#3]           // Bottom-right Y

//--------------------------------
-
bl      m2_vwf.erase_tile
add     r0,r0,#1
cmp     r0,r2
bls     -
ldrb    r0,[r4,#0]
add     r1,r1,#1
cmp     r1,r3
bls     -
add     r4,r4,#4
b       .status_clear_loop

//--------------------------------
+
pop     {r0-r4,pc}

//--------------------------------
.status_clear_areas:

db $05,$01,$06,$02 // Level
db $0C,$07,$0E,$0A // Current HP and PP
db $10,$07,$12,$0A // Max HP and PP
db $0C,$0B,$12,$0C // Exp
db $01,$0D,$07,$0E // Exp to next level
db $01,$0F,$1C,$10 // PSI info
db $19,$01,$1C,$0E // Stats
db $FF,$FF


//==============================================================================
// void status_redraw()
// In:
//    r5: #0x3005230
//==============================================================================

.status_redraw:
push    {r0-r7,lr}

//--------------------------------
// Call the clobbered code to redraw the old (broken) window,
// since we still need the borders
bl      $80BD7AC

//--------------------------------
// Clear the text area
ldr     r0,[r5,#0x18]        // Get the status window address
mov     r4,r0
bl      m2_vwf.clear_window

// Clear the map
bl      m2_vwf.clear_tilemap

//--------------------------------
// (Copying the code at $80B8308)
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

// I think this renders it
mov     r0,r4
bl      $80C8FFC

//--------------------------------
pop     {r0-r7,pc}