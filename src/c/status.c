#include "window.h"
#include "status.h"
#include "number-selector.h"
#include "locs.h"

void printNumberOfStatus(int maxLength, int value, int blankX, int y, int strX, int width)
{
    byte str[0x10];
    int end = setNumber_getLength(value, str, maxLength);
    str[end] = 0;
    str[end + 1] = 0xFF;
    print_blankstr_buffer(blankX, y, width, (int*)(OVERWORLD_BUFFER - 0x2000));
    int x = (strX - (end * 6));
    print_string_in_buffer(str, x, y << 3, (int*)(OVERWORLD_BUFFER - 0x2000));
}

void printStatusSymbolArrangement(unsigned short symbolTile, WINDOW* window)
{
    unsigned short *arrangementBase = ((*tilemap_pointer) + (((window->window_y) + 2) << 5) + window->window_x);
    unsigned short ailmentTile = ((*tile_offset) + symbolTile) | (*palette_mask);
    (*(arrangementBase + 10)) = ailmentTile;
    if(symbolTile == 0x1FF)
        ailmentTile -= 0x20;
    (*(arrangementBase + 42)) = (ailmentTile + 0x20);
}

void printStatusString(WINDOW* window, int value)
{
    byte *str = m2_strlookup((int*)0x8B17EE4, (byte*)0x8B17424, value);
    printstr_hlight_buffer(window, str, 1, 2, 0);
}

int statusNumbersPrint(WINDOW* window, bool doNotPrint)
{
    if ((!(window->flags_unknown3a & 0x10)) && !doNotPrint)
    {
        window->flags_unknown3a |= 0x10;

        // Draw window header
        map_tile(0xB3, window->window_x, window->window_y - 1);
        clear_name_header(window);
        copy_name_header(window, *active_window_party_member);
    }
    
    if(!doNotPrint)
    {
        m2_hpwindow_up(*active_window_party_member);
        PC *character_data = &(m2_ness_data[*active_window_party_member]);
        printNumberOfStatus(2, character_data->level, 0x5, 1, 0x38, 3);
        printNumberOfStatus(3, character_data->hp_max, 0x10, 7, 0x93, 3);
        printNumberOfStatus(3, character_data->hp_rolling, 0xC, 7, 0x78, 3);
        printNumberOfStatus(3, character_data->pp_max, 0x10, 9, 0x93, 3);
        printNumberOfStatus(3, character_data->pp_rolling, 0xC, 9, 0x78, 3);
        printNumberOfStatus(7, character_data->experience, 0xC, 0xB, 0x93, 7);
        if(character_data->level < 99)
        {
            unsigned int *experienceLevelTable = (unsigned int*)0x8B1EC20;
            unsigned int experienceLevelUp = *(experienceLevelTable + ((*active_window_party_member) * 100) + character_data->level + 1);
            printNumberOfStatus(7, experienceLevelUp - character_data->experience, 2, 0xD, 0x3D, 6);
        }
        else
            print_blankstr_buffer(2, 0xD, 6, (int*)(OVERWORLD_BUFFER - 0x2000));
        printNumberOfStatus(3, character_data->offense_effective, 0x19, 0x1, 0xE1, 4);
        printNumberOfStatus(3, character_data->defense_effective, 0x19, 0x3, 0xE1, 4);
        printNumberOfStatus(3, character_data->speed_effective, 0x19, 0x5, 0xE1, 4);
        printNumberOfStatus(3, character_data->guts_effective, 0x19, 0x7, 0xE1, 4);
        printNumberOfStatus(3, character_data->vitality_effective, 0x19, 0x9, 0xE1, 4);
        printNumberOfStatus(3, character_data->iq_effective, 0x19, 0xB, 0xE1, 4);
        printNumberOfStatus(3, character_data->luck_effective, 0x19, 0xD, 0xE1, 4);
        print_blankstr_buffer(5, 0xF, 0x14, (int*)(OVERWORLD_BUFFER - 0x2000));
        if((*active_window_party_member) != JEFF)
        {
            byte *str = m2_strlookup((int*)0x8B17EE4, (byte*)0x8B17424, 0x13);
            print_string_in_buffer(str, 0x2C, (0xF) << 3, (int*)(OVERWORLD_BUFFER - 0x2000));
        }
        print_blankstr_buffer(1, 0x3, 0xA, (int*)(OVERWORLD_BUFFER - 0x2000));
        unsigned short symbolTile = ailmentTileSetup(character_data, 0);
        if(symbolTile == 0)
        {
            printStatusSymbolArrangement(0x1FF, window);
        }
        if(character_data->ailment != CONSCIOUS)
            printStatusString(window, 0x7F + character_data->ailment);
        else if(character_data->ailment2 != CONSCIOUS)
            printStatusString(window, 0x86 + character_data->ailment2);
        else if(character_data->homesick)
            printStatusString(window, 0x89);
        if(character_data->ailment != CONSCIOUS || character_data->ailment2 != CONSCIOUS || character_data->ailment3 != CONSCIOUS || character_data->strange || character_data->cant_concentrate || character_data->unknown2[0])
        {
            if(symbolTile == 0)
                return 0;
            printStatusSymbolArrangement(symbolTile, window);
            return 0;
        }
    }
    return -1;
    
}

