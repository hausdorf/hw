/*
 * PS1 ALEX CLEMMER u0458675
 *
 * Roses are red
 * violets are blue,
 * will it increase my grade
 * if I bring cookies to you?
 */
#include <stdio.h>
#include <assert.h>

/* Any bit in x is set to 1 */
int anyBit1(int x)
{
    return x || 0;
}

/* Any bit in x is set to 0 */
int anyBit0(int x)
{
    return ~x || 0;
}

/* Any bit in the least significant byte is 1 */
int anyBitLsb1(int x)
{
    return (~((~0x00) << 8) & x) || 0;
}

/* Any bit in the most significant byte is 1 */
int anyBitMsb1(int x)
{
    int mask = 0xFF << ((sizeof(int) << 3) - 8);
    int masked =  mask & x;
    return masked || 0;
}

int main()
{
    /* anyBit1 tests */
    assert(anyBit1(0x00) == 0);
    assert(anyBit1(0x01) == 1);
    assert(anyBit1(-0x01) == 1);

    /* anyBit0 tests */
    assert(anyBit0(0x00) == 1);
    assert(anyBit0(~0x00) == 0);
    assert(anyBit0(0x01) == 1);
    assert(anyBit0(-0x01) == 0);

    /* anyBitlsb1 tests */
    assert(anyBitLsb1(0x01) == 1);
    assert(anyBitLsb1(0x01 << 8) == 0);
    assert(anyBitLsb1(0x01 << 7) == 1);
    assert(anyBitLsb1(0x00) == 0);

    /* anyBitMsb1 tests */
    assert(anyBitMsb1(0x00) == 0);
    assert(anyBitMsb1(0x01 << ((sizeof(int) << 3) - 1)) == 1);
    assert(anyBitMsb1(0x01) == 0);
}
