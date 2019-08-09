#include "window.h"
#include "vwf.h"
#include "number-selector.h"
#include "locs.h"
#include "fileselect.h"

byte decode_character(byte chr)
{
    int c = chr - CHAR_OFFSET;
    if ((c < 0) || ((c >= CHAR_END) && (c < YOUWON_START)) || (c > ARROW))
        c = QUESTION_MARK;

    return c;
}

byte encode_ascii(char chr)
{
    return (byte)(chr + 48);
}

int get_tile_number(int x, int y)
{
    x--;
    y--;
    if(y > 0xF)
        y = 0xE + (y & 1);
    return m2_coord_table[x + ((y >> 1) * 28)] + (y & 1) * 32; //This is... Very not suited for tilemaps of variable width, which can have more than 0x10 tiles vertically.
}

int get_tile_number_with_offset(int x, int y)
{
    return get_tile_number(x, y) + *tile_offset;
}

int get_tile_number_grid(int x, int y)
{
    return x + (y * 32);
}

int expand_bit_depth(byte row, int foreground)
{
    foreground &= 0xF;
    return m2_bits_to_nybbles[row + (foreground * 256)];
}

byte reduce_bit_depth(int row, int foreground)
{
    int foregroundRow = row * 0x11111111;
    row ^= foregroundRow;

    int lower = m2_nybbles_to_bits[row & 0xFFFF];
    int upper = m2_nybbles_to_bits[(row >> 16) & 0xFFFF];

    return lower | (upper << 4);
}

// x,y: tile coordinates
void clear_tile_file(int x, int y, int pixels, int tile_offset_file)
{
    // Clear pixels
    int tileIndex = get_tile_number(x, y) + tile_offset_file;
    if(((tileIndex << 3) != (0xC9C0 >> 2)) && ((tileIndex << 3) != (0xC9E0 >> 2)))
        cpufastset(&pixels, &vram[tileIndex * 8], CPUFASTSET_FILL | 8);
}

// x,y: tile coordinates
void clear_rect_file(int x, int y, int width, int height, int pixels, int tile_offset_file, unsigned short *tilesetDestPtr)
{
    for (int tileY = 0; tileY < height; tileY++)
    {
        for (int tileX = 0; tileX < width; tileX++)
        {
            if((tilesetDestPtr[x + tileX + ((y + tileY) * width)] & 0x3FF) != 0x95)
                clear_tile_file(x + tileX, y + tileY, pixels, tile_offset_file);
            else
                break;
        }
    }
}

void wrapper_file_string(int x, int y, int length, byte *str, int window_selector)
{
    m2_cstm_last_printed[0] = window_selector; //First time setup
    print_file_string(x, y, length, str, window_selector, 0);
}

void wrapper_delete_string(int x, int y, int length, byte *str, int window_selector)
{
    print_file_string(x, y, length, str - 0x20 + 0x40 - 0x15, window_selector, 0x6000);
}

void wrapper_name_string(int x, int y, int length, byte *str, int window_selector)
{
    char String[length];
    for(int i = 0; i < length; i++)
    {
        if(str[i] == 0xFD)
            String[i] = 0x70;
        else if(str[i] == 0xF1)
            String[i] = 0x53;
        else
            String[i] = str[i];
    }
    print_file_string(x, y, length, String, window_selector, 0x7800);
}

void wrapper_name_summary_string(int x, int y, int length, byte *str, int window_selector)
{
    char String[length];
    for(int i = 0; i < length; i++)
            String[i] = str[i];
    print_file_string(x, y, length, String, window_selector, 0x2800);
}

int count_pixels(byte *str, int length)
{
    int pixels = 0;
    for(int i = 0; i < length; i++)
        if((str[i] != 0xFF) && (str[i] != 0xFE)) //The latter one is not really needed
            pixels += (m2_widths_table[0][decode_character(str[i])] & 0xFF);
    int tiles = pixels >> 3;
    if((pixels & 7) != 0)
        tiles +=1;
    return tiles;
}

void wrapper_copy_string(int x, int y, int length, byte *str, int window_selector)
{
    print_file_string(x, y, length, str, window_selector, 0x6000);
}

void clearArr(int x, int y, int width, unsigned short *tilesetDestPtr)
{
    for(int i = x; i < width - 2; i++)
    {
        if((tilesetDestPtr[i + (y * width)] & 0x3FF) != 0x95)
        {
            tilesetDestPtr[i + (y * width)] = 0x13F;
            tilesetDestPtr[i + ((y+1) * width)] = 0x13F;
        }
        else
            break;
    }
}

void print_file_string(int x, int y, int length, byte *str, int window_selector, int offset)
{
    int *tilesetBasePtr = (int *)(0x82B79B4 + (window_selector * 20));
    int width = tilesetBasePtr[2];
    unsigned short *tilesetDestPtr = (unsigned short *)(tilesetBasePtr[0]);
    clearArr(x, y, width, tilesetDestPtr); //Cleans all of the arrangements this line could ever use
    
    int pixelX = x * 8;
    int pixelY = (y * 8) + 3;
    int realmask = *palette_mask;
    *palette_mask = 0; //File select is special and changes its palette_mask on the fly.
    clear_rect_file(x, y, width, 2, 0x11111111, 0x400 + (offset >> 5), tilesetDestPtr); //Clean the rectangle before printing

    for (int i = 0; i < length; i++)
    {
        byte chr = str[i];

        if (chr == 0xFF)
        {
            break; // the game does something else here, haven't looked into what exactly
        }
        else if (chr == 0xFE)
        {
            // Define 0xFE as a control code
            byte cmd = str[++i];
            switch (cmd)
            {
                case CUSTOMCC_ADD_X:
                    pixelX += str[++i];
                    break;

                case CUSTOMCC_SET_X:
                    pixelX = str[++i];
                    break;
            }
            continue;
        }

        chr = decode_character(chr);
        int pixels = print_character_with_callback(
            chr,
            pixelX,
            pixelY,
            0,
            9,
            vram + 0x2000 + (offset >> 2),
            &get_tile_number,
            tilesetDestPtr,
            width,
            (offset >>5));

        pixelX += pixels;
    }
    *palette_mask = realmask;
}

unsigned short setupCursorAction(int *Pos1, int *Pos2)
{
    int *a = (int *)0x3000024;
    int *caller = (int *)a[0];
    int CursorX = caller[0xDA4 >> 2];
    int CursorY = caller[0xDA8 >> 2];
    int alphabet = caller[0xDAC >> 2];
    int *table = (int *)0x82B8FFC; //Address of the alphabet table
    
    int choice = 0;
    int counter = 0;
    
    for(int i = 0; i < CursorY; i++)
    {
        if(i <= 4)
            choice += 0xE;
        else
            choice += 3;
    }
    
    choice += CursorX;
    (*Pos1) = alphabet;
    (*Pos2) = choice;
    
    unsigned short letter = (table[choice] >> (16 * alphabet));
    return letter;
}

