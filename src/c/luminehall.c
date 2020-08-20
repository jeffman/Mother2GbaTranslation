#include "luminehall.h"
#include "locs.h"

void writeLumineHallText()
{
    //Function that writes out the Lumine text in the form of arrangements.
    //It adds a VWF to what the base game did
    byte *lumineText_curr_ptr = luminetext;
    int *hallLineSize = &m2_hall_line_size;
    int length = 0;
    int currLenInTile = 0;
    int currPos = 0;
    int Tiles[4];
    setTilesToBlank(Tiles);
    //First things first, it calculates the total length of the text in pixels
    while((*lumineText_curr_ptr) != END)
    {
        length += getCharWidth(*lumineText_curr_ptr);
        lumineText_curr_ptr++;
    }
    //It then gets the length in arrangements. It also makes sure it's a number divisible by 8.
    //This avoids having empty tiles showing
    length = (length & 7 == 0 ? length : (length + (8 - (length & 7)))) >> 1;
    (*hallLineSize) = length;
    lumineText_curr_ptr = luminetext;
    unsigned short *hallAddress = m2_get_hall_address();
    //Prints out the characters
    while((*lumineText_curr_ptr) != END)
    {
        readLumineCharacter(*lumineText_curr_ptr, Tiles, hallAddress, length, &currPos, &currLenInTile);
        lumineText_curr_ptr++;
    }
    //Avoid having tiles that were not entirely printed
    while((currPos*4) < length)
    {
        printVoidLumineTiles(hallAddress, length, currPos);
        currPos++;
    }
}

void readLumineCharacter(byte chr, int *Tiles, unsigned short *hallAddress, int length, int *currPos, int *currLen)
{
    //Reads a character. Handles special cases.
    //The valid characters are printed to the Tiles 1bpp buffer that stores the VWF form of the text.
    //This is then converted (when it makes sense to do so) to arrangements by printLumineTiles.
    int tileWidth = 2;
    int tileHeight = 2;
    int chosenLen;
    int renderedLen;
    byte *glyphRows;
    int AlternativeTiles[4];
    switch(chr)
    {
        case END:
            return;
        case BLANK:
            printEmptyLumineTile(Tiles, hallAddress, length, *currPos, *currLen);
            for(int i = 1; i < 8; i++)
                printVoidLumineTiles(hallAddress, length, (*currPos) + i);
            (*currPos) += 8;
            return;
        case PC_START:
        case PC_START+1:
        case PC_START+2:
        case PC_START+3:
            readLumineCharacterName(pc_names+(chr-PC_START)*(PC_NAME_SIZE + 2), Tiles, AlternativeTiles, hallAddress, length, currPos, currLen);
            return;
        default:
            chosenLen = m2_widths_table[0][chr] & 0xFF;
            renderedLen = m2_widths_table[0][chr] >> 8;
            glyphRows = &m2_font_table[0][chr * tileWidth * tileHeight * 8];
    }
    if(chosenLen <= 0)
        return;
    if(((*currLen) + chosenLen) >= 8)
    {
        setTilesToBlank(AlternativeTiles);
        if(renderedLen > 0)
            printLumineCharacterInMultiTiles(Tiles, AlternativeTiles, glyphRows, renderedLen, *currLen);
        printLumineTiles(Tiles, hallAddress, length, *currPos);
        (*currPos)++;
        copyTiles(Tiles, AlternativeTiles);
        (*currLen) = ((*currLen) + chosenLen) & 7;
    }
    else
    {
        if(renderedLen > 0)
            printLumineCharacterInSingleTiles(Tiles, glyphRows, renderedLen, *currLen);
        (*currLen) += chosenLen;
    }
}

void printEmptyLumineTile(int *Tiles, unsigned short *hallAddress, int length, int currPos, int currLen)
{
    //Prints either an entirely empty tile or what's been done in the current tile
    if(currLen == 0)
        printVoidLumineTiles(hallAddress, length, currPos);
    else
    {
        printLumineTiles(Tiles, hallAddress, length, currPos);
        setTilesToBlank(Tiles);
    }
}

void readLumineCharacterName(byte* str, int *Tiles, int* AlternativeTiles, unsigned short *hallAddress, int length, int *currPos, int *currLen)
{
    //Reads a playable character's name.
    //The characters are printed to the Tiles 1bpp buffer that stores the VWF form of the text.
    //This is then converted (when it makes sense to do so) to arrangements by printLumineTiles.
    //This is separate in order to avoid recursive issues caused by user's tinkering
    int tileWidth = 2;
    int tileHeight = 2;
    int chosenLen;
    int renderedLen;
    byte *glyphRows;
    for(int i = 0; i < PC_NAME_SIZE; i++)
    {
        if(*(str + 1) == 0xFF)
            return;
        byte chr = decode_character(*(str++));
        chosenLen = m2_widths_table[0][chr] & 0xFF;
        renderedLen = m2_widths_table[0][chr] >> 8;
        glyphRows = &m2_font_table[0][chr * tileWidth * tileHeight * 8];
        if(chosenLen <= 0)
            continue;
        if(((*currLen) + chosenLen) >= 8)
        {
            setTilesToBlank(AlternativeTiles);
            if(renderedLen > 0)
                printLumineCharacterInMultiTiles(Tiles, AlternativeTiles, glyphRows, renderedLen, *currLen);
            printLumineTiles(Tiles, hallAddress, length, *currPos);
            (*currPos)++;
            copyTiles(Tiles, AlternativeTiles);
            (*currLen) = ((*currLen) + chosenLen) & 7;
        }
        else
        {
            if(renderedLen > 0)
                printLumineCharacterInSingleTiles(Tiles, glyphRows, renderedLen, *currLen);
            (*currLen) += chosenLen;
        }
    }
    
}

