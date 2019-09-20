#include "types.h"
#include "pc.h"

#define NULL (0)
#define QUESTION_MARK 0x1F
#define CPUFASTSET_FILL (0x1000000)
#define TRUE 1
#define FALSE 0

#define TILESET_OFFSET_BUFFER_MULTIPLIER 0x8
#define CHAR_OFFSET 0x50
#define CHAR_END 0x60
#define YOUWON_START 0x64
#define YOUWON_END 0x6C
#define ARROW 0x6D
#define SPACE 0x50
#define ZERO 0x60

#define WINDOW_AREA_BG 0x44444444
#define WINDOW_HEADER_BG 0x33333333
#define WINDOW_HEADER_X 0x10
#define WINDOW_HEADER_Y 0x11
#define WINDOW_HEADER_TILE (WINDOW_HEADER_X + (WINDOW_HEADER_Y * 32))

#define OVERWORLD_BUFFER 0x200F200

#define CUSTOMCC_SET_X 0x5F
#define CUSTOMCC_ADD_X 0x60

byte decode_character(byte chr);
byte encode_ascii(char chr);
int get_tile_number(int x, int y);
int get_tile_number_with_offset(int x, int y);
int get_tile_number_buffer(int x, int y);
int get_tile_number_with_offset_buffer(int x, int y);
int ascii_strlen(char *str);
int wrapper_count_pixels_to_tiles(byte *str, int length);
int count_pixels_to_tiles(byte *str, int length, int startingPos);
int expand_bit_depth(byte row, byte foreground);
byte reduce_bit_depth(int row, int foregroundRow);
byte print_character(byte chr, int x, int y);
byte print_character_formatted(byte chr, int x, int y, int font, int foreground);
byte print_character_to_window(byte chr, WINDOW* window);
void print_special_character(int tile, int x, int y);
void map_special_character(unsigned short tile, int x, int y);
void map_tile(unsigned short tile, int x, int y);
byte print_character_with_callback(byte chr, int x, int y, int font, int foreground,
    int *dest, int (*getTileCallback)(int, int), unsigned short *tilemapPtr, int tilemapWidth, byte doubleTileHeight);
byte print_character_with_callback_1bpp_buffer(byte chr, int x, int y, byte *dest, int (*getTileCallback)(int, int), int font,
    unsigned short *tilemapPtr, int tilemapWidth, byte doubleTileHeight);
byte print_character_to_ram(byte chr, int *dest, int xOffset, int font, int foreground);
int print_window_header_string(int *dest, byte *str, int x, int y);
void clear_window_header(int *dest, int length, int x, int y);
int print_window_number_header_string(int *dest, byte *str, int x, int y);
unsigned short* print_equip_header(int type, unsigned short *tilemap, unsigned int *dest,
    WINDOW *window);
