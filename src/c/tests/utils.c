#include "utils.h"

#define CPUFASTSET_FILL (0x1000000)
#define IWRAM (0x3000000)
#define IWRAM_SIZE (0x8000-0x2000)

#define NON_IWRAM_RESET 0xFD

#define RIGHT_BORDER_TILE 0x0095

void blank_memory()
{
    int blank_value = 0;
    cpufastset(&blank_value, (void*)IWRAM, CPUFASTSET_FILL | (IWRAM_SIZE >> 2));
    reg_ram_reset(NON_IWRAM_RESET);
}

void setup_ness_name()
{
    for(int i = 0; i < 5; i++)
        *(pc_names + i) = W_LETTER;
    *(pc_names + 5) = 0;
    *(pc_names + 6) = 0xFF;
}

void setup_king_name()
{
    for(int i = 0; i < 6; i++)
        *(pc_names + KING_OFFSET + i) = W_LETTER;
    *(pc_names + KING_OFFSET + 6) = 0;
    *(pc_names + KING_OFFSET + 7) = 0xFF;
}

bool text_stayed_inside(WINDOW* window)
{
    if(window->redraw)
        return true;
    
    for(int i = 0; i < window->window_height; i++)
        if((*tilemap_pointer)[(0x20*(window->window_y + i))+window->window_x + window->window_width] != RIGHT_BORDER_TILE)
            return false;
        
    return true;
}