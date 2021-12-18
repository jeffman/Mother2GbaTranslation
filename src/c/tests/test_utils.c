#include "test_utils.h"

#define CPUFASTSET_FILL (0x1000000)
#define IWRAM (0x3000000)
#define IWRAM_SIZE (0x8000-0x2000)

#define NON_IWRAM_RESET 0xFD

void blank_memory()
{
    int blank_value = 0;
    cpufastset(&blank_value, (void*)IWRAM, CPUFASTSET_FILL | (IWRAM_SIZE >> 2));
    reg_ram_reset(NON_IWRAM_RESET);
}