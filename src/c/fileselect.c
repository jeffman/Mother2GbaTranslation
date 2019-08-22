#include "window.h"
#include "vwf.h"
#include "number-selector.h"
#include "locs.h"
#include "fileselect.h"

int get_tile_number_file_select(int x, int y)
{
    x--;
    y--;
    return m2_coord_table_file[x + ((y >> 1) * 28)] + (y & 1) * 32;
}

// x,y: tile coordinates
void clear_tile_file(int x, int y, int pixels, int tile_offset_file)
{
    // Clear pixels
    int tileIndex = get_tile_number_file_select(x, y) + tile_offset_file;
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

unsigned short* getTilesetDest(int window_selector, int *width)
{
    int *tilesetBasePtr = (int *)(0x82B79B4 + (window_selector * 20));
    (*width) = tilesetBasePtr[2];
    return (unsigned short *)(tilesetBasePtr[0]);
}
unsigned short getPaletteFromFileWindow(int x, int y, int window_selector)
{
	int width;
    unsigned short *tilesetDestPtr = getTilesetDest(window_selector, &width);
	return (tilesetDestPtr[x + (y * width)] & 0x3000); //Get the palette used. Useful to keep the highlighting.
}

void setPaletteToFileWindow(int x, int y, int window_selector, unsigned short palette)
{
	int width;
    unsigned short *tilesetDestPtr = getTilesetDest(window_selector, &width);
	tilesetDestPtr[x + (y * width)] = ((tilesetDestPtr[x + (y * width)] & 0x3FF) | palette); //Set the palette used. Useful to keep the highlighting.
}

void setPaletteToZero(int x, int y, int window_selector)
{
	int width;
    unsigned short *tilesetDestPtr = getTilesetDest(window_selector, &width);
	tilesetDestPtr[x + (y * width)] = 0x013F; //Set palette to 0 when this one is called. No highlighting here.
}

void setPaletteOnAllFile(int x, int y, byte *str, int length, int window_selector)
{
	int width;
    unsigned short *tilesetDestPtr = getTilesetDest(window_selector, &width);
	unsigned short palette = getPaletteFromFileWindow(x, y, window_selector);
	for(int i = 0; i < count_pixels_to_tiles(str, length, (x + 1) << 3); i++)
	{
		tilesetDestPtr[i + x + (y * width)] = (tilesetDestPtr[i + x + (y * width)] & 0x3FF) | palette;
		tilesetDestPtr[i + x + ((y + 1) * width)] = (tilesetDestPtr[i + x + ((y + 1) * width)] & 0x3FF) | palette;
	}
}

void wrapper_file_string_selection(int x, int y, int length, byte *str, int window_selector)
{
    m2_cstm_last_printed[0] = window_selector; //First time setup
    print_file_string(x, y, length, str, window_selector, 1, 0);
	setPaletteOnAllFile(x, y, str, length, window_selector);
}

void setPaletteOnFile(int x, int y, int window_selector, FILE_SELECT *file)
{
	setPaletteOnAllFile(x, y, file->formatted_str, 0x40, window_selector);
}

void wrapper_first_file_string(int x, int y, int length, byte *str, int window_selector)
{
	setPaletteToZero(x, y, window_selector); //The game does not reset the palette for these lines. Instead it reprints them with palette 0. Hence if we want to mantain the highlighting consistent, we need to set the palette our code will use to 0 ourselves.
    m2_cstm_last_printed[0] = window_selector; //First time setup
    print_file_string(x, y, length, str, window_selector, 1, 0);
}

void wrapper_delete_string(int x, int y, int length, byte *str, int window_selector)
{
    print_file_string(x, y, length, str - 0x20 + 0x40 - 0x15, window_selector, 7, 0xA);
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
    print_file_string(x, y, length, String, window_selector, 5, 0);
}

void wrapper_name_summary_string(int x, int y, int length, byte *str, int window_selector)
{
    char String[length];
    for(int i = 0; i < length; i++)
            String[i] = str[i];
    print_file_string(x, y, length, String, window_selector, 3, 0);
}

void wrapper_copy_string(int x, int y, int length, byte *str, int window_selector)
{
    print_file_string(x, y, length, str, window_selector, 8, 0xC);
}

void clearArr(int x, int y, int width, unsigned short *tilesetDestPtr, int windowX)
{
    for(int i = x; i < width + windowX - 2; i++)
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

void print_file_string(int x, int y, int length, byte *str, int window_selector, int windowX, int windowY)
{
    int *tilesetBasePtr = (int *)(0x82B79B4 + (window_selector * 20));
    int width = tilesetBasePtr[2];
    unsigned short *tilesetDestPtr = (unsigned short *)(tilesetBasePtr[0]);
	unsigned short getBasePal = tilesetDestPtr[x + (y * width)] & 0x3000;
	tilesetDestPtr = tilesetDestPtr - windowX - (windowY * width);
    clearArr(x + windowX, y + windowY, width, tilesetDestPtr, windowX); //Cleans all of the arrangements this line could ever use
    
    int pixelX = (x + windowX) * 8;
    int pixelY = ((y + windowY) * 8) + 3;
    int realmask = *palette_mask;
    *palette_mask = getBasePal; //File select is special and changes its palette_mask on the fly.
    clear_rect_file(x + windowX, y + windowY, width, 2, 0x11111111, 0x400, tilesetDestPtr); //Clean the rectangle before printing

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
            vram + 0x2000,
            &get_tile_number_file_select,
            tilesetDestPtr,
            width);

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

void options_setup(char String[], int selector)
{
    int index = 0;
    char Continue[] = "Continue";
    char Copy[] = "Copy";
    char Delete[] = "Delete";
    char Setup[] = "Set Up";
	switch(selector)
	{
		case 0:
			for(int i = 0; i < (sizeof(Continue) -1); i++)
				String[index++] = encode_ascii(Continue[i]);
			break;
		case 1:
			for(int i = 0; i < (sizeof(Copy) -1); i++)
				String[index++] = encode_ascii(Copy[i]);
			break;
		case 2:
			for(int i = 0; i < (sizeof(Delete) -1); i++)
				String[index++] = encode_ascii(Delete[i]);
			break;
		default:
			for(int i = 0; i < (sizeof(Setup) -1); i++)
				String[index++] = encode_ascii(Setup[i]);
			break;
	}

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
            String[index++] = (0x13) << 3;
            for(int i = 0; i < (sizeof(Yep) -1); i++)
                String[index++] = encode_ascii(Yep[i]);
            //Re-position
            format_options_cc(String, &index, CUSTOMCC_SET_X);
            String[index++] = (0x17) << 3;
            for(int i = 0; i < (sizeof(Nope) -1); i++)
                String[index++] = encode_ascii(Nope[i]);
        break;
    }
    //END
    String[index++] = 0xFF;
}

void print_windows(int windowX, int windowY, int window_selector)
{
    char String[64];
	unsigned short palettes[3];
    switch(window_selector)
    {
        case 0x10: //Delete
            delete_setup(String, 0);
            print_file_string(1, 1, 0x40, String, window_selector, windowX, windowY);
            delete_setup(String, 1);
            print_file_string(2, 5, 0x40, String, window_selector, windowX, windowY);
            delete_setup(String, 2);
            print_file_string(2, 7, 0x40, String, window_selector, windowX, windowY);
            m2_cstm_last_printed[0] = window_selector | (m2_cstm_last_printed[0] & 0x20);
            break;
        case 0xE: //Options
			palettes[0] = getPaletteFromFileWindow(0x8, 1, window_selector);
			palettes[1] = getPaletteFromFileWindow(0xC, 1, window_selector);
			palettes[2] = getPaletteFromFileWindow(0x11, 1, window_selector);
            options_setup(String, 0);
            print_file_string(2, 1, 0x40, String, window_selector, windowX, windowY);
            options_setup(String, 1);
			setPaletteToFileWindow(0x8, 1, window_selector, palettes[0]); //Makes sure the highlighting is kept
            print_file_string(0x8, 1, 0x40, String, window_selector, windowX, windowY);
            options_setup(String, 2);
			setPaletteToFileWindow(0xC, 1, window_selector, palettes[1]);
            print_file_string(0xC, 1, 0x40, String, window_selector, windowX, windowY);
            options_setup(String, 3);
			setPaletteToFileWindow(0x11, 1, window_selector, palettes[2]);
            print_file_string(0x11, 1, 0x40, String, window_selector, windowX, windowY);
            m2_cstm_last_printed[0] = window_selector | (m2_cstm_last_printed[0] & 0x20);
        break;
        case 1: //Text Speed
            if(((m2_cstm_last_printed[0] & 0x1F) != 1) && ((m2_cstm_last_printed[0] & 0x80) == 0)) //If Text Flavour is printed, don't reprint it
            {
                text_speed_setup(String, 0);
                print_file_string(1, 1, 0x40, String, window_selector, windowX, windowY);
                text_speed_setup(String, 1);
                print_file_string(2, 3, 0x40, String, window_selector, windowX, windowY);
                text_speed_setup(String, 2);
                print_file_string(2, 5, 0x40, String, window_selector, windowX, windowY);
                text_speed_setup(String, 3);
                print_file_string(2, 7, 0x40, String, window_selector, windowX, windowY);
                m2_cstm_last_printed[0] = window_selector | (m2_cstm_last_printed[0] & 0x20);
            }
			else if ((m2_cstm_last_printed[0] & 0x80) != 0) //This has not been printed. Instead Text Flavour has been.
				m2_cstm_last_printed[0] = 2;
        break;
        case 0x2: //Text Flavour
            if((m2_cstm_last_printed[0] & 0x1F) != 2){
                text_flavour_setup(String, 0);
                print_file_string(1, 1, 0x40, String, window_selector, windowX, windowY);
                text_flavour_setup(String, 1);
                print_file_string(1, 3, 0x40, String, window_selector, windowX, windowY);
                text_flavour_setup(String, 2);
                print_file_string(2, 5, 0x40, String, window_selector, windowX, windowY);
                text_flavour_setup(String, 3);
                print_file_string(2, 7, 0x40, String, window_selector, windowX, windowY);
                text_flavour_setup(String, 4);
                print_file_string(2, 9, 0x40, String, window_selector, windowX, windowY);
                text_flavour_setup(String, 5);
                print_file_string(2, 11, 0x40, String, window_selector, windowX, windowY);
                text_flavour_setup(String, 6);
                print_file_string(2, 13, 0x40, String, window_selector, windowX, windowY);
                m2_cstm_last_printed[0] = window_selector; //Set the alphabet bit to 0.
            }
        break;
        case 0xF: //Copy
            copy_setup(String);
            print_file_string(1, 1, 0x40, String, window_selector, windowX, windowY);
        break;
        case 0x3: //Ness' name + description
        case 0x4: //Paula's name + description
        case 0x5: //Jeff's name + description
        case 0x6: //Poo's name + description
        case 0x7: //King's name + description
        case 0x8: //FavFood's name + description
        case 0x9: //FavThing's name + description
            if((m2_cstm_last_printed[0] & 0x1F) != window_selector){
                description_setup(String, window_selector);
                print_file_string(9, 1, 0x40, String, window_selector, windowX, windowY);
                m2_cstm_last_printed[0] = window_selector | (m2_cstm_last_printed[0] & 0x20);
            }
        break;
        case 0xA: //Alphabet 1
            if((m2_cstm_last_printed[0] & 0x20) == 0) //Print this once and stop
            {
                //Main thing
                alphabet_setup(String, 0, true);
                print_file_string(2, 1, 0x40, String, window_selector, windowX, windowY);
                alphabet_setup(String, 1, true);
                print_file_string(2, 3, 0x40, String, window_selector, windowX, windowY);
                alphabet_setup(String, 2, true);
                print_file_string(2, 5, 0x40, String, window_selector, windowX, windowY);
                alphabet_setup(String, 3, true);
                print_file_string(2, 7, 0x40, String, window_selector, windowX, windowY);
                alphabet_setup(String, 4, true);
                print_file_string(2, 9, 0x40, String, window_selector, windowX, windowY);
                alphabet_setup(String, 5, true);
                print_file_string(2, 13, 0x40, String, window_selector, windowX, windowY);
                m2_cstm_last_printed[0] = (m2_cstm_last_printed[0] & 0x1F) | 0x20; //Printed flag
            }
        break;
        case 0xB: //Alphabet 2
            if((m2_cstm_last_printed[0] & 0x40) == 0) //Print this once and stop
            {
                //Main thing
                alphabet_setup(String, 0, false);
                print_file_string(2, 1, 0x40, String, window_selector, windowX, windowY);
                alphabet_setup(String, 1, false);
                print_file_string(2, 3, 0x40, String, window_selector, windowX, windowY);
                alphabet_setup(String, 2, false);
                print_file_string(2, 5, 0x40, String, window_selector, windowX, windowY);
                alphabet_setup(String, 3, false);
                print_file_string(2, 7, 0x40, String, window_selector, windowX, windowY);
                alphabet_setup(String, 4, true);
                print_file_string(2, 9, 0x40, String, window_selector, windowX, windowY);
                alphabet_setup(String, 5, true);
                print_file_string(2, 13, 0x40, String, window_selector, windowX, windowY);
                m2_cstm_last_printed[0] = (m2_cstm_last_printed[0] & 0x1F) | 0x40; //Printed flag
            }
        
        break;
        case 0xC: //Alphabet 3 - Won't use
        
        break;
        case 0xD: //Is this okay? Yes No
            summary_setup(String, 0);
            print_file_string(0xC, 5, 0x40, String, window_selector, windowX, windowY);
            summary_setup(String, 1);
            print_file_string(0xC, 0xB, 0x40, String, window_selector, windowX, windowY);
            summary_setup(String, 2);
            print_file_string(0x1, 0x11, 0x40, String, window_selector, windowX, windowY);
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
    file->formatted_str[index++] = 80;

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
    file->formatted_str[index++] = (0x10 << 3);
    
    for (int i = 0; i < (sizeof(levelStr) - 1); i++)
        file->formatted_str[index++] = encode_ascii(levelStr[i]);

    if (tens > 0)
        file->formatted_str[index++] = tens + ZERO;

    file->formatted_str[index++] = ones + ZERO;
    
    file->formatted_str[index++] = 0xFF;
}