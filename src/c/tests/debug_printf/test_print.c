#include "test_print.h"
#include "mgba.h"
#include <stdarg.h>


void test_printf(const char* ptr, ...) {
	va_list args;
	va_start(args, ptr);
    mgba_printf(MGBA_LOG_DEBUG, ptr, args);
	va_end(args);
}

void assert_print(bool condition, const char* file, int line)
{
    if(!condition)
        test_printf("FAIL! File: %s - Line: %d", file, line);
}

void start_session()
{
    mgba_open();
    test_printf("Starting...");
}

void end_session()
{
    test_printf("Done!");
    mgba_close();
}