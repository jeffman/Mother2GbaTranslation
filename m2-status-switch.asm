// Status window: level
org $80C139C
mov     r3,#6
mul     r3,r4
mov     r2,#56
sub     r2,r2,r3

org $80C13AA
mov     r3,#8
bl      m2_formatting.status1

// Status window: max HP
org $80C13F6
mov     r5,#6
mul     r4,r5
mov     r5,#147
sub     r4,r5,r4

org $80C1406
mov     r3,#56
bl      m2_formatting.status1

// Status window: current HP
org $80C1452
mov     r5,#6
mul     r4,r5
mov     r5,#120
sub     r4,r5,r4

org $80C1462
mov     r3,#56
bl      m2_formatting.status1

// Status window: max PP
org $80C14AE
mov     r0,#6
mul     r4,r0
mov     r0,#147
sub     r4,r0,r4
org $80C14BE
mov     r3,#72
bl      m2_formatting.status1

// Status window: current PP
org $80C150A
mov     r3,#6
mul     r4,r3
mov     r3,#120

org $80C1516
sub     r2,r3,r4
mov     r3,#72
bl      m2_formatting.status1

// Status window: total exp
org $80C156A
mov     r1,#6
mul     r4,r1
mov     r1,#147
sub     r4,r1,r4

org $80C157A
mov     r3,#88
bl      m2_formatting.status1

// Status window: exp to next level
org $80C15EC
mov     r0,#6
mul     r4,r0
mov     r0,#61
sub     r4,r0,r4

org $80C15FC
mov     r3,#104
bl      m2_formatting.status1

// Status window: offense
org $80C167C
mov     r6,#6
mul     r4,r6
mov     r6,#225
sub     r4,r6,r4

org $80C168C
mov     r3,#8
bl      m2_formatting.status1

// Status window: defense
org $80C16D6
mov     r2,#6
mul     r4,r2
sub     r4,r6,r4

org $80C16E4
mov     r3,#24
bl      m2_formatting.status1

// Status window: speed
org $80C172E
mov     r2,#6
mul     r4,r2
sub     r4,r6,r4

org $80C173C
mov     r3,#40
bl      m2_formatting.status1

// Status window: guts
org $80C1786
mov     r2,#6
mul     r4,r2
sub     r4,r6,r4

org $80C1794
mov     r3,#56
bl      m2_formatting.status1

// Status window: vitality
org $80C17DE
mov     r2,#6
mul     r4,r2
sub     r4,r6,r4

org $80C17EC
mov     r3,#72
bl      m2_formatting.status1

// Status window: IQ
org $80C1836
mov     r2,#6
mul     r4,r2
sub     r4,r6,r4

org $80C1844
mov     r3,#88
bl      m2_formatting.status1

// Status window: Luck
org $80C188E
mov     r2,#6
mul     r4,r2
sub     r6,r6,r4

org $80C189C
mov     r3,#104
bl      m2_formatting.status1

// Status window: Press A for PSI info
org $80C18DA
mov     r2,#44
mov     r3,#120
bl      m2_formatting.status1

org $80C1398; bl m2_formatting.status_clear
org $80C13F2; nop; nop // spaces
org $80C144E; nop; nop // spaces
org $80C14AA; nop; nop // spaces
org $80C1506; nop; nop // spaces
org $80C1566; nop; nop // spaces
org $80C15E8; nop; nop // spaces
org $80C162A; nop; nop // ?
org $80C1678; nop; nop // spaces
org $80C16D2; nop; nop // spaces
org $80C172A; nop; nop // spaces
org $80C17DA; nop; nop // spaces
org $80C1832; nop; nop // spaces
org $80C188A; nop; nop // spaces
org $80C1782; nop; nop
org $80C11AC; nop; nop
org $80C11D2; nop; nop