void setupCursorMovement()
{
    int *a = (int *)0x3000024;
    int *caller = (int *)a[0];
    int CursorX = caller[0xDA4 >> 2];
    int CursorY = caller[0xDA8 >> 2];
    int yAxys = 0;
    int xAxys = 0;
    
    // Check for pressing left or right
    PAD_STATE state = *pad_state;

    if (state.right)
        xAxys = 1;
    else if (state.left)
        xAxys = -1;
    else if (state.up)
        yAxys = -1;
    else if(state.down)
        yAxys = 1;

    if(xAxys != 0)
    {
        CursorX += xAxys;
        switch(CursorY)
        {
            case 0:
            case 1:
            case 2:
                if(CursorX < 0)
                    CursorX = 0xA;
                if(CursorX > 0xA)
                    CursorX = 0;
            break;
            case 3:
                if(CursorX < 0)
                    CursorX = 0xB;
                if(CursorX > 0xB)
                    CursorX = 0;
            break;
            case 4:
                if(CursorX < 0)
                    CursorX = 0x3;
                if(CursorX > 0x3)
                    CursorX = 0;
            break;
            default:
                if(CursorX < 0)
                    CursorX = 0x2;
                if(CursorX > 0x2)
                    CursorX = 0;
            break;
        }
        m2_soundeffect(0x1A7);
    }
    else if(yAxys != 0)
    {
        switch(CursorY)
        {
            case 0:
            case 1:
            case 2:
                CursorY += yAxys;
                if(CursorY < 0)
                {
                    if((CursorX >= 0x9))
                    {
                        CursorX = 2 + CursorX - 0x9;
                        CursorY = 4;
                    }
                    else if(CursorX == 0)
                        CursorY = 5;
                    else
                        CursorY = 3;
                }
                else if(CursorY == 3 && CursorX >= 0x9)
                    CursorX += 1;
            break;
            case 3:
                CursorY += yAxys;
                if(CursorY == 2 && CursorX >= 9)
                    CursorX -=1;
                if(CursorY == 4)
                {
                    if(CursorX <= 3)
                        CursorX = 0;
                    else if (CursorX <= 9)
                        CursorX = 1;
                    else
                        CursorX = 2 + CursorX - 0xA;
                }
            break;
            case 4:
                CursorY += yAxys;
                if(CursorY == 3)
                {
                    if(CursorX >= 2)
                        CursorX = 0xA + CursorX - 2;
                    if(CursorX == 1)
                        CursorX = 4;
                }
                if(CursorY == 5)
                {
                    if(CursorX >= 2)
                        CursorX = 1;
                    else
                        CursorX = 0;
                }
            break;
            default:
                CursorY += yAxys;
                if(CursorY == 4 && CursorX == 2)
                    CursorX = 3;
                if(CursorY == 6)
                {
                    if(CursorX == 0)
                        CursorY = 0;
                    else
                        CursorY = 5;
                }
            break;
        }
        m2_soundeffect(0x1A8);
    }
    
    caller[0xDA4 >> 2] = CursorX;
    caller[0xDA8 >> 2] = CursorY;
}

void setupCursorPosition(int *x, int *y)
{
    int *a = (int *)0x3000024;
    int *caller = (int *)a[0];
    int CursorX = caller[0xDA4 >> 2];
    int CursorY = caller[0xDA8 >> 2];
    (*x) = 0;
    (*y) = 0;
    if(CursorY <= 4)
    {
        (*y) = 2 + (CursorY << 1);
        switch(CursorY)
        {
            case 0:
            case 1:
            case 2:
                switch(CursorX)
                {
                    case 9:
                    case 0xA:
                        (*x) = 23 + ((CursorX -9) << 1);
                    break;
                    default:
                        (*x) = 1 + (CursorX << 1);
                    break;
                }
            break;
            case 3:
                switch(CursorX)
                {
                    case 0xA:
                    case 0xB:
                        (*x) = 23 + ((CursorX -0xA) << 1);
                    break;
                    default:
                        (*x) = 1 + (CursorX << 1);
                    break;
                }
            break;
            default:
                switch(CursorX)
                {
                    case 0:
                        (*x) = 1;
                    break;
                    case 1:
                        (*x) = 8;
                    break;
                    case 2:
                    case 3:
                        (*x) = 23 + ((CursorX- 2) << 1);
                    break;
                }
            break;
        }
    }
    else
    {
        (*y) = 14;
        switch(CursorX)
        {
            case 0:
                (*x) = 1;
            break;
            case 1:
                (*x) = 18;
            break;
            default:
                (*x) = 26;
            break;
        }
    }
}

void format_options_cc(char String[], int *index, byte cmd)
{
    String[(*index)++] = 0xFE;
    String[(*index)++] = cmd;
}

void options_setup(char String[])
{
    int index = 0;
    char Continue[] = "Continue";
    for(int i = 0; i < (sizeof(Continue) -1); i++)
        String[index++] = encode_ascii(Continue[i]);
    
    // Re-position
    format_options_cc(String, &index, CUSTOMCC_SET_X);
    String[index++] = 64;
            
    char Copy[] = "Copy";
    for(int i = 0; i < (sizeof(Copy) -1); i++)
        String[index++] = encode_ascii(Copy[i]);
            
    // Re-position
    format_options_cc(String, &index, CUSTOMCC_SET_X);
    String[index++] = 97;
            
    char Delete[] = "Delete";
    for(int i = 0; i < (sizeof(Delete) -1); i++)
        String[index++] = encode_ascii(Delete[i]);
            
    // Re-position
    format_options_cc(String, &index, CUSTOMCC_SET_X);
    String[index++] = 137;
            
    char Setup[] = "Set Up";
    for(int i = 0; i < (sizeof(Setup) -1); i++)
        String[index++] = encode_ascii(Setup[i]);
            
    //END
    String[index++] = 0xFF;
}

void text_speed_setup(char String[], int selector)
{
    int index = 0;
    char Text_Speed[] = "Please select text speed.";
    char Medium[] = "Medium";
    char Fast[] = "Fast";
    char Slow[] = "Slow";
    switch(selector)
    {
        case 0:
            for(int i = 0; i < (sizeof(Text_Speed) -1); i++)
                String[index++] = encode_ascii(Text_Speed[i]);
        break;
        case 1:
            for(int i = 0; i < (sizeof(Fast) -1); i++)
                String[index++] = encode_ascii(Fast[i]);
        break;
        case 2:
            for(int i = 0; i < (sizeof(Medium) -1); i++)
                String[index++] = encode_ascii(Medium[i]);
        break;
        default:
            for(int i = 0; i < (sizeof(Slow) -1); i++)
                String[index++] = encode_ascii(Slow[i]);
        break;
    }
    //END
    String[index++] = 0xFF;
}