void printLumineCharacterInMultiTiles(int *Tiles, int *AlternativeTiles, byte *glyphRows, int glyphLen, int currLen)
{
    //Prints a character to the tiles 1bpp buffer.
    //The part that goes beyond the tiles buffer will be printed to the AlternativeTiles buffer
    int tileWidth = 2;
    int tileHeight = 2;
    int startY = START_Y;
    
    for(int dTileY = 0; dTileY < tileHeight; dTileY++)
    {
        int tileIndex = dTileY * 2;
        for(int half = 0; half < 2; half++)
        {
            int tile = Tiles[tileIndex + half];
            int alternativeTile = AlternativeTiles[tileIndex + half];
            int endingTile = 0;
            int endingAlternativeTile = 0;
            for(int row = 0; row < 4; row++)
            {
                unsigned short canvasRow = ((tile >> (8 * row))&0xFF) | (((alternativeTile >> (8 * row))&0xFF) << 8);
                unsigned short glyphRow = 0;
                if(row + (half * 4) - startY >= 0)
                    glyphRow = glyphRows[row + (half * 4) - startY + (dTileY * 8 * tileWidth)] << currLen;
                else if(dTileY == 1)
                    glyphRow = glyphRows[row + (half * 4) - startY + 8] << currLen;
                canvasRow |= glyphRow;
                endingTile |= (canvasRow & 0xFF) << (8 * row);
                endingAlternativeTile |= ((canvasRow >> 8) & 0xFF) << (8 * row);
            }
            Tiles[tileIndex + half] = endingTile;
            AlternativeTiles[tileIndex + half] = endingAlternativeTile;
        }
    }
}

void printLumineCharacterInSingleTiles(int *Tiles, byte *glyphRows, int glyphLen, int currLen)
{
    //Prints a character to the tiles 1bpp buffer.
    //We know this won't go outside of the buffer's range, so we avoid some checks
    int tileWidth = 2;
    int tileHeight = 2;
    int startY = START_Y;
    
    for(int dTileY = 0; dTileY < tileHeight; dTileY++)
    {
        int tileIndex = dTileY * 2;
        for(int half = 0; half < 2; half++)
        {
            int tile = Tiles[tileIndex + half];
            int endingTile = 0;
            for(int row = 0; row < 4; row++)
            {
                byte canvasRow = ((tile >> (8 * row))&0xFF);
                byte glyphRow = 0;
                if(row + (half * 4) - startY >= 0)
                    glyphRow = glyphRows[row + (half * 4) - startY + (dTileY * 8 * tileWidth)] << currLen;
                else if(dTileY == 1)
                    glyphRow = glyphRows[row + (half * 4) - startY + 8] << currLen;
                canvasRow |= glyphRow;
                endingTile |= canvasRow << (8 * row);
            }
            Tiles[tileIndex + half] = endingTile;
        }
    }
}

void copyTiles(int *Tiles, int* AlternativeTiles)
{
    for(int i = 0; i < 4; i++)
        Tiles[i] = AlternativeTiles[i];
}

void setTilesToBlank(int *Tiles)
{
    for(int i = 0; i < 4; i++)
        Tiles[i] = 0;
}

void printLumineTiles(int *Tiles, unsigned short *hallAddress, int length, int currPos)
{
    //Converts what is written in 1bpp in the Tiles buffer to arrangements
    unsigned short *start = hallAddress + (currPos * 4);
    int currHalfTile;
    int value;
    for(int k = 0; k < 4; k++)
    {
        for(int i = 0; i < 2; i++)
        {
            currHalfTile = (Tiles[k] >> i*16)&0xFFFF;
            for(int j = 0; j < 4; j++)
            {
                value = (currHalfTile&3)+((currHalfTile>>6)&0xC);
                start[j] = luminesquaretable[value];
                currHalfTile = currHalfTile >> 2;
            }
            start += length;
        }
    }
        
}

void printVoidLumineTiles(unsigned short *hallAddress, int length, int currPos)
{
    //Prints empty arrangements fast
    unsigned short *start = hallAddress + (currPos*4);
    for(int k = 0; k < 4; k++)
    {
        for(int i = 0; i < 2; i++)
        {
            for(int j = 0; j < 4; j++)
            {
                start[j] = luminesquaretable[0];
            }
            start += length;
        }
    }
        
}

int getCharWidth(byte chr)
{
    //Gets the length for a character. Also handles special cases
    switch(chr)
    {
        case END:
            return 0;
        case BLANK:
            return BLANK_SIZE;
        case PC_START:
        case PC_START+1:
        case PC_START+2:
        case PC_START+3:
            return getPCWidth(pc_names+(chr-PC_START)*(PC_NAME_SIZE + 2));
        default:
            return m2_widths_table[0][chr] & 0xFF;
    }
}

int getPCWidth(byte* pc_ptr)
{
    //Gets the length for a playable character's name.
    //This is separate in order to avoid recursive issues caused by user's tinkering
    int length = 0;
    byte chr;
    for(int i = 0; i < PC_NAME_SIZE; i++)
    {
        chr = *(pc_ptr+i+1);
        if(chr == 0xFF)
            return length;
        chr = decode_character(*(pc_ptr+i));
        length += m2_widths_table[0][chr] & 0xFF;
    }
    return length;
}