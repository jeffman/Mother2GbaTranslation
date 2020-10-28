#include "credits.h"

void printPlayerNameCredits(unsigned short *arrangements)
{
    //Converts the player name to arrangements
    int length = 0;
    byte *player_name = m2_player1;
    unsigned short yPosition = m2_credits_extras[0];
    unsigned short defaultNameLength = m2_credits_extras[1];
    //First things first, it calculates the length of the string
    for(length = 0; length < PLAYER_NAME_SIZE && (*(++player_name)) != 0xFF; length++);
    
    //Gets where to position the arrangements...
    int start_pos = ((0x1F - length) >> 1) + 1;
    int start_pos_default = ((0x1F - defaultNameLength) >> 1) + 1;
    unsigned short *player_name_arrangements = (yPosition << 5) + arrangements + start_pos;
    unsigned short *default_player_name_arrangements = (yPosition << 5) + arrangements + start_pos_default;
    player_name = m2_player1;
    
    //Clears the default MARIO player name...
    for(int i = 0; i < defaultNameLength; i++)
    {
        default_player_name_arrangements[i] = 0xF19B;
        default_player_name_arrangements[i + 0x20] = 0xF19B;
    }
    
    //Puts the new arrangements in
    for(int i = 0; i < length; i++)
    {
        unsigned short arrangement = m2_credits_conversion_table[player_name[i]];
        player_name_arrangements[i] = arrangement;
        player_name_arrangements[i + 0x20] = arrangement + 0x20;
    }
}
void writeCastText(unsigned short *bg0Arrangements, unsigned short *bg1Arrangements)
{
    //Function that writes out the VWF Cast roll text and puts the arrangements in.
    byte *castText_curr_ptr;
    byte *castText_curr_start = cast_vwf_names;
    int length;
    int Tiles[SIDE_BUFFER_SIZE + 1][4];
    unsigned short lastEdited = 0;
    
    //Do all the entries
    while((*castText_curr_start) != END_ALL)
    {
        //Read info
        unsigned short tile_y = (*castText_curr_start) + ((*(castText_curr_start + 1)) << 8);
        int center_x = *(castText_curr_start + 2);
        castText_curr_start += 3;
        
        //Setup
        castText_curr_ptr = castText_curr_start;
        length = 0;
        setTilesToBlankCast(Tiles[0]);
        
        //First things first, it calculates the total length of the text in pixels
        while((*castText_curr_ptr) != END)
            length += getCharWidthCast(*(castText_curr_ptr++));
        
        //Calculate the starting position of the text
        int x = center_x - (length >> 1);
        
        if((x + length) > 240) //GBA Screen width
            x = 240 - length;
        if(x < 0)
            x = 0;
        
        //It then gets the length in arrangements
        int effectiveLength = length;
        length = (length + 7) >> 3;
        castText_curr_ptr = castText_curr_start;
        int currXStart = x;
        
        //Prints out the characters
        while((*castText_curr_ptr) != END)
            x += readCastCharacter(*(castText_curr_ptr++), Tiles, bg0Arrangements, x, tile_y, &lastEdited);
        
        
        if((x & 7) != 0)
        {
            //Do the last one
            unsigned short baseTileValue = m2_cast_vwf_free;
            int *baseGraphicsPointer = (int*)((baseTileValue << 5) + BASE_GRAPHICS_ADDRESS);
            int currLen = x & 7;
            int currPos = x >> 3;
            unsigned short *baseArrangementsPointer = bg0Arrangements + (tile_y << 5) + currPos + 1;
            int tileValue = (((lastEdited) >> 5) << 6) + ((lastEdited) & 0x1F);
            lastEdited++;
            printCastTiles(Tiles[0], baseArrangementsPointer, baseGraphicsPointer + (tileValue << 3), baseTileValue + tileValue);
        }
        
        //End of cycle stuff
        castText_curr_start = (castText_curr_ptr + 1);
    }
}

