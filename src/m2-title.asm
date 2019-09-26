// r3 has 2028008
// [r3+14] has 2028028
// [2028028+10] has pointer to our palette buffer, 0x200 bytes after which
//              we have some free space to use for things
//              Let's allocate some variables:
//                  +0x00:  Sequence 01 -- initial delay flag

//---------------------------------------------------------
title_return:
ldr     r0,=0x8011B8C
mov     pc,r0

//---------------------------------------------------------
// In:  r0 = pointer to pointer to little struct
// Out: r0 = pointer to our buffer area (0x2011B60)
title_get_buffer:
push    {r1,lr}
ldr     r0,[r0]
ldr     r1,[r0,0x14]
ldr     r0,[r1,0x10]
ldr     r1,=0x200
add     r0,r0,r1
pop     {r1,pc}

//---------------------------------------------------------
title_sequence_00:

// Normally the game enables BG0 in sequence 8, but we want
// it enabled from the start so copy that code to here
push    {r3}
mov     r1,r9
add     r1,0x78
mov     r0,0x88
lsl     r0,r0,5
strh    r0,[r1]

// Copy static palette to BG pal 8
ldr     r3,[r3]
ldr     r3,[r3,0x14]
ldr     r1,=0x40000D4
ldr     r2,[r3,0xC]         // m2_title_text_pal_static
str     r2,[r1]
ldr     r0,=0x5000100
str     r0,[r1,4]
ldr     r0,=0x84000008
str     r0,[r1,8]
ldr     r0,[r1,8]
pop     {r3}

// Return to old sequence 0 code
ldr     r0,=m2_title_sequence_00
mov     pc,r0

//---------------------------------------------------------
title_sequence_01:

// EB has a 38 frame delay between starting the music
// and starting the fade-in
mov     r0,r3
bl      title_get_buffer

// Check if we've set our delay flag yet
ldr     r1,[r0]
cmp     r1,0
beq     @@unset

    @@set:

        // Skip our code and return to the old sequence 1 code
        ldr     r0,=m2_title_sequence_01
        mov     pc,r0

    @@unset:

        // Count to 0x26 before starting the fade-in
        ldr     r3,[r3]
        ldr     r1,[r3,4]
        cmp     r1,0x26
        bge     @@unset_start_fade
        b       @@end

        @@unset_start_fade:
        mov     r1,0
        str     r1,[r3,4]
        mov     r1,1
        str     r1,[r0]

@@end:
b       title_return

//---------------------------------------------------------
title_sequence_04:

// Just need to reset the frame counter
ldr     r2,[r3]
mov     r0,1
neg     r0,r0           // This gets incremented before calling the sequence subroutines,
                        // and we want it to be 0 on the first frame for sequence 5,
                        // so start it at -1
str     r0,[r2,4]

ldr     r0,=m2_title_sequence_04
mov     pc,r0

//---------------------------------------------------------
title_sequence_05:

push    {r4}
ldr     r3,[r3]
mov     r4,r3
ldr     r0,[r4,4]       // frame number

// Frame 0-1: inverted colours
cmp     r0,1
bhi     @@next1

    // Only change the palette on frame 0
    cmp     r0,1
    beq     @@advance_frame

    @@inverted:

        // Load inverted BG palettes
        // (all white for BG pal 0-7,
        // all black for BG pal 8-F)
        ldr     r1,=0x40000D4
        mov     r2,1
        neg     r2,r2
        push    {r2}
        mov     r2,sp
        str     r2,[r1]
        ldr     r0,=0x5000000
        str     r0,[r1,4]
        ldr     r0,=0x85000040
        str     r0,[r1,8]
        ldr     r0,[r1,8]
        mov     r2,0
        str     r2,[sp]
        mov     r2,sp
        str     r2,[r1]
        ldr     r0,=0x5000100
        str     r0,[r1,4]
        ldr     r0,=0x85000040
        str     r0,[r1,8]
        ldr     r0,[r1,8]
        pop     {r2}
        b       @@advance_frame

@@next1:
// Frame 2-29: animated text, 2 frames per palette change
cmp     r0,29
bhi     @@next2

    // Only change palette on the even frames
    sub     r0,2
    lsl     r1,r0,0x1F
    bmi     @@advance_frame

    // On frame 2, we need to reset BG pal 0-7 to black
    cmp     r0,0
    bne     @@skip_black_palettes
    ldr     r1,=0x40000D4
    push    {r0}
    mov     r2,sp
    str     r2,[r1]
    ldr     r2,=0x5000000
    str     r2,[r1,4]
    ldr     r2,=0x85000040
    str     r2,[r1,8]
    ldr     r2,[r1,8]
    add     sp,4

    @@skip_black_palettes:
    // Get source palette address
    ldr     r3,[r3,0x14]
    ldr     r1,[r3,8]           // m2_title_text_pal_animated
    lsl     r0,r0,4
    add     r0,r0,r1

    // Copy to BG pal 8
    ldr     r1,=0x40000D4
    str     r0,[r1]
    ldr     r0,=0x5000100
    str     r0,[r1,4]
    ldr     r0,=0x84000008
    str     r0,[r1,8]
    ldr     r0,[r1,8]
    b       @@advance_frame

@@next2:
// For now let's just go to the next sequence, not sure what to do next yet
mov     r0,0
str     r0,[r4,4]
mov     r0,6
ldr     r1,[r4,0x14]
add     r1,0x84
str     r0,[r1]
pop     {r4}
b       title_return

@@advance_frame:
pop     {r4}
ldr     r0,[r4,4]
add     r0,1
str     r0,[r4,4]
b       title_return

.pool
