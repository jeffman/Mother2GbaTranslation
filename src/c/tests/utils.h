#ifndef TEST_UTILS
#define TEST_UTILS

#include "../window.h"
#include "../locs.h"

#define W_LETTER 0x87
#define KING_OFFSET 0x1C

#define run_test(func) \
    blank_memory();\
    _setup();\
    func();

void setup_ness_name();
void setup_king_name();
void blank_memory();
bool text_stayed_inside(WINDOW* window);

extern void cpufastset(void *source, void *dest, int mode);
extern void reg_ram_reset(int flag);
extern int m2_setupwindow(WINDOW* window, short window_x, short window_y, short window_width, short window_height);

#endif