#include "main_test.h"
#include "battle_test.h"
#include "menu_test.h"
#include "debug_printf/test_print.h"

void start_tests()
{
    start_session();
    
    start_battle_tests();
    start_menu_tests();
    
    end_session();
    
    stop(0);
}
