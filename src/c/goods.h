#ifndef HEADER_GOODS_INCLUDED
#define HEADER_GOODS_INCLUDED

#include "window.h"
#include "character.h"
#include "input.h"

typedef enum DIRECTION_MOVED
{
    DIRECTION_NONE,
    DIRECTION_RIGHT,
    DIRECTION_LEFT
} MOVED;

typedef enum GOODS_ACTION
{
    ACTION_NONE = 0,
    ACTION_STEPIN = 1,
    ACTION_STEPOUT = -1
} GOODS_ACTION;

int goods_outer_process(WINDOW* window, int y_offset, bool give);
int goods_inner_process(WINDOW *window, unsigned short *items);
void goods_print_items(WINDOW *window, unsigned short *items, int y_offset);
void shop_print_items(WINDOW *window, unsigned char *items, int y_offset, int itemsnum);
void setupSelf_Alive(byte *String, int *index, byte user, byte item);
void setupSelf_Dead(byte *String, int *index, byte user, byte item);
void setupFull_Both_Alive(byte *String, int *index, byte user, byte target, byte item);
void setupFull_Target_Dead(byte *String, int *index, byte user, byte target, byte item);
void setupFull_User_Dead(byte *String, int *index, byte user, byte target, byte item);
void setupFull_Both_Dead(byte *String, int *index, byte user, byte target, byte item);
void setup_Both_Alive(byte *String, int *index, byte user, byte target, byte item);
void setup_Target_Dead(byte *String, int *index, byte user, byte target, byte item);
void setup_User_Dead(byte *String, int *index, byte user, byte target, byte item);
void setup_Both_Dead(byte *String, int *index, byte user, byte target, byte item);
void give_print(byte item, byte target, byte source, WINDOW *window, byte *str);

extern bool m2_isequipped(int item_index);
extern void m2_soundeffect(int index);
extern int m2_div(int dividend, int divisor);
extern int m2_sub_a334c(int value);
extern int m2_sub_a3384(int value);
extern void m2_clearwindowtiles(WINDOW* window);
extern int bin_to_bcd(int value, int* digit_count);

extern int m2_items;
extern CHARACTER_DATA m2_ness_data[];

#endif
