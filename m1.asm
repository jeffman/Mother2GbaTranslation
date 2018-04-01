arch gba.thumb

//org $8FFFFFF; db $01 // TURN TRANSLATION DEBUG MODE ON


//========================================================================================
//                         MOTHER 1+2 HACKS NOT RELATED TO MOTHER 1
//========================================================================================

// alter select screen graphical text (where you choose between MOTHER 1 and MOTHER 2)
org $86DDC74; incbin gfx/m12_gfx_whichgame_a.bin
org $86E4F94; incbin gfx/m12_gfx_whichgame_b.bin

//========================================================================================
//                           MOTHER 1 SAVE FILE SELECT MENU HACKS
//========================================================================================

// Alter the file select menus
org $8FE5000; incbin gfx/m1_window_file_menu_1.bin
org $8F0D208; dd $8FE5000

// move character info positions
org $8F0D138; db $03
org $8F0D148; db $0E
org $8F0D162; db $17
org $8FE6000; incbin gfx/m1_window_file_menu_2.bin
org $8F0D2A4; dd $8FE6000
org $8F0D236; db $08

// "Copy to where?" window
org $8FE7000; incbin gfx/m1_window_file_menu_3.bin
org $8F0D37C; dd $8FE7000
// move "copy to" cursor when selecting a slot
org $8F2A0B6; db $00
org $8F2A0BA; db $00
org $8F2A0BE; db $00

// "Delete this file?" window
org $8FE8000; incbin gfx/m1_window_file_menu_4.bin
org $8F0D3DC; dd $8FE8000

// lower box erasing stuff
org $8F2713D; db $01
org $8F27141; db $1C
org $8F27146; db $1C
org $8F2714B; db $1C
org $8F27150; db $1C
org $8F27155; db $1C


//========================================================================================
//                           MOTHER 1 NAMING SCREEN STUFF
//========================================================================================

// alter naming windows
org $8F0DE4C; dd $8FE7A00
org $8FE7A00; incbin gfx/m1_window_naming.bin
org $8F0DDA8; db $02  // move desc. text up one row
org $8F0DDB4; db $05  // move name to be below the text
org $8F0DF7E; db $05
org $8F0DE78; db $05
org $8F0DF52; db $05
org $8F0DFA0; db $05

// repoint character text and resize it
org $8F0DBBC; dd $8FE7C00
org $8F0DBC4; dd $8FE7C30
org $8F0DBD0; dd $8FE7C60
org $8F0DBDC; dd $8FE7C90
org $8F0DBE8; dd $8FE7CC0

// change the question marks when typing a name to dots
org $8F0DF78; db $FC
org $8F0DF6A; db $FC
org $8F0DD72; db $FC
org $8F0E1FE; db $FC

// repoint list of unallowed names
org $8F0E2A0; dd $8FE80C0

// repoint "name not allowed" window
org $8F0E2A4; dd $8FE7200
org $8FE7200; incbin gfx/m1_window_name_not_allowed.bin

// move the naming screen sprites up a few pixels
org $8F0DDE0; db $10

// repoint "Fav. Food" text on confirmation screen to allow longer text
org $8F0DBF0; dd $8FE7900

// clear out the "Is this OK?" confirmation window
org $8F2742C; db $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01
org $8F2743F; db $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01


//========================================================================================
//                          MOTHER 1 PLAYER NAMING SCREEN STUFF
//========================================================================================

org $8F0BC62; db $FC
org $8F0BDD8; db $FC
org $8F0BDE6; db $FC
org $8F0BF88; db $FC


//========================================================================================
//                            MOTHER 1 BATTLE-RELATED HACKS
//========================================================================================

// alter character stats window in battle
org $8F0AEFC; dd $8FE7400
org $8FE7400; incbin gfx/m1_window_char_stats.bin

