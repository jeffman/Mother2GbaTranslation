#include "../battle_data.h"
#include "debug_printf/test_print.h"

#define W_LETTER 0x87
#define KING_OFFSET 0x1C
#define RIGHT_BORDER_TILE 0x0095

void start_battle_tests();

extern void m2_battletext_loadstr(char* string);

extern ENEMY_DATA m2_enemies[];
extern bool m2_script_readability;
extern short m2_is_battle;
extern byte m2_btl_enemies_size;
extern BATTLE_DATA* m2_btl_user_ptr;
extern BATTLE_DATA* m2_btl_target_ptr;
extern void m2_set_user_name(int val);
extern void m2_set_target_name();