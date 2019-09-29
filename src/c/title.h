#ifndef HEADER_TITLE_INCLUDED
#define HEADER_TITLE_INCLUDED

#include "types.h"

typedef struct TITLE_COORD_TABLE {
    int unknown_a[3];
    int y_end[9];
    int y_start[9];
    int x_end[9];
    int x_start[9];
} TITLE_COORD_TABLE;

typedef struct TITLE_SPRITE {
    struct TITLE_SPRITE *prev;
    void *anim_table;
    void *oam_entry_table;
    void *unknown_table;
    int unknown_a[5];
    int x;
    int y;
    int unknown_b[5];
} TITLE_SPRITE;

typedef struct TITLE_EXTENDED {
    unsigned short *pal_buffer[5];
    byte unknown_a[0x70];
    int sequence;
    TITLE_SPRITE sprites[9];
    int unknown[0x16];
} TITLE_EXTENDED;

typedef struct TITLE_CONTROL {
    int unknown_a;
    int frame;
    int unknown_b[3];
    TITLE_EXTENDED *ext;
    int unknown_c[2];
} TITLE_CONTROL;

void title_text_sequence(
    TITLE_CONTROL *control,
    TITLE_EXTENDED *ext,
    TITLE_COORD_TABLE *coords);

extern int m2_div(int dividend, int divisor);

#endif
