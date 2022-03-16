#include "uart.h"

int main(void)
{
	uart_init();

	char num[3] = "1";

    uart_print(num);

	return 0;
}
