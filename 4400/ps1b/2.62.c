/*
 * PS1 Alex Clemmer u0458675
 *
 * Roses are red
 * voilets are blue
 * this is my submission
 * for problem 2.62
 */
#include <stdio.h>
#include <assert.h>

int int_shifts_are_arithmetic()
{
    /* Shift 1 to top of word */
    int shift = (sizeof(int) << 3) - 1;
    int test = 0x01 << shift;

    /* Shift left; if it's logical, this will give us zeroes. */
    test = test >> 6;

    /* Build mask to test to see if top byte contains ones */
    int mask = 0xF << (shift - 3);

    /* PRINT STATEMENTS FOR TESTING
    printf("test: %x\n", test);
    printf("mask: %x\n", mask);
    printf("test: %x\n", mask & test);
    */
    return (mask & test) || 0;
}

int main()
{
    printf("Test: %d\n", int_shifts_are_arithmetic());
}
