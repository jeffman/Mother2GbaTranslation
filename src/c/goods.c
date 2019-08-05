#include "goods.h"
#include "vwf.h"
#include "locs.h"
#include "pc.h"
#include "input.h"

// Process the outer Goods window (i.e. character selection)
// Called every frame. Replaces $80BF858 fully.
// Returns 1 if the user steps into the inner window,
// -1 if the user steps back out to the previous window,
// and 0 for no action.
// y_offset is added to account for the Tracy goods window, which
// the game offsets by one tile downwards
int goods_outer_process(WINDOW* window, int y_offset)
{
    // Get the weird signed parity value
    short unknown = window->unknown6;
    bool is_even = (unknown & 1) == 0;
    short signed_parity;

    if (is_even)
        signed_parity = 0;
    else
        signed_parity = (unknown < 0) ? -1 : 1;

    // Get pointer to current PC items
    short current_pc = *active_window_party_member;
    short original_pc = current_pc;
    unsigned short *current_items = (*pc_stats)[current_pc].goods;

    // Count number of items in first and second display columns
    int item_counts[2];
    for (int i = 0; i < 14; i += 2)
    {
        if (current_items[i] != 0)
            item_counts[0]++;

        if (current_items[i + 1] != 0)
            item_counts[1]++;
    }

    // Check for pressing left or right
    PAD_STATE state = *pad_state;
    MOVED moved = DIRECTION_NONE;

    if (!window->hold)
    {
        if (state.right)
        {
            current_pc++;
            moved = DIRECTION_RIGHT;
        }
        else if (state.left)
        {
            current_pc--;
            moved = DIRECTION_LEFT;
        }
    }

    // Clear window field if moving
    if (moved != DIRECTION_NONE)
    {
        window->unknown7 = 0;
        window->vwf_skip = false;
    }

    // We moved; find the nearest active party character
    bool found = false;
    if (moved == DIRECTION_RIGHT)
    {
        for (int i = 0; i < 4; i++)
        {
            if (current_pc > 3)
                current_pc = 0;

            if ((*pc_flags)[current_pc])
            {
                found = true;
                break;
            }

            current_pc++;
        }
    }
    else if (moved == DIRECTION_LEFT)
    {
        for (int i = 0; i < 4; i++)
        {
            if (current_pc < 0)
                current_pc = 3;

            if ((*pc_flags)[current_pc])
            {
                found = true;
                break;
            }

            current_pc--;
        }
    }

    if (found)
    {
        current_items = (*pc_stats)[current_pc].goods;
        window->unknown7 = 0;
        window->cursor_x = window->cursor_x_base;
        window->cursor_y = 0;
        window->unknown6 = 0;
        window->unknown6a = 0;
    }

    *active_window_party_member = current_pc;
    m2_hpwindow_up(current_pc);
    clear_name_header(window);
    copy_name_header(window, current_pc);

    // Print item names
    if (!window->vwf_skip)
    {
        goods_print_items(window, current_items, y_offset);
        window->vwf_skip = true;
    }

    // Play sound effect if we're moving
    PAD_STATE state_shadow = *pad_state_shadow;
    if (state_shadow.left || state_shadow.right || state_shadow.up || state_shadow.down)
    {
        if (state.left || state.right)
        {
            if (current_pc != original_pc)
            {
                if (*window_flags & 0x800)
                    m2_soundeffect(0x131);
                else
                    m2_soundeffect(0x12E);
            }
        }

        window->hold = true;
    }
    else
    {
        window->hold = false;
    }

    // Check if we're exiting
    if (state.b || state.select)
    {
        m2_soundeffect(0x12E);
        window->counter = 0;
        return ACTION_STEPOUT;
    }

    // Check if we're descending
    if (state.a || state.l)
    {
        m2_soundeffect(0x12D);
        window->counter = 0;

        unsigned short first_item = current_items[0];
        if (first_item > 0)
        {
            // If the first item isn't null, erase the arrow border tiles
            clear_window_arrows(window);
        }

        return signed_parity + 1;
    }

    window->counter++;

    if (*pc_count > 1)
    {
        // We're doing a bit of simplification here.
        // The Japanese version tries to highlight the arrow you pressed.
        // It only shows for a couple frames and it looks weird, so we're
        // just going to show the arrows and not bother with the direction indicator.
        draw_window_arrows(window, window->counter < 8);
    }

    if (window->counter > 16)
        window->counter = 0;

    return ACTION_NONE;
}