void delete_setup(char String[], int selector)
{
    int index = 0;
    char Delete[] = "Are you sure you want to delete?";
    char No[] = "No";
    char Yes[] = "Yes";
    switch(selector)
    {
        case 0:
            for(int i = 0; i < (sizeof(Delete) -1); i++)
                String[index++] = encode_ascii(Delete[i]);
        break;
        case 1:
            for(int i = 0; i < (sizeof(No) -1); i++)
                String[index++] = encode_ascii(No[i]);
        break;
        default:
            for(int i = 0; i < (sizeof(Yes) -1); i++)
                String[index++] = encode_ascii(Yes[i]);
        break;
    }
    //END
    String[index++] = 0xFF;
}

void text_flavour_setup(char String[], int selector)
{
    int index = 0;
    char Text_Flavour_1[] = "Which style of windows";
    char Text_Flavour_2[] = "do you prefer?";
    char Plain[] = "Plain flavor";
    char Mint[] = "Mint flavor";
    char Strawberry[] = "Strawberry flavor";
    char Banana[] = "Banana flavor";
    char Peanut[] = "Peanut flavor";
    switch(selector)
    {
        case 0:
            for(int i = 0; i < (sizeof(Text_Flavour_1) -1); i++)
                String[index++] = encode_ascii(Text_Flavour_1[i]);
        break;
        case 1:
            for(int i = 0; i < (sizeof(Text_Flavour_2) -1); i++)
                String[index++] = encode_ascii(Text_Flavour_2[i]);
        break;
        case 2:
            for(int i = 0; i < (sizeof(Plain) -1); i++)
                String[index++] = encode_ascii(Plain[i]);
        break;
        case 3:
            for(int i = 0; i < (sizeof(Mint) -1); i++)
                String[index++] = encode_ascii(Mint[i]);
        break;
        case 4:
            for(int i = 0; i < (sizeof(Strawberry) -1); i++)
                String[index++] = encode_ascii(Strawberry[i]);
        break;
        case 5:
            for(int i = 0; i < (sizeof(Banana) -1); i++)
                String[index++] = encode_ascii(Banana[i]);
        break;
        default:
            for(int i = 0; i < (sizeof(Peanut) -1); i++)
                String[index++] = encode_ascii(Peanut[i]);
        break;
    }
    //END
    String[index++] = 0xFF;
}

void description_setup(char String[], int selector)
{
    int index = 0;
    char Ness[] = "Please name him.";
    char Paula[] = "Name her, too.";
    char Jeff[] = "Name your friend.";
    char Poo[] = "Name another friend.";
    char King[] = "Name your pet.";
    char FavFood[] = "Favorite homemade food?";
    char FavThing[] = "What's your favorite thing?";
    switch(selector)
    {
        case 3:
            for(int i = 0; i < (sizeof(Ness) -1); i++)
                String[index++] = encode_ascii(Ness[i]);
        break;
        case 4:
            for(int i = 0; i < (sizeof(Paula) -1); i++)
                String[index++] = encode_ascii(Paula[i]);
        break;
        case 5:
            for(int i = 0; i < (sizeof(Jeff) -1); i++)
                String[index++] = encode_ascii(Jeff[i]);
        break;
        case 6:
            for(int i = 0; i < (sizeof(Poo) -1); i++)
                String[index++] = encode_ascii(Poo[i]);
        break;
        case 7:
            for(int i = 0; i < (sizeof(King) -1); i++)
                String[index++] = encode_ascii(King[i]);
        break;
        case 8:
            for(int i = 0; i < (sizeof(FavFood) -1); i++)
                String[index++] = encode_ascii(FavFood[i]);
        break;
        default:
            for(int i = 0; i < (sizeof(FavThing) -1); i++)
                String[index++] = encode_ascii(FavThing[i]);
        break;
    }
    //END
    String[index++] = 0xFF;
}

void copy_setup(char String[])
{
    int index = 0;
    char Copy[] = "Copy to where?";
    for(int i = 0; i < (sizeof(Copy) -1); i++)
        String[index++] = encode_ascii(Copy[i]);
    //END
    String[index++] = 0xFF;
}

void letterSetup(char String[], int selector, bool capital, int *index)
{
    char base = capital ? 'A' : 'a';
    int value = 9 - (selector >> 1);
    for(int i = 0; i < value; i++)
    {
        String[(*index)++] = encode_ascii(base + i + (selector * 9));
        // Re-position
        format_options_cc(String, &(*index), CUSTOMCC_SET_X);
        if(i != value -1)
            String[(*index)++] = (2 * (i + 2)) << 3;
        else
            String[(*index)++] = (24) << 3;
    }
    switch(selector)
    {
        case 0:
            String[(*index)++] = 93;
            // Re-position
            format_options_cc(String, &(*index), CUSTOMCC_SET_X);
            String[(*index)++] = (26) << 3;
            String[(*index)++] = 83;
        break;
        case 1:
            String[(*index)++] = 87;
            // Re-position
            format_options_cc(String, &(*index), CUSTOMCC_SET_X);
            String[(*index)++] = (26) << 3;
            String[(*index)++] = 174;
        break;
        default:
            String[(*index)++] = 94;
            // Re-position
            format_options_cc(String, &(*index), CUSTOMCC_SET_X);
            String[(*index)++] = (26) << 3;
            String[(*index)++] = 95;
        break;
    }
}
void numbersSetup(char String[], int *index)
{
    char base = '0';
    for(int i = 0; i < 10; i++)
    {
        String[(*index)++] = encode_ascii(base + i);
        // Re-position
        format_options_cc(String, &(*index), CUSTOMCC_SET_X);
        if(i != 9)
            String[(*index)++] = (2 * (i + 2)) << 3;
        else
            String[(*index)++] = (24) << 3;
    }
    String[(*index)++] = 81;
    // Re-position
    format_options_cc(String, &(*index), CUSTOMCC_SET_X);
    String[(*index)++] = (26) << 3;
    String[(*index)++] = 0xAC;
}

