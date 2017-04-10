typedef unsigned char byte;

unsigned short *tile_offset = (unsigned short*)0x30051EC;
unsigned short *palette_mask = (unsigned short*)0x3005228;
unsigned short **tilemap = (unsigned short**)0x3005270;
int *vram = (int*)0x6000000;

int get_tile_number(int x, int y);
int expand_bit_depth(byte row, int foreground);
byte reduce_bit_depth(int row, int foreground);
byte print_character(byte chr, byte x, byte y, byte font, byte foreground);

extern unsigned short m2_coord_table[];
extern int m2_bits_to_nybbles[];
extern byte m2_nybbles_to_bits[];
extern byte *m2_font_table[];
extern byte m2_font_heights[];
extern unsigned short *m2_widths_table[];
