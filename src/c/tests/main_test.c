#include "main_test.h"
#include "battle_test.h"
#include "debug_printf/test_print.h"

void start_tests()
{
    start_session();
    
    start_battle_tests();
    
    end_session();
    
    while(1)
        vblank();
}