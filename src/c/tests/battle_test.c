#include "battle_test.h"

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
    
    m2_btl_user_ptr->letter = W_LETTER - INITIAL_SYMBOL_ENEMY;
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

void test_target_text()
{
    m2_btl_user_ptr->is_enemy = true;
    m2_btl_enemies_size = 1;
    m2_btl_user_ptr->letter = 1;
    m2_btl_user_ptr->unknown_3[0] = 1;

    for(int j = 0; j <= 230; j++)
    {
        m2_btl_user_ptr->id = j;
        m2_btl_user_ptr->enemy_id = j;
        printTargetOfAttack(0,0);
        store_pixels_overworld_buffer(0x10);     // This is just for visualization purposes
        assert_message(text_stayed_inside(window_pointers[3]), "Target text for Enemy %d", j);
    }
    
    m2_btl_user_ptr->letter = W_LETTER - INITIAL_SYMBOL_ENEMY;
    m2_btl_user_ptr->unknown_3[0] = 0;

    for(int j = 0; j <= 230; j++)
    {
        m2_btl_user_ptr->id = j;
        m2_btl_user_ptr->enemy_id = j;
        printTargetOfAttack(0,0);
        store_pixels_overworld_buffer(0x10);     // This is just for visualization purposes
        assert_message(text_stayed_inside(window_pointers[3]), "Target text for Enemy %d - W", j);
    }
    
}

static void _setup()
{
    (window_pointers[2]) = (struct WINDOW*)0x2029F88;
    (window_pointers[3]) = (struct WINDOW*)0x2029FD8;
    m2_setupwindow((window_pointers[2]), 4, 1, 0x16, 4);
    m2_btl_user_ptr = (BATTLE_DATA*)0x2021110;
    m2_btl_target_ptr = (BATTLE_DATA*)0x2021110;
    setup_ness_name();
    setup_king_name();
    m2_is_battle = 1;
    (*(byte*)(0x3005050)) = 0xFF;
    (*(short*)(0x30023DC)) = 0;                  // Default delay between prints
    (*(int*)(0x3005220)) = 0x2028820;
    *tilemap_pointer= (unsigned short*)0x2028018;
    (*(byte*)(0x202514C)) = 8;                   // Point to the btl_user_ptr
    (*(unsigned short*)(0x500001E)) = 0x7FFF;    // Make it so it's easy to check what's being written
    m2_script_readability = false;
    setup_overworld_buffer();
}

void start_battle_tests()
{
    run_test(test_encounter_text);
    run_test(test_death_text);
    run_test(test_target_text);
}