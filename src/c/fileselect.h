#ifndef HEADER_FILE_SELECT_INCLUDED
#define HEADER_FILE_SELECT_INCLUDED

#include "types.h"
#include "vwf.h"

typedef struct FILE_SELECT {
    short status;       // 0 = used, -1 = empty
    short slot;         // 0-2
    short text_speed;   // 0-2
    short unknown_a;
    short unknown_b;    // used when going to file setup
    short ness_level;
    byte ness_name[8];
    byte unknown_c[64];
    byte paula_name[8];
    byte unknown_d[64];
    byte jeff_name[8];
    byte unknown_e[64];
    byte poo_name[8];
    byte unknown_f[68];
    byte king_name[4];
    byte unknown_g[64];
    byte food_name[8];
    byte unknown_h[64];
    byte thing_name[8];
    byte unknown_i[64];
    byte formatted_str[64];
} FILE_SELECT;

int get_tile_number_file_select(int x, int y);
void clear_tile_file(int x, int y, int pixels, int tile_offset_file);
void clear_rect_file(int x, int y, int width, int height, int pixels, int tile_offset_file, unsigned short *tilesetDestPtr);
unsigned short* getTilesetDest(int window_selector, int *width);
unsigned short getPaletteFromFileWindow(int x, int y, int window_selector);
void setPaletteToFileWindow(int x, int y, int window_selector, unsigned short palette);
void setPaletteToZero(int x, int y, int window_selector);
void setPaletteOnAllFile(int x, int y, byte *str, int length, int window_selector);
void wrapper_file_string_selection(int x, int y, int length, byte *str, int window_selector);
void setPaletteOnFile(int x, int y, int window_selector, FILE_SELECT *file);
void print_file_string(int x, int y, int length, byte *str, int window_selector, int windowX, int windowY);
void wrapper_first_file_string(int x, int y, int length, byte *str, int window_selector);
void wrapper_delete_string(int x, int y, int length, byte *str, int window_selector);
void wrapper_name_string(int x, int y, int length, byte *str, int window_selector);
void wrapper_name_summary_string(int x, int y, int length, byte *str, int window_selector);
void wrapper_copy_string(int x, int y, int length, byte *str, int window_selector);
void clearArr(int x, int y, int width, unsigned short *tilesetDestPtr, int windowX);
void print_file_string(int x, int y, int length, byte *str, int window_selector, int windowX, int windowY);
unsigned short setupCursorAction(int *Pos1, int *Pos2);
void setupCursorMovement();
void setupCursorPosition(int *x, int *y);
void format_options_cc(char String[], int *index, byte cmd);
void options_setup(char String[], int selector);
void text_speed_setup(char String[], int selector);
void delete_setup(char String[], int selector);
void text_flavour_setup(char String[], int selector);
void description_setup(char String[], int selector);
void copy_setup(char String[]);
void letterSetup(char String[], int selector, bool capital, int *index);
void numbersSetup(char String[], int *index);
void alphabet_setup(char String[], int selector, bool capital);
void summary_setup(char String[], int selector);
void print_windows(int windowX, int windowY, int window_selector);
void format_file_cc(FILE_SELECT *file, int *index, byte cmd);
void format_file_string(FILE_SELECT *file);

extern unsigned short m2_coord_table_file[];
extern byte m2_cstm_last_printed[];

extern void cpufastset(void *source, void *dest, int mode);
#endif


