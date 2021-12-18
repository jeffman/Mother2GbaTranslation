#ifndef TEST_UTILS
#define TEST_UTILS

#define run_test(func) \
    blank_memory();\
    _setup();\
    func();

void blank_memory();

extern void cpufastset(void *source, void *dest, int mode);
extern void reg_ram_reset(int flag);

#endif