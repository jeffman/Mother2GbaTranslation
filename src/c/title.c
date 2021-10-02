#include "title.h"

void title_text_sequence(
    TITLE_CONTROL *control,
    TITLE_EXTENDED *ext,
    TITLE_COORD_TABLE *coords)
{
    int duration = 140; // approximate length of EB's animation,
                        // from the first frame that H is visible
                        // until all letters have stopped moving
    int frame = control->frame;

    if (frame > duration)
    {
        control->frame = -1;
        ext->sequence++;
        return;
    }

    for (int i = 0; i < 9; i++)
    {
        int x_start = coords->x_start[i];
        int x_end = coords->x_end[i];
        int x_delta = x_end - x_start;
        int x_new = (m2_div((x_delta * frame) << 12, duration) >> 12) + x_start;

        // X coordinate is only 9 bits signed, so clamp the values to a reasonable range
        if (x_new < -250)
            x_new = -250;
        if (x_new > 250)
            x_new = 250;

        ext->sprites[i].x = x_new;
        ext->sprites[i].y = coords->y_end[i]; // we're not translating the sprites vertically
    }
}
