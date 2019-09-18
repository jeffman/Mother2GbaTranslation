#include "window.h"
#include "equip.h"
#include "number-selector.h"
#include "locs.h"


int equipReadInput(WINDOW* window) //Returns the character whose window we're going in, ACTION_NONE if nothing happens or ACTION_STEPOUT if going out of this window
{
    unsigned short previousCharacter = *active_window_party_member;
    int currentCharacter = previousCharacter;
    PAD_STATE state = *pad_state;
    PAD_STATE state_shadow = *pad_state_shadow;
    bool printed = false; //Used to avoid sound issues. If we printed, we don't make sounds
    
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
        if(currentCharacter != previousCharacter) //Print only if needed
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

void equippablePrint(WINDOW* window) //Prints equippable items (The innermost equip window)
{
    unsigned short savedValue = 0;
    byte* freeSpace = free_strings_pointers[3];
    byte *none = m2_strlookup((int*)0x8B17EE4, (byte*)0x8B17424, 0x2C);
    PC *character_data = &(m2_ness_data[*active_window_party_member]);
    
    unsigned short* something = (unsigned short*)0x3005224;
    unsigned short* something2 = (unsigned short*)0x300522C;
    
    for(int i = 0; i < 7; i++)
        freeSpace[i] = 0;
    freeSpace[7] = 0xFF;
    
    int* headerAddress = (int*)(((int)vram) + ((*something2) << 0xE) + ((*tile_offset) << 5));
    map_tile(0xB3, window->window_x, window->window_y - 1);
    
    unsigned short val = *something;
    if(!window->vwf_skip)
        clear_window_header(headerAddress, 8, 0x10, 0x11);

    unsigned short* lastUsed = print_equip_header(*something, (unsigned short*)((*tilemap_pointer) + (((window->window_y - 1) << 5) + window->window_x + 1)), headerAddress, window);
    
    window->vwf_skip = true;
    
    if(window->cursor_x > 6) //Mode which prints only 5 items in M12. Used if one has more than 8 items of an equippable kind.
    {
        clearWindowTiles_buffer(window);
        short counter = 0;
        while(counter < 5)
        {
            int value = (window->cursor_x_base * 5) + counter;
            byte equippables;
            if(value <= 0xD)
                equippables = *(window->number_text_area + 4 + value);
            else 
                equippables = 0xFF;
            if(equippables == 0xFF)
            {
                freeSpace[counter] = 0xFD;
                printstr_buffer(window, none, 1, counter, false);
                break;
            }
            else
            {
                byte *item = m2_strlookup((int*)0x8B1AF94, (byte*)0x8B1A694, character_data->goods[equippables - 1]);
                byte x = 1;
                if(m2_isequipped(equippables))
                {
                    map_special_character(0x1DE,(window->window_x + 1), (counter << 1) + 1); //Print the E
                    x++;
                }
                printstr_buffer(window, item, x, counter, false);
                freeSpace[counter] = equippables;
                counter++;
            }
        }
        
        byte* str = NULL;
        switch(val)
        {
            case 3:
                str = m12_other_str9; //->Weapons
            break;
            case 4:
                str = m12_other_str10; //->Body
            break;
            case 5:
                str = m12_other_str11; //->Arms
            break;
            case 6:
                str = m12_other_str12; //->Other
            break;
            default:
            break;
        }
        
        if(str != NULL)
            savedValue = printstr_buffer(window, str, 1, 6, false); //Prints the string, savedValue is used to understand where to print "(X)"
        
        int tmp = m2_div(window->cursor_x, 5);
        str = NULL;
        if(tmp <= window->cursor_x_base)
            str = m2_strlookup((int*)0x8B17EE4, (byte*)0x8B17424, 0x8C);
        else
            str = m2_strlookup((int*)0x8B17EE4, (byte*)0x8B17424, 0x8D + window->cursor_x_base);
        printstr_hlight_pixels_buffer(window, str, savedValue, 6 << 4, false); //Prints "(X)"
        freeSpace[5] = 0;
        freeSpace[6] = 0xFE;
        freeSpace[7] = 0xFF;
    }
    else //Prints up to 7 equippable items. It's the same as the above cycle, without the cursor_x_base stuff.
    {
        short counter = 0;
        while(counter < 7)
        {
            byte equippables = *(window->number_text_area + 4 + counter);

            if(equippables == 0xFF)
            {
                freeSpace[counter] = 0xFD;
                freeSpace[counter + 1] = 0xFF; //Different from the cycle above
                printstr_buffer(window, none, 1, counter, false);
                break;
            }
            else
            {
                byte *item = m2_strlookup((int*)0x8B1AF94, (byte*)0x8B1A694, character_data->goods[equippables - 1]);
                byte x = 1;
                if(m2_isequipped(equippables))
                {
                    map_special_character(0x1DE,(window->window_x + 1), (counter << 1) + 1); //Print the E
                    x++;
                }
                printstr_buffer(window, item, x, counter, false);
                freeSpace[counter] = equippables;
                counter++;
            }
        }
    }
    
    window->loaded_code = 0;
}

int equippableReadInput(WINDOW* window) //Manages input in equipment-choice innermost window. Returns the equippable item the cursor is on or ACTION_STEPOUT
{
    byte* freeSpace = free_strings_pointers[3];
    PC *character_data = &(m2_ness_data[*active_window_party_member]);
    bool printed = (window->loaded_code == 1);

    // Get weird sign height value
    unsigned short height = window->window_height;
    unsigned int height_sign_bit = height >> 15;
    unsigned int weird_value = (((height + height_sign_bit) << 15) >> 16);
    
    // Clear cursor tiles
    map_tile(0x1FF, window->window_x, window->window_y + window->cursor_y * 2);
    map_tile(0x1FF, window->window_x, window->window_y + window->cursor_y * 2 + 1);

    if(window->loaded_code == 1) //We're printing
        equippablePrint(window);
        
    PAD_STATE state = *pad_state;
    PAD_STATE state_shadow = *pad_state_shadow;
    
    unsigned short possibleEquippablesCount = window->cursor_x;
    short previousY = window->cursor_y;
    short currentY = window->cursor_y;
    
    int counter = 0;
    
    //Loads the total amount of items
    if(possibleEquippablesCount > 6)
        counter = 7;
    else if(weird_value > 0)
        while(counter < weird_value && freeSpace[counter] != 0xFF)
            counter++;
    
    
    if(state.up)
    {
        currentY--;
        if(currentY < 0)
        {
            if(window->hold)
                currentY = 0;
            else
                currentY = counter - 1;
        }
        else 
            while(freeSpace[currentY] == 0)
                currentY--;
    }
    
    if(state.down)
    {
        currentY++;
        if(currentY >= counter)
        {
            if(window->hold)
                currentY = counter - 1;
            else
                currentY = 0;
        }
        else 
            while(freeSpace[currentY] == 0)
                currentY++;
    }
    
    if(state_shadow.up || state_shadow.down)
    {
        window->counter = 0;
        if(previousY != currentY)
            m2_soundeffect(0x12F);
        window->hold = true;
        window->cursor_y = currentY;
    }
    else
        window->hold = false;
    
    if(state.b || state.select)
    {
        window->counter = 0;
        m2_soundeffect(0x12E);
        return ACTION_STEPOUT;
    }
    
    if((state.a || state.l) && !printed) //Avoid sound issues when going into the window
    {
        window->counter = 0xFFFF;
        if(freeSpace[window->cursor_y] == 0xFE)
        {
            m2_soundeffect(0x12D); //Do the sound only if we're changing the page. Otherwise the original code will do the appropriate sound
            window->counter = 0;
            window->cursor_x_base++;
            if(m2_div(window->cursor_x, 5) < window->cursor_x_base)
                window->cursor_x_base = 0;
            return 0xFE; //Change window counter
        }
        if(window->cursor_y + 1 < counter)
            return freeSpace[window->cursor_y]; //Equipment
        return 0xFD; //None
    }
    
    if (window->counter != 0xFFFF)
    {
        window->counter++;

        // Draw cursor for current item
        map_special_character((window->counter <= 7) ? 0x99 : 0x9A,
            window->window_x,
            window->window_y + window->cursor_y * 2);

        if (window->counter > 0x10)
            window->counter = 0;
    }

    if(window->cursor_y + 1 < counter)
        return freeSpace[window->cursor_y];
    return 0xFD; //None


}

//Simplified inner equip routine (The original routine had a pointer to a table of valid cursor positions as a parameter)
int innerEquipInput(WINDOW* window)
{
    bool printing = !window->vwf_skip;
    window->vwf_skip = true;
    
    PAD_STATE state = *pad_state;
    PAD_STATE state_shadow = *pad_state_shadow;

    short previousY = window->cursor_y;
    short currentY = window->cursor_y;
    
    // Clear cursor tiles
    map_tile(0x1FF, window->window_x, window->window_y + window->cursor_y * 2);
    map_tile(0x1FF, window->window_x, window->window_y + window->cursor_y * 2 + 1);
    
    if(state.up) //This has been simplified
    {
        currentY--;
        if(currentY < 0)
        {
            if(window->hold)
                currentY = 0;
            else
                currentY = 3;
        }
    }
    
    if(state.down) //This has been simplified
    {
        currentY++;
        if(currentY >= 4)
        {
            if(window->hold)
                currentY = 3;
            else
                currentY = 0;
        }
    }
    
    //The game does stuff when pressing left or right, however for the equipment window this is not needed
    if(state.right) //This routine in particular did both the main overworld window and the inner equip window
    {
    }
    
    
    if(state.left)
    {
    }
    
    if(state_shadow.up || state_shadow.down)
    {
        window->counter = 0;
        if(previousY != currentY)
            m2_soundeffect(0x12F);
        window->hold = true;
        window->cursor_y = currentY;
    }
    else
        window->hold = false;
    
    if((state.b || state.select) && (!printing))
    {
        window->counter = 0;
        m2_soundeffect(0x12E);
        window->vwf_skip = false;
        return ACTION_STEPOUT;
    }
    
    
    if((state.a || state.l) && (!printing))
    {
        window->counter = 0xFFFF;
        m2_soundeffect(0x12D);
        window->vwf_skip = false;
        return (window->cursor_y << 1) + ACTION_STEPIN;
    }
    
    if (window->counter != 0xFFFF)
    {
        window->counter++;

        // Draw cursor
        map_special_character((window->counter <= 7) ? 0x99 : 0x9A,
            window->window_x,
            window->window_y + window->cursor_y * 2);

        if (window->counter > 0x10)
            window->counter = 0;
    }
    
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
        print_blankstr_buffer(window->window_x + 6, 1, 0xC, (byte*)(OVERWORLD_BUFFER - ((*tile_offset) * TILESET_OFFSET_BUFFER_MULTIPLIER)));
        print_blankstr_buffer(window->window_x + 6, 3, 0xC, (byte*)(OVERWORLD_BUFFER - ((*tile_offset) * TILESET_OFFSET_BUFFER_MULTIPLIER)));
        print_blankstr_buffer(window->window_x + 6, 5, 0xC, (byte*)(OVERWORLD_BUFFER - ((*tile_offset) * TILESET_OFFSET_BUFFER_MULTIPLIER)));
        print_blankstr_buffer(window->window_x + 6, 7, 0xC, (byte*)(OVERWORLD_BUFFER - ((*tile_offset) * TILESET_OFFSET_BUFFER_MULTIPLIER)));
        
        //Clear the previous numbers
        print_blankstr_buffer(8, 0xB, 0x8, (byte*)(OVERWORLD_BUFFER - ((*tile_offset) * TILESET_OFFSET_BUFFER_MULTIPLIER)));
        print_blankstr_buffer(8, 0xD, 0x8, (byte*)(OVERWORLD_BUFFER - ((*tile_offset) * TILESET_OFFSET_BUFFER_MULTIPLIER)));
        
        //Reprint the ":"s

        print_character_with_callback_1bpp_buffer(decode_character(0x6A), ((window->window_x + 6) << 3), (0x1 << 3), (byte*)(OVERWORLD_BUFFER - ((*tile_offset) * TILESET_OFFSET_BUFFER_MULTIPLIER)), &get_tile_number_with_offset, 0, *tilemap_pointer, 32, 0xC);
        print_character_with_callback_1bpp_buffer(decode_character(0x6A), ((window->window_x + 6) << 3), (0x3 << 3), (byte*)(OVERWORLD_BUFFER - ((*tile_offset) * TILESET_OFFSET_BUFFER_MULTIPLIER)), &get_tile_number_with_offset, 0, *tilemap_pointer, 32, 0xC);
        print_character_with_callback_1bpp_buffer(decode_character(0x6A), ((window->window_x + 6) << 3), (0x5 << 3), (byte*)(OVERWORLD_BUFFER - ((*tile_offset) * TILESET_OFFSET_BUFFER_MULTIPLIER)), &get_tile_number_with_offset, 0, *tilemap_pointer, 32, 0xC);
        print_character_with_callback_1bpp_buffer(decode_character(0x6A), ((window->window_x + 6) << 3), (0x7 << 3), (byte*)(OVERWORLD_BUFFER - ((*tile_offset) * TILESET_OFFSET_BUFFER_MULTIPLIER)), &get_tile_number_with_offset, 0, *tilemap_pointer, 32, 0xC);
        
        //Print the equipment
        if(character_data->equipment[0] == 0) //Weapon
            print_string_in_buffer(nothing, (((window->window_x + 7)) << 3) - 2, (0x1) << 3, (byte*)(OVERWORLD_BUFFER - ((*tile_offset) * TILESET_OFFSET_BUFFER_MULTIPLIER)));
        else
        {
            item = m2_strlookup((int*)0x8B1AF94, (byte*)0x8B1A694, character_data->goods[character_data->equipment[0] - 1]);
            map_special_character(0x1DE,(window->window_x + 7), 0x1); //Print the E
            printstr_buffer(window, item, 8, 0, false);
        }
        
        if(character_data->equipment[1] == 0) //Body
            print_string_in_buffer(nothing, (((window->window_x + 7)) << 3) - 2, (0x3) << 3, (byte*)(OVERWORLD_BUFFER - ((*tile_offset) * TILESET_OFFSET_BUFFER_MULTIPLIER)));
        else
        {
            item = m2_strlookup((int*)0x8B1AF94, (byte*)0x8B1A694, character_data->goods[character_data->equipment[1] - 1]);
            map_special_character(0x1DE,(window->window_x + 7), 0x3); //Print the E
            printstr_buffer(window, item, 8, 1, false);
        }
        
        if(character_data->equipment[2] == 0) //Arms
            print_string_in_buffer(nothing, (((window->window_x + 7)) << 3) - 2, (0x5) << 3, (byte*)(OVERWORLD_BUFFER - ((*tile_offset) * TILESET_OFFSET_BUFFER_MULTIPLIER)));
        else
        {
            item = m2_strlookup((int*)0x8B1AF94, (byte*)0x8B1A694, character_data->goods[character_data->equipment[2] - 1]);
            map_special_character(0x1DE,(window->window_x + 7), 0x5); //Print the E
            printstr_buffer(window, item, 8, 2, false);
        }
        
        if(character_data->equipment[3] == 0) //Other
            print_string_in_buffer(nothing, (((window->window_x + 7)) << 3) - 2, (0x7) << 3, (byte*)(OVERWORLD_BUFFER - ((*tile_offset) * TILESET_OFFSET_BUFFER_MULTIPLIER)));
        else
        {
            item = m2_strlookup((int*)0x8B1AF94, (byte*)0x8B1A694, character_data->goods[character_data->equipment[3] - 1]);
            map_special_character(0x1DE,(window->window_x + 7), 0x7); //Print the E
            printstr_buffer(window, item, 8, 3, false);
        }
}

//Prints the numbers in the window in a formatted way
void printNumberEquip(WINDOW* window, byte* str, unsigned short x, unsigned short y, bool highlight)
{
    while((*str) == 0x50)
    {
        x += 6;
        str++;
    }
    printstr_hlight_pixels_buffer(window, str, x, y, highlight);
}

//Prints Offense: and Defense:
void printEquipWindowNumberText(WINDOW* window)
{
    handle_first_window_buffer(window, (byte*)(OVERWORLD_BUFFER - ((*tile_offset) * TILESET_OFFSET_BUFFER_MULTIPLIER)));
    printstr_hlight_pixels_buffer(window, window->text_start, 0, 3, false);
}

//Prints the arrow for the numbers in the Offense/Defense menu
void printEquipNumbersArrow(WINDOW* window)
{
    printTinyArrow((window->window_x + 9) << 3, (window->window_y + 0) << 3);
    printTinyArrow((window->window_x + 9) << 3, (window->window_y + 2) << 3);
}
