#include "print.h"

int main(void)
{
    int a = 2;
    int b = 4;
    int c = 0;

    __asm__
    (
        "mul %[c], %[a], %[b]"
        : [c] "=r" (c)
        : [a] "r" (a), [b] "r" (b)
    );

    print(c);

    return 0;
}