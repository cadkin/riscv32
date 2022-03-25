#include "tc_hazard.h"

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

int d_hz_3(int a)
{
    int b = 0;
    int c = 0;

    __asm__
    (
        "lw %[b], -36(s0)\n\t"
        "nop\n\t"
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

int lb_hz(int a)
{
    int b = 1;
    int c = 0;
    int d = 0;

    __asm__
    (
        "lw %[c], -20(s0)\n\t"
        "nop\n\t"
        "bnez %[c], success4\n\t"
        "j fail4\n\t"
        "success4:\n\t"
        "sw %[a],-24(s0)\n\t"
        "fail4:"
        : [d] "=r" (d)
        : [a] "r" (a), [b] "r" (b), [c] "r" (c)
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
        "bnez %[c], success1\n\t"
        "j fail1\n\t"
        "success1:\n\t"
        "sw %[a],-24(s0)\n\t"
        "fail1:"
        : [d] "=r" (d)
        : [a] "r" (a), [b] "r" (b), [c] "r" (c)
    );

    return c;
}

int b_hz_2(int a)
{
    int b = 1;
    int c = 0;
    int d = 0;

    __asm__
    (
        "nop\n\t"
        "nop\n\t"
        "add %[c], %[b], zero\n\t"
        "nop\n\t"
        "bnez %[c], success2\n\t"
        "j fail2\n\t"
        "success2:\n\t"
        "sw %[a],-24(s0)\n\t"
        "fail2:"
        : [d] "=r" (d)
        : [a] "r" (a), [b] "r" (b), [c] "r" (c)
    );

    return c;
}

int b_hz_3(int a)
{
    int b = 1;
    int c = 0;
    int d = 0;

    __asm__
    (
        "lw %[c], -20(s0)\n\t"
        "nop\n\t"
        "nop\n\t"
        "bnez %[c], success3\n\t"
        "j fail3\n\t"
        "success3:\n\t"
        "sw %[a],-24(s0)\n\t"
        "fail3:"
        : [d] "=r" (d)
        : [a] "r" (a), [b] "r" (b), [c] "r" (c)
    );

    return c;
}

int s_hz(int a)
{
    int b = 0;
    int c = 0;

    __asm__
    (
        "lw %[b], -36(s0)\n\t"
        "sw %[b], -24(s0)"
        :
        : [a] "r" (a), [b] "r" (b)
    );

    return c;
}
