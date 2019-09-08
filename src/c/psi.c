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
    byte (*possibleTargets)[3][4] = (byte(*)[3][4])cursorValues;
    WINDOW *window = getWindow(7);
    SpecialPSIFlag *SpecialPSIFlags = (SpecialPSIFlag*)(character_general_data + 0x22A);
    bool print[0x11];
    for(int i = 0; i < 0x11; i ++)
        print[i] = true;

    for(int i = 0; i < 4; i++)
    {
        (*possibleTargets)[0][i] = 0;
        (*possibleTargets)[1][i] = 0;
        (*possibleTargets)[2][i] = 0;
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
    byte *baseStrPointer = (byte*)(&psitext);
    byte value = 0;
    byte value2 = 0;
    byte *str = 0;
    if(extract != 4)
    {
        value = (*(string_group1 + (printInfo->PSIPrintInfoID * 12)));
        value = (value * 0x64);
        value2 = (*(string_group1 + (printInfo->PSIPrintInfoID * 12) + 1));
        value2 = (value2 * 0x14);
        str = baseStrPointer + (0x11 * 0x14) + value + value2; //It doesn't use the pointer to the description the struct has but it obtains it like this...
    }
    else
        str = baseStrPointer + (0x11 * 0x14);
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
    byte *baseStrPointer = (byte*)(&psitext);
    byte (*possibleTargets)[3][4] = (byte(*)[3][4])cursorValues;

    if(printPSILine)
    {
        byte PSIID = printInfo->PSIID;
        str = baseStrPointer + ((PSIID - 1) * 0x14);
        printstr_hlight_buffer(window, str, 0, printInfo->YPrinting, 0);
        if(PSIID == 1)
        {
            str = (byte*)(m2_ness_name + (7 * 4) + (8 * 2)); //Go to Rockin's name
            print_string_in_buffer(str, 0x71, ((printInfo->YPrinting) + window->window_y) << 3, (int*)(OVERWORLD_BUFFER - 0x2000));
        }
    }
    
    byte symbol = printInfo->symbol;
    str = (byte*)(0x8B1B904 + (symbol * 3));
    printstr_hlight_buffer(window, str, printInfo->XSymbol + 1, printInfo->YPrinting, 0);
    int targetX = (((printInfo->XSymbol - 9) >> 0x1F) + printInfo->XSymbol - 9) >> 1;
    (*possibleTargets)[printInfo->YPrinting][targetX] = value;
}

int PSITargetWindowInput(WINDOW* window)
{

    if (!(window->flags_unknown3a & 0x10))
    {
        window->flags_unknown3a |= 0x10;

        // Draw window header
        map_tile(0xB3, window->window_x, window->window_y - 1);
        clear_name_header(window);
        copy_name_header(window, *active_window_party_member);
    }

    return PSITargetInput(window);    
}

