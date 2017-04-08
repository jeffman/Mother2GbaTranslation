#include "vwf.h"

int get_tile_number(int x, int y)
{
    x--;
    y--;
    return LDRH(ADDR(m2_coord_table) + (x + ((y >> 1) * 28)) * 2) + (y & 1) * 32;
}
