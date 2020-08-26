#ifndef HEADER_LUMINE_INCLUDED
#define HEADER_LUMINE_INCLUDED

#include "types.h"
#include "locs.h"
#include "vwf.h"

#define LUMINE_FONT 0
#define LUMINE_FONT_WIDTH 2
#define LUMINE_FONT_HEIGHT 2
#define SIDE_BUFFER_SIZE 2
#define START_Y 2
#define END 0xFF
#define BLANK 0xFE
#define BLANK_SIZE 0x40
#define PC_START 0xFA
#define PC_NAME_SIZE 5

void writeLumineHallText();
int getCharWidth(byte chr);
int getPCWidth(byte* pc_ptr);
void setTilesToBlank(int *Tiles);
void printLumineTiles(int *Tiles, unsigned short *hallAddress, int length, int currPos);
void printVoidLumineTiles(unsigned short *hallAddress, int length, int currPos);
void printEmptyLumineTile(int *Tiles, unsigned short *hallAddress, int length, int currPos, int currLen);
void readLumineCharacter(byte chr, int *Tiles, unsigned short *hallAddress, int length, int *currPos, int *currLen);
void readLumineCharacterName(byte* str, int *Tiles, int AlternativeTiles[SIDE_BUFFER_SIZE][4], unsigned short *hallAddress, int length, int *currPos, int *currLen);
void printLumineCharacterInMultiTiles(int *Tiles, int AlternativeTiles[SIDE_BUFFER_SIZE][4], byte *glyphRows, int glyphLen, int currLen);
void printLumineCharacterInSingleTiles(int *Tiles, byte *glyphRows, int glyphLen, int currLen);
void copyTiles(int *Tiles, int AlternativeTiles[SIDE_BUFFER_SIZE][4], int indexMatrix);
void printLumineCharacter(byte chr, int *Tiles, int AlternativeTiles[SIDE_BUFFER_SIZE][4], unsigned short *hallAddress, int length, int *currPos, int *currLen);


extern unsigned short* m2_get_hall_address();

extern int m2_hall_line_size;
extern byte luminetext[];
extern unsigned short luminesquaretable[];
#endif