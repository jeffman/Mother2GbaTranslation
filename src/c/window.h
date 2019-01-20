#include "types.h"

typedef struct WINDOW {
    // 0x00
    bool enable : 1;          // 0x0001
    unsigned int flags_unknown1 : 3;  // 0x000E
    bool flags_unknown2 : 1;  // 0x0010
    bool redraw : 1;          // 0x0020
    unsigned int flags_unknown3 : 10; // 0xFFC0
    byte pixel_x;
    bool vwf_skip : 1;
    unsigned int vwf_unused : 7;
    byte* text_start;
    byte* text_start2;
    byte* menu_text;

    // 0x10
    int unknown2;
    int text_offset;
    int unknown3;
    int text_offset2;

    // 0x20
    unsigned short window_area;
    unsigned short window_x;
    unsigned short window_y;
    unsigned short window_width;
    unsigned short window_height;
    unsigned short text_x;
    unsigned short text_y;
    unsigned short unknown4;

    // 0x30
    unsigned short delay;
    unsigned short counter;
    unsigned short cursor_x;
    unsigned short cursor_y;
    short unknown6;
    unsigned short unknown6a;
    unsigned short unknown7;
    unsigned short unknown7a;

    // 0x40
    unsigned short page;
    unsigned short cursor_delta;
    int unknown9;
    int unknown10;
    int unknown11;
} WINDOW;
