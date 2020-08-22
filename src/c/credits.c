#include "credits.h"

void printPlayerNameCredits(unsigned short *arrangements)
{
    //Converts the player name to arrangements
    int length = 0;
    byte *player_name = m2_player1;
    //First things first, it calculates the length of the string
    for(length = 0; length < PLAYER_NAME_SIZE && (*(++player_name)) != 0xFF; length++);
    
    //Gets where to position the arrangements...
    int start_pos = ((0x1F - length) >> 1) + 1;
    int start_pos_default = ((0x1F - 5) >> 1) + 1;
    unsigned short *player_name_arrangements = ((0x89 << 2) << 5) + arrangements + start_pos;
    unsigned short *default_player_name_arrangements = ((0x89 << 2) << 5) + arrangements + start_pos_default;
    player_name = m2_player1;
    
    //Clears the default MARIO player name...
    for(int i = 0; i < 5; i++)
    {
        default_player_name_arrangements[i] = 0xF19B;
        default_player_name_arrangements[i + 0x20] = 0xF19B;
    }
    
    //Puts the new arrangements in
    for(int i = 0; i < length; i++)
    {
        unsigned short arrangement = m2_credits_conversion_table[player_name[i]];
        player_name_arrangements[i] = arrangement;
        player_name_arrangements[i + 0x20] = arrangement + 0x20;
    }
}