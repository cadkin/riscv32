#include "uart.h"

int main(void) {
	uart_init();

	char c; 
	while(1) {
		c = uart_read_blocking();
		uart_put_blocking(c);
	}

	return 0;
}