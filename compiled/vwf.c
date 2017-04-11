#include "window.h"
#include "vwf.h"

int get_tile_number(int x, int y)
{
    x--;
    y--;
    return m2_coord_table[x + ((y >> 1) * 28)] + (y & 1) * 32;
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

byte __attribute__ ((noinline)) print_character(byte chr, byte x, byte y, byte font, byte foreground)
{
    int tileOffset = *tile_offset;
    int paletteMask = *palette_mask;
    byte *glyphRows = &m2_font_table[font][chr * 32];

    int widths = m2_widths_table[font][chr];
    int virtualWidth = widths & 0xFF;

    int tileHeight = m2_font_heights[font];

    int tileX = x >> 3;
    int tileY = y >> 3;

    int leftPortionWidth = 8 - (x & 7);

    for (int dTileY = 0; dTileY < tileHeight; dTileY++) // dest tile Y
    {
        int dTileX = 0;
        int renderedWidth = widths >> 8;

        while (renderedWidth > 0)
        {
            // Glue the leftmost part of the glyph onto the rightmost part of the canvas
            int tileIndex = get_tile_number(tileX + dTileX, tileY + dTileY) + tileOffset;

            for (int row = 0; row < 8; row++)
            {
                int canvasRow = vram[(tileIndex * 8) + row];
                byte reducedCanvasRow = reduce_bit_depth(canvasRow, foreground);
                byte glyphRow = glyphRows[row + (dTileY * 16) + (dTileX * 8)] & ((1 << leftPortionWidth) - 1);
                glyphRow <<= (8 - leftPortionWidth);

                int expandedGlyphRow = expand_bit_depth(glyphRow, foreground);
                int expandedGlyphRowMask = expand_bit_depth(glyphRow, 0xF) ^ 0xFFFFFFFF;
                canvasRow &= expandedGlyphRowMask;
                canvasRow |= expandedGlyphRow;

                vram[(tileIndex * 8) + row] = canvasRow;
            }

            (*tilemap)[tileX + dTileX + ((tileY + dTileY) * 32)] = paletteMask | tileIndex;

            if (renderedWidth - leftPortionWidth > 0 && leftPortionWidth < 8)
            {
                // Glue the rightmost part of the glyph onto the leftmost part of the next tile
                // on the canvas
                tileIndex = get_tile_number(tileX + dTileX + 1, tileY + dTileY) + tileOffset;

                for (int row = 0; row < 8; row++)
                {
                    int canvasRow = vram[(tileIndex * 8) + row];
                    byte reducedCanvasRow = reduce_bit_depth(canvasRow, foreground);
                    byte glyphRow = glyphRows[row + (dTileY * 16) + (dTileX * 8)] >> leftPortionWidth;

                    int expandedGlyphRow = expand_bit_depth(glyphRow, foreground);
                    int expandedGlyphRowMask = expand_bit_depth(glyphRow, 0xF) ^ 0xFFFFFFFF;
                    canvasRow &= expandedGlyphRowMask;
                    canvasRow |= expandedGlyphRow;

                    vram[(tileIndex * 8) + row] = canvasRow;
                }

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
    int chr = *str - 0x50;
    if ((chr < 0) || ((chr >= 0x60) && (chr < 0x64)) || (chr >= 0x6D))
        chr = QUESTION_MARK;

    int x = window->pixel_x + (window->window_x + window->text_x) * 8;
    int y = (window->window_y + window->text_y) * 8;

    x += print_character(chr, x, y, font, foreground);

    window->pixel_x = x & 7;
    window->text_x = (x >> 3) - window->window_x;
}