int readCastCharacter(byte chr, int Tiles[SIDE_BUFFER_SIZE + 1][4], unsigned short *arrangements, int x, int tile_y, unsigned short *lastEdited)
{
    //Reads a character. Handles special cases.
    //The valid characters are printed to the Tiles 1bpp buffer that stores the VWF form of the text.
    //This is then stored (when it makes sense to do so) to arrangements and graphics by printCastTiles.
    switch(chr)
    {
        case END:
            return 0;
        case PC_START:
        case PC_START+1:
        case PC_START+2:
        case PC_START+3:
            return readCastCharacterName(pc_names+(chr-PC_START)*(PC_NAME_SIZE + 2), Tiles, arrangements, x, tile_y, PC_NAME_SIZE, lastEdited);
        case PC_START+4:
            return readCastCharacterName(pc_names+(chr-PC_START)*(PC_NAME_SIZE + 2), Tiles, arrangements, x, tile_y, DOG_NAME_SIZE, lastEdited);
        default:
            return printCastCharacter(chr, Tiles, arrangements, x, tile_y, lastEdited);
    }
}

int readCastCharacterName(byte* str, int Tiles[SIDE_BUFFER_SIZE + 1][4], unsigned short *arrangements, int x, int tile_y, int max_size, unsigned short *lastEdited)
{
    //Reads a playable character's name.
    //The characters are printed to the Tiles 1bpp buffer that stores the VWF form of the text.
    //This is then converted (when it makes sense to do so) to arrangements by printLumineTiles.
    //This is separate in order to avoid recursive issues caused by user's tinkering
    int totalLen = 0;

    for(int i = 0; i < max_size; i++)
    {
        if(*(str + 1) == 0xFF)
            return totalLen;
        byte chr = decode_character(*(str++));
        totalLen += printCastCharacter(chr, Tiles, arrangements, x + totalLen, tile_y, lastEdited);
    }
    return totalLen;
}

int printCastCharacter(byte chr, int Tiles[SIDE_BUFFER_SIZE + 1][4], unsigned short *arrangements, int x, int tile_y, unsigned short *lastEdited)
{
    //Function that gets a character and then prints it to the Tiles buffer.
    //If the buffer is full, it uses the AlternativeTiles side-buffer and then prints Tiles to the arrangements.
    //The same happens to any AlternativeTiles side-buffer that gets full
    int tileWidth = CAST_FONT_WIDTH;
    int tileHeight = CAST_FONT_HEIGHT;
    unsigned short baseTileValue = m2_cast_vwf_free;
    int *baseGraphicsPointer = (int*)((baseTileValue << 5) + BASE_GRAPHICS_ADDRESS);
    int chosenLen = m2_widths_table[CAST_FONT][chr] & 0xFF;
    int renderedLen = m2_widths_table[CAST_FONT][chr] >> 8;
    byte *glyphRows = &m2_font_table[CAST_FONT][chr * tileWidth * tileHeight * 8];
    int currLen = x & 7;
    int currPos = x >> 3;
    unsigned short *baseArrangementsPointer = arrangements + (tile_y << 5) + currPos + 1;
    
    if(chosenLen <= 0)
        return 0;

    if((currLen + chosenLen) >= 8)
    {
        for(int i = 0; i < SIDE_BUFFER_SIZE; i++)
            setTilesToBlankCast(Tiles[i + 1]);
        
        if(renderedLen > 0)
            printCastCharacterInMultiTiles(Tiles, glyphRows, renderedLen, currLen);
        
        int fullAlternatives = ((currLen + chosenLen) >> 3);
        for(int i = 0; i < fullAlternatives; i++)
        {
            int tileValue = (((*lastEdited) >> 5) << 6) + ((*lastEdited) & 0x1F);
            (*lastEdited)++;
            printCastTiles(Tiles[i], baseArrangementsPointer + i, baseGraphicsPointer + (tileValue << 3), baseTileValue + tileValue);
        }
        
        copyTilesCast(Tiles, fullAlternatives);
    }
    else if(renderedLen > 0)
        printCastCharacterInSingleTiles(Tiles, glyphRows, renderedLen, currLen);
    
    return chosenLen;
}

