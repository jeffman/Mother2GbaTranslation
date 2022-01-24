#include "window.h"

extern void cpuset(void *source, void *dest, int mode);

void copy_window(WINDOW* source, WINDOW* destination) {
    cpuset(source, destination, sizeof(WINDOW) >> 1);
}