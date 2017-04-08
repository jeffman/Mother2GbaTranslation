#define ADDR(a) ((int)&a)

extern int const m2_coord_table;

inline unsigned char LDRB(int address)
{
    return *((unsigned char*)address);
}

inline unsigned short LDRH(int address)
{
    return *((unsigned short*)address);
}

inline int LDR(int address)
{
    return *((int*)address);
}
