#include "window.h"

void __attribute__((naked)) cpufastset(void *source, void *dest, int mode) {}
byte* __attribute__((naked)) m2_strlookup(int *offset_table, byte *strings, int index) {}
int __attribute__((naked)) bin_to_bcd(int value, int* digit_count) {}
int __attribute__((naked)) m2_drawwindow(WINDOW* window) {}
int __attribute__((naked)) m2_resetwindow(WINDOW* window, bool skip_redraw) {}
void __attribute__((naked)) m2_hpwindow_up(int character) {}
bool __attribute__((naked)) m2_isequipped(int item_index) {}
void __attribute__((naked)) m2_soundeffect(int index) {}
int __attribute__((naked)) m2_div(int dividend, int divisor) {}