int PSITargetInput(WINDOW* window)
{
    short topX = window->cursor_x;
    short topY = window->cursor_y;
    short beforeX = topX;
    short beforeY = topY;
    short currentX = beforeX;
    short currentY = beforeY;
    byte (*possibleTargets)[3][4] = (byte(*)[3][4])cursorValues;
    byte target = (*possibleTargets)[currentY][currentX];
    
    if(target == 0)
    {
        currentX = 0;
        for(currentY = 0; currentY < 3 && (*possibleTargets)[currentY][currentX] == 0; currentY++)
        {
            for(currentX = 0; currentX < 4 && (*possibleTargets)[currentY][currentX] == 0; currentX++);
            if(currentX == 4)
                currentX = 0;
        }
        if(currentY < 3)
        {
            topX = currentX;
            topY = currentY;
            beforeX = currentX;
            beforeY = currentY;
        }
        else
            return ACTION_ERROR;
    }
    
    map_tile(0x1FF, window->window_x + (currentX * 2) + 9, window->window_y + currentY * 2);
    map_tile(0x1FF, window->window_x + (currentX * 2) + 9, window->window_y + currentY * 2 + 1);

    PAD_STATE state = *pad_state;
    PAD_STATE state_shadow = *pad_state_shadow;
    
    if(state.up)
    {
        currentY--;
        if(currentY < 0 && window->hold)
            currentY = 0;
        else if(currentY < 0)
        {
            currentY = 2;
            while((*possibleTargets)[currentY][currentX] == 0)
                currentY--;
        }
        else
        {
            for(int i = 0; (*possibleTargets)[currentY][currentX] == 0 && i <= 2;)
            {
                if((*possibleTargets)[currentY][currentX] != 0)
                    break;
                currentX--;
                if(currentX < 0)
                {
                    i++;
                    currentY--;
                    currentX = beforeX;
                }
                if(currentY < 0)
                    currentY = 2;
            }
        }
    }
    
    beforeX = currentX;
    beforeY = currentY;
    
    if(state.down)
    {
        currentY++;
        if(currentY > 2 && window->hold)
            currentY = 2;
        else if(currentY > 2)
        {
            currentY = 0;
            while((*possibleTargets)[currentY][currentX] == 0)
                currentY++;
        }
        else
        {
            for(int i = 0; (*possibleTargets)[currentY][currentX] == 0 && i <= 2;)
            {
                if((*possibleTargets)[currentY][currentX] != 0)
                    break;
                currentX--;
                if(currentX < 0)
                {
                    i++;
                    currentY++;
                    currentX = beforeX;
                }
                if(currentY > 2)
                {
                    if(window->hold)
                    {
                        currentY = beforeY;
                        currentX = beforeX;
                        break;
                    }
                    currentY = 0;
                }
            }
        }
    }
    
    beforeX = currentX;
    beforeY = currentY;
    
    if(state.right)
    {
        currentX++;
        if(state_shadow.up && window->hold)
            currentX--;
        else if(currentX > 3)
        {
            if(window->hold)
                currentX = 3;
            else
            {
                currentX = 0;
                while((*possibleTargets)[currentY][currentX] == 0)
                    currentX++;
            }
        }
        else
        {
            if((*possibleTargets)[currentY][currentX] != 0);
            else
            {
                if(state_shadow.down || state_shadow.up)
                    currentX = beforeX;
                else if(currentY == 0)
                {
                    short tmpX = currentX;
                    while(currentY <= 1)
                    {
                        currentX = tmpX;
                        while(currentX < 3)
                        {
                            if((*possibleTargets)[currentY][currentX] != 0)
                                break;
                            currentX++;
                        }
                        if((*possibleTargets)[currentY][currentX] != 0)
                            break;
                        currentY++;
                    }
                    if(currentY == 2)
                    {
                        currentY = beforeY;
                        if(window->hold)
                            currentX = beforeX;
                        else
                        {
                            currentX = 0;
                            while((*possibleTargets)[currentY][currentX] == 0)
                                currentX++;
                        }
                    }
                }
                else
                {
                    short tmpX = currentX;
                    for(currentY = 2; currentY >= 0; currentY--)
                    {
                        currentX = tmpX;
                        while(currentX < 3)
                        {
                            if((*possibleTargets)[currentY][currentX] != 0)
                                break;
                            currentX++;
                        }
                        if((*possibleTargets)[currentY][currentX] != 0)
                            break;
                    }
                    if(currentY < 0)
                    {
                        currentY = beforeY;
                        if(window->hold)
                            currentX = beforeX;
                        else
                        {
                            currentX = 0;
                            while((*possibleTargets)[currentY][currentX] == 0)
                                currentX++;
                        }
                    }
                }
            }
        }
    }
    
    beforeX = currentX;
    beforeY = currentY;
    
    if(state.left)
    {
        currentX--;
        if(state_shadow.up && window->hold)
            currentX++;
        else if(currentX < 0)
        {
            if(window->hold)
                currentX = 0;
            else
            {
                currentX = 3;
                while((*possibleTargets)[currentY][currentX] == 0)
                    currentX--;
            }
        }
        else
        {
            if((*possibleTargets)[currentY][currentX] != 0);
            else
            {
                if(state_shadow.down || state_shadow.up)
                    currentX = beforeX;
                else if(currentY == 0)
                {
                    short tmpX = currentX;
                    while(currentY <= 1)
                    {
                        currentX = tmpX;
                        while(currentX > 0)
                        {
                            if((*possibleTargets)[currentY][currentX] != 0)
                                break;
                            currentX--;
                        }
                        if((*possibleTargets)[currentY][currentX] != 0)
                            break;
                        currentY++;
                    }
                    if(currentY == 2)
                    {
                        currentY = beforeY;
                        if(window->hold)
                            currentX = beforeX;
                        else
                        {
                            currentX = 3;
                            while((*possibleTargets)[currentY][currentX] == 0)
                                currentX--;
                        }
                    }
                }
                else
                {
                    short tmpX = currentX;
                    for(currentY = 2; currentY >= 0; currentY--)
                    {
                        currentX = tmpX;
                        while(currentX > 0)
                        {
                            if((*possibleTargets)[currentY][currentX] != 0)
                                break;
                            currentX--;
                        }
                        if((*possibleTargets)[currentY][currentX] != 0)
                            break;
                    }
                    if(currentY < 0)
                    {
                        currentY = beforeY;
                        if(window->hold)
                            currentX = beforeX;
                        else
                        {
                            currentX = 3;
                            while((*possibleTargets)[currentY][currentX] == 0)
                                currentX--;
                        }
                    }
                }
            }
        }
    }
    
    window->cursor_x = currentX;
    window->cursor_y = currentY;
    
    target = (*possibleTargets)[currentY][currentX];
    if(currentX != topX || currentY != topY)
        window->vwf_skip = false;
    
    bool beforeVWF = window->vwf_skip;
    
    if(!window->vwf_skip)
    {
        clear_window_buffer(getWindow(9), (int*)(OVERWORLD_BUFFER - 0x2000));
        psiTargetWindow_buffer(target);
        window->vwf_skip = true;
    }
    
    if(state_shadow.right || state_shadow.left || state_shadow.up || state_shadow.down)
    {
        window->counter = 0;
        int flag = *window_flags;
        if(state.up || state.down)
        {
            if(currentY != topY)
                m2_soundeffect(0x12F);
        }
        if(state.left || state.right)
        {
            if(currentX != topX)
                m2_soundeffect(0x12E);
        }
        window->hold = true;
    }
    else
        window->hold = false;
    
    if((state.b || state.select) && (beforeVWF))
    {
        m2_soundeffect(0x12E);
        window->counter = 0;
        return ACTION_STEPOUT;
    }
    
    window->cursor_x_delta = target;
    
    if((state.a || state.l) && (beforeVWF))
    {
        m2_soundeffect(0x12D);
        window->counter = 0xFFFF;
        return target;
    }
    
    if (window->counter != 0xFFFF)
    {
        window->counter++;

        // Draw cursor for current item
        map_special_character((window->counter <= 7) ? 0x99 : 0x9A,
            window->window_x + (window->cursor_x * 2) + 9,
            window->window_y + window->cursor_y * 2);

        if (window->counter > 0x10)
            window->counter = 0;
    }
    
    return ACTION_NONE;
}
