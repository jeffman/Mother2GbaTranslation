#ifndef HEADER_PSI_INCLUDED
#define HEADER_PSI_INCLUDED

#include "vwf.h"

typedef struct PSIClasses {
    bool Offense : 1;
    bool Recover : 1;
    bool Assist : 1;
    bool Other : 1;
} PSIClasses;

typedef struct PSIWindow
{
    bool Character_Window : 1;
    bool Classes_Window : 1;
} PSIWindow;

typedef struct PSIPrintInfo {
    byte PSIID;
    byte symbol;
    PSIClasses possibleClasses;
    PSIWindow windowType;
    unsigned short PSIPrintInfoID;
    byte levelLearnt[3];
    byte XSymbol;
    unsigned short YPrinting;
    byte *description;
} PSIPrintInfo;

typedef struct SpecialPSIFlag {
    bool Ness_Teleport_Alpha : 1;
    bool Poo_Starstorm_Alpha : 1;
    bool Poo_Starstorm_Omega : 1;
    bool Ness_Teleport_Beta  : 1;
} SpecialPSIFlag;


void psiWindow_buffer(CHARACTER psiCharacter, PSIWindow typeOfWindow, PSIClasses printableClasses);
void psiTargetWindow_buffer(byte target);
void psiPrint_buffer(byte value, WINDOW* window, bool printPSILine, PSIPrintInfo *printInfo);
int PSITargetWindowInput(WINDOW* window);
int PSITargetInput(WINDOW* window);


extern PSIPrintInfo m2_psi_print_table[];

#endif