void alphabet_setup(char String[], int selector, bool capital)
{
    int index = 0;
    char Capital[] = "CAPITAL";
    char Small[] = "small";
    char DontCare[] = "Don't Care";
    char Backspace[] = "Backspace";
    char Ok[] = "OK";
    switch(selector)
    {
        case 0:
        case 1:
        case 2:
            letterSetup(String, selector, capital, &index);
        break;
        case 3:
            numbersSetup(String, &index);
        break;
        case 4:
            for(int i = 0; i < (sizeof(Capital) -1); i++)
                String[index++] = encode_ascii(Capital[i]);
            //Re-position
            format_options_cc(String, &index, CUSTOMCC_SET_X);
            String[index++] = (9) << 3;
            for(int i = 0; i < (sizeof(Small) -1); i++)
                String[index++] = encode_ascii(Small[i]);
            //Re-position
            format_options_cc(String, &index, CUSTOMCC_SET_X);
            String[index++] = (24) << 3;
            String[index++] = 111;
            // Re-position
            format_options_cc(String, &index, CUSTOMCC_SET_X);
            String[index++] = (26) << 3;
            String[index++] = 0xAF;
        break;
        default:
            for(int i = 0; i < (sizeof(DontCare) -1); i++)
                String[index++] = encode_ascii(DontCare[i]);
            //Re-position
            format_options_cc(String, &index, CUSTOMCC_SET_X);
            String[index++] = (19) << 3;
            for(int i = 0; i < (sizeof(Backspace) -1); i++)
                String[index++] = encode_ascii(Backspace[i]);
            //Re-position
            format_options_cc(String, &index, CUSTOMCC_SET_X);
            String[index++] = (27) << 3;
            for(int i = 0; i < (sizeof(Ok) -1); i++)
                String[index++] = encode_ascii(Ok[i]);
        break;
    }
    //END
    String[index++] = 0xFF;
}

void summary_setup(char String[], int selector)
{
    int index = 0;
    char FavFood[] = "Favorite food:";
    char FavThing[] = "Coolest thing:";
    char AreYouSure[] = "Are you sure?";
    char Yep[] = "Yep";
    char Nope[] = "Nope";
    switch(selector)
    {
        case 0:
            for(int i = 0; i < (sizeof(FavFood) -1); i++)
                String[index++] = encode_ascii(FavFood[i]);
        break;
        case 1:
            for(int i = 0; i < (sizeof(FavThing) -1); i++)
                String[index++] = encode_ascii(FavThing[i]);
        break;
        default:
            for(int i = 0; i < (sizeof(AreYouSure) -1); i++)
                String[index++] = encode_ascii(AreYouSure[i]);
            //Re-position
            format_options_cc(String, &index, CUSTOMCC_SET_X);
            String[index++] = (0x10) << 3;
            for(int i = 0; i < (sizeof(Yep) -1); i++)
                String[index++] = encode_ascii(Yep[i]);
            //Re-position
            format_options_cc(String, &index, CUSTOMCC_SET_X);
            String[index++] = (0x14) << 3;
            for(int i = 0; i < (sizeof(Nope) -1); i++)
                String[index++] = encode_ascii(Nope[i]);
        break;
    }
    //END
    String[index++] = 0xFF;
}

void print_windows(int window_selector)
{
    char String[64];
    int offset = 0;
    switch(window_selector)
    {
        case 0x10: //Delete
            offset = 0x6000;
            delete_setup(String, 0);
            print_file_string(1, 1, 0x40, String, window_selector, offset);
            delete_setup(String, 1);
            print_file_string(2, 5, 0x40, String, window_selector, offset);
            delete_setup(String, 2);
            print_file_string(2, 7, 0x40, String, window_selector, offset);
            m2_cstm_last_printed[0] = window_selector | (m2_cstm_last_printed[0] & 0x20);
            break;
        case 0xE: //Options
            offset = 0x1800;
            options_setup(String);
            print_file_string(2, 1, 0x40, String, window_selector, offset);
            m2_cstm_last_printed[0] = window_selector | (m2_cstm_last_printed[0] & 0x20);
        break;
        case 1: //Text Speed
            if(((m2_cstm_last_printed[0] & 0x1F) != 2) && ((m2_cstm_last_printed[0] & 0x1F) != 1)) //If Text Flavour is printed, then this is too. No need to reprint. Avoids tearing
            {
                offset = 0x6000;
                text_speed_setup(String, 0);
                print_file_string(1, 1, 0x40, String, window_selector, offset);
                text_speed_setup(String, 1);
                print_file_string(2, 3, 0x40, String, window_selector, offset);
                text_speed_setup(String, 2);
                print_file_string(2, 5, 0x40, String, window_selector, offset);
                text_speed_setup(String, 3);
                print_file_string(2, 7, 0x40, String, window_selector, offset);
                m2_cstm_last_printed[0] = window_selector | (m2_cstm_last_printed[0] & 0x20);
            }
        break;
        case 0x2: //Text Flavour
            if((m2_cstm_last_printed[0] & 0x1F) != 2){
                offset = 0x2800;
                text_flavour_setup(String, 0);
                print_file_string(1, 1, 0x40, String, window_selector, offset);
                text_flavour_setup(String, 1);
                print_file_string(1, 3, 0x40, String, window_selector, offset);
                text_flavour_setup(String, 2);
                print_file_string(2, 5, 0x40, String, window_selector, offset);
                text_flavour_setup(String, 3);
                print_file_string(2, 7, 0x40, String, window_selector, offset);
                text_flavour_setup(String, 4);
                print_file_string(2, 9, 0x40, String, window_selector, offset);
                text_flavour_setup(String, 5);
                print_file_string(2, 11, 0x40, String, window_selector, offset);
                text_flavour_setup(String, 6);
                print_file_string(2, 13, 0x40, String, window_selector, offset);
                m2_cstm_last_printed[0] = window_selector; //Set the alphabet bit to 0.
            }
        break;
        case 0xF: //Copy
            offset = 0x6000;
            copy_setup(String);
            print_file_string(1, 1, 0x40, String, window_selector, offset);
        break;
        case 0x3: //Ness' name + description
        case 0x4: //Paula's name + description
        case 0x5: //Jeff's name + description
        case 0x6: //Poo's name + description
        case 0x7: //King's name + description
        case 0x8: //FavFood's name + description
        case 0x9: //FavThing's name + description
            if((m2_cstm_last_printed[0] & 0x1F) != window_selector){
				if(window_selector == 3)
					m2_cstm_last_printed[0] = window_selector; //Set the alphabet bits to 0. Fixes issue where random garbage would go in here when transitioning screen from the main menu.
                offset = 0x1800;
                description_setup(String, window_selector);
                print_file_string(9, 1, 0x40, String, window_selector, offset);
                m2_cstm_last_printed[0] = window_selector | (m2_cstm_last_printed[0] & 0x20);
            }
        break;
        case 0xA: //Alphabet 1
            if((m2_cstm_last_printed[0] & 0x20) == 0) //Print this once and stop
            {
                //Main thing
                offset = 0x2800;
                alphabet_setup(String, 0, true);
                print_file_string(2, 1, 0x40, String, window_selector, offset);
                alphabet_setup(String, 1, true);
                print_file_string(2, 3, 0x40, String, window_selector, offset);
                alphabet_setup(String, 2, true);
                print_file_string(2, 5, 0x40, String, window_selector, offset);
                alphabet_setup(String, 3, true);
                print_file_string(2, 7, 0x40, String, window_selector, offset);
                alphabet_setup(String, 4, true);
                print_file_string(2, 9, 0x40, String, window_selector, offset);
                alphabet_setup(String, 5, true);
                print_file_string(2, 13, 0x40, String, window_selector, offset);
                m2_cstm_last_printed[0] = (m2_cstm_last_printed[0] & 0x1F) | 0x20; //Printed flag
            }
        break;
        case 0xB: //Alphabet 2
            if((m2_cstm_last_printed[0] & 0x40) == 0) //Print this once and stop
            {
                //Main thing
                offset = 0x2800;
                alphabet_setup(String, 0, false);
                print_file_string(2, 1, 0x40, String, window_selector, offset);
                alphabet_setup(String, 1, false);
                print_file_string(2, 3, 0x40, String, window_selector, offset);
                alphabet_setup(String, 2, false);
                print_file_string(2, 5, 0x40, String, window_selector, offset);
                alphabet_setup(String, 3, false);
                print_file_string(2, 7, 0x40, String, window_selector, offset);
                alphabet_setup(String, 4, true);
                print_file_string(2, 9, 0x40, String, window_selector, offset);
                alphabet_setup(String, 5, true);
                print_file_string(2, 13, 0x40, String, window_selector, offset);
                m2_cstm_last_printed[0] = (m2_cstm_last_printed[0] & 0x1F) | 0x40; //Printed flag
            }
        
        break;
        case 0xC: //Alphabet 3 - Won't use
        
        break;
        case 0xD: //Is this okay? Yes No
            offset = 0x2800;
            summary_setup(String, 0);
            print_file_string(0xC, 5, 0x40, String, window_selector, offset);
            summary_setup(String, 1);
            print_file_string(0xC, 0xB, 0x40, String, window_selector, offset);
            summary_setup(String, 2);
            print_file_string(0x1, 0x11, 0x40, String, window_selector, offset);
            m2_cstm_last_printed[0] = window_selector; //Set the alphabet bit to 0.
        break;
        default: //File select string, already printed
        break;
    }
    
}


