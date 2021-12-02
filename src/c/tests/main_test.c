#include "main_test.h"
#include "battle_test.h"
#include "debug_printf/test_print.h"

void start_tests()
{
    start_session();
    
    blank_memory();
    start_battle_tests();
    
    blank_memory();
    
    end_session();
    
    while(1)
        vblank();
}

void blank_memory()
{
    int blank_value = 0;
    cpufastset(&blank_value, (void*)IWRAM, CPUFASTSET_FILL | (IWRAM_SIZE >> 2));
    reg_ram_reset(NON_IWRAM_RESET);
}