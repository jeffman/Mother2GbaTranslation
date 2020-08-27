//==============================================================================
//Fixes the issue where Gyigas and other enemies would not use their death attack
//(or phase change) because of the poison
dee6c_fix_poison_gyigas:
push    {lr}

bl      0x80E9CFC //Normal code

ldr     r2,=#0x2024860 //Where the action's data is stored
ldr     r0,[r6,#0] //Load the entity's slot
add     r0,#0x44
ldrh    r1,[r0,#0]
cmp     r1,#0
beq     @@normal //Characters have this set as 0
cmp     r1,#0xDA //This particular Gyigas phase does not need this... (It will reflect the poison randomly if we let it continue)
beq     @@normal
ldrh    r1,[r0,#4] // Get the enemy's current HP
cmp     r1,#0 //Check if they're 0
bne     @@normal
ldrh    r1,[r0,#6] // Get the enemy's scrolling HP
cmp     r1,#0 //Check if they're 0 (probably not needed)
bne     @@normal
mov     r0,#0x9 //Fabricate a death check for the enemy
add     r2,#0x16
strh    r0,[r2,#0]
mov     r0,#0
strh    r0,[r2,#4]
mov     r0,#4 //This counts as a PSI, since setting it as a normal attack would make it so the Diamond Dog would reflect it
strh    r0,[r2,#6]
add     r2,#0xC
strh    r0,[r2,#0x6]
mov     r0,#1
strh    r0,[r2,#4]
mov     r0,#0
strh    r0,[r2,#0]
add     r2,#0x24
strh    r0,[r2,#0]
strh    r0,[r2,#0x12]
ldr     r2,=#0x2025034
mov     r0,#1
strh    r0,[r2,#0] //This is a PSI. Not a physical attack
ldr     r0,=#0x3005378
mov     r1,#0xC //This is PSI Cool Thing
strh    r1,[r0,#0]
mov     r1,#0
strh    r1,[r0,#0x10]
b       @@end

@@normal:
mov     r0,#0x64 //Normal game's behaviour
strh    r0,[r2,#0x16]

@@end:
pop     {pc}


//==============================================================================