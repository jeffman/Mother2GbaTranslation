arch gba.thumb
incsrc m12-main-strings.asm
incsrc m12-itemnames.asm
incsrc m12-misctext.asm
incsrc m12-psitext.asm
incsrc m12-enemynames.asm
incsrc m12-psinames.asm

// Fix pointers to "PSI "
org $80C21AC; dd $08B3FE4C
org $80C2364; dd $08B3FE4C
org $80C2420; dd $08B3FE4C
org $80C24DC; dd $08B3FE4C
org $80D3998; dd $08B3FE4C
incsrc m12-psitargets.asm
