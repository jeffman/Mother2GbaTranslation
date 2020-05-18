REG_DISPCNT  equ 0x04000000 //Display Control, 16-bit
REG_DISPSTAT equ 0x04000004 //General LCD Status
REG_BG0CNT  equ 0x04000008 //BG0 Control
REG_IME  equ 0x04000208 //Interrupt Master Enable Register
REG_IE  equ 0x04000200 //Interrupt Enable Register
REG_IF  equ 0x04000202 //Interrupt Request Flags / IRQ Acknowledge
REG_BLDCNT  equ 0x04000050 //Color Special Effects Selection
REG_BLDY  equ 0x04000054 //Brightness Coefficient
VRAM equ 0x06000000 //Video RAM, 16-bit
BGCRAM equ 0x05000000 //BG Color RAM, 16-bit
REG_KEYINPUT  equ 0x04000130 //Key Status
LZ77UnCompVRAM equ #18

m12_intro_screen:
	push {r0-r4}
	ldr r0,=REG_DISPCNT
	mov r1,#0xFF
	add r1,r1,#1
	strh r1,[r0]

	ldr r0,=REG_DISPSTAT
	mov r1,#8
	strh r1,[r0]
	
	ldr r0,=REG_BG0CNT
	mov r1,#0x80
	strh r1,[r0]
	
	ldr r0,=REG_IME
	mov r1,#0x1
	strh r1,[r0]
	
	ldr r0,=REG_IE
	mov r1,#0x1
	strh r1,[r0]
	
	ldr r0,=REG_IF
	mov r1,#0x1
	strh r1,[r0]
	
	ldr r0,=REG_BLDCNT
	mov r1,#0xA1
	strh r1,[r0]
	
	ldr r0,=REG_BLDY
	mov r1,#16
	strh r1,[r0]
		
	ldr r0,=disclaimer_palette
	ldr r1,=BGCRAM
	ldr r4,=#159*2
	@@palette:
		ldrh r3,[r0,r5]
		strh r3,[r1,r5]
		add r5,#2
		cmp r5,r4
		bne @@palette

	ldr r2,=#0x100
	ldr r0,=disclaimer_map
	ldr r1,=VRAM
	ldr r4,=#1280
	@@map:
		sub r4,#2
		ldrh r3,[r0,r4]
		add r3,r2
		strh r3,[r1,r4]
		cmp r4,#0
		bne @@map

	ldr r0,=#disclaimer_graphics
	ldr r1,=VRAM+0x4000
	swi LZ77UnCompVRAM

	ldr r2,=REG_BLDCNT
	mov  r4,#0x10
	@@fadein:
		strh r4,[r2,#4]
		swi  #5
		swi  #5 // 15 loops with 2 intrs each gives a total fade-in time of 0.5 seconds
		sub  r4,#1
		bpl  @@fadein

	ldr  r2,=REG_KEYINPUT
	ldr  r4,=#0x3FF
	@@loop3:
		swi  #5 // VBlankIntrWait
		ldrh r0,[r2,#0]	
		cmp  r0,r4
		beq  @@loop3
	
	@@next:
		ldr r2,=REG_BLDCNT
		mov  r4,#0x00
		@@fadeout:
			strh r4,[r2,#4]
			swi  #5
			swi  #5 // 15 loops with 2 intrs each gives a total fade-in time of 0.5 seconds
			add  r4,#1
			cmp r4,#0x11
			bne @@fadeout
		
	mov r0,#0
	ldr r1,=BGCRAM
	ldr r4,=#74
	@@cpal:
		sub r4,#2
		strh r0,[r1,r4]
		cmp r4,#0
		bne @@cpal

	pop {r0-r4}
	push {lr}
	ldr r0,=#0x3007FFC
	str r1,[r0,#0]
	pop  {pc}
.pool
