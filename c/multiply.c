// See LICENSE for license details.

// *************************************************************************
// multiply filter bencmark
// -------------------------------------------------------------------------
//
// This benchmark tests the software multiply implemenation. The
// input data (and reference data) should be generated using the
// multiply_gendata.pl perl script and dumped to a file named
// dataset1.h

//--------------------------------------------------------------------------
// Input/Reference Data

#include "print.h"
#define DATA_SIZE 4

int multiply(int x, int y)
{
    int i;
    int result = 0;

    for (i = 0; i < 32; i++)
    {
        if ((x & 0x1) == 1)
            result = result + y;

        x = x >> 1;
        y = y << 1;
    }

    return result;
}

//--------------------------------------------------------------------------
// Main

int main(int argc, char *argv[])
{
    int i;
    int results_data[DATA_SIZE];
    int input_data1[DATA_SIZE] = {1, 2, 3, 4};
    int input_data2[DATA_SIZE] = {8, 7, 6, 5};

    for (i = 0; i < DATA_SIZE; i++)
    {
        results_data[i] = multiply(input_data1[i], input_data2[i]);
    }

    for (i = 0; i < DATA_SIZE; i++)
    {
        print(results_data[i]);
    }
}
