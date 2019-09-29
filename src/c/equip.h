#ifndef HEADER_EQUIP_INCLUDED
#define HEADER_EQUIP_INCLUDED

#include "vwf.h"

void equipPrint(WINDOW* window);
int equipReadInput(WINDOW* window);
void equippablePrint(WINDOW* window);
int equippableReadInput(WINDOW* window);
int innerEquipInput(WINDOW* window);
void printEquipWindowNumberText(WINDOW* window);
void printEquipNumbersArrow(WINDOW* window);


extern byte m12_other_str9[];
extern byte m12_other_str10[];
extern byte m12_other_str11[];
extern byte m12_other_str12[];

#endif