#ifndef TEST_M2_UTILS
#define TEST_M2_UTILS

#include "../window.h"
#include "../vwf.h"
#include "../locs.h"

#define W_LETTER 0x87
#define KING_OFFSET 0x1C

void setup_ness_name();
void setup_king_name();
bool text_stayed_inside(WINDOW* window);
void setup_overworld_buffer();

extern int m2_setupwindow(WINDOW* window, short window_x, short window_y, short window_width, short window_height);

#endif