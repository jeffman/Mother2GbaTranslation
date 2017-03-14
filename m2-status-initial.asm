// Level
org     $80C0BAE
mov     r0,#5
mov     r1,#1
mov     r2,#3
bl      m2_vwf.print_blankstr
mov     r3,#6
mul     r3,r4
mov     r2,#56
sub     r2,r2,r3

org     $80C0BC6
mov     r3,#8
bl      m2_vwf_entries.c0a5c_printstr

// Max HP
org     $80C0C06
mov     r0,#0x10
mov     r1,#7
mov     r2,#3
bl      m2_vwf.print_blankstr
mov     r5,#6
mul     r4,r5
mov     r5,#147
sub     r4,r5,r4

org     $80C0C20
mov     r3,#56
bl      m2_vwf_entries.c0a5c_printstr

// Current HP
org     $80C0C62
mov     r0,#0xC
mov     r1,#7
mov     r2,#3
bl      m2_vwf.print_blankstr
mov     r5,#6
mul     r4,r5
mov     r5,#120
sub     r4,r5,r4

org     $80C0C7C
mov     r3,#56
bl      m2_vwf_entries.c0a5c_printstr

// Max PP
org     $80C0CBE
mov     r0,#0x10
mov     r1,#9
mov     r2,#3
bl      m2_vwf.print_blankstr
mov     r0,#6
mul     r4,r0
mov     r0,#147
sub     r4,r0,r4

org     $80C0CD8
mov     r3,#72
bl      m2_vwf_entries.c0a5c_printstr

// Current PP
org     $80C0D1A
mov     r0,#0xC
mov     r1,#9
mov     r2,#3
bl      m2_vwf.print_blankstr
mov     r5,#6
mul     r4,r5
mov     r5,#120

org     $80C0D30
sub     r2,r5,r4
mov     r3,#72
bl      m2_vwf_entries.c0a5c_printstr

// Total exp
org     $80C0D78
mov     r0,#0xC
mov     r1,#0xB
mov     r2,#7
bl      m2_vwf.print_blankstr
mov     r1,#6
mul     r4,r1
mov     r1,#147
sub     r4,r1,r4

org     $80C0D92
mov     r3,#88
bl      m2_vwf_entries.c0a5c_printstr

// Exp to next level
org     $80C0DF8
mov     r0,#2
mov     r1,#0xD
mov     r2,#6
bl      m2_vwf.print_blankstr
mov     r3,#6
mul     r4,r3
mov     r3,#61
sub     r4,r3,r4

org     $80C0E12
mov     r3,#104
bl      m2_vwf_entries.c0a5c_printstr

org     $80C0E38
mov     r0,#2
mov     r1,#0xD
mov     r2,#6
bl      m2_vwf.print_blankstr

// Offense
org     $80C0E86
mov     r0,#0x19
mov     r1,#1
mov     r2,#4
bl      m2_vwf.print_blankstr
mov     r6,#6
mul     r4,r6
mov     r6,#225
sub     r4,r6,r4

org     $80C0EA0
mov     r3,#8
bl      m2_vwf_entries.c0a5c_printstr

// Defense
org     $80C0EE0
mov     r0,#0x19
mov     r1,#3
mov     r2,#4
bl      m2_vwf.print_blankstr
mov     r2,#6
mul     r4,r2
sub     r4,r6,r4

org     $80C0EF8
mov     r3,#24
bl      m2_vwf_entries.c0a5c_printstr

// Speed
org     $80C0F38
mov     r0,#0x19
mov     r1,#5
mov     r2,#4
bl      m2_vwf.print_blankstr
mov     r2,#6
mul     r4,r2
sub     r4,r6,r4

org     $80C0F50
mov     r3,#40
bl      m2_vwf_entries.c0a5c_printstr

// Guts
org     $80C0F90
mov     r0,#0x19
mov     r1,#7
mov     r2,#4
bl      m2_vwf.print_blankstr
mov     r2,#6
mul     r4,r2
sub     r4,r6,r4

org     $80C0FA8
mov     r3,#56
bl      m2_vwf_entries.c0a5c_printstr

// Vitality
org     $80C0FE8
mov     r0,#0x19
mov     r1,#9
mov     r2,#4
bl      m2_vwf.print_blankstr
mov     r2,#6
mul     r4,r2
sub     r4,r6,r4

org     $80C1000
mov     r3,#72
bl      m2_vwf_entries.c0a5c_printstr

// IQ
org     $80C1040
mov     r0,#0x19
mov     r1,#0xB
mov     r2,#4
bl      m2_vwf.print_blankstr
mov     r2,#6
mul     r4,r2
sub     r4,r6,r4

org     $80C1058
mov     r3,#88
bl      m2_vwf_entries.c0a5c_printstr

// Luck
org     $80C1098
mov     r0,#0x19
mov     r1,#0xD
mov     r2,#4
bl      m2_vwf.print_blankstr
mov     r2,#6
mul     r4,r2
sub     r6,r6,r4

org     $80C10B0
mov     r3,#104
bl      m2_vwf_entries.c0a5c_printstr

// Press A for PSI info
org     $80C10C0
bl      m2_vwf_entries.c0a5c_psi_info_blank
b       $80C10FA

org     $80C10F2
mov     r2,#44
mov     r3,#120
bl      m2_vwf_entries.c0a5c_printstr

// Ailment
org     $80C10FE
mov     r0,#1
mov     r1,#3
mov     r2,#10
bl      m2_vwf.print_blankstr
b       $80C1116
