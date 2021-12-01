#include "debug_printf/test_print.h"

#define CPUFASTSET_FILL (0x1000000)
#define EWRAM (0x2000000)
#define EWRAM_SIZE (0x40000)
#define IWRAM (0x3000000)
#define IWRAM_SIZE (0x8000)
#define IO (0x4000000)
#define IO_SIZE (0x400)
#define PALETTES (0x5000000)
#define PALETTES_SIZE (0x400)
#define VRAM (0x6000000)
#define VRAM_SIZE (0x18000)
#define OBJECTS (0x7000000)
#define OBJECTS_SIZE (0x400)

void start_tests();
void blank_memory();

extern void vblank();
extern void cpufastset(void *source, void *dest, int mode);