unsigned short format_tile(unsigned short tile, bool flip_x, bool flip_y);
void copy_name_header(WINDOW *window, int character_index);
void clear_name_header(WINDOW* window);
void draw_window_arrows(WINDOW *window, bool big);
void clear_window_arrows(WINDOW *window);
void weld_entry(WINDOW *window, byte *str);
int weld_entry_saturn(WINDOW *window, byte *str);
void weld_entry_custom(WINDOW *window, byte *str, int font, int foreground);
void clear_tile(int x, int y, int pixels);
void clear_rect(int x, int y, int width, int height, int pixels);
void clear_rect_ram(int *dest, int tileCount, int pixels);
void clear_window(WINDOW *window);
void print_blankstr(int x, int y, int width);
void print_blankstr_window(int x, int y, int width, WINDOW* window);
void copy_tile(int xSource, int ySource, int xDest, int yDest);
void copy_tile_up(int x, int y);
void print_space(WINDOW *window);
int print_string(byte *str, int x, int y);
int print_menu_string(WINDOW* window);
void print_number_menu(WINDOW* window, int style);
void print_number_menu_current(byte digit, WINDOW* window);
void clear_number_menu(WINDOW* window);
void format_cash_window(int value, int padding, byte* str);
void handle_first_window(WINDOW* window);
void getCharName(byte character, byte *str, int *index);
void copy_name(byte *str, byte *source, int *index, int pos);
byte getSex(byte character);
void getPossessive(byte character, byte *str, int *index);
void getPronoun(byte character, byte *str, int *index);
void setupShortMainMenu_Talk_to_Goods(char *String);
int get_pointer_jump_back(byte *character);
void print_letter_in_buffer(WINDOW* window, byte* character, byte *dest);
void weld_entry_custom_buffer(WINDOW *window, byte *str, int font, int foreground, byte* dest);
byte print_character_formatted_buffer(byte chr, int x, int y, int font, int foreground, byte *dest);
int print_window_with_buffer(WINDOW* window);
byte print_character_with_codes(WINDOW* window, byte* dest);
int buffer_reset_window(WINDOW* window, bool skip_redraw, byte* dest);
void handle_first_window_buffer(WINDOW* window, byte* dest);
void clear_window_buffer(WINDOW *window, byte* dest);
void clear_rect_buffer(int x, int y, int width, int height, byte* dest);
void clear_tile_buffer(int x, int y, byte* dest);
int buffer_drawwindow(WINDOW* window, byte* dest);
void scrolltext_buffer(WINDOW* window, byte* dest);
void properScroll(WINDOW* window, byte* dest);
int jumpToOffset(byte* character);
void copy_tile_buffer(int xSource, int ySource, int xDest, int yDest, byte *dest);
void copy_tile_up_buffer(int x, int y, byte *dest);
void setStuffWindow_Graphics();
void clearWindowTiles_buffer(WINDOW* window);
int initWindow_buffer(WINDOW* window, byte* text_start, unsigned short delay_between_prints);
void print_blankstr_buffer(int x, int y, int width, byte *dest);
void print_blankstr_window_buffer(int x, int y, int width, WINDOW* window);
int print_alphabet_buffer(WINDOW* window);
unsigned short ailmentTileSetup(byte *ailmentBase, unsigned short defaultVal);
int setNumber_getLength(int value, byte *str, int maxLength);
int print_string_in_buffer(byte *str, int x, int y, byte *dest);
void printCashWindow();
WINDOW* getWindow(int index);
void printTinyArrow(int x, int y);
int printstr_buffer(WINDOW* window, byte* str, unsigned short x, unsigned short y, bool highlight);
unsigned short printstr_hlight_buffer(WINDOW* window, byte* str, unsigned short x, unsigned short y, bool highlight);
unsigned short printstr_hlight_pixels_buffer(WINDOW* window, byte* str, unsigned short x, unsigned short y, bool highlight);
void load_pixels_overworld_buffer();
void store_pixels_overworld_buffer(int totalYs);

extern unsigned short m2_coord_table[];
extern byte m2_ness_name[];
extern int m2_bits_to_nybbles[];
extern int m2_bits_to_nybbles_fast[];
extern byte m2_nybbles_to_bits[];
extern byte *m2_font_table[];
extern byte m2_font_widths[];
extern byte m2_font_heights[];
extern unsigned short *m2_widths_table[];
extern byte m12_other_str5[];
extern byte m12_other_str6[];
extern byte m12_other_str7[];
extern byte m12_other_str8[];
extern byte m2_cstm_last_printed[];
extern byte *m2_script_readability;
extern int overworld_buffer;
extern PC m2_ness_data[];
extern int m2_arrow_tile[];

extern bool m2_isequipped(int item_index);
extern void cpufastset(void *source, void *dest, int mode);
extern byte* m2_strlookup(int *offset_table, byte *strings, int index);
extern void m2_formatnumber(int value, byte* strDest, int length);
extern int bin_to_bcd(int value, int* digit_count);
extern int m2_drawwindow(WINDOW* window);
extern int m2_resetwindow(WINDOW* window, bool skip_redraw);
extern void m2_hpwindow_up(int character);
extern int m2_div(int dividend, int divisor);
extern int m2_remainder(int dividend, int divisor);
extern void m2_soundeffect(int index);
extern void m2_printstr(WINDOW* window, byte* str, unsigned short x, unsigned short y, bool highlight);
extern int customcodes_parse_generic(int code, char* parserAddress, WINDOW* window, byte* dest);
extern void m2_sub_d3c50();
extern void m2_sub_d6844();
extern int m2_setupwindow(WINDOW* window, short window_x, short window_y, short window_width, short window_height);
extern void m2_setupbattlename(short value);
