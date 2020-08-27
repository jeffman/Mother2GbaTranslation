#ifndef HEADER_PC_INCLUDED
#define HEADER_PC_INCLUDED

#include "types.h"

typedef enum AILMENT
{
    CONSCIOUS = 0,
    UNCONSCIOUS = 1,
    DIAMONDIZED = 2,
    PARALYZED = 3,
    NAUSEOUS = 4,
    POISONED = 5,
    SUNSTROKE = 6,
    SNIFFLING = 7
} AILMENT;

typedef enum AILMENT2
{
    MASHROOMIZED = 1,
    POSSESSED = 2
} AILMENT2;

typedef enum AILMENT3
{
    SLEEP = 1,
    CRYING = 2,
    CANNOT_MOVE = 3,
    SOLIDIFIED = 4
} AILMENT3;

typedef enum CHARACTER
{
    NESS = 0,
    PAULA = 1,
    JEFF = 2,
    POO = 3
} CHARACTER;

typedef struct PC {
    unsigned short goods[14];
    int experience;
    //0x20
    byte unknown[12];
    short level;
    short unknown2a;
    //0x30
    unsigned short hp_max;
    unsigned short hp_current;
    byte hp_unknown[2]; // possibly a rolling flag + a fractional value
    unsigned short hp_rolling;
    unsigned short pp_max;
    unsigned short pp_current;
    byte pp_unknown[2];
    unsigned short pp_rolling;
    //0x40
    AILMENT ailment;
    AILMENT2 ailment2;
    AILMENT3 ailment3;
    bool strange;
    bool cant_concentrate;
    bool homesick;
    bool unknown2[2];
    byte offense_base;
    byte defense_base;
    byte speed_base;
    byte guts_base;
    byte luck_base;
    byte vitality_base;
    byte iq_base;
    byte offense_effective;
    //0x50
    byte defense_effective;
    byte speed_effective;
    byte guts_effective;
    byte luck_effective;
    byte vitality_effective;
    byte iq_effective;
    byte unknown3[11];
    //0x61
    byte equipment[4];
    byte unknown4[7];
} PC;

#endif
