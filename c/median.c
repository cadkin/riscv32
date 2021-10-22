// See LICENSE for license details.

//**************************************************************************
// Median filter (c version)
//--------------------------------------------------------------------------

#define DATA_SIZE 5

#include "print.h"

void median(int n, int input[], int results[])
{
    int A, B, C, i;

    // Zero the ends
    results[0] = 0;
    results[n - 1] = 0;

    // Do the filter
    for (i = 1; i < (n - 1); i++)
    {
        A = input[i - 1];
        B = input[i];
        C = input[i + 1];

        if (A < B)
        {
            if (B < C)
                results[i] = B;
            else if (C < A)
                results[i] = A;
            else
                results[i] = C;
        }
        else
        {
            if (A < C)
                results[i] = A;
            else if (C < B)
                results[i] = B;
            else
                results[i] = C;
        }
    }

    for(i = 1; i < n - 1; i++)
    {
        print(results[i]);
    }
}

//--------------------------------------------------------------------------
// Main

int main(int argc, char *argv[])
{
    static unsigned int scratch[DATA_SIZE];
    int input_data[DATA_SIZE] = {7, 2, 10, 5, 6};

    median(DATA_SIZE, input_data, scratch);

    return 0;
}
