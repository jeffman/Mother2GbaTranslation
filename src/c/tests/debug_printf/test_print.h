#include "mgba.h"
#include "stdbool.h"

#define MAX_STR_SIZE 0x100
#define NULL 0

#define assert(condition) assert_print(condition, __FILE__, __LINE__, NULL)
#define assert_message(condition, format, ...) assert_print(condition, __FILE__, __LINE__, format, __VA_ARGS__)

void assert_print(bool condition, const char* file, int line, const char* message, ...);
void test_printf(const char* string, ...);
void start_session(void);
void end_session(void);

