#include "window.h"
#include "battle.h"
#include "number-selector.h"
#include "locs.h"

//Prints enemy target window
void printTargetOfAttack(short a, short target)
{
    WINDOW *window = getWindow(3);
    m2_setupwindow(window, 0x9, 0x3, 0x14, 0x2);
    initWindow_buffer(window, NULL, 0);
    printstr_buffer(window, m12_battle_commands_str11, 0, 0, false); //To 
    if(target != -1)
    {
        printstr_hlight_buffer(window, m12_battle_commands_str14, 8, 0, false);// " "
        short *pointer = (short*)(0x20248E0 + 0x83E);
        byte *pointer2 = (byte*)(pointer);
        short value = *pointer;
        m2_setupbattlename((a * value) + target + 1);
        byte* str = ((*((byte**)0x3005220)) + 0x4C0);
        printstr_buffer(window, str, 2, 0, false);
        if(a != 0)
            pointer2 += 0x2E;
        else
            pointer2 += 0x26;
        byte val = *(pointer2 + target);
        unsigned short ailmentTile = ailmentTileSetup((byte*)(0x2020CCF + (val * 0x94)), 0);
        if(ailmentTile >= 1)
        {
            map_tile(ailmentTile, window->window_x + 0x13, window->window_y);
            map_tile(ailmentTile + 0x20, window->window_x + 0x13, window->window_y + 1);
        }
        else
        {
            map_tile(0x1FF, window->window_x + 0x13, window->window_y);
            map_tile(0x1FF, window->window_x + 0x13, window->window_y + 1);
        }
    }
    else
    {
        if(a == 0) //a is the row here
            printstr_buffer(window, m12_battle_commands_str12, 2, 0, false); //the Front Row
        else
            printstr_buffer(window, m12_battle_commands_str13, 2, 0, false); //the Back Row
    }
}

//Only implements up to Goods right now
void printBattleMenu(byte validXs, byte validYs, byte highlighted)
{
    unsigned short* drawValue = (unsigned short*)0x2025122;
    byte *str;
    WINDOW* window = getWindow(0);
    if(validXs & 1)
    {
        if(validYs & 1)
        {
            print_blankstr_buffer(2,1,5,(byte*)(OVERWORLD_BUFFER - ((*tile_offset) * 8)));
            if((*drawValue) == 2)
            {
                print_blankstr_buffer(7,1,5,(byte*)(OVERWORLD_BUFFER - ((*tile_offset) * 8)));
                str = m12_battle_commands_str10; //Do Nothing
            }
            else if((*drawValue) == 1)
                str = m12_battle_commands_str6; //Shoot
            else
                str = m12_battle_commands_str0; //Bash
            printstr_hlight_buffer(window, str, 1, 0, highlighted & 1);
        }
        
        if(validYs & 2)
        {
            print_blankstr_buffer(2,3,5,(byte*)(OVERWORLD_BUFFER - ((*tile_offset) * 8)));
            if((*active_window_party_member) != 2)
                printstr_hlight_buffer(window, m12_battle_commands_str3, 1, 1, highlighted & 2); //PSI
            else
                printstr_hlight_buffer(window, m12_battle_commands_str7, 1, 1, highlighted & 2); //Spy
        }
    }
    
    if(validXs & 2)
    {
        if(validYs & 1)
        {
            if((*drawValue) != 2)
            {
                print_blankstr_buffer(7,1,5,(byte*)(OVERWORLD_BUFFER - ((*tile_offset) * 8)));
                printstr_hlight_buffer(window, m12_battle_commands_str1, 6, 0, highlighted & 4); //Goods
            }
        }
        
        if(validYs & 2)
        {
            print_blankstr_buffer(7,3,5,(byte*)(OVERWORLD_BUFFER - ((*tile_offset) * 8)));
            if((*drawValue) != 2)
            {
                printstr_hlight_buffer(window, m12_battle_commands_str4, 6, 1, highlighted & 8); //Defend
            }
        }
    }
}