int statusReadInput(WINDOW* window)
{
    unsigned short previousCharacter = *active_window_party_member;
    int currentCharacter = previousCharacter;
    PAD_STATE state = *pad_state;
    PAD_STATE state_shadow = *pad_state_shadow;
    
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
        m2_hpwindow_up(currentCharacter);
        clear_name_header(window);
        copy_name_header(window, currentCharacter);
        (*active_window_party_member) = currentCharacter;
        if(currentCharacter != previousCharacter)
            statusNumbersPrint(window, false);
    }
    
    if(state_shadow.right || state_shadow.left)
    {
        if(state.right || state.left)
        {
            int flag = *window_flags;
            if(flag & 0x800)
            {
                if(currentCharacter != previousCharacter)
                    m2_soundeffect(0x131);
            }
            else if(currentCharacter != previousCharacter)
                    m2_soundeffect(0x12E);
        }
        window->hold = true;
    }
    else
        window->hold = false;
    
    if(state.b || state.select)
    {
        m2_soundeffect(0x12E);
        window->counter = 0;
        return ACTION_STEPOUT;
    }
    else if(state.a || state.l)
    {
        m2_soundeffect(0x12D);
        if(currentCharacter != JEFF)
        {    
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
        else 
            return 0;
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

int statusWindowNumbers(WINDOW* window, bool doNotPrint)
{
    if(statusNumbersPrint(window, doNotPrint) == 0)
        return 0;
    return statusReadInput(window);
}

int statusWindowText(WINDOW* window)
{
    if(window->redraw)
        buffer_drawwindow(window, (int*)(OVERWORLD_BUFFER - 0x2000));
    if(window->loaded_code != 0 && ((*script_readability) == 0))
    {
        window->delay = 0;
        while(true)
        {
            while(window->text_y >= window->window_height || window->window_y + window->text_y > 0x1F)
                properScroll(window, (int*)(OVERWORLD_BUFFER - 0x2000));
            byte *str = window->text_start + window->text_offset;
            if((*(str + 1)) == 0xFF)
            {
                int returnedLength = customcodes_parse_generic(*str, str, window, (int*)(OVERWORLD_BUFFER - 0x2000));
                if(returnedLength != 0)
                {
                    if(returnedLength < 0)
                        returnedLength = 0;
                    window->text_offset += returnedLength;
                }
                else
                {
                    if((*str) == 1)
                    {
                        window->text_y += 2;
                        window->text_x = 0;
                        window->text_offset += 2;
                    }
                    else if((*str) == 0)
                    {
                        window->loaded_code = 0;
                        break;
                    }
                    else
                        window->text_offset++;
                }
            }
            else
            {
                if(window->text_x >= window->window_width || window->window_x + window->text_x > 0x1F)
                {
                    window->text_y += 2;
                    window->text_x = 0;
                }
                weld_entry_custom_buffer(window, str, 0, 0xF, (int*)(OVERWORLD_BUFFER - 0x2000));
                window->text_offset++;
            }
        }
    }

    return 0;
}