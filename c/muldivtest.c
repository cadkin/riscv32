#include "uart.h"
#include "print.h"

int main(void)
{
	uart_init();

    int i = 1;
	int max = 200;
	int num = 1000;

	for (i = 2; i < max; i*i)
	{
		num / 
	}

	char numchar[12];

    print(i);

	itoa(i, numchar);
	uart_print(numchar);

	return 0;
}
