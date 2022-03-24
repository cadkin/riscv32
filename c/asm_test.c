#include "print.h"
#include "uart.h"
#include "malloc.h"
#include "qsort.h"
#include "tc_hazard.h"

#define DATA_SIZE 10

int qsort_test(int a);
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

    // Qsort Test
    test = qsort_test(10);
    print(test);

    // UART Test
    uart_test();
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