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

int load_The_user_target(BATTLE_DATA* bd, bool ignore_letters)
{
    int val_to_store = 1;
    short user;
    
    if(!m2_is_battle)
        return 1;
    
    if(bd->is_enemy || bd->npc_id != 0)
    {
        user = bd->id;
        val_to_store = (m2_enemy_attributes[user] & 0xFF) + 1;
        
        if(!ignore_letters && user != PORKY && bd->is_enemy)
        {
            if(bd->letter != 1 || m2_sub_daf84(bd->enemy_id) != 2)
                val_to_store = NO_THE; //Multiple of the same enemy are on the field...
        }
        if(user == KING)
            val_to_store = NO_THE;
    }
    else
        val_to_store = NO_THE; //It's a party member, no "The "

    return val_to_store;
}

int load_gender_user_target(BATTLE_DATA* bd)
{
    int val_to_store = MALE; //Default is male
    short user;
    
    if(!m2_is_battle)
        return m2_cstm_last_pc != PAULA ? MALE : FEMALE; //Only Paula is female
    
    if(bd->is_enemy || bd->npc_id != 0)
    {
        user = bd->id;
        val_to_store = ((m2_enemy_attributes[user] >> 8) & 0xFF);
        
        if(user == KING)
            val_to_store = NEUTRAL;
    }
    else
    {
        user = bd->id;
        if(user <= 3)
            val_to_store = bd->pc_id != PAULA ? MALE : FEMALE; //Only Paula is female
    }

    return val_to_store;
}

int custom_codes_parse_generic(int code, char* parserAddress, WINDOW* window, byte* dest)
{
    int addedSize = 0;
    
    //Prepare variables for the data in the switches
    WINDOW* inv_window;
    WINDOW* dialogue_window;
    int val_to_store;
    bool store;
    short user;
    
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
            addedSize = 3;
            val_to_store = 0;
            store = false;
            switch((byte)parserAddress[2])
            {
                case ENEMY_PLURALITY:
                    // 5E FF 01 : Load enemy plurality into memory
                    val_to_store = m2_btl_enemies_size > 3 ? 3 : m2_btl_enemies_size;
                    store = true;
                    break;
                
                case BATTLE_USER_THE:
                    // 5E FF 02 : Load user's usage of "The " into memory
                    val_to_store = load_The_user_target(m2_btl_user_ptr, (bool)parserAddress[3]);
                    addedSize += 1;
                    store = true;
                    break;
                    
                case BATTLE_TARGET_THE:
                    // 5E FF 03 : Load target's usage of "The " into memory
                    val_to_store = load_The_user_target(m2_btl_target_ptr, false);
                    store = true;
                    break;
                    
                case BATTLE_USER_GENDER:
                    // 5E FF 04 : Load user's gender into memory
                    val_to_store = load_gender_user_target(m2_btl_user_ptr);
                    store = true;
                    break;
                    
                case BATTLE_TARGET_GENDER:
                    // 5E FF 05 : Load target's gender into memory - UNUSED but coded, just like in EB
                    val_to_store = load_gender_user_target(m2_btl_target_ptr);
                    store = true;
                    break;
                
                case IS_NEWLINE:
                    // 5E FF 06 : Load whether it's a newline or not
                    val_to_store = (window->text_y != 0) && (window->pixel_x == 0) && (window->text_x == 0) ? 1 : 2;
                    store = true;
                    break;
                
                default:
                    break;
            }
            if(store)
                m2_store_to_win_memory(val_to_store);
            break;
        
        case CALL_GIVE_TEXT:
            // 5D FF: Call give text
            handle_first_window_buffer(window, dest);
            inv_window = (*window_pointers) + INV_WINDOW_VALUE;
            byte source = m2_source_pc;
            byte target = m2_active_window_pc;
            int item_index = inv_window->cursor_x == 0 ? 0 : 1;
            item_index += (inv_window->cursor_y << 1);
            unsigned short item = (*pc_stats)[source].goods[item_index];
            byte* free_string = *free_strings_pointers;
            if(item != NULL)
            {
                give_print(item, target, source, (*window_pointers) + DIALOGUE_WINDOW_VALUE, free_string);
                clearWindowTiles_buffer((*window_pointers) + DIALOGUE_WINDOW_VALUE);
                addedSize = -1;
            }
            else // Not really needed, but will just make the game not print anything instead of softlocking
                addedSize = 2;
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
            
        case RESET_WRITE_BUFFER:
            // 58 FF: Reset the writing buffer to avoid crashes
            free_overworld_buffer();
            break;
        
        case CHECK_WIDTH_OVERFLOW:
            // 57 FF: Start/End width calculation.
            // Jump to newline if it would go over the window's boundaries
            if((byte)parserAddress[2] == CALC_WIDTH_END)
                window->inside_width_calc = false;
            else
                if(!window->inside_width_calc) {
                    WINDOW w;
                    int possible_return_addresses = 10;
                    int return_addresses[possible_return_addresses];
                    int nreturns = *((int*)(0x3005078));
                    cpuset((int*)(0x3005080), return_addresses, possible_return_addresses * 2);
                    copy_window(window, &w);
                    window->text_offset += 3;
                    window->inside_width_calc = true;
                    while(window->inside_width_calc)
                        m2_printnextch(window);
                    if(false && text_overflows_window(window)) {
                        w.text_x = 0;
                        w.pixel_x = 0;
                        w.text_y += 2;
                    }
                    copy_window(&w, window);
                    (*((int*)(0x3005078))) = nreturns;
                    cpuset(return_addresses, (int*)(0x3005080), possible_return_addresses * 2);
                }
            addedSize = 3;
            break;
        
        default:
            break;
    }
    
    return addedSize;
}
