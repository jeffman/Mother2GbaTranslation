#include "test_print.h"
#include "mgba.h"
#include <stdarg.h>
#include "printf.h"


void test_printf(const char* ptr, ...) {
	va_list args;
	va_start(args, ptr);
    mgba_printf(MGBA_LOG_DEBUG, ptr, args);
	va_end(args);
}

void assert_print(bool condition, const char* file, int line, const char* message, ...)
{
    char str[MAX_STR_SIZE];
    if(!condition)
    {
        if(message == NULL)
            test_printf("FAIL! File: %s - Line: %d", file, line);
        else
        {
            va_list args;
            va_start(args, message);
            vsnprintf(str, MAX_STR_SIZE, message, args);
            va_end(args);
            test_printf("FAIL! File: %s - Line: %d - Message: %s", file, line, str);
        }
    }
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