void format_file_cc(FILE_SELECT *file, int *index, byte cmd)
{
    file->formatted_str[(*index)++] = 0xFE;
    file->formatted_str[(*index)++] = cmd;
}

int ascii_strlen(char *str)
{
    int len = 0;
    while (str[len] != 0)
        len++;
    return len;
}

void format_file_string(FILE_SELECT *file)
{
    int index = 0;

    // Slot
    int slot = file->slot + 1;
    file->formatted_str[index++] = (byte)(slot + ZERO);
    file->formatted_str[index++] = encode_ascii(':');
    file->formatted_str[index++] = encode_ascii(' ');

    if (file->status != 0)
    {
        char startNewStr[] = "Start New Game";
        for (int i = 0; i < (sizeof(startNewStr) - 1); i++)
            file->formatted_str[index++] = encode_ascii(startNewStr[i]);

        file->formatted_str[index++] = 0xFF;
        return;
    }

    // Name
    for (int i = 0; i < 5; i++)
    {
        byte name_chr = file->ness_name[i];

        if (name_chr != 0xFF)
            file->formatted_str[index++] = name_chr;
        else
            file->formatted_str[index++] = encode_ascii(' ');
    }

    // Re-position
    format_file_cc(file, &index, CUSTOMCC_SET_X);
    file->formatted_str[index++] = 76;

    // Level
    char levelStr[] = "Level: ";
    for (int i = 0; i < (sizeof(levelStr) - 1); i++)
        file->formatted_str[index++] = encode_ascii(levelStr[i]);

    int level = file->ness_level;
    int ones = m2_remainder(level, 10);
    int tens = m2_div(level, 10);

    if (tens > 0)
        file->formatted_str[index++] = tens + ZERO;

    file->formatted_str[index++] = ones + ZERO;

    // Re-position
    format_file_cc(file, &index, CUSTOMCC_SET_X);
    file->formatted_str[index++] = 128;

    // Text speed
    char textSpeedStr[] = "Text Speed: ";
    for (int i = 0; i < (sizeof(textSpeedStr) - 1); i++)
        file->formatted_str[index++] = encode_ascii(textSpeedStr[i]);

    char speedStrs[][7] = {
        "Fast",
        "Medium",
        "Slow"
    };

    char *speedStr = speedStrs[file->text_speed];
    for (int i = 0; i < ascii_strlen(speedStr); i++)
        file->formatted_str[index++] = encode_ascii(speedStr[i]);

    file->formatted_str[index++] = 0xFF;
    
    //Delete part

    index = (0x40 - 0x15); //Maximum length of this is 0x15 with the 0xFF. The strings do not collide... By 1 byte. If you were to remove this string's end (which you could), it would be by 2 bytes.
    
    file->formatted_str[index++] = (byte)(slot + ZERO);
    file->formatted_str[index++] = encode_ascii(':');
    file->formatted_str[index++] = encode_ascii(' ');
    
    // Name
    for (int i = 0; i < 5; i++)
    {
        byte name_chr = file->ness_name[i];

        if (name_chr != 0xFF)
            file->formatted_str[index++] = name_chr;
        else
            file->formatted_str[index++] = encode_ascii(' ');
    }

    // Re-position
    format_file_cc(file, &index, CUSTOMCC_SET_X);
    file->formatted_str[index++] = 72;
    
    for (int i = 0; i < (sizeof(levelStr) - 1); i++)
        file->formatted_str[index++] = encode_ascii(levelStr[i]);

    if (tens > 0)
        file->formatted_str[index++] = tens + ZERO;

    file->formatted_str[index++] = ones + ZERO;
    
    file->formatted_str[index++] = 0xFF;
}

byte print_character(byte chr, int x, int y)
{
    return print_character_formatted(chr, x, y, 0, 0xF);
}

byte print_character_formatted(byte chr, int x, int y, int font, int foreground)
{
    // 0x64 to 0x6C (inclusive) is YOU WON
    if ((chr >= YOUWON_START) && (chr <= YOUWON_END))
    {
        print_special_character(chr + 0xF0, x, y);
        return 8;
    }

    // 0x6D is an arrow ->
    else if (chr == ARROW)
    {
        print_special_character(ARROW + 0x30, x, y);
        return 8;
    }

    return print_character_with_callback(chr, x, y, font, foreground, vram, &get_tile_number_with_offset, *tilemap_pointer, 32, 0);
}

byte print_character_to_ram(byte chr, int *dest, int xOffset, int font, int foreground)
{
    return print_character_with_callback(chr, xOffset, 0, font, foreground, dest, &get_tile_number_grid, NULL, 32, 0);
}