// alter main battle text box design
org $8F275E6; db $01
org $8F275EC; db $1A
org $8F275F5; db $1A
org $8F275FE; db $1A
org $8F27607; db $1A
org $8F27610; db $1A
org $8F2761A; db $1A
org $8F27616; db $02

// clear out "can't use that in battle" text
org $8F2780D; db $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01

// clear out "can't equip in battle" text
org $8F2783A; db $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01

// repoint and set up "??? can't use this" battle text
org $8F29F50; dd $8FE78A0
org $8FE78A0; incbin gfx/m1_window_cant_use_item.bin

// clear out text speed box
org $8F2789C; db $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01
org $8F278B3; db $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01

org $8F2761F; db $01   // make the game delete the battle box properly
org $8F27623; db $1C
org $8F27628; db $1C
org $8F2762D; db $1C
org $8F27632; db $1C
org $8F27637; db $1C

org $8F27770; db $0D   // move enemy name box left a little bit
org $8F27776; db $0F   // expand enemy name box in battle
org $8F2777F; db $0F
org $8F27788; db $0F
org $8F27791; db $0F
org $8F2779A; db $0F
org $8F277A3; db $0F
org $8F10F32; db $0E   // move cursor

// get pre-parsing stuff to work so we can do auto line wraps
org $8F0F226; bl copy_battle_line_to_ram

// add a space between the enemy name and the suffix letters if there are multiple enemies
org $8F0F2DA; bl add_space_to_enemy_name

// only undo auto-indenting if it's battle text
org $8F0C088; bl possibly_ignore_auto_indents


//========================================================================================
//                              MOTHER 1 OVERWORLD HACKS
//========================================================================================

// Alter the Command menu
org $8F0B290; dd $8FE4000
org $8FE4000; incbin gfx/m1_window_command_menu.bin

// Alter the Status menu
org $8F0B188; dd $8FE4800
org $8FE4800; incbin gfx/m1_window_status_menu.bin
org $8F0C6B4; db $04   // fix status menu number alignment

// alter main dialogue box
org $8F0CAE4; bl choose_text_window_type
org $8F0AE48; dd wide_text_box
org $8F7E100
wide_text_box:
   incbin gfx/m1_window_wide_text_box.bin
org $8F0CB1E; bl save_line_number_a
// keep game from updating character status on top of dialog boxes
org $8F0B01C; nop; nop;

// let capsule items be "swallowed" instead of "drank"
org $8F08576; bl swallow_item
org $8F08586; bl swallow_item
org $8F08596; bl swallow_item
org $8F085A6; bl swallow_item
org $8F085B6; bl swallow_item

// repoint yes/no main dialog options, make the game know when to choose which one
org $8FE7100; incbin gfx/m1_window_yes_no.bin
org $8FE7140; incbin gfx/m1_window_yes_no_small.bin
org $8F04FCE; bl choose_yes_no_size

// alter the item action menus
org $8F0B7C4; dd $8FE4B00
org $8FE4B00; incbin gfx/m1_window_item_action_menu.bin
org $8F29FB6; db $17
org $8F29FBA; db $17
org $8F29FBE; db $17
org $8F29FC2; db $17
org $8F29FC6; db $17
org $8F29FCE; db $17
org $8F29FD2; db $17
org $8F29FD6; db $17

// expand store menu width
org $8F0BAC0; dd $8FE7800
org $8FE7800; incbin gfx/m1_window_shop_menu.bin
org $8F0BAD8; db $0E

// repoint and expand the "Who?" window
org $8F0B9F4; dd $8FE7560
org $8FE7560; incbin gfx/m1_window_who.bin
// delete expanded "Who?" window properly
org $8F0B9B8; db $08
org $8F0B9CC; db $08
org $8F0B9E0; db $08


//========================================================================================
//                  FIXES TO BUGS IN THE ORIGINAL MOTHER 1 PROGRAMMING
//========================================================================================

org $8F66332; db $0A   // makes player attack sounds use proper sound
org $8F66308; db $01   // makes enemy attack sounds use proper sound

