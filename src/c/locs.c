#include "locs.h"

int            *window_flags               = (int*)            0x300130C;
PC             (*pc_stats)[4]              = (PC(*)[4])        0x3001D54;
byte           *pc_count                   = (byte*)           0x3001F0B;
bool           (*pc_flags)[4]              = (bool(*)[4])      0x3001F0C;
byte           *pc_names                   = (byte*)           0x3001F10;
PAD_STATE      *pad_state                  = (PAD_STATE*)      0x3002500;
PAD_STATE      *pad_state_shadow           = (PAD_STATE*)      0x3002504;
unsigned short *tile_offset                = (unsigned short*) 0x30051EC;
int            *first_window_flag          = (int*)            0x30051F0;
unsigned short *palette_mask               = (unsigned short*) 0x3005228;
short          *active_window_party_member = (short*)          0x3005264;
unsigned short **tilemap_pointer           = (unsigned short**)0x3005270;
int            *fileselect_pixels_location = (int*)            0x2015000;
int            *vram                       = (int*)            0x6000000;
int            *m2_misc_offsets            = (int*)            0x8B17EE4;
byte           *m2_misc_strings            = (byte*)           0x8B17424;
int            *m2_items_offsets           = (int*)            0x8B1AF94;
byte           *m2_items_strings           = (byte*)           0x8B1A694;
unsigned short *name_header_tiles          = (unsigned short*) 0x8B1B8B0;
