// Level
.org    0x80C1392
mov     r0,5
mov     r1,1
mov     r2,3
bl      print_blankstr
mov     r3,6
mul     r3,r4
mov     r2,56
sub     r2,r2,r3

.org    0x80C13AA
mov     r3,8
bl      c0a5c_printstr

// Max HP
.org    0x80C13EC
mov     r0,0x10
mov     r1,7
mov     r2,3
bl      print_blankstr
mov     r3,6
mul     r4,r3
mov     r3,147
sub     r4,r3,r4

.org    0x80C1406
mov     r3,56
bl      c0a5c_printstr

// Current HP
.org    0x80C1448
mov     r0,0xC
mov     r1,7
mov     r2,3
bl      print_blankstr
mov     r3,6
mul     r4,r3
mov     r3,120
sub     r4,r3,r4

.org    0x80C1462
mov     r3,56
bl      c0a5c_printstr

// Max PP
.org    0x80C14A4
mov     r0,0x10
mov     r1,9
mov     r2,3
bl      print_blankstr
mov     r0,6
mul     r4,r0
mov     r0,147
sub     r4,r0,r4

.org    0x80C14BE
mov     r3,72
bl      c0a5c_printstr

// Current PP
.org    0x80C1500
mov     r0,0xC
mov     r1,9
mov     r2,3
bl      print_blankstr
mov     r3,6
mul     r4,r3
mov     r3,120

.org    0x80C1516
sub     r2,r3,r4
mov     r3,72
bl      c0a5c_printstr

// Total exp
.org    0x80C1560
mov     r0,0xC
mov     r1,0xB
mov     r2,7
bl      print_blankstr
mov     r1,6
mul     r4,r1
mov     r1,147
sub     r4,r1,r4

.org    0x80C157A
mov     r3,88
bl      c0a5c_printstr

// Exp to next level
.org    0x80C15E2
mov     r0,2
mov     r1,0xD
mov     r2,6
bl      print_blankstr
mov     r0,6
mul     r4,r0
mov     r0,61
sub     r4,r0,r4

.org    0x80C15FC
mov     r3,104
bl      c0a5c_printstr

.org    0x80C1624
mov     r0,2
mov     r1,0xD
mov     r2,6
bl      print_blankstr

// Offense
.org    0x80C1672
mov     r0,0x19
mov     r1,1
mov     r2,4
bl      print_blankstr
mov     r6,6
mul     r4,r6
mov     r6,225
sub     r4,r6,r4

.org    0x80C168C
mov     r3,8
bl      c0a5c_printstr

// Defense
.org    0x80C16CC
mov     r0,0x19
mov     r1,3
mov     r2,4
bl      print_blankstr
mov     r2,6
mul     r4,r2
sub     r4,r6,r4

.org    0x80C16E4
mov     r3,24
bl      c0a5c_printstr

// Speed
.org    0x80C1724
mov     r0,0x19
mov     r1,5
mov     r2,4
bl      print_blankstr
mov     r2,6
mul     r4,r2
sub     r4,r6,r4

.org    0x80C173C
mov     r3,40
bl      c0a5c_printstr

// Guts
.org    0x80C177C
mov     r0,0x19
mov     r1,7
mov     r2,4
bl      print_blankstr
mov     r2,6
mul     r4,r2
sub     r4,r6,r4

.org    0x80C1794
mov     r3,56
bl      c0a5c_printstr

// Vitality
.org    0x80C17D4
mov     r0,0x19
mov     r1,9
mov     r2,4
bl      print_blankstr
mov     r2,6
mul     r4,r2
sub     r4,r6,r4

.org    0x80C17EC
mov     r3,72
bl      c0a5c_printstr

// IQ
.org    0x80C182C
mov     r0,0x19
mov     r1,0xB
mov     r2,4
bl      print_blankstr
mov     r2,6
mul     r4,r2
sub     r4,r6,r4

.org    0x80C1844
mov     r3,88
bl      c0a5c_printstr

// Luck
.org    0x80C1884
mov     r0,0x19
mov     r1,0xD
mov     r2,4
bl      print_blankstr
mov     r2,6
mul     r4,r2
sub     r6,r6,r4

.org    0x80C189C
mov     r3,104
bl      c0a5c_printstr

// Press A for PSI info
.org    0x80C18AC
bl      c0a5c_psi_info_blank
b       0x80C18E2

.org    0x80C18DA
mov     r2,44
mov     r3,120
bl      c0a5c_printstr

// Ailment
.org    0x80C18E2
mov     r0,1
mov     r1,3
mov     r2,10
bl      print_blankstr
b       0x80C18FA
