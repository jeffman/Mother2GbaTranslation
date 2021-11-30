#include "battle_test.h"
#include "debug_printf/test_print.h"
#include "../locs.h"

bool text_stayed_inside(WINDOW* window);

void test_encounter_text()
{
    m2_btl_user_ptr->is_enemy = true;
    m2_btl_user_ptr->letter = 1;
    for(int i = 1; i <= 3; i++)
    {
        m2_btl_enemies_size = i;
    
        for(int j = 0; j <= 230; j++)
        {
            m2_btl_user_ptr->id = j;
            m2_btl_user_ptr->enemy_id = j;
            m2_set_user_name(1);
            m2_battletext_loadstr(m2_enemies[j].encounter_text);
            if(m2_btl_enemies_size == 1)
                assert_message(text_stayed_inside(window_pointers[2]), "Encounter text for Enemy %d", j);
            else if (m2_btl_enemies_size == 2)
                assert_message(text_stayed_inside(window_pointers[2]), "Encounter text for Enemy %d - cohort", j);
            else
                assert_message(text_stayed_inside(window_pointers[2]), "Encounter text for Enemy %d - cohorts", j);
        }
    }
}

void test_death_text()
{
    m2_btl_user_ptr->is_enemy = true;
    m2_btl_enemies_size = 1;
    m2_btl_user_ptr->letter = 1;
    m2_btl_user_ptr->unknown_3[0] = 1;

    for(int j = 0; j <= 230; j++)
    {
        m2_btl_user_ptr->id = j;
        m2_btl_user_ptr->enemy_id = j;
        m2_set_target_name();
        m2_battletext_loadstr(m2_enemies[j].death_text);
        assert_message(text_stayed_inside(window_pointers[2]), "Death text for Enemy %d", j);
    }
    
    m2_btl_user_ptr->letter = 0x17;
    m2_btl_user_ptr->unknown_3[0] = 0;

    for(int j = 0; j <= 230; j++)
    {
        m2_btl_user_ptr->id = j;
        m2_btl_user_ptr->enemy_id = j;
        m2_set_target_name();
        m2_battletext_loadstr(m2_enemies[j].death_text);
        assert_message(text_stayed_inside(window_pointers[2]), "Death text for Enemy %d - W", j);
    }
    
}

bool text_stayed_inside(WINDOW* window)
{
    for(int i = 0; i < window->window_height; i++)
        if((*tilemap_pointer)[(0x20*(window->window_y + i))+window->window_x + window->window_width] != RIGHT_BORDER_TILE)
            return false;
    return true;
}

void setup_ness_name()
{
    for(int i = 0; i < 5; i++)
        *(pc_names + i) = W_LETTER;
    *(pc_names + 5) = 0;
    *(pc_names + 6) = 0xFF;
}

void setup_king_name()
{
    for(int i = 0; i < 6; i++)
        *(pc_names + KING_OFFSET + i) = W_LETTER;
    *(pc_names + KING_OFFSET + 6) = 0;
    *(pc_names + KING_OFFSET + 7) = 0xFF;
}

void setup_battle_tests()
{
    (window_pointers[2]) = (struct WINDOW*)0x2029F88;
    (window_pointers[2])->window_x = 4;
    (window_pointers[2])->window_y = 1;
    (window_pointers[2])->window_width = 0x16;
    (window_pointers[2])->window_height = 4;
    (window_pointers[2])->window_area = (window_pointers[2])->window_width * (window_pointers[2])->window_height;
    m2_btl_user_ptr = (BATTLE_DATA*)0x2021110;
    m2_btl_target_ptr = (BATTLE_DATA*)0x2021110;
    setup_ness_name();
    setup_king_name();
    m2_is_battle = 1;
    (*(byte*)(0x3005050)) = 0xFF;
    (*(short*)(0x30023DC)) = 0;                  // Default delay between prints
    (*(int*)(0x3005220)) = 0x2028820;
    *tilemap_pointer= (unsigned short*)0x2028018;
    (*(unsigned short*)(0x500001E)) = 0x7FFF;    // Make it so it's easy to check what's being written
    m2_script_readability = false;
}

void do_battle_tests()
{
    test_encounter_text();
    test_death_text();
}

void start_battle_tests()
{
    setup_battle_tests();
    do_battle_tests();
}