#include "help_funcs.h"

int __aeabi_uidivmod(int dividend, int divisor)
{
    return m2_remainder(dividend, divisor);
}

int __aeabi_uidiv(int dividend, int divisor)
{
    return m2_div(dividend, divisor);
}