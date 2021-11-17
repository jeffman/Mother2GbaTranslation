#ifndef HEADER_BATTLE_DATA_INCLUDED
#define HEADER_BATTLE_DATA_INCLUDED

#include "types.h"

// NOTE: WE DON'T KNOW HOW BIG THIS STRUCT IS
typedef struct BATTLE_DATA {
    byte unknown[0x42];
    short id;           //0x42
    byte unknown_2[0x15];
    byte letter;        //0x59
    byte unknown_3[0x2];
    bool is_enemy;      //0x5C
    byte npc_id;        //0x5D
    byte pc_id;         //0x5E
    byte unknown_4[0x33];
    short enemy_id;     //0x92
} BATTLE_DATA;

typedef struct ENEMY_DATA {
    byte unknown[0x14];
    char* encounter_text;
    byte unknown_2[0x28];
} ENEMY_DATA;

#endif