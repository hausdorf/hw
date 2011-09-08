#include <stdio.h>
#include <limits.h>

int main()
{
    int a = 0x7FFFFFFF;
    int cmp = 0x10000000;
    int b = a + 1;
    int c = ~(b & cmp);

    printf("a:\t%08x\n", a);
    printf("b:\t%08x\n", b);
    printf("c:\t%08x\n", c);
    printf("c:\t%08x\n", !!c);
    printf("\n");

    a = 0x80000000;
    cmp = 0x10000000;
    b = a + 1;
    c = ~(b & cmp);

    printf("a:\t%08x\n", a);
    printf("b:\t%08x\n", b);
    printf("c:\t%08x\n", c);
    printf("c:\t%08x\n", !c);

}
