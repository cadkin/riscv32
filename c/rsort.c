// See LICENSE for license details.

//**************************************************************************
// Quicksort benchmark
//--------------------------------------------------------------------------
//
// This benchmark uses quicksort to sort an array of integers. The
// implementation is largely adapted from Numerical Recipes for C. The
// input data (and reference data) should be generated using the
// qsort_gendata.pl perl script and dumped to a file named
// dataset1.h

#include "print.h"
//#include <stdio.h>
#include <string.h>
#include <limits.h>
#define DATA_SIZE 4
typedef __uintptr_t uintptr_t;

//--------------------------------------------------------------------------
// Input/Reference Data

#define LOG_BASE 8
#define BASE (1 << LOG_BASE)

#if 0
#define fetch_add(ptr, inc) __sync_fetch_and_add(ptr, inc)
#else
#define fetch_add(ptr, inc) ((*(ptr) += (inc)) - (inc))
#define static_assert(cond) switch(0) { case 0: case !!(long)((1 << 8) % 2 == 0): ; }
#endif

void* memcpy(void* dest, const void* src, size_t len)
{
  if ((((uintptr_t)dest | (uintptr_t)src | len) & (sizeof(uintptr_t)-1)) == 0) {
    const uintptr_t* s = src;
    uintptr_t *d = dest;
    while (d < (uintptr_t*)(dest + len))
      *d++ = *s++;
  } else {
    const char* s = src;
    char *d = dest;
    while (d < (char*)(dest + len))
      *d++ = *s++;
  }
  return dest;
}

void sort(unsigned int n, unsigned int *arrIn, unsigned int *scratchIn)
{
    unsigned int i = 0;
    
    unsigned int log_exp = 0;
    unsigned int buckets[BASE];
    unsigned int *bucket = buckets;
    asm(""
        : "+r"(bucket));
    unsigned int *arr = arrIn, *scratch = scratchIn, *p;
    unsigned int *b;

    while (log_exp < CHAR_BIT * sizeof(unsigned int))
    {
        for (b = bucket; b < bucket + BASE; b++)
            *b = 0;

        for (p = arr; p < &arr[n - 3]; p += 4)
        {
            unsigned int a0 = p[0];
            unsigned int a1 = p[1];
            unsigned int a2 = p[2];
            unsigned int a3 = p[3];
            fetch_add(&bucket[(a0 >> log_exp) % BASE], 1);
            fetch_add(&bucket[(a1 >> log_exp) % BASE], 1);
            fetch_add(&bucket[(a2 >> log_exp) % BASE], 1);
            fetch_add(&bucket[(a3 >> log_exp) % BASE], 1);
        }
        for (; p < &arr[n]; p++)
            bucket[(*p >> log_exp) % BASE]++;

        unsigned int prev = bucket[0];
        prev += fetch_add(&bucket[1], prev);
        for (b = &bucket[2]; b < bucket + BASE; b += 2)
        {
            prev += fetch_add(&b[0], prev);
            prev += fetch_add(&b[1], prev);
        }
        static_assert(BASE % 2 == 0);

        for (p = &arr[n - 1]; p >= &arr[3]; p -= 4)
        {
            unsigned int a0 = p[-0];
            unsigned int a1 = p[-1];
            unsigned int a2 = p[-2];
            unsigned int a3 = p[-3];
            unsigned int *pb0 = &bucket[(a0 >> log_exp) % BASE];
            unsigned int *pb1 = &bucket[(a1 >> log_exp) % BASE];
            unsigned int *pb2 = &bucket[(a2 >> log_exp) % BASE];
            unsigned int *pb3 = &bucket[(a3 >> log_exp) % BASE];
            unsigned int *s0 = scratch + fetch_add(pb0, -1);
            unsigned int *s1 = scratch + fetch_add(pb1, -1);
            unsigned int *s2 = scratch + fetch_add(pb2, -1);
            unsigned int *s3 = scratch + fetch_add(pb3, -1);
            s0[-1] = a0;
            s1[-1] = a1;
            s2[-1] = a2;
            s3[-1] = a3;
        }
        for (; p >= &arr[0]; p--)
            scratch[--bucket[(*p >> log_exp) % BASE]] = *p;

        unsigned int *tmp = arr;
        arr = scratch;
        scratch = tmp;

        log_exp += LOG_BASE;
    }
    if (arr != arrIn)
        memcpy(arr, scratch, n * sizeof(unsigned int));

    for(i = 0; i < n; i++)
    {
        print(arr[i]);
    }
}

//--------------------------------------------------------------------------
// Main

int main(int argc, char *argv[])
{
    static unsigned int scratch[DATA_SIZE];
    int input_data[DATA_SIZE] = {3, 4, 2, 1};

    sort(DATA_SIZE, input_data, scratch);

    return 0;
}
