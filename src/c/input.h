#ifndef HEADER_INPUT_INCLUDED
#define HEADER_INPUT_INCLUDED

typedef struct PAD_STATE {
    unsigned int a : 1;
    unsigned int b : 1;
    unsigned int select : 1;
    unsigned int start : 1;
    unsigned int right : 1;
    unsigned int left : 1;
    unsigned int up : 1;
    unsigned int down : 1;
    unsigned int r : 1;
    unsigned int l : 1;
    unsigned int unused : 6;
} PAD_STATE;

#endif
