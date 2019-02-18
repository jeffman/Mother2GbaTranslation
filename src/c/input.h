#ifndef HEADER_INPUT_INCLUDED
#define HEADER_INPUT_INCLUDED

typedef struct PAD_STATE {
    bool a : 1;
    bool b : 1;
    bool select : 1;
    bool start : 1;
    bool right : 1;
    bool left : 1;
    bool up : 1;
    bool down : 1;
    bool r : 1;
    bool l : 1;
    unsigned int unused : 6;
} PAD_STATE;

#endif
