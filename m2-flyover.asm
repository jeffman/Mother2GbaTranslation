
largevwf:
	push {lr}
	mov r0,r2
	ldrb r1,[r4]
	add r4,r4,1
	ldr r2,=m2_widths_big
	ldrb r2,[r2,r1]
	bl 0x80B3280
	pop {pc}
	
.pool

flyoverweld:
    push {r5-r7,lr}
	add r1,r1,r3
	ldrb r0,[r1]
	ldr r5,=#0x30051D4
	ldr r5,[r5]
	mov r6,#0x90
	lsl r6,r6,#6
	add r5,r5,r6
	ldrh r5,[r5]
	mov r6,#1
	and r5,r6
	cmp r5,#1
	bne @@even
	
	ldrb r5,[r4]
	mov r6,#0xF
	and r5,r6
	lsl r6,r0,#4
	orr r5,r6
	mov r6,#0xFF
	and r5,r6
	strb r5,[r4]
	
	mov r7,r4
	mov r6,#3
	and r7,r6
	cmp r7,#3
	bne @@old
	mov r7,r4
	add r7,#0x1C
	b @@ok
	
@@old:
	mov r7,r4
	
@@ok:
	ldrb r5,[r7,#1]
	mov r6,#0xF0
	and r5,r6
	lsr r6,r0,#4
	orr r5,r6
	strb r5,[r7,#1]
	b @@end
	
@@even:
	strb r0,[r4]

@@end:
	pop {r5-r7,pc}
	
.pool

//.org 0x80c4c0c 
//.byte 0x20,0x1C,0x51,0x46,0x2A,0x22


//0x80B3256 