// Process the inner Goods window (i.e. item selection)
// Called every frame. Replaces $80BEB6C fully.
// Returns
int goods_inner_process(WINDOW *window, unsigned short *items)
{
    // Get weird sign height value
    unsigned short height = window->window_height;
    unsigned int height_sign_bit = height >> 15;
    unsigned int weird_value = (((height + height_sign_bit) << 15) >> 16);

    // The game gets the cursor column and then does another weird signed
    // parity operation on it
    int cursor_col = m2_div(window->cursor_x, window->cursor_x_delta);
    if (cursor_col >= 0)
        cursor_col = cursor_col & 1;
    else
        cursor_col = -((-cursor_col) & 1);

    // Count number of items in first and second display columns
    int item_counts[2];
    item_counts[0] = 0;
    item_counts[1] = 0;
    for (int i = 0; i < 14; i += 2)
    {
        if (items[i] != 0)
            item_counts[0]++;

        if (items[i + 1] != 0)
            item_counts[1]++;
    }

    int biggest_col = item_counts[0] > item_counts[1] ? item_counts[0] : item_counts[1];

    // If there aren't any items, return early
    PAD_STATE state = *pad_state;
    PAD_STATE state_shadow = *pad_state_shadow;

    if (biggest_col == 0)
    {
        if (state.b || state.select)
        {
            window->counter = 0;
            window->vwf_skip = false;
            m2_sub_a334c(0);
            m2_sub_a3384(0);
            return -1;
        }
        else
        {
            return 0;
        }
    }

    // Clear cursor tiles
    map_tile(0x1FF, window->window_x + window->cursor_x, window->window_y + window->cursor_y * 2);
    map_tile(0x1FF, window->window_x + window->cursor_x, window->window_y + window->cursor_y * 2 + 1);

    int cursor_x_prev = window->cursor_x;
    int cursor_y_prev = window->cursor_y;

    // Handle cursor movement
    if (state.up)
    {
        window->cursor_y--;
        if ((short)window->cursor_y < 0)
        {
            if (window->hold)
                window->cursor_y = 0;
            else
                window->cursor_y = item_counts[cursor_col] - 1;
        }
        else
        {
            int item_index = window->cursor_y * 2 + cursor_col;
            if (items[item_index] == 0)
            {
                window->cursor_y = cursor_y_prev - 2;
                if (window->cursor_y < 0)
                    window->cursor_y = 0;
            }
        }
    }
    else if (state.down)
    {
        window->cursor_y++;
        if ((short)window->cursor_x <= 0)
        {
            if (window->cursor_y >= item_counts[0])
            {
                if (window->hold)
                    window->cursor_y = item_counts[0] - 1;
                else
                {
                    window->cursor_y = 0;
                    window->unknown7 = 0;
                }
            }
        }
        else
        {
            if (window->cursor_y >= item_counts[1])
            {
                if (item_counts[0] > item_counts[1])
                {
                    window->cursor_x = 0;
                    if (window->cursor_x_delta > 0)
                        cursor_col = m2_div(-(window->cursor_x + window->cursor_x_base), window->cursor_x_delta);
                }
                else
                {
                    if (window->hold)
                        window->cursor_y = item_counts[1] - 1;
                    else
                        window->cursor_y = 0;
                }
            }
        }
    }
    else if (state.right)
    {
        int prev_cursor_x = window->cursor_x;
        window->cursor_x += window->cursor_x_delta;

        if (((short)window->cursor_x - (short)window->cursor_x_base) > ((short)window->window_x + (short)window->cursor_x_delta))
        {
            if (window->hold)
                window->cursor_x = window->cursor_x_delta;
            else
                window->cursor_x = window->cursor_x_base;

            cursor_col = m2_div(window->cursor_x, window->cursor_x_delta);
        }
        else
        {
            if (window->cursor_x_delta != 0)
                cursor_col = m2_div(window->cursor_x - window->cursor_x_base, window->cursor_x_delta);

            int item_index = window->cursor_y * 2 + cursor_col;
            if (items[item_index] == 0)
            {
                if (state_shadow.down)
                {
                    window->cursor_x = prev_cursor_x;
                    if (window->cursor_x_delta != 0)
                        cursor_col = m2_div(window->cursor_x + window->window_x - window->cursor_x_base, window->cursor_x_delta);
                }
                else
                {
                    if (window->cursor_y > 0)
                        window->cursor_y--;
                    else
                    {
                        window->cursor_x = window->cursor_x_base;
                        if (window->cursor_x_delta != 0)
                            cursor_col = m2_div(window->cursor_x, window->cursor_x_delta);
                        else
                            cursor_col = 0;
                    }
                }
            }
        }
    }
    else if (state.left)
    {
        window->cursor_x -= window->cursor_x_delta;
        if ((short)window->cursor_x < (short)window->cursor_x_base)
        {
            if (window->hold)
            {
                window->cursor_x = window->cursor_x_base;
                cursor_col = 0;
            }
            else
            {
                window->cursor_x = window->cursor_x_base + window->cursor_x_delta;
                if (window->cursor_x_delta != 0)
                    cursor_col = m2_div(window->cursor_x + window->window_x, window->cursor_x_delta);

                int item_index = window->cursor_y * 2 + cursor_col;
                if (items[item_index] == 0)
                    window->cursor_x = window->cursor_x_base;
            }
        }
        else
        {
            if (window->cursor_x_delta != 0)
                cursor_col = m2_div(window->cursor_x - window->window_x - window->cursor_x_base, window->cursor_x_delta);

            int item_index = window->cursor_y * 2 + cursor_col;
            if (items[item_index] == 0)
                window->cursor_y--;
        }
    }

    if (window->first && !window->vwf_skip)
    {
        window->first = false;
        window->vwf_skip = true;

        // Draw window header
        map_tile(0xB3, window->window_x, window->window_y - 1);
        clear_name_header(window);
        copy_name_header(window, *active_window_party_member);

        m2_clearwindowtiles(window);

        if (weird_value > 0)
            goods_print_items(window, items, 0);
    }

    if (state_shadow.up || state_shadow.down || state_shadow.left || state_shadow.right)
    {
        window->counter = 0;

        if ((state.up || state.down) && (window->cursor_y != cursor_y_prev))
            m2_soundeffect(0x12F);
        else if ((state.left || state.right) && (window->cursor_x != cursor_x_prev))
            m2_soundeffect(0x12E);

        window->hold = true;
    }
    else
        window->hold = false;

    if (state.b || state.select)
    {
        window->counter = 0;
        window->vwf_skip = false;
        m2_soundeffect(0x12E);
        m2_sub_a334c(0);
        m2_sub_a3384(0);
        return -1;
    }

    if (state.a || state.l)
    {
        window->counter = 0xFFFF;
        window->vwf_skip = false;
        m2_soundeffect(0x12D);
        m2_sub_a334c(*active_window_party_member + 1);

        int selected_index = cursor_col + window->cursor_y * 2 + 1;
        m2_sub_a3384(selected_index);
        return selected_index & 0xFFFF;
    }

    if (window->counter != 0xFFFF)
    {
        window->counter++;

        // Draw cursor for current item
        map_special_character((window->counter <= 7) ? 0x99 : 0x9A,
            window->window_x + window->cursor_x,
            window->window_y + window->cursor_y * 2);

        if (window->counter > 0x10)
            window->counter = 0;
    }

    return 0;
}

