#include "test_m2_utils.h"

#define RIGHT_BORDER_TILE              0x0095
#define OVERWORLD_BUFFER_LIMIT         0x2028000

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

void setup_overworld_buffer()
{
    *((int*)(OVERWORLD_BUFFER_POINTER)) = OVERWORLD_BUFFER_LIMIT - OVERWORLD_BUFFER_SIZE;
}