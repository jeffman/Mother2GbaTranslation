#include "test_utils.h"
#include "test_m2_utils.h"
#include "debug_printf/test_print.h"

#include "../battle_data.h"
#include "../battle.h"
#include "../vwf.h"

#define INITIAL_SYMBOL_ENEMY 0x70

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