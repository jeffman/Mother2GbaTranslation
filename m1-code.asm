increase_offense:
  push {lr}            // this function was the prank used on the live stream
  push {r2-r7}

  mov  r3,r0
  ldr  r0,=#0x30031FA  // see if the Easy Ring is equipped on Ninten
  ldrb r0,[r0,#0]
  cmp  r0,#0x37        // if it isn't, do normal stuff
  bne  +               // else change enemy stats in ways I don't fully understand

  mov  r0,r3
  ldr  r2,=#0xFF00
  orr  r0,r2
  mov  r3,r0

  +
  mov  r0,r3
  and  r0,r7
  strh r0,[r1,#0]
  pop  {r2-r7}
  pop  {pc}

//----------------------------------------------------------------------------------------

increaseexp:
  mov  r3,r0
  ldr  r0,=#0x30031FA  // see if the Easy Ring is equipped on Ninten
  ldrb r0,[r0,#0]
  cmp  r0,#0x37        // if it isn't, do normal stuff
  bne  +               // else quadruple experience gained
  mov  r0,r3
  lsl  r3,r3,#2
  ldr  r0,=#0x8FFFFFF  // increase even more if debug mode is on
  ldrb r0,[r0,#0]
  cmp  r0,#0x1
  bne  +
  lsl  r3,r3,#4

  +
  mov r0,r4
  bx  lr

//----------------------------------------------------------------------------------------

increasemoney:
  push {r1}
  ldr  r1,=#0x30031FA
  ldrb r1,[r1,#0]
  cmp  r1,#0x37
  bne  +
  lsl  r0,r0,#1        // double money if easy ring is equipped
  ldr  r1,=#0x8FFFFFF  // increase even more if debug mode is on
  ldrb r1,[r1,#0]
  cmp  r1,#0x1
  bne  +
  lsl  r0,r0,#3

  +
  pop  {r1}
  add  r0,r3,r0
  strh r0,[r1,#0]
  bx   lr

//----------------------------------------------------------------------------------------

lowerencounterrate:
  ldr  r1,=#0x8F1BB48

  ldr  r0,=#0x30031FA    // see if the Easy Ring is equipped on Ninten
  ldrb r0,[r0,#0]
  cmp  r0,#0x37          // if it isn't, do normal stuff
  bne  +                 // else do our easy-making stuff
  ldr  r1,=#enratetable
  ldr  r0,=#0x8FFFFFF    // see if debug mode is on
  ldrb r0,[r0,#0]
  cmp  r0,#0x1           // load no-enemies data if debug mode is on
  bne  +
  ldr  r1,=#enratetable2

  +
  mov r0,r13
  bx  lr

enratetable:
  db $08,$07,$06,$06,$05,$04,$03,$02
enratetable2:
  db $00,$00,$00,$00,$00,$00,$00,$00

//----------------------------------------------------------------------------------------

producescreen1:
  push {r6}
  mov  r0,#0xC8
  strb r0,[r6,#0x0D]
  mov  r0,#0xC9
  strb r0,[r6,#0x0E]
  mov  r0,#0xCA
  strb r0,[r6,#0x0F]
  mov  r0,#0xCB
  strb r0,[r6,#0x10]
  mov  r0,#0xCD
  strb r0,[r6,#0x11]
  mov  r0,#0xCE
  strb r0,[r6,#0x12]
  mov  r0,#0xCF
  strb r0,[r6,#0x13]
  add  r6,#0x33
  mov  r0,#0xDF
  strb r0,[r6,#0x0]
  sub  r6,#0x6
  mov  r0,#0xD8
  strb r0,[r6,#0x0]
  pop  {r6}
  bx   lr

producescreen2:
  mov  r0,#0xE3
  strb r0,[r1,#0]
  add  r1,#1
  mov  r0,#0xE4
  strb r0,[r1,#0]
  add  r1,#1
  mov  r0,#0xE5
  strb r0,[r1,#0]
  add  r1,#1
  mov  r0,#0xE6
  strb r0,[r1,#0]
  add  r1,#1
  mov  r0,#0xE7
  strb r0,[r1,#0]
  add  r1,#1
  mov  r0,#0xE8
  strb r0,[r1,#0]
  add  r1,#1
  bx   lr

//----------------------------------------------------------------------------------------

// this determines if the game should use the original size text box or the expanded one

choose_text_window_type:
  push {lr}
  push {r4}
  ldr  r0,=#0x8F26D4A      // load original, small text box window

  // sometimes r4 doesn't have the actual line number, usually when doing non-dialog stuff
  // like when you use items. So we check for that now here
  ldr  r4,=#0x2014300      // since we're doing an unusual line, let's check our custom
  ldrh r4,[r4,#0]          // variable to see what the actual line # is
  cmp  r4,#0
  beq  +
  

  // if we're here, we're looking at a standard dialog line, with the line number in r4
  // so we'll load from a custom table to see if this line needs a small window or not

  .load_table_entry:
  ldr  r1,=#0x8FED000      // this is the start of our custom table
  add  r1,r1,r4
  ldrb r1,[r1,#0]          // if the value in the table is 1, then use small window
  cmp  r1,#0x1
  beq  +

  ldr  r0,=#wide_text_box  // load wide text box window

  +
  mov  r4,#0               // unset our custom "current line #" variable
  ldr  r1,=#0x2014300
  strh r4,[r1,#0]

  pop  {r4}
  bl   $8F0C058
  ldr  r1,=#0x30034B0
  mov  r0,#0x80
  strb r0,[r1,#0]
  pop  {r0}
  bx   r0

//----------------------------------------------------------------------------------------
// the yes/no selection is weird, so we gotta make it fit the window size too

choose_yes_no_size:
   push {lr}
   push {r1-r7}
   strb r1,[r0,#0x0]

   ldr  r0,=#0x8FE7140      // load small-sized yes/no window address
   ldr  r4,=#0x2014300      // let's get the line #, making sure it's not null
   ldrh r4,[r4,#0]
   cmp  r4,#0
   beq  +

   // if we're here, we're looking at a standard dialog line, with the line number in r4
   // so we'll load from a custom table to see if this line needs a small yes/no or not
   .load_table_entry:
   ldr  r1,=#0x8FED000      // this is the start of our custom table
   add  r1,r1,r4
   ldrb r1,[r1,#0]          // if the value in the table is 1, then use small window
   cmp  r1,#0x1
   beq  +

   ldr  r0,=#0x8FE7100      // load wide yes/no window

   +
   pop  {r1-r7}
   pop  {pc}


//----------------------------------------------------------------------------------------

// In Japanese, the word for drink is the same for swallow, which makes it weird when
// you try to use an HP capsule or something and it says you drank it. This little hack
// will make it say "swallow" if it's appropriate.

swallow_item:
   ldr  r1,=#0x30007D4       // this has the current item # (hopefully all the time)
   ldrb r1,[r1,#0]           // load item #
   cmp  r1,#0x4E             // see if the item is between 4E and 52, which are capsules
   blt  .drink               // if not, then load the normal "drink" line
   cmp  r1,#0x52             // if it is, then load the "swallow" line
   bgt  .drink
   ldr  r1,=#0x6AE
   b    +

   .drink:
   ldr r1,=#0x6B0

   +
   bx lr

//----------------------------------------------------------------------------------------

// saves the current text line number to a custom area of RAM for use in other hacks here

save_line_number_a:
  ldr  r1,=#0x2014300
  strh r0,[r1,#0]

  lsl r0,r0,#0x10
  ldr r1,=#0x30034E8
  bx  lr

//----------------------------------------------------------------------------------------
// basic string copy, r0 is the source address, r1 is the target address, 00 = end of line
// upon return, r0 has the number of bytes copied, r1 has the address of the end of line

strcopy:
   push {r2,r3,lr}
   
   -
   ldrb r2,[r0,#0x0]
   strb r2,[r1,#0x0]
   add  r0,#0x1
   add  r1,#0x1
   cmp  r2,#0x0
   beq  +
   add  r3,#0x1
   b    -

   +
   mov  r0,r3
   pop  {r2,r3,pc}

//----------------------------------------------------------------------------------------
// copies a string (meant for battle text) to RAM, parsing control codes when possible
// this is done so we can add in auto line breaks as necessary later on
// r0 is source address, r1 is target address, line needs to be terminated with 00

parsecopy:

  push {r0-r7,lr}

  .loop_start:
  ldrb r2,[r0,#0x0]      // load character from ROM string
  cmp  r2,#0x3           // see if it's a control code, if so, let's do control code stuff
  bne  .copy_character

  .parse_control_code:
  ldrb r3,[r0,#0x1]      // load control code argument
  cmp  r3,#0x10; bne +; bl control_code_10; b .loop_start
  +
  cmp  r3,#0x11; bne +; bl control_code_11; b .loop_start
  +
  cmp  r3,#0x12; bne +; bl control_code_12; b .loop_start
  +
  cmp  r3,#0x13; bne +; bl control_code_13; b .loop_start
  +
  cmp  r3,#0x16; bne +; bl control_code_16; b .loop_start
  +
  cmp  r3,#0x17; bne +; bl control_code_17; b .loop_start
  +
  cmp  r3,#0x1D; bne +; bl control_code_1D; b .loop_start
  +
  cmp  r3,#0x20; bne +; bl control_code_20; b .loop_start
  +
  cmp  r3,#0x21; bne +; bl control_code_21; b .loop_start
  + 
  cmp  r3,#0x22; bne +; bl control_code_22; b .loop_start
  + 
  cmp  r3,#0x23; bne +; bl control_code_23; b .loop_start
  + 
  cmp  r3,#0xF0; bne +; bl control_code_F0; b .loop_start
  + 
  cmp  r3,#0xF1; bne +; bl control_code_F1; b .loop_start
  + 

  .copy_control_code:
  mov  r3,#0x3
  strb r3,[r1,#0x0]
  ldrb r3,[r0,#0x1]
  strb r3,[r1,#0x1]
  add  r0,#0x2
  add  r1,#0x2
  b    .loop_start

  .copy_character:
  strb r2,[r1,#0x00]
  add  r0,#0x1
  add  r1,#0x1
  cmp  r2,#0x0
  beq  +
  b    .loop_start  

  +
  pop  {r0-r7,pc}

//----------------------------------------------------------------------------------------

// r0 has the text line number

copy_battle_line_to_ram:
   push {lr}

   // now find the ROM address of the line in question, place in r0

   lsl  r0,r0,#0x10
   ldr  r1,=#0x30034E8
   ldr  r1,[r1,#0x0]
   lsr  r0,r0,#0xE
   add  r0,r0,r1
   ldr  r0,[r0,#0x0]
   cmp  r0,#0x0
   beq  +

   // now we store the target in r1 and execute a custom string copy
   ldr  r1,=#0x2014310
   bl   parsecopy

   // now we scan the final string and add [BREAK]s as necessary to create auto-wrapping
   ldr  r0,=#0x2014310
   bl   perform_auto_wrap

   // now we send the game's display routine on its merry way
   bl   $8F0C058

   battle_calling:  // this line is referenced by the auto-indent hack
   +
   pop {pc}

//----------------------------------------------------------------------------------------

perform_auto_wrap:
   push {r0-r7,lr}
   mov  r2,r0      // load r2 with the start address of the string
   mov  r1,r2      // r1 is the current character's address
   mov  r7,r2      // r7 is last_space, the spot where the last space was
   mov  r4,#0      // char_loc = 0

   //-------------------------------------------------------------------------------
   // Now we do the meat of the auto word wrap stuff
   .word_wrap_loop:
   ldrb r0,[r1,#0x0]            // load current character

   cmp  r0,#0x0
   beq  .word_wrap_end          // jump to the end if we're at the end of the string

   cmp  r0,#0x1                 // is the current character a space?
   beq  .space_found
   cmp  r0,#0x2                 // is the current character a [BREAK]?
   beq  .newline_found

   cmp  r0,#0x03                // if r0 == 0x03, this is a CC, so skip the width adding junk
   beq  .no_wrap_needed
   b    .main_wrap_code

   pop  {r0-r7,pc}

   //-------------------------------------------------------------------------------
   // We found a space or a space-like character, so reset some values

   .newline_found:
   mov  r4,#0                   // this was a [WAIT] or [BREAK], so reset the width
   mov  r7,r1                   // last_space = curr_char_address
   b    .no_wrap_needed

   .space_found:
   mov r7,r1                    // last_space = curr_char_address
                     
   //--------------------------------------------------------------------------------------------
   // Here is the real meat of the auto word wrap routine

   .main_wrap_code:
   add  r4,#0x1                 // char_loc++
   cmp  r4,#0x1B
   blt  .no_wrap_needed         // if curr_width < box_width, go to no_wrap_needed to update the width and such

   mov  r4,#0                   // if we're executing this, then width >= box_width, so do curr_width = 0 now

   mov  r1,r7                   // curr_char_address = last_space_address// we're gonna recheck earlier stuff

   mov  r0,#0x02
   strb r0,[r7,#0x0]            // replace the last space-ish character with a newline code

   //--------------------------------------------------------------------------------------------
   // Get ready for the next loop iteration

   .no_wrap_needed:
   add  r1,#1                   // curr_char_address++
   b    .word_wrap_loop         // do the next loop iteration

   //--------------------------------------------------------------------------------------------
   // Let's get out of here!

   .word_wrap_end:
   pop  {r0-r7,pc}


//----------------------------------------------------------------------------------------

control_code_10:
  push {r0,lr}
  ldr  r0,=#0x3003208
  bl   strcopy
  pop  {r0}
  add  r0,#0x2
  sub  r1,#1
  pop  {pc}

//----------------------------------------------------------------------------------------

control_code_11:
  push {r0,lr}
  ldr  r0,=#0x3003288
  bl   strcopy
  pop  {r0}
  add  r0,#0x2
  sub  r1,#1
  pop  {pc}

//----------------------------------------------------------------------------------------

control_code_12:
  push {r0,lr}
  ldr  r0,=#0x3003248
  bl   strcopy
  pop  {r0}
  add  r0,#0x2
  sub  r1,#1
  pop  {pc}

//----------------------------------------------------------------------------------------

control_code_13:
  push {r0,lr}
  ldr  r0,=#0x30032C8
  bl   strcopy
  pop  {r0}
  add  r0,#0x2
  sub  r1,#1
  pop  {pc}

//----------------------------------------------------------------------------------------

control_code_16:
  push {lr}
  push {r0,r2}
  push {r1}
  ldr  r1,=#0x3003190
  ldrb r2,[r1,#0x8]
  lsl  r0,r2,#0x6
  add  r1,#0x38
  add  r0,r0,r1
  pop  {r1}
  bl   strcopy
  pop  {r0,r2}
  add  r0,#0x2
  sub  r1,#1
  pop  {pc}

//----------------------------------------------------------------------------------------
// this adds "'s party" if there's more than one character in the party

control_code_17:
  push {r0,lr}
  ldr  r0,=#0x3003190
  ldrb r0,[r0,#0x9]
  cmp  r0,#0x0
  beq  +

  ldr  r0,=#0x8F7E600
  bl   strcopy
  sub  r1,#1

  +
  pop  {r0}
  add  r0,#0x2
  pop  {pc}

//----------------------------------------------------------------------------------------
// this prints an item name

control_code_1D:
  push {lr}
  push {r0,r2-r7}
  push {r1}

  ldr  r1,=#0x30007D4
  ldrb r2,[r1,#0x0]
  lsl  r0,r2,#0x18
  cmp  r0,#0
  blt  line434
  mov  r1,r2
  mov  r2,#0xFA
  lsl  r2,r2,#2
  b    line456

  line434:
  lsr  r0,r0,#0x18
  cmp  r0,#0xBF
  bhi  line450
  ldr  r0,=#0x8F29EB0
  ldrb r1,[r1,#0]
  sub  r1,#0x80
  lsl  r1,r1,#1
  add  r1,r1,r0
  ldrh r0,[r1,#0]
  b    +

  line450:
  ldrb r1,[r1,#0]
  mov  r2,#0xEA
  lsl  r2,r2,#2
  line456:
  add  r0,r1,r2
  lsl  r0,r0,#0x10
  ldr  r1,=#0x30034E8
  ldr  r1,[r1,#0]
  lsr  r0,r0,#0xE
  add  r0,r0,r1
  ldr  r0,[r0,#0]

  +
  pop  {r1}
  bl   strcopy
  sub  r1,#1
  pop  {r0,r2-r7}

  add r0,#0x2
  pop {pc}

//----------------------------------------------------------------------------------------

control_code_20:
  push {r0,lr}
  ldr  r0,=#0x3003640
  bl   strcopy
  pop  {r0}
  add  r0,#0x2
  sub  r1,#1
  pop  {pc}

//----------------------------------------------------------------------------------------

control_code_21:
  push {r0,lr}
  ldr  r0,=#0x3003610
  bl   strcopy
  pop  {r0}
  add  r0,#0x2
  sub  r1,#1
  pop  {pc}

//----------------------------------------------------------------------------------------

control_code_22:
  push {r0,lr}
  ldr  r0,=#0x30036A0
  bl   strcopy
  pop  {r0}
  add  r0,#0x2
  sub  r1,#1
  pop  {pc}

//----------------------------------------------------------------------------------------
// this is a custom battle control code that selects a/an/the for when an item is used

control_code_F0:
  push {lr}
  push {r2-r7}
  push {r0}

  ldr  r5,=#0x8F70840
  ldr  r4,=#0x3003690
  ldrh r0,[r4,#0x0]
  add  r0,#0x1
  add  r0,r0,r5
  ldrb r0,[r0,#0x0]      // this now has the item number being used
  lsl  r0,r0,#0x4
  ldr  r5,=#0x8FFE000
  add  r0,r0,r5          // we now have the address of the custom article string to copy

  bl   strcopy
  pop  {r0}
  add  r0,#0x2
  sub  r1,#1

  pop  {r2-r7}
  pop  {pc}

//----------------------------------------------------------------------------------------
// this is a custom battle control code that selects a/an/the when an item is won in battle

control_code_F1:
  push {lr}
  push {r2-r7}
  push {r0}

  ldr  r4,=#0x30007D4
  ldrb r0,[r4,#0x0]      // this now has the item number being used
  lsl  r0,r0,#0x4
  ldr  r5,=#0x8FFE000
  add  r0,r0,r5          // we now have the address of the custom article string to copy

  bl   strcopy
  pop  {r0}
  add  r0,#0x2
  sub  r1,#1

  pop  {r2-r7}
  pop  {pc}

//----------------------------------------------------------------------------------------
// this is used to display numbers

control_code_23:
  push {r0,lr}
  push {r7}
  mov  r7,r1
  ldr  r0,=#0x3003708
  ldr  r0,[r0,#0]         // r0 now has the number to be displayed, but we gotta convert it
  mov  r5,r0              // copy number to r5 for easy retrieval
  mov  r6,#0              // initialize counter
  push {r4-r6}

  .loop_start:
  ldr  r0,=#0x20142F0     // this is the write address in our custom area in RAM
  add  r4,r0,r6
  mov  r0,r5
  mov  r1,#0xA
  bl   $8F15210           // calling the division routine
  add  r0,#0xB0           // r0 now has the tile # for the digit to be printed
  strb r0,[r4,#0x0]       // store digit tile # to RAM
  add  r6,#1              // increment counter
  mov  r0,r5
  mov  r1,#0xA
  bl   $8F15198           // call remainder routine
  mov  r5,r0
  cmp  r5,#0x0
  bne  .loop_start


  .reverse_string:        // the number string is actually stored in reverse, so we gotta fix that
  ldr  r4,=#0x20142F0
  mov  r1,r7              // we're gonna reverse the number string into the main string
  cmp  r6,#0              // make sure we actually have a string to copy, this is the # of bytes
  ble  .end_routine

  sub  r6,#1              // we want to start just before the end of the string
  .reverse_string_loop:
  add  r5,r4,r6           // give r5 the address of the byte to load
  ldrb r0,[r5,#0x0]       // load byte
  strb r0,[r1,#0x0]       // store byte in main string and increment position
  add  r1,#1

  sub  r6,#1              // decrement counter, do another loop if necessary
  cmp  r6,#0
  blt  .end_routine
  b    .reverse_string_loop

  .end_routine:           // r1 needs to return the current address in the main string
  pop  {r4-r6}
  pop  {r7}
  pop  {r0}
  add  r0,#0x2
  pop  {pc}

//----------------------------------------------------------------------------------------
// if there are multiple enemies, this will add a space between the names and the end letters

add_space_to_enemy_name:
  push {lr}
  mov  r4,#0x01
  strb r4,[r5,#0x0]
  strb r0,[r5,#0x1]
  add  r5,#0x2
  pop  {pc}

//----------------------------------------------------------------------------------------
// only ignore auto-indenting if we're in battle

possibly_ignore_auto_indents:
   push {lr}
   push {r2-r7}
   mov  r0,r1
   
   mov  r3,sp
   add  r3,#0x2C
   ldr  r3,[r3,#0]
   ldr  r2,=#battle_calling
   add  r2,#1
   cmp  r3,r2
   beq  +

   add  r0,#1

   +
   pop  {r2-r7}
   strb r0,[r2,#0x0]
   pop  {pc}

//======================================================================
// Intro screen stuff
//======================================================================

//print "Intro screen routine: ",pc
//org $83FC600
org $8106CAC
intro_screen:
push {r0-r4}

// Enable VBlank interrupt crap
ldr  r2,=#0x4000000
mov  r0,#0xB
strh r0,[r2,#4] // LCD control
mov  r1,#2
lsl  r1,r1,#8
ldrh r0,[r2,r1]
mov  r3,#1
orr  r0,r3
strh r0,[r2,r1] // Master interrupt control

// Enable BG0
ldrh r0,[r2,#0]
mov  r1,#1
lsl  r1,r1,#8
orr  r0,r1
strh r1,[r2,#0]

// Set BG0 to 256-color mode; the following screen uses it anyway so we're good
ldrh r0,[r2,#8]
mov  r1,#0x80
orr  r0,r1
strh r0,[r2,#8]

// Fill the first row of tilemap data with the first tile in our file
ldr  r0,=#0x6000000
ldr  r1,=#0x200
ldr  r3,=#0x400
//mov  r1,#0
mov  r2,#0
-
strh r1,[r0,#0]
add  r0,#2
add  r2,#1
cmp  r2,r3
bne  -


// now we copy the actual tilemap data of our image to the tile map area
ldr  r0,=#0x6000040
ldr  r1,=#0x3FE
//mov  r2,#0
ldr  r2,=#0x200

-
mov  r3,#0x3F
and  r3,r0
cmp  r3,#0x3C
bne  +
add  r0,#4
+
strh r2,[r0,#0]
add  r0,#2
add  r2,#1
cmp  r2,r1
blt  -
ldr r0,=#disclaimer_graphics
ldr r1,=#0x6008000
swi #0x12



// load our palette
ldr  r0,=#disclaimer_palette
mov  r1,#5
lsl  r1,r1,#0x18
mov  r2,#1
lsl  r2,r2,#8
swi  #0xB


// Fade in
ldr  r2,=#0x4000050
mov  r0,#0x81
strh r0,[r2,#0] // Set blending mode to whiteness for BG0
mov  r4,#0x10
-
strh r4,[r2,#4]
swi  #5
swi  #5 // 15 loops with 2 intrs each gives a total fade-in time of 0.5 seconds
sub  r4,#1
bpl  -

// Conditional delay for ~2 seconds
// 0x78 VBlankIntrWaits is 2 seconds
mov  r2,#1 // set to 0 if we don't need to delay
ldr  r4,=#0xFFFFFFFF
ldr  r0,=#0xE000000      // check mother 1 slot 1
ldrb r3,[r0,#0]
cmp  r3,#0xFF
beq  +
mov  r2,#0
b    delay

+
ldr  r0,=#0xE000300      // check mother 1 slot 2
ldrb r3,[r0,#0]
cmp  r3,#0xFF
beq  +
mov  r2,#0
b    delay

+
ldr  r0,=#0xE000600      // check mother 1 slot 3
ldrb r3,[r0,#0]
cmp  r3,#0xFF
beq  +
mov  r2,#0
b    delay

+
ldr  r0,=#0xE002000      // check mother 2 data
ldrb r3,[r0,#0]
cmp  r3,#0xFF
beq  +
mov  r2,#0
b    delay


+
delay:
cmp  r2,#0
beq  buttonwait
mov  r4,#0x78
-
swi  #5
sub  r4,#1
cmp  r4,#0
bne  -
+

buttonwait:
// Wait for any button press
ldr  r2,=#0x4000130
ldr  r4,=#0x3FF
-
swi  #5 // VBlankIntrWait
ldrh r0,[r2,#0]
cmp  r0,r4
beq  -

// Fade out
ldr  r2,=#0x4000050
mov  r0,#0x81
strh r0,[r2,#0] // Set blending mode to whiteness for BG0
mov  r4,#0x0
-
strh r4,[r2,#4]
swi  #5
swi  #5 // 15 loops with 2 intrs each gives a total fade-out time of 0.5 seconds
add  r4,#1
cmp  r4,#0x10
bls  -

// Clear the palette
mov  r0,#1
neg  r0,r0
push {r0}
mov  r0,sp
mov  r1,#5
lsl  r1,r1,#0x18
mov  r2,#1
lsl  r2,r2,#24
add  r2,#0x80
swi  #0xC
add  sp,#4

// ----------------------
pop  {r0-r4}

.intro_screen_end:
push {lr}
ldr r0,=#0x3007FFC
str r1,[r0,#0]
pop  {pc}

//======================================================================

org $8FEE000;
disclaimer_palette:
incbin data/intro-screen-pal.bin

disclaimer_graphics:
incbin data/intro-screen-gfx.bin

org $800027A; bl intro_screen
