#include "print.h"

int d_hz_1(int a)
{
    int b = 0;
    int c = 0;

    __asm__
    (
        "add %[b], %[a], zero\n\t"
        "sub %[c], %[b], zero"
        : [c] "=r" (c)
        : [a] "r" (a), [b] "r" (b)
    );

    return c;
}

int d_hz_2(int a)
{
    int b = 0;
    int c = 0;

    __asm__
    (
        "add %[b], %[a], zero\n\t"
        "nop\n\t"
        "sub %[c], %[b], zero"
        : [c] "=r" (c)
        : [a] "r" (a), [b] "r" (b)
    );

    return c;
}

int l_hz(int a)
{
    int b = 0;
    int c = 0;

    __asm__
    (
        "lw %[b], -36(s0)\n\t"
        "add %[c], %[b], zero"
        : [c] "=r" (c)
        : [a] "r" (a), [b] "r" (b)
    );

    return c;
}

int b_hz_1(int a)
{
    int b = 1;
    int c = 0;
    int d = 0;

    __asm__
    (
        "nop\n\t"
        "nop\n\t"
        "add %[c], %[b], zero\n\t"
        "bnez %[c], success\n\t"
        "j fail\n\t"
        "success:\n\t"
        "sw %[a],-24(s0)\n\t"
        "fail:"
        : [d] "=r" (d)
        : [a] "r" (a), [b] "r" (b), [c] "r" (c)
    );

    return c;
}

int main(void)
{
    int test = 0;

    test = d_hz_1(1);
    print(test);

    test = d_hz_2(2);
    print(test);

    test = l_hz(3);
    print(test);

    test = b_hz_1(4);
    print(test);

	return 0;
}