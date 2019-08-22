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

typedef struct CHARACTER_DATA {
    // 0x00
    unsigned short inventory[14];
	//0x1C
	unsigned int experience;
	byte unknown[0xC];
	unsigned int level;
	unsigned short maxHp;
	unsigned short currentHp;
	unsigned short unknown2;
	unsigned short scrollingHp;
	unsigned short maxPp;
	unsigned short currentPp;
	unsigned short unknown3;
	unsigned short scrollingPp;
	AILMENT ailment;
	byte flag[5];
	byte unknown4[2];
	byte base_atk;
	byte base_def;
	byte base_speed;
	byte base_guts;
	byte base_luck;
	byte base_vitality;
	byte base_iq;
	byte atk;
	byte def;
	byte speed;
	byte guts;
	byte luck;
	byte vitality;
	byte iq;
	byte unknown5[0xB];
	byte equipment[4];
	byte unknown6[0x7];
} CHARACTER_DATA;

