#include "mgba.h"
#include "stdbool.h"

#define assert(condition) assert_print(condition, __FILE__, __LINE__)

void assert_print(bool condition, const char* file, int line);
void test_printf(const char* string, ...);
void start_session(void);
void end_session(void);

