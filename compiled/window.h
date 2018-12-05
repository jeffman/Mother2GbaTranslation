#include "types.h"

typedef struct WINDOW {
    unsigned short flags;
    unsigned short pixel_x;
    byte* text_start;
    byte* text_start2;
    byte* menu_text;
    int unknown2;
    int text_offset;
    int unknown3;
    int text_offset2;
    unsigned short window_area;
    unsigned short window_x;
    unsigned short window_y;
    unsigned short window_width;
    unsigned short window_height;
    unsigned short text_x;
    unsigned short text_y;
    unsigned short unknown4;
    unsigned short delay;
    unsigned short unknown5;
    unsigned short cursor_x;
    unsigned short cursor_y;
    int unknown6;
    int unknown7;
    unsigned short page;
    unsigned short cursor_delta;
    int unknown9;
    int unknown10;
    int unknown11;
} WINDOW;
