#ifndef HEADER_LOCS_INCLUDED
#define HEADER_LOCS_INCLUDED

#include "types.h"
#include "pc.h"

extern unsigned short *tile_offset;
extern int *first_window_flag;
extern unsigned short *palette_mask;
extern short *active_window_party_member;
extern unsigned short **tilemap_pointer;
extern int *vram;
extern PC (*pc_stats)[4];
extern int *m2_misc_offsets;
extern byte *m2_misc_strings;

#endif
