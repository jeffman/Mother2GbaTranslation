#include "window.h"

void __attribute__((naked)) m12_first_function() {}
void __attribute__((naked)) stop(int param) {}
void __attribute__((naked)) cpufastset(void *source, void *dest, int mode) {}
void __attribute__((naked)) cpuset(void *source, void *dest, int mode) {}
byte* __attribute__((naked)) m2_strlookup(int *offset_table, byte *strings, int index) {}
unsigned short* __attribute__((naked)) m2_get_hall_address() {}
int __attribute__((naked)) bin_to_bcd(int value, int* digit_count) {}
int __attribute__((naked)) m2_drawwindow(WINDOW* window) {}
int __attribute__((naked)) m2_resetwindow(WINDOW* window, bool skip_redraw) {}
void __attribute__((naked)) m2_hpwindow_up(int character) {}
bool __attribute__((naked)) m2_isequipped(int item_index) {}
void __attribute__((naked)) m2_soundeffect(int index) {}
int __attribute__((naked)) m2_div(int dividend, int divisor) {}
int __attribute__((naked)) __aeabi_uidiv(int dividend, int divisor) {}
int __attribute__((naked)) m2_remainder(int dividend, int divisor) {}
int __attribute__((naked)) __aeabi_uidivmod(int dividend, int divisor) {}
void __attribute__((naked)) m2_formatnumber(int value, byte* strDest, int length) {}
int __attribute__((naked)) m2_store_to_win_memory(int value) {}
int __attribute__((naked)) m2_sub_a3384(int value) {}
void __attribute__((naked)) m2_sub_d3c50() {}
void __attribute__((naked)) m2_sub_d6844() {}
byte __attribute__((naked)) m2_sub_daf84(short value) {}
byte __attribute__((naked)) m2_battletext_loadstr(char* string) {}
void __attribute__((naked)) m2_set_user_name(int val) {}
void __attribute__((naked)) m2_set_target_name() {}
int __attribute__((naked)) m2_setupwindow(WINDOW* window, short window_x, short window_y, short window_width, short window_height) {}
int __attribute__((naked)) m2_clearwindowtiles(WINDOW* window) {}
void __attribute__((naked)) m2_printstr(WINDOW* window, byte* str, unsigned short x, unsigned short y, bool highlight) {}
void __attribute__((naked)) m2_setupbattlename(short value) {}
void __attribute__((naked)) store_pixels_overworld() {}
void __attribute__((naked)) load_pixels_overworld() {}
void __attribute__((naked)) generic_reprinting_first_menu_talk_to_highlight() {}
void __attribute__((naked)) m12_dim_palette(short* palette, int total, int dimmingFactor) {}
int __attribute__((naked)) m2_jump_to_offset(byte* character) {}
byte* __attribute__((naked)) m2_malloc(int size) {}
void __attribute__((naked)) m2_free(int* address) {}
void __attribute__((naked)) m2_title_teardown() {}
void __attribute__((naked)) vblank() {}
int __attribute__((naked)) m2_set_equippables(WINDOW* window, unsigned short choice, byte* index_list) {}
void __attribute__((naked)) reg_ram_reset(int flag) {}
void __attribute__((naked)) m2_printnextch(WINDOW* window) {}
