#include "window.h"
#include "vwf.h"
#include "number-selector.h"

byte decode_character(byte chr)
{
    int c = chr - CHAR_OFFSET;
    if ((c < 0) || ((c >= CHAR_END) && (c < YOUWON_START)) || (c > ARROW))
        c = QUESTION_MARK;

    return c;
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

    return print_character_with_callback(chr, x, y, font, foreground, vram, &get_tile_number_with_offset, TRUE);
}

byte print_character_to_ram(byte chr, int *dest, int xOffset, int font, int foreground)
{
    return print_character_with_callback(chr, xOffset, 0, font, foreground, dest, &get_tile_number_grid, FALSE);
}

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

byte print_character_with_callback(byte chr, int x, int y, int font, int foreground,
    int *dest, int (*getTileCallback)(int, int), int useTilemap)
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

    for (int dTileY = 0; dTileY < tileHeight; dTileY++) // dest tile Y
    {
        int dTileX = 0;
        int renderedWidth = widths >> 8;

        while (renderedWidth > 0)
        {
            // Glue the leftmost part of the glyph onto the rightmost part of the canvas
            int tileIndex = getTileCallback(tileX + dTileX, tileY + dTileY); //get_tile_number(tileX + dTileX, tileY + dTileY) + tileOffset;

            for (int row = 0; row < 8; row++)
            {
                int canvasRow = dest[(tileIndex * 8) + row];
                byte glyphRow = glyphRows[row + (dTileY * 8 * tileWidth) + (dTileX * 8)] & ((1 << leftPortionWidth) - 1);
                glyphRow <<= (8 - leftPortionWidth);

                int expandedGlyphRow = expand_bit_depth(glyphRow, foreground);
                int expandedGlyphRowMask = ~expand_bit_depth(glyphRow, 0xF);
                canvasRow &= expandedGlyphRowMask;
                canvasRow |= expandedGlyphRow;

                dest[(tileIndex * 8) + row] = canvasRow;
            }

            if (useTilemap)
                (*tilemap_pointer)[tileX + dTileX + ((tileY + dTileY) * 32)] = paletteMask | tileIndex;

            if (renderedWidth - leftPortionWidth > 0 && leftPortionWidth < 8)
            {
                // Glue the rightmost part of the glyph onto the leftmost part of the next tile
                // on the canvas
                tileIndex = getTileCallback(tileX + dTileX + 1, tileY + dTileY); //get_tile_number(tileX + dTileX + 1, tileY + dTileY) + tileOffset;

                for (int row = 0; row < 8; row++)
                {
                    int canvasRow = dest[(tileIndex * 8) + row];
                    byte glyphRow = glyphRows[row + (dTileY * 8 * tileWidth) + (dTileX * 8)] >> leftPortionWidth;

                    int expandedGlyphRow = expand_bit_depth(glyphRow, foreground);
                    int expandedGlyphRowMask = ~expand_bit_depth(glyphRow, 0xF);
                    canvasRow &= expandedGlyphRowMask;
                    canvasRow |= expandedGlyphRow;

                    dest[(tileIndex * 8) + row] = canvasRow;
                }

                if (useTilemap)
                    (*tilemap_pointer)[tileX + dTileX + 1 + ((tileY + dTileY) * 32)] = paletteMask | tileIndex;
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

void clear_window_header(int *dest)
{
    dest += (WINDOW_HEADER_X + (WINDOW_HEADER_Y * 32)) * 8;
    clear_rect_ram(dest, 16, WINDOW_HEADER_BG);
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
            int page = window->page;
            str = m2_strlookup(m2_misc_offsets, m2_misc_strings, page + 0x8C);
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

void weld_entry(WINDOW *window, byte *str)
{
    weld_entry_custom(window, str, 0, 0xF);
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
                        window->cursor_delta = (set_value - first_set_value) >> 3;
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

    window->text_x = (x / 8) - window->window_x;
    window->pixel_x = x & 7;

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
    for (int i = 0; i < window->cursor_delta; i++)
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