// Prints all 14 items to a goods window.
// Erases the slot before printing. Prints blanks for null items.
void goods_print_items(WINDOW *window, unsigned short *items, int y_offset)
{
    int item_x = (window->window_x << 3) + 8;
    int item_y = (window->window_y + y_offset) << 3;

    for (int i = 0; i < 14; i++)
    {
        int item = items[i];
        int x = item_x + ((i & 1) * 88);
        int y = item_y + ((i >> 1) * 16);

        print_blankstr(x >> 3, y >> 3, 11);

        if (item > 0)
        {
            int x_offset = 0;

            if (m2_isequipped(i + 1))
            {
                x_offset = 8;
                map_special_character(0x1DE, x >> 3, y >> 3);
            }

            byte *item_str = m2_strlookup(m2_items_offsets, m2_items_strings, item);
            print_string(item_str, x + x_offset, y);
        }
    }
}

//This works. Gets price given the item (Could not get a proper thumb routine to work, it would automatically go to arm)
//What this routine does is: it receives the item value, multiplies it by 20 and then sums it with the address of m2_items to get the item price that is at that address.
//Original code is at 0x80C7D58
unsigned short getPrice(int item)
{
    unsigned short *value = (unsigned short *)(&m2_items + (item * 5));
    return value[0];
}

// Prints all itemsnum items to a shop window.
// Erases the slot before printing. Prints blanks for null items.
void shop_print_items(WINDOW *window, unsigned char *items, int y_offset, int itemsnum)
{
    int item_x = (window->window_x << 3) + 8;
    int item_y = (window->window_y + y_offset) << 3;

    for (int i = 0; i < itemsnum; i++)
    {
        int item = items[i];
        int x = item_x;
        int y = item_y + (i * 16);

        print_blankstr(x >> 3, y >> 3, 16);

        if (item > 0)
        {
            int x_offset = 0;
            byte *item_str = m2_strlookup(m2_items_offsets, m2_items_strings, item);
            print_string(item_str, x + x_offset, y);
            int digit_count;
            int bcd = bin_to_bcd(getPrice(item), &digit_count); //Get the price in bcd, so it can be printed
            int base = 120;
            print_character(decode_character(0x56), x + base, y); //00, it will be at the end, always at the same position
            print_character(decode_character(0x54), x + base - 8 - (digit_count * 6), y); //dollar, it must be before all digits
            // Write the digits
            for (int j = 0; j < digit_count; j++)
            {
                byte digit = ((bcd >> ((digit_count - 1 - j) * 4)) & 0xF) + ZERO;
                print_character(decode_character(digit), x + base - 8 - ((digit_count - j - 1) * 6), y); //write a single digit
            }
        }
    }
}

