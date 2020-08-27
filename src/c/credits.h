#ifndef HEADER_CREDITS_INCLUDED
#define HEADER_CREDITS_INCLUDED

#include "types.h"
#include "locs.h"

#define PLAYER_NAME_SIZE 24
#define CAST_FONT 0
#define CAST_FONT_WIDTH 2
#define CAST_FONT_HEIGHT 2
#define SIDE_BUFFER_SIZE 2
#define START_Y 2
#define END_ALL 0xFF
#define END 0xFE
#define PC_START 0xF9
#define PC_NAME_SIZE 5
#define DOG_NAME_SIZE 6
#define BASE_GRAPHICS_ADDRESS 0x6000000
#define PALETTE 0xF000

void printPlayerNameCredits(unsigned short *arrangements);
void writeCastText(unsigned short *bg0Arrangements, unsigned short *bg1Arrangements);
int getCharWidthCast(byte chr);
int getPCWidthCast(byte* pc_ptr, int max_size);
void setTilesToBlankCast(int *Tiles);
void printCastTiles(int Tiles[4], unsigned short *arrangements, int *graphics, unsigned short tileValue);
int readCastCharacter(byte chr, int Tiles[SIDE_BUFFER_SIZE + 1][4], unsigned short *arrangements, int x, int tile_y, unsigned short *lastEdited);
int readCastCharacterName(byte* str, int Tiles[SIDE_BUFFER_SIZE + 1][4], unsigned short *arrangements, int x, int tile_y, int max_size, unsigned short *lastEdited);
void printCastCharacterInMultiTiles(int Tiles[SIDE_BUFFER_SIZE + 1][4], byte *glyphRows, int glyphLen, int currLen);
void printCastCharacterInSingleTiles(int Tiles[SIDE_BUFFER_SIZE + 1][4], byte *glyphRows, int glyphLen, int currLen);
void copyTilesCast(int Tiles[SIDE_BUFFER_SIZE + 1][4], int indexMatrix);
int printCastCharacter(byte chr, int Tiles[SIDE_BUFFER_SIZE + 1][4], unsigned short *arrangements, int x, int tile_y, unsigned short *lastEdited);

extern byte m2_player1[];
extern byte cast_vwf_names[];
extern unsigned short m2_cast_vwf_free;
extern unsigned short m2_credits_conversion_table[];
extern int m2_bits_to_nybbles_fast_cast[];

#endif