org $8F29E86; db $AC   // undo the programmers' nonsensical comma replacement stuff
org $8F29E84; db $A3   // undo programmers' weirdness to help get smart quotes working


//========================================================================================
//                                NEW MOTHER 1 GOODIES
//========================================================================================

// create item info for Easy Ring and place it in a box in Ninten's room
org $8F1B3C8; db $1B,$80,$3F,$9C,$02,$00,$02,$00
org $8F027B4; dd newobjecttable
org $8FE8200
newobjecttable:
  incbin gfx/m1_data_object_table_1.bin  // repointing a map object table to insert Easy Ring box

org $8F1258E; bl increaseexp
org $8F10350; bl increasemoney
org $8F09698; bl lowerencounterrate
//org $8F0E5E0; bl increase_offense  // turns the Easy Ring into the prank Hard Ring


//========================================================================================
//                               MOTHER 1 ENDING HACKS
//========================================================================================

// the ending runs via one long continuous script, need to repoint it so we can fix stuff
org $8FEA400; incbin gfx/m1_data_ending_script.bin
org $8F0A500; dd $8FEA400
org $8FEBDB8; db $01,$02,$03,$04,$05,$00,$00,$00,$00,$00,$00,$00  // DIRECTOR
org $8FEBDE4; db $06,$07,$08,$09,$0A,$0B,$0C,$0D,$00,$00,$00,$00  // GAME DESIGNERS
org $8FEBE05; db $0E,$0F,$10,$11,$12,$13,$14,$15,$16,$00,$00,$00  // MUSIC PRODUCERS
org $8FEBE26; db $0E,$0F,$17,$18,$19,$1A,$1B,$1C,$00,$00,$00,$00  // MUSICAL EFFECTS
org $8FEBE47; db $1D,$1E,$1F,$03,$0C,$20,$21,$22,$23,$15,$16,$00  // CHARACTER DESIGNERS
org $8FEBE68; db $24,$25,$26,$27,$28,$09,$29,$2A,$00,$00,$00,$00  // FIGURE MODELING
org $8FEBE84; db $11,$2B,$2C,$2D,$2E,$2F,$30,$00,$00,$00,$00,$00  // PROGRAMMERS
org $8FEBEAA; db $31,$32,$1E,$33,$34,$35,$36,$37,$38,$1C,$00,$00  // SCENARIO ASSISTANTS
org $8FEBED5; db $39,$3A,$3B,$3C,$3D,$04,$3E,$00,$00,$00,$00,$00  // COORDINATORS
org $8FEBF0C; db $11,$12,$13,$14,$3F,$00,$00,$00,$00,$00,$00,$00  // PRODUCER
org $8FEBF28; db $40,$41,$42,$43,$44,$45,$46,$47,$48,$49,$00,$00  // EXECUTIVE PRODUCER
//org $8FEBDA9; db $1E // change music played here


//========================================================================================
//                             UNCENSORING MOTHER 1 STUFF
//========================================================================================


//========================================================================================
//                               MOTHER 1 GRAPHIC HACKS
//========================================================================================

// insert new main font
org $8F2A5A8; incbin gfx/m1-gfx-font.bin

// alter the presented by/produced by screens
org $8F633EC; incbin gfx/m1_gfx_produced_by_a.bin
org $8F6350C; incbin gfx/m1_gfx_produced_by_b.bin
org $8F0D5D0; bl producescreen1; b $8F0D5E8
org $8F0D63C; bl producescreen2; b $8F0D664
org $8F0D66E; nop
org $8F0D676; nop

// make the "CD" machine say "ATM" instead
org $8F328F0; incbin gfx/m1_gfx_atm.bin

// change some of the graphical text used in the end credits
org $8F5FF2c; incbin gfx/m1_gfx_credits.bin


//========================================================================================
//                              NEW MOTHER 1 CODE HACKS
//========================================================================================

org $8FEC400; incsrc m1-code.asm
