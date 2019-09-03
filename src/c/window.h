#ifndef HEADER_WINDOW_INCLUDED
#define HEADER_WINDOW_INCLUDED

#include "types.h"

typedef enum WINDOW_ACTION
{
    ACTION_NONE = 0,
    ACTION_STEPIN = 1,
    ACTION_STEPOUT = -1
} WINDOW_ACTION;

typedef struct WINDOW {
    // 0x00
    bool enable                  : 1; // 0x0001 Indicates that the window is enabled.
    unsigned int flags_unknown1  : 3; // 0x000E
    bool hold                    : 1; // 0x0010 Indicates that a button is still being held from a previous frame.
    bool redraw                  : 1; // 0x0020 Indicates that the window border should be redrawn.
    unsigned int flags_unknown3a : 5; // 0x07C0
    bool first                   : 1; // 0x0800 Set immediately after the window is initialized and drawn.
                                      //        Typically checked and cleared on the first frame of the window loop.
                                      //        Might not be used for all windows.
                                      //        Definitely used for the goods *inner* window loop, but not the outer loop.
    unsigned int flags_unknown3b : 4; // 0xF000
    byte pixel_x;
    bool vwf_skip : 1;
    unsigned int vwf_unused : 7;
    byte* text_start;
    byte* text_start2;
    byte* menu_text;

    // 0x10
    byte* number_text_area;
    int text_offset;
    int unknown3;
    int text_offset2;

    // 0x20
    short window_area;
    unsigned short window_x;
    unsigned short window_y;
    unsigned short window_width;
    unsigned short window_height;
    unsigned short text_x;
    unsigned short text_y;
    unsigned short delay_between_prints;

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
    unsigned short cursor_x_base;
    byte cursor_x_delta;
    byte unknown9a;
    byte loaded_code;
    byte unknown9[3];
    int unknown10;
    int unknown11;
} WINDOW;

#endif