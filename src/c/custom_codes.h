#ifndef HEADER_CUSTOM_CODES_INCLUDED
#define HEADER_CUSTOM_CODES_INCLUDED

#include "types.h"
#include "locs.h"
#include "window.h"

#define INV_WINDOW_VALUE      4
#define DIALOGUE_WINDOW_VALUE 2

#define ENEMY_PLURALITY 1

#define RESET_STORED_GOODS    0x59
#define RESTORE_DIALOGUE      0x5A
#define PRINT_MAIN_WINDOW     0x5B
#define LOAD_BUFFER           0x5C
#define CALL_GIVE_TEXT        0x5D
#define STORE_ENEMY_PLURALITY 0x5E
#define SET_PIXEL_X_RENDERER  0x5F
#define ADD_PIXEL_X_RENDERER  0x60
#define BASE_GRAPHICS_ADDRESS 0x6000000

int custom_codes_parse(int code, char* parserAddress, WINDOW* window);
int custom_codes_parse_generic(int code, char* parserAddress, WINDOW* window, byte* dest);

extern void load_pixels_overworld();
extern void generic_reprinting_first_menu_talk_to_highlight();

extern byte m2_bat_enemies_size;
extern byte m2_source_pc;
extern byte m2_active_window_pc;

#endif