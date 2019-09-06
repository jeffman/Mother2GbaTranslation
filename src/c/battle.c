#include "window.h"
#include "battle.h"
#include "number-selector.h"
#include "locs.h"

void printTargetOfAttack(short a, short target)
{
    WINDOW *window = getWindow(3);
    m2_setupwindow(window, 0x9, 0x3, 0x14, 0x2);
    initWindow_buffer(window, NULL, 0);
    printstr_buffer(window, &m12_battle_commands_str11, 0, 0, false);
    if(target != -1)
    {
        printstr_hlight_buffer(window, &m12_battle_commands_str14, 8, 0, 0);
        short *pointer = (short*)(0x20248E0 + 0x83E);
        byte *pointer2 = (byte*)(0x20248E0);
        short value = *pointer;
        m2_setupBattleName((a * value) + target + 1);
        byte* str = ((*((byte**)0x3005220)) + 0x4C0);
        printstr_buffer(window, str, 2, 0, false);
        if(a != 0)
            pointer2 += 0x2E;
        else
            pointer2 += 0x26;
        byte val = *(pointer2 + target);
        unsigned short ailmentTile = ailmentTileSetup((byte*)(0x2020CCF + (val * 0x94)), 0);
        if(ailmentTile >= 1)
            map_tile(ailmentTile, window->window_x + 0x26, window->window_y);
    }
    else
    {
        if(a == 0) //a is the row here
            printstr_buffer(window, &m12_battle_commands_str12, 2, 0, false);
        else
            printstr_buffer(window, &m12_battle_commands_str13, 2, 0, false);
    }
}