// Prints a special tile. Pixels are copied to the VWF buffer.
// x, y in pixels
void print_special_character(int tile, int x, int y)
{
    // Special graphics must be tile-aligned
    x >>= 3;
    y >>= 3;
    unsigned short sourceTileIndex = tile + *tile_offset;
    unsigned short destTileIndex = get_tile_number(x, y) + *tile_offset;

    (*tilemap_pointer)[x + (y * 32)] = destTileIndex | *palette_mask;
    (*tilemap_pointer)[x + ((y + 1) * 32)] = (destTileIndex + 32) | *palette_mask;

    cpufastset(&vram[sourceTileIndex * 8], &vram[destTileIndex * 8], 8);
    cpufastset(&vram[(sourceTileIndex + 32) * 8], &vram[(destTileIndex + 32) * 8], 8);
}

// Maps a special character to the given tile coordinates. Only the tilemap is changed.
// x, y in tiles
void map_special_character(unsigned short tile, int x, int y)
{
    tile = format_tile(tile, false, false);
    (*tilemap_pointer)[x + (y * 32)] = tile;
    (*tilemap_pointer)[x + ((y + 1) * 32)] = tile + 32;
}

// Maps a tile to the given tile coordinates. Only the tilemap is changed.
// x, y in tiles
void map_tile(unsigned short tile, int x, int y)
{
    tile = format_tile(tile, false, false);
    (*tilemap_pointer)[x + (y * 32)] = tile;
}

byte print_character_with_callback(byte chr, int x, int y, int font, int foreground,
    int *dest, int (*getTileCallback)(int, int), unsigned short *tilemapPtr, int tilemapWidth, int tilemapOffset)
{
    int tileWidth = m2_font_widths[font];
    int tileHeight = m2_font_heights[font];
    int widths = m2_widths_table[font][chr];

    int paletteMask = *palette_mask;
    byte *glyphRows = &m2_font_table[font][chr * tileWidth * tileHeight * 8];

    int virtualWidth = widths & 0xFF;
    int leftPortionWidth = 8 - (x & 7);

    int tileX = x >> 3;
    int tileY = y >> 3;
    
    int offsetY = y & 7;

    for (int dTileY = 0; dTileY < tileHeight; dTileY++) // dest tile Y
    {
        int dTileX = 0;
        int renderedWidth = widths >> 8;

        while (renderedWidth > 0)
        {
            // Glue the leftmost part of the glyph onto the rightmost part of the canvas
            int tileIndex = getTileCallback(tileX + dTileX, tileY + dTileY); //get_tile_number(tileX + dTileX, tileY + dTileY) + tileOffset;
            bool availableSwap = (dTileY != (tileHeight - 1));
            int realTileIndex = tileIndex;
            bool useful = false; //Maybe we go over the maximum tile height, let's make sure the extra tile is properly set IF it's useful

            for (int row = 0; row < 8; row++)
            {
                int canvasRow = dest[(realTileIndex * 8) + ((row + offsetY) & 7)];
                byte glyphRow = glyphRows[row + (dTileY * 8 * tileWidth) + (dTileX * 8)] & ((1 << leftPortionWidth) - 1);
                glyphRow <<= (8 - leftPortionWidth);

                int expandedGlyphRow = expand_bit_depth(glyphRow, foreground);
                int expandedGlyphRowMask = ~expand_bit_depth(glyphRow, 0xF);
                int tmpCanvasRow = canvasRow;
                canvasRow &= expandedGlyphRowMask;
                canvasRow |= expandedGlyphRow;
                
                if(!availableSwap && ((row + offsetY) >> 3) == 1 && canvasRow != tmpCanvasRow) //This changed the canvas, then it's useful... IF it's the extra vertical tile
                    useful = true;

                dest[(realTileIndex * 8) + ((row + offsetY) & 7)] = canvasRow;
                if(offsetY != 0 && ((row + offsetY) == 7))
                    realTileIndex = getTileCallback(tileX + dTileX, tileY + dTileY + 1);
            }

            if (tilemapPtr != NULL)
            {
                tilemapPtr[tileX + dTileX + ((tileY + dTileY) * tilemapWidth)] = paletteMask | (tileIndex + tilemapOffset);
                if(useful)
                    tilemapPtr[tileX + dTileX + ((tileY + dTileY + 1) * tilemapWidth)] = paletteMask | (realTileIndex + tilemapOffset);
            }

            if (renderedWidth - leftPortionWidth > 0 && leftPortionWidth < 8)
            {
                // Glue the rightmost part of the glyph onto the leftmost part of the next tile
                // on the canvas
                tileIndex = getTileCallback(tileX + dTileX + 1, tileY + dTileY); //get_tile_number(tileX + dTileX + 1, tileY + dTileY) + tileOffset;
                availableSwap = (dTileY != (tileHeight - 1));
                realTileIndex = tileIndex;
                useful = false; //Maybe we go over the maximum tile height, let's make sure the extra tile is properly set IF it's useful

                for (int row = 0; row < 8; row++)
                {
                    int canvasRow = dest[(realTileIndex * 8) + ((row + offsetY) & 7)];
                    byte glyphRow = glyphRows[row + (dTileY * 8 * tileWidth) + (dTileX * 8)] >> leftPortionWidth;

                    int expandedGlyphRow = expand_bit_depth(glyphRow, foreground);
                    int expandedGlyphRowMask = ~expand_bit_depth(glyphRow, 0xF);
                    int tmpCanvasRow = canvasRow;
                    canvasRow &= expandedGlyphRowMask;
                    canvasRow |= expandedGlyphRow;
                    
                    if(!availableSwap && ((row + offsetY) >> 3) == 1 && canvasRow != tmpCanvasRow) //This changed the canvas, then it's useful... IF it's the extra vertical tile
                        useful = true;

                    dest[(realTileIndex * 8) + ((row + offsetY) & 7)] = canvasRow;
                    if(offsetY != 0 && ((row + offsetY) == 7))
                        realTileIndex = getTileCallback(tileX + dTileX + 1, tileY + dTileY + 1);
                }
                
                if (tilemapPtr != NULL)
                {
                    tilemapPtr[tileX + dTileX + 1 + ((tileY + dTileY) * tilemapWidth)] = paletteMask | (tileIndex + tilemapOffset);
                    if(useful)
                        tilemapPtr[tileX + dTileX + 1 + ((tileY + dTileY + 1) * tilemapWidth)] = paletteMask | (realTileIndex + tilemapOffset);
                }
            }

            renderedWidth -= 8;
            dTileX++;
        }
    }

    return virtualWidth;
}

