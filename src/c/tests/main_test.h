#include "debug_printf/test_print.h"

#define CPUFASTSET_FILL (0x1000000)
#define IWRAM (0x3000000)
#define IWRAM_SIZE (0x8000-0x2000)

#define NON_IWRAM_RESET 0xFD

void start_tests();
void blank_memory();

extern void vblank();
extern void cpufastset(void *source, void *dest, int mode);
extern void reg_ram_reset(int flag);