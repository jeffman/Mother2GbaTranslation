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
  /*  0 */ byte unk0[6];
  /*  6 */ unsigned short hp;
  /*  8 */ unsigned short pp;
  /*  A */ byte unkA[2];
  /*  C */ unsigned int exp;
  /* 10 */ unsigned short money;
  /* 12 */ unsigned short overworldAnim;
  /* 14 */ char *encounter_text;
  /* 18 */ char *death_text;
  /* 1C */ byte palette;
  /* 1D */ byte level;
  /* 1E */ byte bgm;
  /* 1F */ byte offense;
  /* 20 */ byte defense;
  /* 21 */ byte unk21;
  /* 22 */ byte speed;
  /* 23 */ byte guts;
  /* 24 */ byte luck;
  /* 25 */ byte unk25[3];
  /* 28 */ unsigned short actions[4];
  /* 30 */ unsigned short finalAction;
  /* 32 */ unsigned short actionArgs[4];
  /* 3A */ byte unk3A[2];
  /* 3C */ byte unk3C;
  /* 3D */ byte itemDropped;
  /* 3E */ byte unk3E;
  /* 3F */ byte mirrorSuccess;
} ENEMY_DATA;

#endif