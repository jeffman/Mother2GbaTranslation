m2_vwf:

//==============================================================================
// int get_tile_number(int x, int y)
//    In:
//        r0: x
//        r1: y
//    Out:
//        r0: tile number
//==============================================================================

.get_tile_number:
print   "m2vwf.get_tile_number:        $",pc

push    {r1-r5,lr}
ldr     r4,=#m2_coord_table
sub     r0,r0,#1
sub     r1,r1,#1
lsl     r2,r1,#0x1F
lsr     r2,r2,#0x1F
lsr     r1,r1,#1
lsl     r5,r1,#4
sub     r5,r5,r1
sub     r5,r5,r1
lsl     r5,r5,#2
lsl     r0,r0,#1
add     r4,r4,r0
add     r4,r4,r5
ldrh    r0,[r4,#0]
lsl     r2,r2,#5
add     r0,r0,r2
pop     {r1-r5,pc}
