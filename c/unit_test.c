#include "print.h"
#include "uart.h"
#include "spi.h"
#include "malloc.h"
#include "qsort.h"
#include "utils.h"
#include "tc_hazard.h"

#define DATA_SIZE 10

int m_ext_test(int a);
int itoa_atoi_test(int a);
int qsort_test(int a);
int spi_test(int a);
void uart_test();

int main(void)
{
    int test = 0;

    // Hazard Tests
    test = d_hz_3(1); // Fails all (doesn't raise mmio_wea)
    print(test);

    test = d_hz_2(2); // Fails all (raises mmio_wea, outputs 0)
    print(test);

    test = d_hz_1(3); // Fails all (raises mmio_wea, outputs 20)
    print(test);

    test = b_hz_3(4); // Fails B HZ 3 and LB HZ 
    print(test);

    test = b_hz_2(5); // Fails B HZ 2 and B HZ 1
    print(test);

    test = b_hz_1(6); // Fails itself
    print(test);

    test = lb_hz(7);  // Fails itself
    print(test);

    test = l_hz(8);   // Fails itself
    print(test);

    test = s_hz(9);   // Fails itself
    print(test);

    // M-EXT Test
    test = m_ext_test(10);
    print(test);

    // ITOA/ATOI Test
    test = itoa_atoi_test(11);
    print(test);

    // Qsort Test
    test = qsort_test(12);
    print(test);

    // SPI Test
    test = spi_test(13);
    print(test);

    // UART Test
    uart_test();
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

int spi_test(int a)
{
    int result = a;
    char s = 0;

    s = 'a';
    spi_write(s);
    s = 'b';
    spi_write(s);
    s = 'c';
    spi_write(s);
    s = 'd';
    spi_write(s);

    while(!(spi_poll() & 1));
    s = spi_read();
    if (s != 'a') result = 0;

    while(!(spi_poll() & 1));
    s = spi_read();
    if (s != 'b') result = 0;

    while(!(spi_poll() & 1));
    s = spi_read();
    if (s != 'c') result = 0;

    while(!(spi_poll() & 1));
    s = spi_read();
    if (s != 'd') result = 0;

    return result;
}

void uart_test()
{
    // Initialize UART
    uart_init();

    // Send back any characters received in UART
    char c; 
    while(1) {
        c = uart_read_blocking();
        uart_put_blocking(c);
    }
}