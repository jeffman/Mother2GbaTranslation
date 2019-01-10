#include "locs.h"

unsigned short *tile_offset                = (unsigned short*) 0x30051EC;
int            *first_window_flag          = (int*)            0x30051F0;
unsigned short *palette_mask               = (unsigned short*) 0x3005228;
short          *active_window_party_member = (short*)          0x3005264;
unsigned short **tilemap_pointer           = (unsigned short**)0x3005270;
int            *vram                       = (int*)            0x6000000;
PC             (*pc_stats)[4]              = (PC(*)[4])        0x3001D54;
int *m2_misc_offsets                       = (int*)            0x8B17EE4;
byte *m2_misc_strings                      = (byte*)           0x8B17424;