int print_window_header_string(int *dest, byte *str, int x, int y)
{
    int pixelX = x & 7;
    int *destOffset = dest + ((x & ~7) + (y * 32));

    for (;;)
    {
        byte code = *(str + 1);
        if (code == 0xFF)
        {
            if (*str == 0)
                break;

            str += 2;
            continue;
        }

        pixelX += print_character_to_ram(decode_character(*str++), destOffset, pixelX, 4, 0xF);
    }

    return pixelX - (x & 7);
}

void clear_window_header(int *dest, int length, int x, int y)
{
    dest += (x + (y * 32)) * 8;
    clear_rect_ram(dest, length, WINDOW_HEADER_BG);
}

unsigned short* print_equip_header(int type, unsigned short *tilemap, unsigned int *dest, WINDOW *window)
{
    byte *str = 0;

    switch (type)
    {
        case 3:
            str = m12_other_str5; // Weapon
            break;
        case 4:
            str = m12_other_str6; // Body
            break;
        case 5:
            str = m12_other_str7; // Arms
            break;
        case 6:
            str = m12_other_str8; // Other
            break;
    }

    if (str != 0)
    {
        int startX = WINDOW_HEADER_X * 8;
        int startY = WINDOW_HEADER_Y * 8;
        int width = 0;

        width += print_window_header_string(dest, str, startX + width, startY);

        // Print (X)
        if (window->cursor_x > 6)
        {
            int base = window->cursor_x_base;
            str = m2_strlookup(m2_misc_offsets, m2_misc_strings, base + 0x8C);
            width += print_window_header_string(dest, str, startX + width, startY);
        }

        // Update tilemap
        int tiles = (width + 7) >> 3;
        int tileIndex = WINDOW_HEADER_TILE + *tile_offset;

        for (int i = 0; i < tiles; i++)
        {
            *tilemap++ = tileIndex++ | *palette_mask;
        }
    }

    return tilemap;
}

// Returns a formatted tile value including the palette index, flip flags and
// tile offset.
unsigned short format_tile(unsigned short tile, bool flip_x, bool flip_y)
{
    tile += *tile_offset;
    tile |= *palette_mask;

    if (flip_x)
    {
        tile |= (1 << 10);
    }

    if (flip_y)
    {
        tile |= (1 << 11);
    }

    return tile;
}

// Copy party character name to window header
// Assumes that the party character names have already been rendered
// to VRAM; this just copies the map data
void copy_name_header(WINDOW *window, int character_index)
{
    // Coordinates of the name tiles
    int x = window->window_x + 1;
    int y = window->window_y - 1;

    // Print the partial border tile before the name
    (*tilemap_pointer)[x - 1 + (y * 32)] = format_tile(0xB3, false, false);

    // Get name width in pixels
    byte *name_str = pc_names + (character_index * 7);
    unsigned short *widths_table = m2_widths_table[4]; // small font
    int width = 0;

    while (*(name_str + 1) != 0xFF)
    {
        width += widths_table[decode_character(*name_str)] & 0xFF;
        name_str++;
    }

    // Print name
    int num_tiles = (width + 7) >> 3;
    int tile = name_header_tiles[character_index];

    for (int i = 0; i < num_tiles; i++)
    {
        (*tilemap_pointer)[x + i + (y * 32)] = format_tile(tile, false, false);
        tile++;
    }

    // Print flipped partial border tile after name
    (*tilemap_pointer)[x + num_tiles + (y * 32)] = format_tile(0xB3, true, false);
}

// Clears a window's name header by printing border tiles in the slots for the
// name, plus one tile on either side for the partial borders
void clear_name_header(WINDOW* window)
{
    // We don't need to know how long the name is; just make a conservative
    // estimate that it couldn't have been more than 4 tiles wide

    int x = window->window_x; // start of partial border tile
    int y = window->window_y - 1;
    int tile = format_tile(0x96, false, true);

    for (int i = 0; i < 6; i++)
    {
        (*tilemap_pointer)[x + (y * 32)] = tile;
        x++;
    }
}

// Draws the arrow tiles on a window
// The big flag controls what size to use
void draw_window_arrows(WINDOW *window, bool big)
{
    int x = window->window_x + window->window_width - 3;
    int y = window->window_y - 1;
    unsigned short tile = format_tile(big ? 0x9B : 0xBB, false, false);
    (*tilemap_pointer)[x + (y * 32)] = tile;
    (*tilemap_pointer)[x + 1 + (y * 32)] = tile + 1;
}

// Replaces window arrow tiles with regular border tiles
void clear_window_arrows(WINDOW *window)
{
    int x = window->window_x + window->window_width - 3;
    int y = window->window_y - 1;
    unsigned short tile = format_tile(0x96, false, true);
    (*tilemap_pointer)[x + (y * 32)] = tile;
    (*tilemap_pointer)[x + 1 + (y * 32)] = tile;
}

void weld_entry(WINDOW *window, byte *str)
{
    weld_entry_custom(window, str, 0, 0xF);
}

int weld_entry_saturn(WINDOW *window, byte *str)
{
    weld_entry_custom(window, str, 1, 0xF);

    // TODO: figure out when the original routine at 80ED770 might return non-zero
    // Looking at 80CA3A4, maybe 1 is returned if a non-saturn glyph is encountered?
    // And looking at 80D2F24, that seems to be the case...
    return 0;
}

void weld_entry_custom(WINDOW *window, byte *str, int font, int foreground)
{
    int chr = decode_character(*str);

    int x = window->pixel_x + (window->window_x + window->text_x) * 8;
    int y = (window->window_y + window->text_y) * 8;

    x += print_character_formatted(chr, x, y, font, foreground);

    window->pixel_x = x & 7;
    window->text_x = (x >> 3) - window->window_x;
}

// Returns: ____XXXX = number of characters printed
//          XXXX____ = number of pixels printed
// x, y: pixels
int print_string(byte *str, int x, int y)
{
    if (str == NULL)
        return 0;

    byte chr;
    int initial_x = x;
    int charCount = 0;

    while (str[1] != 0xFF)
    {
        x += print_character(decode_character(*str++), x, y);
        charCount++;
    }

    int totalWidth = x - initial_x;

    return (charCount & 0xFFFF) | (totalWidth << 16);
}

