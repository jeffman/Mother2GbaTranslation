#include "window.h"
#include "psi.h"
#include "number-selector.h"
#include "locs.h"

void psiWindow_buffer(CHARACTER psiCharacter, PSIWindow typeOfWindow, PSIClasses printableClasses)
{
	PC *char_data = &(m2_ness_data[psiCharacter]);
	PSIPrintInfo *printInfo;
	int level = 0;
	int thing2 = 0;
	byte *str = 0;
	byte *boolCmpWindowType = (byte*)(&(typeOfWindow));
	byte *boolCmpPrintableClasses = (byte*)(&(printableClasses));
	byte *address = (byte*)0x3000A00;
	WINDOW *window = getWindow(7);
	SpecialPSIFlag *SpecialPSIFlags = (SpecialPSIFlag*)(character_general_data + 0x22A);
	bool print[0x11];
	for(int i = 0; i < 0x11; i ++)
		print[i] = true;

	for(int i = 0; i < 4; i++)
	{
		(*(address + i)) = 0;
		(*(address + i + 4)) = 0;
		(*(address + i + 8)) = 0;
	}
	
	if(psiCharacter == POO && typeOfWindow.Classes_Window && printableClasses.Offense)
	{
		if(SpecialPSIFlags->Poo_Starstorm_Alpha)
		{
			printInfo = &(psi_print_info[20]);
			psiPrint_buffer(20 + 1, window, print[6 - 1], printInfo);
			print[6 - 1] = false;
		}
		if(SpecialPSIFlags->Poo_Starstorm_Omega)
		{
			printInfo = &(psi_print_info[21]);
			psiPrint_buffer(21 + 1, window, print[6 - 1], printInfo);
			print[6 - 1] = false;
		}
	}
	
	
	printInfo = &(psi_print_info[0]);
	for(int i = 0; printInfo->PSIID != 0; i++)
	{
		if(psiCharacter != JEFF)
		{
			int val = psiCharacter == POO ? 2 : psiCharacter;
			level = printInfo->levelLearnt[val];
		}
		
		if(level != 0)
		{
			byte *boolCmpWindowTypePrintInfo = (byte*)(&(printInfo->windowType));
			if((*boolCmpWindowType) & (*boolCmpWindowTypePrintInfo))
			{
				if(char_data->level >= level)
				{
					byte *boolCmpPrintableClassesPrintInfo = (byte*)(&(printInfo->possibleClasses));
					if((*boolCmpPrintableClasses) & (*boolCmpPrintableClassesPrintInfo))
					{
						psiPrint_buffer(i + 1, window, print[printInfo->PSIID - 1], printInfo);
						print[printInfo->PSIID - 1] = false;
					}
				}
			}
		}
		printInfo = &(psi_print_info[i + 1]);
	}
	
	if(psiCharacter == NESS && typeOfWindow.Character_Window && printableClasses.Other)
	{
		if(SpecialPSIFlags->Ness_Teleport_Alpha)
		{
			printInfo = &(psi_print_info[0x32]);
			psiPrint_buffer(0x32 + 1, window, print[0x11 - 1], printInfo);
			print[0x11 - 1] = false;
		}
		if(SpecialPSIFlags->Ness_Teleport_Beta)
		{
			printInfo = &(psi_print_info[0x33]);
			psiPrint_buffer(0x33 + 1, window, print[0x11 - 1], printInfo);
			print[0x11 - 1] = false;
		}
	}
}

void psiTargetWindow_buffer(byte target)
{
	WINDOW *window = getWindow(0x9); //Target Window
	PSIPrintInfo *printInfo = &(psi_print_info[target - 1]);
	byte *string_group1 = (byte*)(0x8B204E4);
	byte extract = (printInfo->PSIID);
	byte value = 0;
	byte value2 = 0;
	byte *str = 0;
	if(extract != 4)
	{
		value = (*(string_group1 + (printInfo->PSIPrintInfoID * 12)));
		value = (value * 0x64);
		value2 = (*(string_group1 + (printInfo->PSIPrintInfoID * 12) + 1));
		value2 = (value2 * 0x14);
		str = (byte*)(0x8B74390 + value + value2); //It doesn't use the pointer to the description the struct has but it obtains it like this...
	}
	else
		str = (byte*)(0x8B74390);
	printstr_hlight_buffer(window, str, 0, 0, 0);
	
	str = m2_strlookup((int*)0x8B17EE4, (byte*)0x8B17424, 0x1B);
	printstr_buffer(window, str, 0, 1, 0);

	value = (*(string_group1 + (printInfo->PSIPrintInfoID * 12) + 3));
	str = (window->number_text_area + 0x12);
	m2_formatnumber(value, str, 2);
	(*(window->number_text_area + 0x14)) = 0;
	(*(window->number_text_area + 0x15)) = 0xFF;
	printstr_buffer(window, str, 7, 1, 0);
}

void psiPrint_buffer(byte value, WINDOW* window, bool printPSILine, PSIPrintInfo *printInfo)
{
	byte *str = 0;
	byte *address = (byte*)0x3000A00;

	if(printPSILine)
	{
		byte PSIID = printInfo->PSIID;
		str = (byte*)(0x8B74228 + (PSIID * 0x14));
		printstr_hlight_buffer(window, str, 0, printInfo->YPrinting << 1, 0);
		if(PSIID == 1)
		{
			str = (byte*)(m2_ness_name + (7 * 4) + (8 * 2)); //Go to Rockin's name
			print_string_in_buffer(str, 0x71, ((printInfo->YPrinting << 1) + window->window_y) << 3, (int*)(0x2014000 - 0x2000));
		}
	}
	
	byte symbol = printInfo->symbol;
	str = (byte*)(0x8B1B904 + (symbol * 3));
	printstr_hlight_buffer(window, str, printInfo->XSymbol + 1, printInfo->YPrinting << 1, 0);
	int val = ((((printInfo->XSymbol - 9) >> 0x1F) + printInfo->XSymbol - 9) >> 1) + (printInfo->YPrinting << 2);
	(*(address + val)) = value;
}