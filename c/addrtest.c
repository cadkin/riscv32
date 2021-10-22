#include"print.h" 
#include"uart.h" 

int uart_read_word() {
	char buf[4];
	int i;
	for (i = 0; i < 4; i++)
		buf[i] = uart_read_blocking(); 
	char * ptr = &buf[0]; 
	return *((int *)ptr); 
}

int main(void) {
	// char buf[4]; 
	// int i = 0;
	// for (i = 0; i < 4; i++)
	// 	buf[i] = uart_read_blocking();
	// char * ptr = &buf[0]; 
	// int x = *((int *)ptr);
	// print(x);
	return 0;
}