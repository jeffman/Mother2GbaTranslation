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
    SNIFFLING = 7,
    MASHROOMIZED = 8,
    POSSESSED = 9,
    HOMESICK = 0xA,
} AILMENT;

typedef struct PC {
    unsigned short goods[14];
    int experience;
    byte unknown[12];
    int level;
    unsigned short hp_max;
    unsigned short hp_current;
    byte hp_unknown[2]; // possibly a rolling flag + a fractional value
    unsigned short hp_rolling;
    unsigned short pp_max;
    unsigned short pp_current;
    byte pp_unknown[2];
    unsigned short pp_rolling;
    AILMENT ailment;
    bool mashroomized;
    bool sleep;
    bool strange;
    bool cant_concentrate;
    bool homesick;
    byte unknown2[2];
    byte offense_base;
    byte defense_base;
    byte speed_base;
    byte guts_base;
    byte luck_base;
    byte vitality_base;
    byte iq_base;
    byte offense_effective;
    byte defense_effective;
    byte speed_effective;
    byte guts_effective;
    byte luck_effective;
    byte vitality_effective;
    byte iq_effective;
    byte unknown3[11];
    byte equipment[4];
    byte unknown4[7];
} PC;

#endif
