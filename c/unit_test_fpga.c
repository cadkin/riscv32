#include "print.h"
#include "uart.h"
#include "malloc.h"
#include "qsort.h"
#include "utils.h"
#include "tc_hazard.h"

#define DATA_SIZE 10

int m_ext_test(int a);
int itoa_atoi_test(int a);
int qsort_test(int a);
void uart_test();

int main(void)
{
    int test = 0;
	char num_char[9];

    // Initialize UART
	uart_init();

    // Hazard Tests
    test = d_hz_3(1); // Fails all (doesn't raise mmio_wea)
    itoa(test, num_char);
    uart_print(num_char);

    test = d_hz_2(2); // Fails all (raises mmio_wea, outputs 0)
    itoa(test, num_char);
    uart_print(num_char);

    test = d_hz_1(3); // Fails all (raises mmio_wea, outputs 20)
    itoa(test, num_char);
    uart_print(num_char);

    test = b_hz_3(4); // Fails B HZ 3 and LB HZ 
    itoa(test, num_char);
    uart_print(num_char);

    test = b_hz_2(5); // Fails B HZ 2 and B HZ 1
    itoa(test, num_char);
    uart_print(num_char);

    test = b_hz_1(6); // Fails itself
    itoa(test, num_char);
    uart_print(num_char);

    test = lb_hz(7);  // Fails itself
    itoa(test, num_char);
    uart_print(num_char);

    test = l_hz(8);   // Fails itself
    itoa(test, num_char);
    uart_print(num_char);

    test = s_hz(9);   // Fails itself
    itoa(test, num_char);
    uart_print(num_char);

    // M-EXT Test
    test = m_ext_test(10);
    itoa(test, num_char);
    uart_print(num_char);

    // ITOA/ATOI Test
    test = itoa_atoi_test(11);
    itoa(test, num_char);
    uart_print(num_char);

    // Qsort Test
    test = qsort_test(12);
    itoa(test, num_char);
    uart_print(num_char);
}

int qsort_test(int a)
{
    int result = 0;
    int i = 0;

    int check_data[DATA_SIZE] = {
        4,
        8,
        16,
        32,
        64,
        128,
        256,
        512,
        1024,
        65536
    };

    int *input_data = malloc(DATA_SIZE * sizeof(int));
    input_data[0] = 65536;
    input_data[1] = 1024;
    input_data[2] = 512;
    input_data[3] = 256;
    input_data[4] = 128;
    input_data[5] = 64;
    input_data[6] = 32;
    input_data[7] = 16;
    input_data[8] = 8;
    input_data[9] = 4;

    sort(DATA_SIZE, input_data);

    result = a;
    for(i = 0; i < DATA_SIZE; i++)
    {
        if(input_data[i] != check_data[i])
        {
            result = 0;
        }
    }

    return result;
}

int m_ext_test(int a)
{
    int result = 0;
    int i = 0;
    int num = 0;

    int mul_check[5] = {
        277284,
        4112,
        2052,
        64,
        12
    };

    int div_check[5] = {
        17330,
        257,
        128,
        4,
        0
    };

    int mul_data[5] = {
        0,
        0,
        0,
        0,
        0
    };

    int div_data[5] = {
        0,
        0,
        0,
        0,
        0
    };

    int *input_data = malloc(5 * sizeof(int));
    input_data[0] = 69321;
    input_data[1] = 1028;
    input_data[2] = 513;
    input_data[3] = 16;
    input_data[4] = 3;

    num = 4;

    for (i = 0; i < 5; i++)
    {
        __asm__
        (
            "mul %[c], %[a], %[b]"
            : [c] "=r" (mul_data[i])
            : [a] "r" (input_data[i]), [b] "r" (num)
        );
        __asm__
        (
            "div %[c], %[a], %[b]"
            : [c] "=r" (div_data[i])
            : [a] "r" (input_data[i]), [b] "r" (num)
        );
    }

    result = a;
    for (i = 0; i < 5; i++)
    {
        if(mul_data[i] != mul_check[i])
        {
            result = 0;
        }
    }

    for (i = 0; i < 5; i++)
    {
        if(div_data[i] != div_check[i])
        {
            result = 0;
        }
    }

    return result;
}

int itoa_atoi_test(int a)
{
    int result = 0;
    int i = 0;
    int num = 0;
    char numchar[9];

    char *data_check[5];
    
    data_check[0] = "277291";
    data_check[1] = "4112";
    data_check[2] = "205";
    data_check[3] = "16";
    data_check[4] = "3";

    int *input_data = malloc(5 * sizeof(int));
    input_data[0] = 277291;
    input_data[1] = 4112;
    input_data[2] = 205;
    input_data[3] = 16;
    input_data[4] = 3;

    result = a;
    for (i = 0; i < 5; i++)
    {
        itoa(input_data[i], numchar);
        if(strcmp(numchar, data_check[i]) != 0)
        {
            result = 0;
        }

        num = atoi(numchar);
        if(num != input_data[i])
        {
            result = 0;
        }
    }

    return result;
}
