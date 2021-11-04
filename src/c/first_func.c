#include "first_func.h"

void main_func()
{
    #ifdef TEST
        start_tests();
    #else
        m12_first_function();
    #endif
}