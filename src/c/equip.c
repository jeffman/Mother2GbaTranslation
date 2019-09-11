#include "window.h"
#include "equip.h"
#include "number-selector.h"
#include "locs.h"


int equipReadInput(WINDOW* window)
{
    unsigned short previousCharacter = *active_window_party_member;
    int currentCharacter = previousCharacter;
    PAD_STATE state = *pad_state;
    PAD_STATE state_shadow = *pad_state_shadow;
    bool printed = false;
    
    if(state.right && !window->hold)
        currentCharacter += 1;
    
    if(state.left && !window->hold)
        currentCharacter -= 1;
    
    if((state.left || state.right) && !window->hold)
    {
        window->unknown7 = 0;
        if(state.left)
        {
            if(currentCharacter < 0)
                currentCharacter = 3;
            int foundChar = currentCharacter;
            for(int i = 0; i < 4; i++)
            {
                if (foundChar < 0)
                    foundChar = 3;
                if ((*pc_flags)[foundChar])
                    break;
                
                foundChar--;
            }
            currentCharacter = foundChar;
        }
        else
        {
            if(currentCharacter > 3)
                currentCharacter = 0;
            int foundChar = currentCharacter;
            for(int i = 0; i < 4; i++)
            {
                if (foundChar > 3)
                    foundChar = 0;
                if ((*pc_flags)[foundChar])
                    break;
                
                foundChar++;
            }
            currentCharacter = foundChar;
        }
        (*active_window_party_member) = currentCharacter;
        if(currentCharacter != previousCharacter)
        {
            equipPrint(window);
            printed = true;
        }
    }
    
    if(state_shadow.right || state_shadow.left)
    {
        if(state.right || state.left)
        {
            if(currentCharacter != previousCharacter)
                m2_soundeffect(0x131);
        }
        window->hold = true;
    }
    else
        window->hold = false;
    
    if(state.b || state.select)
    {
        if(!printed)
            m2_soundeffect(0x12E);
        window->counter = 0;
        return ACTION_STEPOUT;
    }
    else if(state.a || state.l)
    {
        if(!printed)
            m2_soundeffect(0x12D);
        if((*pc_count) > 1)
        {
            unsigned short *arrangementBase = (*tilemap_pointer) + (((window->window_y - 1) << 5) + window->window_x + window->window_width - 4);
            unsigned short topTile = ((*tile_offset) + 0x96) | (*palette_mask) | 0x800;
            (*arrangementBase) = topTile;
            (*(arrangementBase + 1)) = topTile;
            (*(arrangementBase + 2)) = topTile;
            (*(arrangementBase + 3)) = topTile;
        }
        
        window->counter = 0;
        return 1;
    }
    
    window->counter++;
    
    if (*pc_count > 1)
    {
        // We're doing a bit of simplification here.
        // The Japanese version tries to highlight the arrow you pressed.
        // It only shows for a couple frames and it looks weird, so we're
        // just going to show the arrows and not bother with the direction indicator.
        draw_window_arrows(window, window->counter < 8);
    }

    if (window->counter > 16)
        window->counter = 0;
    
    return ACTION_NONE;
}

