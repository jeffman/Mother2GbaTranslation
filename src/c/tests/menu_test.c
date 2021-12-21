#include "menu_test.h"

#define GOODS_X 0x6
#define GOODS_Y 0x1
#define GOODS_WIDTH 0x17
#define GOODS_HEIGHT 0xE

#define INNERMOST_EQUIP_X 0x12
#define INNERMOST_EQUIP_Y 0x1
#define INNERMOST_EQUIP_WIDTH 0xB
#define INNERMOST_EQUIP_HEIGHT 0xE

#define TOTAL_ITEMS 253

#define CHOICE_WEAPONS 0x3
#define CHOICE_BODY 0x4
#define CHOICE_ARMS 0x5
#define CHOICE_OTHER 0x6

void getEquippables(byte* equip_buffers);

void test_items_text()
{
    byte equip_buffers[TOTAL_ITEMS];
    getEquippables(equip_buffers);
    m2_setupwindow((window_pointers[4]), GOODS_X, GOODS_Y, GOODS_WIDTH, GOODS_HEIGHT);
    
    *active_window_party_member = 0;
    unsigned short *current_items = (*pc_stats)[0].goods;
    byte *current_equipment = (*pc_stats)[0].equipment;
    current_items[0] = 0;
    
    for(int i = 0; i < TOTAL_ITEMS; i++)
    {
        current_items[1] = i;
        current_equipment[0] = 0;
        initWindow_buffer(window_pointers[4], NULL, 0);
        goods_print_items(window_pointers[4], current_items, 0);
        store_pixels_overworld_buffer(0x10);         // This is just for visualization purposes
        assert_message(text_stayed_inside(window_pointers[4]), "Goods window: Item %d", i);
        if(equip_buffers[i] != 0)
        {
            current_equipment[0] = 2;
            initWindow_buffer(window_pointers[4], NULL, 0);
            goods_print_items(window_pointers[4], current_items, 0);
            store_pixels_overworld_buffer(0x10);         // This is just for visualization purposes
            assert_message(text_stayed_inside(window_pointers[4]), "Goods window: Item %d - Equipped", i);
        }
    }
}

void test_equip_text()
{
    byte fsp_buffer[0x20];
    free_strings_pointers[3] = fsp_buffer;
    byte equipped_buffer[6];
    byte equip_buffers[TOTAL_ITEMS];
    getEquippables(equip_buffers);
    equipped_buffer[4] = 1;
    equipped_buffer[5] = 0xFF;
    m2_setupwindow((window_pointers[4]), INNERMOST_EQUIP_X, INNERMOST_EQUIP_Y, INNERMOST_EQUIP_WIDTH, INNERMOST_EQUIP_HEIGHT);
    
    *active_window_party_member = 0;
    *((unsigned short*)0x3005224) = CHOICE_WEAPONS;
    unsigned short *current_items = (*pc_stats)[0].goods;
    byte *current_equipment = (*pc_stats)[0].equipment;
    window_pointers[4]->cursor_x = 1;
    window_pointers[4]->number_text_area = equipped_buffer;
    
    for(int i = 0; i < TOTAL_ITEMS; i++)
    {
        if(equip_buffers[i] != 0)
        {
            current_items[0] = i;
            current_equipment[0] = 1;
            initWindow_buffer(window_pointers[4], NULL, 0);
            equippablePrint(window_pointers[4]);
            store_pixels_overworld_buffer(0x10);         // This is just for visualization purposes
            assert_message(text_stayed_inside(window_pointers[4]), "Equip window: Item %d - Equipped", i);
        }
    }
}

void getEquippables(byte* equip_buffers)
{
    byte buffer[0x20];
    
    for(int i = 0; i < TOTAL_ITEMS; i++)
    {
        for(int j = 0; j < 4; j++)
        {
            if(j == 0 || equip_buffers[i] == 0)
            {
                *active_window_party_member = (short)j;
                unsigned short *current_items = (*pc_stats)[j].goods;
                current_items[0] = i;
                int found = 0;
                found += m2_set_equippables((window_pointers[4]), CHOICE_WEAPONS, buffer);
                found += m2_set_equippables((window_pointers[4]), CHOICE_BODY, buffer);
                found += m2_set_equippables((window_pointers[4]), CHOICE_ARMS, buffer);
                found += m2_set_equippables((window_pointers[4]), CHOICE_OTHER, buffer);
                equip_buffers[i] = found;
            }
        }
    }
}

static void _setup()
{
    (window_pointers[4]) = (struct WINDOW*)0x2030948;
    (*(byte*)(0x3005050)) = 0xFF;
    (*(short*)(0x30023DC)) = 0;                  // Default delay between prints
    (*(int*)(0x3005220)) = 0x2028820;
    *tilemap_pointer= (unsigned short*)0x2028018;
    (*(unsigned short*)(0x500001E)) = 0x7FFF;    // Make it so it's easy to check what's being written
    setup_overworld_buffer();
}

void start_menu_tests()
{
    run_test(test_items_text);
    run_test(test_equip_text);
}