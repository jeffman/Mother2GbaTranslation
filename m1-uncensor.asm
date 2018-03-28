//==========================================================================================================
// THIS FILE MAKES VARIOUS CHANGES TO THE MOTHER 1+2 ROM TO UNCENSOR STUFF IN THE MOTHER 1 PORTION
// IT ONLY UNCENSORS GRAPHICS, ANY TEXT CHANGES WILL NEED TO BE MANUALLY DONE WITH THE GAME'S TEXT FILES
//==========================================================================================================

// insert original Mother 1 enemy graphics
org $8F67880; incbin m1_restoration_gfx_enemies.bin

// insert original Mother 1 map tile graphics
org $8F2B9A0; incbin m1_restoration_gfx_maptiles.bin

// insert original Mother 1 map tile palettes - might not be necessary
org $8F3C190; incbin m1_restoration_gfx_map_palettes.bin

// insert original Mother 1 sprite graphics
org $8F339A0; incbin m1_restoration_gfx_sprites.bin

// replace some ending graphics with the original sprites
org $8F60F3C; incbin m1_restoration_gfx_ending.bin

// fix cross in church
org $8F50214; db $5A,$5B,$5C,$5D,$5E,$7F,$7F,$7F
org $8F501E6; db $06
org $8F501EA; db $00
org $8F501EE; db $3F
// fix cross in church in ending, note that this modifies data in a file we've included earlier in
// a previously empty area, so if that file gets moved, then these addresses will need to change too.
org $8FEB1A3; db $1C,$1D
org $8FEB1B7; db $1E,$3F
org $8FEB1CB; db $3F
org $8FEB282; db $00
org $8FEB287; db $00
