#ifndef HEADER_LOCS_INCLUDED
#define HEADER_LOCS_INCLUDED

#include "types.h"
#include "pc.h"
#include "input.h"
#include "window.h"
#include "psi.h"

extern int *fileselect_pixels_location;
extern byte *cursorValues;
extern int *window_flags;
extern PC (*pc_stats)[4];
extern int *cash_on_hand;
extern byte *pc_count;
extern bool (*pc_flags)[4];
extern byte *pc_names;
extern PAD_STATE *pad_state;
extern PAD_STATE *pad_state_shadow;
extern byte *script_readability;
extern unsigned short *tile_offset;
extern int *first_window_flag;
extern byte **free_strings_pointers;
extern int **buffer_pointer;
extern unsigned short *palette_mask;
extern WINDOW **window_pointers;
extern short *active_window_party_member;
extern unsigned short **tilemap_pointer;
extern int *vram;
extern int *m2_misc_offsets;
extern byte *m2_misc_strings;
extern int *m2_items_offsets;
extern byte *m2_items_strings;
extern unsigned short *name_header_tiles;
extern byte *character_general_data;
extern PSIPrintInfo *psi_print_info;

#endif
