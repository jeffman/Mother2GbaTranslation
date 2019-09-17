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
// r0 = pointer to pointer little struct
title_get_buffer:
push    {r1,lr}
ldr     r0,[r0]
ldr     r1,[r0,0x14]
ldr     r0,[r1,0x10]
ldr     r1,=0x200
add     r0,r0,r1
pop     {r1,pc}

//---------------------------------------------------------
title_sequence_01:

// EB has a 38 frame delay between starting the music
// and starting the fade-in
push    {r0-r1}
mov     r0,r3
bl      title_get_buffer

// Check if we've set our delay flag yet
ldr     r1,[r0]
cmp     r1,0
beq     @@unset

    @@set:
    // Count to 3 like before
    ldr     r3,[r3]
    ldr     r0,[r3,4]
    cmp     r0,2
    bgt     @@next_fade
    b       @@end
    @@next_fade:
    mov     r1,r9
    add     r1,0x7C
    ldrh    r0,[r1]
    sub     r0,1
    mov     r2,0
    strh    r0,[r1]
    str     r2,[r3,4]
    ldrh    r0,[r1]
    cmp     r0,0
    beq     @@fade_done
    b       @@end
    @@fade_done:
    mov     r0,2
    mov     r4,r10
    str     r0,[r4]
    b       @@end

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
pop     {r0-r1}
b       title_return

.pool
