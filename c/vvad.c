// See LICENSE for license details.

//**************************************************************************
// Vector-vector add benchmark
//--------------------------------------------------------------------------
//
// This benchmark uses adds to vectors and writes the results to a
// third vector. The input data (and reference data) should be
// generated using the vvadd_gendata.pl perl script and dumped
// to a file named dataset1.h.

//--------------------------------------------------------------------------
// Input/Reference Data

#define DATA_SIZE 5
#include "print.h"

//--------------------------------------------------------------------------
// vvadd function

void vvadd(int n, int a[], int b[], int c[])
{
    int i;
    for (i = 0; i < n; i++)
        c[i] = a[i] + b[i];

    for (i = 0; i < n; i++)
        print(c[i]);
}

//--------------------------------------------------------------------------
// Main

int main(int argc, char *argv[])
{
    int results_data[DATA_SIZE];

    int input1_data[DATA_SIZE] = {1, 2, 3, 4, 5};

    int input2_data[DATA_SIZE] = {6, 7, 8, 9, 10};

    // Do the vvadd
    vvadd(DATA_SIZE, input1_data, input2_data, results_data);
}