int print_menu_string(WINDOW* window)
{
    byte *menu_text = window->menu_text;
    if (menu_text == NULL)
        return 0;

    int x = window->window_x << 3;
    int y = (window->window_y + window->text_y) << 3;

    byte chr;
    int initial_x = x;
    int charCount = 0;
    bool looping = true;
    int set_count = 0;
    byte first_set_value = 0;

    while (looping)
    {
        if (menu_text[1] == 0xFF)
        {
            switch (menu_text[0])
            {
                case CUSTOMCC_SET_X:
                {
                    byte set_value = menu_text[2];
                    x = set_value + initial_x;
                    menu_text += 3;

                    set_count++;
                    if (set_count == 1)
                    {
                        first_set_value = set_value;
                    }
                    else if (set_count == 2)
                    {
                        // If we're calling SET the second time, update the
                        // window cursor delta to be the difference between
                        // the two set values
                        window->cursor_x_delta = (set_value - first_set_value) >> 3;
                    }

                    break;
                }
                case CUSTOMCC_ADD_X:
                    x += menu_text[2];
                    menu_text += 3;
                    break;
                default:
                    looping = false;
                    break;
            }
        }
        else
        {
            x += print_character(decode_character(*menu_text++), x, y);
            charCount++;
        }
    }

    window->text_x = 0;
    window->pixel_x = 0;

    int totalWidth = x - initial_x;

    return (charCount & 0xFFFF) | (totalWidth << 16);
}

// x,y: tile coordinates
void clear_tile(int x, int y, int pixels)
{
    // Clear pixels
    int tileIndex = get_tile_number(x, y) + *tile_offset;
    cpufastset(&pixels, &vram[tileIndex * 8], CPUFASTSET_FILL | 8);

    // Reset the tilemap (e.g. get rid of equip or SMAAAASH!! tiles)
    (*tilemap_pointer)[x + (y * 32)] = tileIndex | *palette_mask;
}

// x,y: tile coordinates
void clear_rect(int x, int y, int width, int height, int pixels)
{
    for (int tileY = 0; tileY < height; tileY++)
    {
        for (int tileX = 0; tileX < width; tileX++)
        {
            clear_tile(x + tileX, y + tileY, pixels);
        }
    }
}

void clear_rect_ram(int *dest, int tileCount, int pixels)
{
    cpufastset(&pixels, dest, CPUFASTSET_FILL | (tileCount * 8));
}

void clear_window(WINDOW *window)
{
    clear_rect(window->window_x, window->window_y,
        window->window_width, window->window_height,
        WINDOW_AREA_BG);
}

// x, y, width: tile coordinates
void print_blankstr(int x, int y, int width)
{
    clear_rect(x, y, width, 2, WINDOW_AREA_BG);
}

// x, y, width: tile coordinates
void print_blankstr_window(int x, int y, int width, WINDOW* window)
{
    print_blankstr(x + window->window_x, y + window->window_y, width);
}

// x,y: tile coordinates
void copy_tile(int xSource, int ySource, int xDest, int yDest)
{
    int sourceTileIndex = get_tile_number(xSource, ySource) + *tile_offset;
    int destTileIndex = get_tile_number(xDest, yDest) + *tile_offset;
    cpufastset(&vram[sourceTileIndex * 8], &vram[destTileIndex * 8], 8);
}

// x,y: tile coordinates
void copy_tile_up(int x, int y)
{
    copy_tile(x, y, x, y - 2);
}

void print_space(WINDOW *window)
{
    byte space = SPACE;
    weld_entry(window, &space);
}

// Prints the dollar sign, the zeroes, and (optionally if style == 1) the 00 symbol
void print_number_menu(WINDOW* window, int style)
{
    // Print a $ sign (0x54) at (32, 32) pixels
    int x = (window->window_x << 3) + 32;
    int y = (window->window_y << 3) + 32;

    print_character(decode_character(0x54), x, y);
    x += 8;

    // Print the zeroes (0x60)
    for (int i = 0; i < window->cursor_x_delta; i++)
    {
        print_character(decode_character(0x60), x, y);
        x += 8;
    }

    // Print the 00 symbol (0x56)
    if (style == 1)
    {
        print_character(decode_character(0x56), x, y);
    }
}

// Print the given digit for the number selection menu at the current cursor location
void print_number_menu_current(byte digit, WINDOW* window)
{
    // Skip the 4 blank tiles
    int x = (window->window_x + (window->cursor_x_delta - window->cursor_x) + 4) << 3;

    // Skip the first two text rows
    int y = (window->window_y + 4) << 3;

    // Erase what was there before
    print_blankstr(x >> 3, y >> 3, 1);

    // Now print the digit
    print_character(decode_character(digit + 0x60), x, y);
}

// Clears the number menu of a window
// More specifically, clear the 3rd row of text and reset the bottom window border
void clear_number_menu(WINDOW* window)
{
    // Clear the text
    print_blankstr_window(0, 4, window->window_width, window);

    // Reset the border (6th tile row)
    unsigned short border_tile = (*tile_offset + 0x96) | *palette_mask;
    for (int i = 0; i < window->window_width; i++)
    {
        (*tilemap_pointer)[window->window_x + i + ((window->window_y + 6) * 32)] = border_tile;
    }
}

// Prints a character to a window, and updates the window's text position
byte print_character_to_window(byte chr, WINDOW* window)
{
    int x = ((window->window_x + window->text_x) << 3) + window->pixel_x;
    int y = (window->window_y + window->text_y) << 3;

    byte width = print_character(chr, x, y);
    x += width;

    window->pixel_x = x & 7;
    window->text_x = (x >> 3) - window->window_x;

    return width;
}

// Write the following, in sequence, to str:
// [5F FF xx] code to right-align the text to padding pixels
// Dollar sign (0x54)
// Digits
// 00 symbol (0x56)
// [00 FF] end code
void format_cash_window(int value, int padding, byte* str)
{
    // Convert digits to BCD for easy parsing
    int digit_count;
    int bcd = bin_to_bcd(value, &digit_count);

    // Dollar sign is 6 pixels wide, 00 symbol is 8
    padding -= 14;

    // Subtract 6 pixels for each digit
    padding -= (6 * digit_count);

    // Control code
    *str++ = 0x5F;
    *str++ = 0xFF;
    *str++ = padding & 0xFF;

    *str++ = 0x54;

    // Write the digits
    for (int i = 0; i < digit_count; i++)
    {
        byte digit = ((bcd >> ((digit_count - 1 - i) * 4)) & 0xF) + ZERO;
        *str++ = digit;
    }

    *str++ = 0x56;
    *str++ = 0;
    *str++ = 0xFF;
}

// The game draws windows lazily: no window will be drawn to the screen until
// a renderable token is encountered. So it's possible to have text that
// does stuff in the background without ever showing a window. Lots of doors
// and hotspots do this for example.
// When the game first encounters a renderable token, it checks two things:
// - If the flag at 0x30051F0 is 1, then call m2_resetwindow and set the flag to 0
// - If the window has flag 0x20 set, then call m2_drawwindow (which unsets the
//   window flag)
// See 80CA2C2 for an example. We want to replicate this behaviour sometimes,
// e.g. for custom control codes that are considered renderable.
void handle_first_window(WINDOW* window)
{
    if (*first_window_flag == 1)
    {
        m2_resetwindow(window, false);
        *first_window_flag = 0;
    }
    else if (window->redraw)
    {
        m2_drawwindow(window);
    }
}
