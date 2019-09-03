#ifndef HEADER_STATUS_INCLUDED
#define HEADER_STATUS_INCLUDED

#include "vwf.h"

void printNumberOfStatus(int maxLength, int value, int blankX, int y, int strX, int width);
void printStatusSymbolArrangement(unsigned short symbolTile, WINDOW* window);
void printStatusString(WINDOW* window, int value);
int statusNumbersPrint(WINDOW* window, bool doNotPrint);
int statusReadInput(WINDOW* window);
int statusWindowNumbers(WINDOW* window, bool doNotPrint);
int statusWindowText(WINDOW* window);

#endif