void printCastCharacterInMultiTiles(int Tiles[SIDE_BUFFER_SIZE + 1][4], byte *glyphRows, int glyphLen, int currLen)
{
    //Prints a character to the tiles 1bpp buffer.
    //The part that goes beyond the tiles buffer will be printed to the AlternativeTiles buffer
    int tileWidth = CAST_FONT_WIDTH;
    int tileHeight = CAST_FONT_HEIGHT;
    int startY = START_Y;
    
    for(int dTileY = 0; dTileY < tileHeight; dTileY++)
    {
        int tileIndex = dTileY * 2;
        int renderedWidth = glyphLen;
        int dTileX = 0;
        while(renderedWidth > 0)
        {
            int *currTile = Tiles[dTileX];
            int *currAlt = Tiles[dTileX + 1];
            for(int half = 0; half < 2; half++)
            {
                int tile = currTile[tileIndex + half];
                int alternativeTile = currAlt[tileIndex + half];
                int endingTile = 0;
                int endingAlternativeTile = 0;
                for(int row = 0; row < 4; row++)
                {
                    unsigned short canvasRow = ((tile >> (8 * row))&0xFF) | (((alternativeTile >> (8 * row))&0xFF) << 8);
                    unsigned short glyphRow = 0;
                    if(row + (half * 4) - startY >= 0)
                        glyphRow = glyphRows[row + (half * 4) - startY + (dTileY * 8 * tileWidth) + (dTileX * 8)] << currLen;
                    else if(dTileY == 1)
                        glyphRow = glyphRows[row + (half * 4) - startY + 8 + (dTileX * 8)] << currLen;
                    canvasRow |= glyphRow;
                    endingTile |= (canvasRow & 0xFF) << (8 * row);
                    endingAlternativeTile |= ((canvasRow >> 8) & 0xFF) << (8 * row);
                }
                currTile[tileIndex + half] = endingTile;
                currAlt[tileIndex + half] = endingAlternativeTile;
            }
            renderedWidth -= 8;
            dTileX++;
        }
    }
}

void printCastCharacterInSingleTiles(int Tiles[SIDE_BUFFER_SIZE + 1][4], byte *glyphRows, int glyphLen, int currLen)
{
    //Prints a character to the tiles 1bpp buffer.
    //We know this won't go outside of the buffer's range, so we avoid some checks
    int tileWidth = CAST_FONT_WIDTH;
    int tileHeight = CAST_FONT_HEIGHT;
    int startY = START_Y;
    
    for(int dTileY = 0; dTileY < tileHeight; dTileY++)
    {
        int tileIndex = dTileY * 2;
        for(int half = 0; half < 2; half++)
        {
            int tile = Tiles[0][tileIndex + half];
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
            Tiles[0][tileIndex + half] = endingTile;
        }
    }
}

void copyTilesCast(int Tiles[SIDE_BUFFER_SIZE + 1][4], int indexMatrix)
{
    for(int i = 0; i < 4; i++)
        Tiles[0][i] = Tiles[indexMatrix][i];
}

void setTilesToBlankCast(int *Tiles)
{
    for(int i = 0; i < 4; i++)
        Tiles[i] = 0;
}

void printCastTiles(int Tiles[4], unsigned short *arrangements, int *graphics, unsigned short tileValue)
{
    //Converts what is written in 1bpp in the Tiles buffer to graphics and arrangements
    int value;
    int currTile;
    for(int i = 0; i < 2; i++)
    {
        arrangements[(i << 5)] = PALETTE | (tileValue + (i << 5));
        for(int k = 0; k < 2; k++)
        {
            currTile = Tiles[k + (i * 2)];
            for(int j = 0; j < 4; j++)
                graphics[(i << 8) + (k << 2) + j] = m2_bits_to_nybbles_fast_cast[((currTile >> (j * 8)) & 0xFF)];
        }
    }
}

int getCharWidthCast(byte chr)
{
    //Gets the length for a character. Also handles special cases
    switch(chr)
    {
        case END:
            return 0;
        case PC_START:
        case PC_START+1:
        case PC_START+2:
        case PC_START+3:
            return getPCWidthCast(pc_names+(chr-PC_START)*(PC_NAME_SIZE + 2), PC_NAME_SIZE);
        case PC_START+4:
            return getPCWidthCast(pc_names+(chr-PC_START)*(PC_NAME_SIZE + 2), DOG_NAME_SIZE);
        default:
            return m2_widths_table[CAST_FONT][chr] & 0xFF;
    }
}

int getPCWidthCast(byte* pc_ptr, int max_size)
{
    //Gets the length for a playable character's name.
    //This is separate in order to avoid recursive issues caused by user's tinkering
    int length = 0;
    byte chr;
    for(int i = 0; i < max_size; i++)
    {
        chr = *(pc_ptr+i+1);
        if(chr == 0xFF)
            return length;
        chr = decode_character(*(pc_ptr+i));
        length += m2_widths_table[CAST_FONT][chr] & 0xFF;
    }
    return length;
}