void equipPrint(WINDOW* window) //Prints equipment
{
        m2_hpwindow_up(*active_window_party_member);
        
        // Draw window header
        map_tile(0xB3, window->window_x, window->window_y - 1);
        clear_name_header(window);
        copy_name_header(window, *active_window_party_member);
        
        PC *character_data = &(m2_ness_data[*active_window_party_member]);
        byte *nothing = m2_strlookup((int*)0x8B17EE4, (byte*)0x8B17424, 0x2A);
        byte *item;
        
        //Clear the previous equipment
        print_blankstr_buffer(window->window_x + 6, 1, 0xC, (int*)(OVERWORLD_BUFFER - 0x2000));
        print_blankstr_buffer(window->window_x + 6, 3, 0xC, (int*)(OVERWORLD_BUFFER - 0x2000));
        print_blankstr_buffer(window->window_x + 6, 5, 0xC, (int*)(OVERWORLD_BUFFER - 0x2000));
        print_blankstr_buffer(window->window_x + 6, 7, 0xC, (int*)(OVERWORLD_BUFFER - 0x2000));
        
        //Clear the previous numbers
        print_blankstr_buffer(7, 0xB, 0x8, (int*)(OVERWORLD_BUFFER - 0x2000));
        print_blankstr_buffer(7, 0xD, 0x8, (int*)(OVERWORLD_BUFFER - 0x2000));
        
        //Reprint the ":"s

        print_character_with_callback(decode_character(0x6A), ((window->window_x + 6) << 3), (0x1 << 3), 0, 0xF, (int*)(OVERWORLD_BUFFER - 0x2000), &get_tile_number_with_offset, *tilemap_pointer, 32, 0xC);
        print_character_with_callback(decode_character(0x6A), ((window->window_x + 6) << 3), (0x3 << 3), 0, 0xF, (int*)(OVERWORLD_BUFFER - 0x2000), &get_tile_number_with_offset, *tilemap_pointer, 32, 0xC);
        print_character_with_callback(decode_character(0x6A), ((window->window_x + 6) << 3), (0x5 << 3), 0, 0xF, (int*)(OVERWORLD_BUFFER - 0x2000), &get_tile_number_with_offset, *tilemap_pointer, 32, 0xC);
        print_character_with_callback(decode_character(0x6A), ((window->window_x + 6) << 3), (0x7 << 3), 0, 0xF, (int*)(OVERWORLD_BUFFER - 0x2000), &get_tile_number_with_offset, *tilemap_pointer, 32, 0xC);
        
        //Print the equipment
        if(character_data->equipment[0] == 0) //Weapon
            print_string_in_buffer(nothing, (((window->window_x + 7)) << 3) - 2, (0x1) << 3, (int*)(OVERWORLD_BUFFER - 0x2000));
        else
        {
            item = m2_strlookup((int*)0x8B1AF94, (byte*)0x8B1A694, character_data->equipment[0]);
            map_special_character(0x1DE,(window->window_x + 7), 0x1); //Print the E
            printstr_buffer(window, item, 8, 0, false);
        }
        
        if(character_data->equipment[1] == 0) //Body
            print_string_in_buffer(nothing, (((window->window_x + 7)) << 3) - 2, (0x2) << 3, (int*)(OVERWORLD_BUFFER - 0x2000));
        else
        {
            item = m2_strlookup((int*)0x8B1AF94, (byte*)0x8B1A694, character_data->equipment[1]);
            map_special_character(0x1DE,(window->window_x + 7), 0x3); //Print the E
            printstr_buffer(window, item, 8, 1, false);
        }
        
        if(character_data->equipment[2] == 0) //Arms
            print_string_in_buffer(nothing, (((window->window_x + 6)) << 3) - 2, (0x3) << 3, (int*)(OVERWORLD_BUFFER - 0x2000));
        else
        {
            item = m2_strlookup((int*)0x8B1AF94, (byte*)0x8B1A694, character_data->equipment[2]);
            map_special_character(0x1DE,(window->window_x + 7), 0x5); //Print the E
            printstr_buffer(window, item, 8, 2, false);
        }
        
        if(character_data->equipment[3] == 0) //Other
            print_string_in_buffer(nothing, (((window->window_x + 7)) << 3) - 2, (0x4) << 3, (int*)(OVERWORLD_BUFFER - 0x2000));
        else
        {
            item = m2_strlookup((int*)0x8B1AF94, (byte*)0x8B1A694, character_data->equipment[3]);
            map_special_character(0x1DE,(window->window_x + 7), 0x7); //Print the E
            printstr_buffer(window, item, 8, 3, false);
        }
}