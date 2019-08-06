#ifndef HEADER_FILE_SELECT_INCLUDED
#define HEADER_FILE_SELECT_INCLUDED

#include "types.h"

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

#endif
