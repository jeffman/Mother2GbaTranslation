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
    cpufastset(&blank_value, (void*)EWRAM, CPUFASTSET_FILL | (EWRAM_SIZE >> 2));
    cpufastset(&blank_value, (void*)IWRAM, CPUFASTSET_FILL | (IWRAM_SIZE >> 3));
    cpufastset(&blank_value, (void*)IO, CPUFASTSET_FILL | (IO_SIZE >> 2));
    cpufastset(&blank_value, (void*)PALETTES, CPUFASTSET_FILL | (PALETTES_SIZE >> 2));
    cpufastset(&blank_value, (void*)VRAM, CPUFASTSET_FILL | (VRAM_SIZE >> 2));
    cpufastset(&blank_value, (void*)OBJECTS, CPUFASTSET_FILL | (OBJECTS_SIZE >> 2));
}