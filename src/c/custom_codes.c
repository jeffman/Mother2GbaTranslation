#include "custom_codes.h"
#include "vwf.h"
#include "goods.h"

void set_window_x(WINDOW* window, int pixels)
{
    window->pixel_x = pixels & 7;
    window->text_x = pixels >> 3;
}

int custom_codes_parse(int code, char* parserAddress, WINDOW* window)
{
    return custom_codes_parse_generic(code, parserAddress, window, (byte*)BASE_GRAPHICS_ADDRESS);
}

int custom_codes_parse_generic(int code, char* parserAddress, WINDOW* window, byte* dest)
{
    int addedSize = 0;
    
    //Prepare variables for the data in the switches
    WINDOW* inv_window;
    WINDOW* dialogue_window;
    int val_to_store;
    bool store;
    
    switch(code)
    {
        case ADD_PIXEL_X_RENDERER:
            // 60 FF XX: Add XX pixels to the renderer
            handle_first_window_buffer(window, dest);
            set_window_x(window, window->pixel_x + (window->text_x << 3) + (byte)parserAddress[2]);
            addedSize = 3;
            break;
            
        case SET_PIXEL_X_RENDERER:
            // 5F FF XX: Set the X value of the renderer to XX
            handle_first_window_buffer(window, dest);
            set_window_x(window, (byte)parserAddress[2]);
            addedSize = 3;
            break;
            
        case STORE_TO_WINDOW_DATA:
            // 5E FF XX : Load a value into memory, based on XX
            val_to_store = 0;
            store = false;
            switch((byte)parserAddress[2])
            {
                case ENEMY_PLURALITY:
                    // 5E FF 01 : Load enemy plurality into memory
                    val_to_store = m2_bat_enemies_size > 3 ? 3 : m2_bat_enemies_size;
                    store = true;
                    break;
                default:
                    break;
            }
            if(store)
                m2_store_to_win_memory(val_to_store);
            addedSize = 3;
            break;
        
        case CALL_GIVE_TEXT:
            // 5D FF: Call give text
            handle_first_window_buffer(window, dest);
            inv_window = (*window_pointers) + INV_WINDOW_VALUE;
            byte source = m2_source_pc;
            byte target = m2_active_window_pc;
            int item_index = inv_window->cursor_x == 0 ? 0 : 1;
            item_index += (inv_window->cursor_y << 1);
            unsigned short item = pc_stats[source]->goods[item_index];
            byte* free_string = *free_strings_pointers;
            if(item != NULL)
                give_print(item, target, source, (*window_pointers) + DIALOGUE_WINDOW_VALUE, free_string);
            addedSize = -1;
            break;
        
        case LOAD_BUFFER:
            // 5C FF: Load buffer
            load_pixels_overworld();
            break;
            
        case PRINT_MAIN_WINDOW:
            // 5B FF: Print main window (if enabled) without restore of window buffer
            generic_reprinting_first_menu_talk_to_highlight();
            addedSize = 2;
            break;
            
        case RESTORE_DIALOGUE:
            // 5A FF: Restore the dialogue window
            dialogue_window = (*window_pointers) + DIALOGUE_WINDOW_VALUE;
            dialogue_window->text_x = 0;
            dialogue_window->text_y = 0;
            dialogue_window->vwf_skip = false;
            m2_drawwindow(dialogue_window);
            addedSize = 2;
            break;
        
        case RESET_STORED_GOODS:
            // 59 FF: Set stored goods window's data so it prints the header from scratch
            inv_window = (*window_pointers) + INV_WINDOW_VALUE;
            inv_window->pixel_x = 0xFF;
            addedSize = 2;
            break;
        
        default:
            break;
    }
    
    return addedSize;
}