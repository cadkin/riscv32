#include"uart.h"
#include"utils.h"

int nothing()
{
    return 1;
}

int main(void)
{
    char str[20];
	char num_str[10];
    int i = 0;
    int num = 298;
	int size = count_digits(num);

	itoa(num, str);
	itoa(size, num_str);

	uart_write_blocking(num_str[0]);
	uart_write_blocking(str[0]);
	uart_write_blocking(str[1]);
	uart_write_blocking(str[2]);

    while(i < size)
    {
        uart_write_blocking(str[i]);
        i++;
    }

    while (1)
        ;
}