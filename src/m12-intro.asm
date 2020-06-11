REG_BASE  equ 0x04000000 //Display Control, 16-bit
REG_DISPSTAT equ 0x4 //General LCD Status
REG_BG0CNT  equ 0x8 //BG0 Control
REG_IME  equ 0x208 //Interrupt Master Enable Register
REG_IE  equ 0x200 //Interrupt Enable Register
REG_IF  equ 0x202 //Interrupt Request Flags / IRQ Acknowledge
REG_BLDCNT  equ 0x50 //Color Special Effects Selection
REG_BLDY  equ 0x54 //Brightness Coefficient
VRAM equ 0x06000000 //Video RAM, 16-bit
BGCRAM equ 0x05000000 //BG Color RAM, 16-bit
REG_KEYINPUT  equ 0x130 //Key Status
LZ77UnCompVRAM equ #18
RegisterRamReset equ 1

m12_intro_screen:
	push {r0-r5}
	ldr r4,=REG_BASE
	ldr r0,=#0x100
	strh r0,[r4]
	
	mov r0,#8
	strh r0,[r4,#REG_DISPSTAT]
	
	mov r0,#0x80
	strh r0,[r4,#REG_BG0CNT]
	
	mov r0,#1
	ldr r1,=#REG_IME
	strh r0,[r4,r1]
	ldr r1,=#REG_IE
	strh r0,[r4,r1]
	ldr r1,=#REG_IF
	strh r0,[r4,r1]
	
	mov r0,#0xA1
	ldr r1,=#REG_BLDCNT
	strh r0,[r4,r1]
	
	mov r0,#16
	ldr r1,=#REG_BLDY
	strh r0,[r4,r1]
	
	ldr r0,=disclaimer_palette
	ldr r1,=BGCRAM
	ldr r2,=#256*2
	@@palette:
		ldrh r3,[r0,r5]
		strh r3,[r1,r5]
		add r5,#2
		cmp r5,r2
		bne @@palette
		
	ldr r2,=#0x100
	ldr r0,=disclaimer_map
	ldr r1,=VRAM
	ldr r5,=#1280
	@@map:
		sub r5,#2
		ldrh r3,[r0,r5]
		add r3,r2
		strh r3,[r1,r5]
		cmp r5,#0
		bne @@map
		
	ldr r0,=#disclaimer_graphics
	ldr r1,=VRAM+0x4000
	swi LZ77UnCompVRAM
	
	ldr r5,=REG_BLDY
	mov r2,#0x10
	@@fadein:
		strh r2,[r4,r5]
		sub r2,#1
		swi 5
		swi 5
		cmp r2,#0
		bne @@fadein
	
	ldr  r5,=REG_KEYINPUT
	ldr  r2,=#0x3FF
	@@keywait:
		swi  #5 // VBlankIntrWait
		ldrh r0,[r4,r5]	
		cmp  r0,r2
		beq  @@keywait
	
	ldr r5,=REG_BLDY
	mov r2,#0x0
	@@fadeout:
		strh r2,[r4,r5]
		add r2,#1
		swi 5
		swi 5
		cmp r2,#0x10
		bne @@fadeout
	
	mov r0,0b0011000
	swi RegisterRamReset
	
	pop {r0-r5}
	push {lr}
	ldr r0,=#0x3007FFC
	str r1,[r0,#0]
	pop  {pc}
.pool
