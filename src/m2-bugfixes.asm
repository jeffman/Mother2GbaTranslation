//==============================================================================
//Fixes the issue where Gyigas could take damage from poison
dee6c_fix_poison_gyigas:
push    {lr}
add     r0,#0x44
ldrh    r0,[r0,#0] // Get the enemy's identifier
lsr     r1,r0,#3 // Divide it by 8
lsl     r2,r1,#3
sub     r0,r0,r2 // Get the division's rest
ldr     r2,=#status_damage_table
add     r2,r2,r1
ldrb    r1,[r2,#0] // Get the byte that contains this entity's data
mov     r2,#1
lsl     r2,r0
and     r2,r1 // If this is not 0, the enemy shouldn't take damage
cmp     r2,#0
bne     @@end

ldr     r0,[r6,#0] // Proceed normally
mov     r1,r4
bl      0x80E9CFC

@@end:
pop     {pc}


//==============================================================================