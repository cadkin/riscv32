#ifndef QSORT_H
#define QSORT_H

#define INSERTION_THRESHOLD 10
#define NSTACK 50

#define SWAP(a, b)            \
    do                        \
    {                         \
        typeof(a) temp = (a); \
        (a) = (b);            \
        (b) = temp;           \
    } while (0)
#define SWAP_IF_GREATER(a, b) \
    do                        \
    {                         \
        if ((a) > (b))        \
            SWAP(a, b);       \
    } while (0)

static void insertion_sort(unsigned int n, int arr[]);
static void selection_sort(unsigned int n, int arr[]);
void sort(unsigned int n, int arr[]);

#endif