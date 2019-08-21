//==============================================================================
//Writes the bigfont letters to RAM
largevwf:
push    {r5,lr}
mov     r0,r2
ldrb    r1,[r4]
add     r4,r4,1
ldr     r2,=m2_widths_big
cmp     r1,#0xFC //0xFC to 0xFF are used by us to print the party's names
bge     @@name
ldrb    r2,[r2,r1]
bl      0x80B3280 //Print the letter to RAM

@@end:
pop     {r5,pc}

@@name:
mov     r5,#0xFC
sub     r1,r1,r5
ldr     r3,=#m2_ness_name //Base name address
lsl     r5,r1,#3
sub     r5,r5,r1 //Get index * 7 to get the name's address
add     r3,r3,r5
mov     r5,r2 //r5 now has m2_widths_big
mov     r1,#0

@@name_loading_cycle:
ldrb    r2,[r3,#1]
cmp     r2,#0xFF //Does the name end? (00 FF)
beq     @@end
push    {r0-r3}
ldrb    r2,[r3,#0] //If not, render the letter (So real letter - 80)
mov     r1,#80
sub     r1,r2,r1
ldrb    r2,[r5,r1]
bl      0x80B3280 //Print the letter to RAM
pop     {r0-r3}
add     r3,#1
add     r1,#1
cmp     r1,#5 //Maximum name length, has it been reached? If not, continue printing
bne     @@name_loading_cycle
b       @@end

.pool

//==============================================================================
//Weld the odd-numbered flyover letters
flyoverweld:
push    {r5-r7,lr}
add     r1,r1,r3
ldrb    r0,[r1] //Load the width of the letter that has to be weld
ldr     r5,=#0x30051D4
ldr     r5,[r5]
mov     r6,#0x90
lsl     r6,r6,#6
add     r5,r5,r6
ldrh    r5,[r5] //Load the current X in pixels
mov     r6,#1
and     r5,r6
cmp     r5,#1 //Is it even?
bne     @@even

ldrb    r5,[r4] //If not, load the first nibble of the current width that is in r4
mov     r6,#0xF
and     r5,r6
lsl     r6,r0,#4
orr     r5,r6 //Add 0xF0 to it
mov     r6,#0xFF
and     r5,r6 //Make sure it stays in one byte
strb    r5,[r4] //Store it

mov     r7,r4
mov     r6,#3
and     r7,r6
cmp     r7,#3 //Do r4's bits end with a 3?
bne     @@old
mov     r7,r4 //If they do, make r7 = r4 + 0x1C
add     r7,#0x1C
b       @@ok

@@old: //If they do not, make r7 = r4
mov     r7,r4

@@ok:
ldrb    r5,[r7,#1]
mov     r6,#0xF0
and     r5,r6 //Get the second nibble of what is in r7 + 1
lsr     r6,r0,#4
orr     r5,r6 //Make the first nibble 0xF
strb    r5,[r7,#1] //Store it back in r7 + 1
b       @@end

@@even: //If it is, store the width in r4
strb    r0,[r4]

@@end:
pop     {r5-r7,pc}

.pool

//.org 0x80c4c0c 
//.byte 0x20,0x1C,0x51,0x46,0x2A,0x22


//0x80B3256 