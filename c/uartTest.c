#include "uart.h"
#include "print.h"

int main(void)
{
	uart_init();

    int i = 5;
	char numchar[12];

    print(i);

	itoa(i, numchar);
	uart_print(numchar);

	return 0;
}
