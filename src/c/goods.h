#ifndef HEADER_GOODS_INCLUDED
#define HEADER_GOODS_INCLUDED

#include "window.h"
#include "pc.h"
#include "input.h"

#define SELF             0
#define SELF_DEAD        1
#define ALIVE_BOTH       2
#define GIVER_DEAD       3
#define TARGET_DEAD      4
#define DEAD             5
#define ALIVE_BOTH_FULL  6
#define GIVER_DEAD_FULL  7
#define TARGET_DEAD_FULL 8
#define DEAD_FULL        9

#define END           0xFF
#define PROMPT        0xFE
#define NEWLINE       0xFD
#define TARGET        0xFC
#define SOURCE        0xFB
#define ALIVE         0xFA
#define TARGET_POSS   0xF9
#define SOURCE_POSS   0xF8
#define TARGET_PRON   0xF7
#define SOURCE_PRON   0xF6
#define ITEM          0xF5

typedef enum DIRECTION_MOVED
{
    DIRECTION_NONE,
    DIRECTION_RIGHT,
    DIRECTION_LEFT
} MOVED;

int goods_outer_process(WINDOW* window, int y_offset, bool give);
int goods_inner_process(WINDOW *window, unsigned short *items);
void goods_print_items(WINDOW *window, unsigned short *items, int y_offset);
void shop_print_items(WINDOW *window, unsigned char *items, int y_offset, int itemsnum);
void give_print(byte item, byte target, byte source, WINDOW *window, byte *str);
void readStringGive(byte *outputString, byte *baseString, byte source, byte target, byte item);
byte *readCharacterGive(byte *outputString, byte chr, byte source, byte target, byte item);


extern void m2_soundeffect(int index);
extern int m2_div(int dividend, int divisor);
extern int m2_sub_a334c(int value);
extern int m2_sub_a3384(int value);
extern void m2_clearwindowtiles(WINDOW* window);
extern int bin_to_bcd(int value, int* digit_count);

extern int m2_items;
extern byte* give_strings_table[];
extern PC m2_ness_data[];

#endif
