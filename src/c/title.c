#include "title.h"
#include "locs.h"

int title_frame_first()
{
    if (*title_counter == 0)
    {
        m2_soundeffect(0xAF);
    }

    (*title_counter)++;

    if (*title_counter == 5 * 60)
    {
        m2_title_teardown();
        return -1;
    }

    return 0;
}

int title_frame_second()
{
    vblank();

    if (*title_counter == 5 * 60)
    {
        m2_title_teardown();
    }

    return 0;
}
