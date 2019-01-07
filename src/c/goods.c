#include "goods.h"
#include "vwf.h"
#include "locs.h"
#include "pc.h"

// Process the outer Goods window (i.e. character selection)
// Called every frame. Replaces $80BF858 fully.
int goods_outer_process(WINDOW* window)
{
    // Copied from assembly: get the weird signed parity value
    short unknown = window->unknown6;
    bool is_even = (unknown & 1) == 0;
    short signed_parity;

    if (is_even)
    {
        signed_parity = 0;
    }
    else
    {
        signed_parity = (unknown < 0) ? -1 : 1;
    }

    int current_pc = *active_window_party_member;
    int first_item = pc_stats[current_pc]->goods[0];
    return first_item;
}
