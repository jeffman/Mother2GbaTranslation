#include "window.h"
#include "vwf.h"
#include "number-selector.h"
#include "locs.h"

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
    return m2_coord_table[x + ((y >> 1) * 28)] + (y & 1) * 32;
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

byte getSex(byte character)
{
	return character == 1 ? 1 : 0; //character 1 is Paula
}

void getPossessive(byte character, byte *str, int *index)
{
	char his[] = "his";
	char her[] = "her";
	if(getSex(character) == 1)
        for (int i = 0; i < (sizeof(her) - 1); i++)
            str[(*index)++] = encode_ascii(her[i]);
	else
        for (int i = 0; i < (sizeof(his) - 1); i++)
            str[(*index)++] = encode_ascii(his[i]);
}

void getPronoun(byte character, byte *str, int *index)
{
	char he[] = "he";
	char she[] = "she";
	if(getSex(character) == 1)
        for (int i = 0; i < (sizeof(she) - 1); i++)
            str[(*index)++] = encode_ascii(she[i]);
	else
        for (int i = 0; i < (sizeof(he) - 1); i++)
            str[(*index)++] = encode_ascii(he[i]);
}

void getCharName(byte character, byte *str, int *index)
{
	copy_name(str, m2_ness_name, index, character * 7);
}

void copy_name(byte *str, byte *source, int *index, int pos)
{
	while(source[pos + 1] != 0xFF)
		str[(*index)++] = source[pos++];
}

int ascii_strlen(char *str)
{
    int len = 0;
    while (str[len] != 0)
        len++;
    return len;
}

int wrapper_count_pixels_to_tiles(byte *str, int length)
{
	return count_pixels_to_tiles(str, length, 0);
}

int count_pixels_to_tiles(byte *str, int length, int startingPos)
{
    int pixels = startingPos;
    for(int i = 0; i < length; i++)
	{
        if((str[i] != 0xFF) && (str[i] != 0xFE)) //The latter one is not really needed
            pixels += (m2_widths_table[0][decode_character(str[i])] & 0xFF);
		else if(str[i] == 0xFE)
		{
            // Define 0xFE as a control code
            byte cmd = str[++i];
            switch (cmd)
            {
                case CUSTOMCC_ADD_X:
                    pixels += str[++i];
                    break;

                case CUSTOMCC_SET_X:
                    pixels = str[++i];
                    break;
            }
		}
		else
			break;
	}
    int tiles = (pixels - startingPos)>> 3;
    if((pixels & 7) != 0)
        tiles +=1;
    return tiles;
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

    return print_character_with_callback(chr, x, y, font, foreground, vram, &get_tile_number_with_offset, *tilemap_pointer, 32);
}

byte print_character_to_ram(byte chr, int *dest, int xOffset, int font, int foreground)
{
    return print_character_with_callback(chr, xOffset, 0, font, foreground, dest, &get_tile_number_grid, NULL, 32);
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
    int *dest, int (*getTileCallback)(int, int), unsigned short *tilemapPtr, int tilemapWidth)
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
                tilemapPtr[tileX + dTileX + ((tileY + dTileY) * tilemapWidth)] = paletteMask | tileIndex;
                if(useful)
                    tilemapPtr[tileX + dTileX + ((tileY + dTileY + 1) * tilemapWidth)] = paletteMask | realTileIndex;
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
                    tilemapPtr[tileX + dTileX + 1 + ((tileY + dTileY) * tilemapWidth)] = paletteMask | tileIndex ;
                    if(useful)
                        tilemapPtr[tileX + dTileX + 1 + ((tileY + dTileY + 1) * tilemapWidth)] = paletteMask | realTileIndex;
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
