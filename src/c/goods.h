#ifndef HEADER_GOODS_INCLUDED
#define HEADER_GOODS_INCLUDED

#include "window.h"
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

int goods_outer_process(WINDOW* window);
void goods_print_items(WINDOW *window, unsigned short *items);

extern bool m2_isequipped(int item_index);
extern void m2_soundeffect(int index);

#endif
