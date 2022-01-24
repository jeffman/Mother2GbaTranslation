#ifndef HEADER_CUSTOM_CODES_INCLUDED
#define HEADER_CUSTOM_CODES_INCLUDED

#include "types.h"
#include "locs.h"
#include "window.h"
#include "battle_data.h"

#define INV_WINDOW_VALUE      4
#define DIALOGUE_WINDOW_VALUE 2

#define PAULA 1
#define MALE 1
#define FEMALE 2
#define NEUTRAL 3

#define NO_THE 1

#define KING                  0xA0
#define PORKY                 0xD8

#define ENEMY_PLURALITY 1
#define BATTLE_USER_THE 2
#define BATTLE_TARGET_THE 3
#define BATTLE_USER_GENDER 4
#define BATTLE_TARGET_GENDER 5
#define IS_NEWLINE 6

#define CALC_WIDTH_START 0
#define CALC_WIDTH_END 1

#define CHECK_WIDTH_OVERFLOW  0x57
#define RESET_WRITE_BUFFER    0x58
#define RESET_STORED_GOODS    0x59
#define RESTORE_DIALOGUE      0x5A
#define PRINT_MAIN_WINDOW     0x5B
#define LOAD_BUFFER           0x5C
#define CALL_GIVE_TEXT        0x5D
#define STORE_TO_WINDOW_DATA  0x5E
#define SET_PIXEL_X_RENDERER  0x5F
#define ADD_PIXEL_X_RENDERER  0x60

#define BASE_GRAPHICS_ADDRESS 0x6000000

int custom_codes_parse(int code, char* parserAddress, WINDOW* window);
int custom_codes_parse_generic(int code, char* parserAddress, WINDOW* window, byte* dest);

extern void load_pixels_overworld();
extern void generic_reprinting_first_menu_talk_to_highlight();
extern byte m2_sub_daf84(short value);
extern void m2_printnextch(WINDOW* window);

extern unsigned short m2_enemy_attributes[];
extern short m2_is_battle;
extern byte m2_cstm_last_pc;
extern BATTLE_DATA* m2_btl_user_ptr;
extern BATTLE_DATA* m2_btl_target_ptr;
extern byte m2_btl_enemies_size;
extern byte m2_source_pc;
extern byte m2_active_window_pc;

#endif