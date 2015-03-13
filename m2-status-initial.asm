// Status window: level
org $80C0BB8
mov     r3,#6
mul     r3,r4
mov     r2,#56
sub     r2,r2,r3

org $80C0BC6
mov     r3,#8
bl      m2_formatting.status1

// Status window: max HP
org $80C0C10
mov     r5,#6
mul     r4,r5
mov     r5,#147
sub     r4,r5,r4

org $80C0C20
mov     r3,#56
bl      m2_formatting.status1

// Status window: current HP
org $80C0C6C
mov     r5,#6
mul     r4,r5
mov     r5,#120
sub     r4,r5,r4

org $80C0C7C
mov     r3,#56
bl      m2_formatting.status1

// Status window: max PP
org $80C0CC8
mov     r0,#6
mul     r4,r0
mov     r0,#147
sub     r4,r0,r4

org $80C0CD8
mov     r3,#72
bl      m2_formatting.status1

// Status window: current PP
org $80C0D24
mov     r5,#6
mul     r4,r5
mov     r5,#120

org $80C0D30
sub     r2,r5,r4
mov     r3,#72
bl      m2_formatting.status1

// Status window: total exp
org $80C0D82
mov     r1,#6
mul     r4,r1
mov     r1,#147
sub     r4,r1,r4

org $80C0D92
mov     r3,#88
bl      m2_formatting.status1

// Status window: exp to next level
org $80C0E02
mov     r3,#6
mul     r4,r3
mov     r3,#61
sub     r4,r3,r4

org $80C0E12
mov     r3,#104
bl      m2_formatting.status1

// Status window: offense
org $80C0E90
mov     r6,#6
mul     r4,r6
mov     r6,#225
sub     r4,r6,r4

org $80C0EA0
mov     r3,#8
bl      m2_formatting.status1

// Status window: defense
org $80C0EEA
mov     r2,#6
mul     r4,r2
sub     r4,r6,r4

org $80C0EF8
mov     r3,#24
bl      m2_formatting.status1

// Status window: speed
org $80C0F42
mov     r2,#6
mul     r4,r2
sub     r4,r6,r4

org $80C0F50
mov     r3,#40
bl      m2_formatting.status1

// Status window: guts
org $80C0F9A
mov     r2,#6
mul     r4,r2
sub     r4,r6,r4

org $80C0FA8
mov     r3,#56
bl      m2_formatting.status1

// Status window: vitality
org $80C0FF2
mov     r2,#6
mul     r4,r2
sub     r4,r6,r4

org $80C1000
mov     r3,#72
bl      m2_formatting.status1

// Status window: IQ
org $80C104A
mov     r2,#6
mul     r4,r2
sub     r4,r6,r4

org $80C1058
mov     r3,#88
bl      m2_formatting.status1

// Status window: Luck
org $80C10A2
mov     r2,#6
mul     r4,r2
sub     r6,r6,r4

org $80C10B0
mov     r3,#104
bl      m2_formatting.status1

// Status window: Press A for PSI info
org $80C10F2
mov     r2,#44
mov     r3,#120
bl      m2_formatting.status1

org $80C0BB4; bl m2_formatting.status_clear
org $80C0C0C; nop; nop // spaces
org $80C0C68; nop; nop // spaces
org $80C0CC4; nop; nop // spaces
org $80C0D20; nop; nop // spaces
org $80C0D7E; nop; nop // spaces
org $80C0DFE; nop; nop // spaces
org $80C06F0; nop; nop // ?
org $80C0E8C; nop; nop // spaces
org $80C0EE6; nop; nop // spaces
org $80C0F3E; nop; nop // spaces
org $80C0F96; nop; nop // spaces
org $80C0FEE; nop; nop // spaces
org $80C1046; nop; nop // spaces
org $80C109E; nop; nop // spaces
org $80C1112; nop; nop
org $80C11AC; nop; nop
org $80C11D2; nop; nop