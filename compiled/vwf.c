#include "window.h"
#include "vwf.h"

byte decode_character(byte chr)
{
    int c = chr - 0x50;
    if ((c < 0) || ((c >= 0x60) && (c < 0x64)) || (c >= 0x6D))
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

byte print_character(byte chr, byte x, byte y, byte font, byte foreground)
{
    return print_character_with_callback(chr, x, y, font, foreground, vram, &get_tile_number_with_offset, TRUE);
}

byte print_character_to_ram(byte chr, int *dest, int xOffset, int font, int foreground)
{
    return print_character_with_callback(chr, xOffset, 0, font, foreground, dest, &get_tile_number_grid, FALSE);
}

byte print_character_with_callback(byte chr, int x, int y, int font, int foreground,
    int *dest, int (*getTileCallback)(int, int), int useTilemap)
{
    int tileWidth = m2_font_widths[font];
    int tileHeight = m2_font_heights[font];
    int widths = m2_widths_table[font][chr];

    int paletteMask = *palette_mask;
    byte const *glyphRows = &m2_font_table[font][chr * tileWidth * tileHeight * 8];

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
                (*tilemap)[tileX + dTileX + ((tileY + dTileY) * 32)] = paletteMask | tileIndex;

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
                    (*tilemap)[tileX + dTileX + 1 + ((tileY + dTileY) * 32)] = paletteMask | tileIndex;
            }

            renderedWidth -= 8;
            dTileX++;
        }
    }

    return virtualWidth;
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

    x += print_character(chr, x, y, font, foreground);

    window->pixel_x = x & 7;
    window->text_x = (x >> 3) - window->window_x;
}

// Returns: ____XXXX = number of characters printed
//          XXXX____ = number of pixels printed
int print_string(byte *str, int x, int y)
{
    byte chr;
    int initialX = x;
    int charCount = 0;

    while (str[1] != 0xFF)
    {
        x += print_character(decode_character(*str++), x, y, 0, 0xF);
        charCount++;
    }

    int totalWidth = x - initialX;

    return (charCount & 0xFFFF) | (totalWidth << 16);
}

void clear_tile(int x, int y, int pixels)
{
    int tileIndex = get_tile_number(x, y) + *tile_offset;
    cpufastset(&pixels, &vram[tileIndex * 8], CPUFASTSET_FILL | 8);
}

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

void clear_window(WINDOW *window)
{
    clear_rect(window->window_x, window->window_y,
        window->window_width, window->window_height,
        0x44444444);
}

void print_blankstr(int x, int y, int width)
{
    clear_rect(x, y, width, 2, 0x44444444);
}

void copy_tile(int xSource, int ySource, int xDest, int yDest)
{
    int sourceTileIndex = get_tile_number(xSource, ySource) + *tile_offset;
    int destTileIndex = get_tile_number(xDest, yDest) + *tile_offset;
    cpufastset(&vram[sourceTileIndex * 8], &vram[destTileIndex * 8], 8);
}

void copy_tile_up(int x, int y)
{
    copy_tile(x, y, x, y - 2);
}

void print_space(WINDOW *window)
{
    byte space = 0x50;
    weld_entry(window, &space);
}
