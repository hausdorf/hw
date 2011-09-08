/*
 * PS1 ALEX CLEMMER u0458675
 *
 * C is great
 * C is neat
 * The K&R
 * is hard to beat.
 */
#include <stdio.h>
#include <assert.h>

int string_length(char *s)
{
    int count = 0;
    int i;
    for (i = 0; s[i] != '\0'; i++) {
        count ++;
    }
    return count;
}

int main(void)
{
    assert(string_length("hello world") == 11);
    assert(string_length("5") == 1);

    assert(string_length("cow") == 3);
    assert(string_length("\n\n\n\n  \n") == 7);
    assert(string_length("") == 0);
    assert(string_length("\0") == 0);
    assert(string_length("\r\n") == 2);
}
