//==============================================================================
// http://en.wikipedia.org/wiki/Double_dabble
// int bin_to_bcd(int binary)
// In:
//    r0: binary number
//    r1: out pointer; amount of digits used will be returned here
// Out:
//    r0: BCD-coded number
//==============================================================================

bin_to_bcd:

push    {r1-r7,lr}
mov     r2,r8
mov     r3,r9
push    {r2-r3}

lsl     r0,r0,5
mov     r1,0
mov     r3,27
mov     r4,3
lsl     r4,r4,8
lsl     r5,r4,4
lsl     r6,r5,4
lsl     r7,r6,12
mov     r9,r7
lsl     r7,r6,8
mov     r8,r7
lsl     r7,r6,4

//--------------------------------
@@prev:

// Ones
lsl     r2,r1,28
lsr     r2,r2,28
cmp     r2,5
bcc     @@next
add     r1,r1,3
@@next:

// Tens
lsl     r2,r1,24
lsr     r2,r2,28
cmp     r2,5
bcc     @@next2
add     r1,0x30
@@next2:

// Hundreds
lsl     r2,r1,20
lsr     r2,r2,28
cmp     r2,5
bcc     @@next3
add     r1,r1,r4
@@next3:

// Thousands
lsl     r2,r1,16
lsr     r2,r2,28
cmp     r2,5
bcc     @@next4
add     r1,r1,r5
@@next4:

// Ten-thousands
lsl     r2,r1,12
lsr     r2,r2,28
cmp     r2,5
bcc     @@next5
add     r1,r1,r6
@@next5:

// Hundred-thousands
lsl     r2,r1,8
lsr     r2,r2,28
cmp     r2,5
bcc     @@next6
add     r1,r1,r7
@@next6:

// Millions
lsl     r2,r1,4
lsr     r2,r2,28
cmp     r2,5
bcc     @@next7
add     r1,r8
@@next7:

// Ten-millions
lsr     r2,r2,28
cmp     r2,5
bcc     @@next8
add     r1,r9
@@next8:

// Shift
lsl     r1,r1,1
tst     r0,r0
bpl     @@next9
add     r1,r1,1
@@next9:
lsl     r0,r0,1
sub     r3,r3,1
bne     @@prev
mov     r0,r1

//--------------------------------
// Check how many digits are used
mov     r3,1
@@prev2:
lsr     r1,r1,4
beq     @@next10
add     r3,r3,1
b       @@prev2
@@next10:

//--------------------------------
mov     r1,r3
pop     {r2-r3}
mov     r8,r2
mov     r9,r3
pop     {r2}
str     r1,[r2]
pop     {r2-r7,pc}


//==============================================================================
// int bcd_to_bin(int bcd)
// In:
//    r0: BCD-coded number
// Out:
//    r0: binary number
//==============================================================================

bcd_to_bin:

push    {r1-r4,lr}
mov     r1,0
mov     r2,10
mov     r3,1

//--------------------------------
// Ones
lsl     r4,r0,28
lsr     r4,r4,28
mul     r4,r3
add     r1,r1,r4
mul     r3,r2

// Tens
lsl     r4,r0,24
lsr     r4,r4,28
mul     r4,r3
add     r1,r1,r4
mul     r3,r2

// Hundreds
lsl     r4,r0,20
lsr     r4,r4,28
mul     r4,r3
add     r1,r1,r4
mul     r3,r2

// Thousands
lsl     r4,r0,16
lsr     r4,r4,28
mul     r4,r3
add     r1,r1,r4
mul     r3,r2

// Ten-thousands
lsl     r4,r0,12
lsr     r4,r4,28
mul     r4,r3
add     r1,r1,r4
mul     r3,r2

// Hundred-thousands
lsl     r4,r0,8
lsr     r4,r4,28
mul     r4,r3
add     r1,r1,r4
mul     r3,r2

// Millions
lsl     r4,r0,4
lsr     r4,r4,28
mul     r4,r3
add     r1,r1,r4
mul     r3,r2

// Ten-millions
lsr     r4,r0,28
mul     r4,r3
add     r1,r1,r4

//--------------------------------
mov     r0,r1
pop     {r1-r4,pc}
