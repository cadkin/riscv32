#include "uart.h"
#include "print.h"

int main(void)
{
	uart_init();

    int i = 0;
	int num = 2;
	char numchar1[12];
	char numchar2[12];
	char creturn[3] = "\r";
	char newline[3] = "\n";
	char separator[3] = " : ";

    print(num);

	for (i = 0; i < 10; i++)
	{
		num = num * 2;
		itoa(i, numchar1);
		uart_print(numchar1);
		uart_print(separator);
		itoa(num, numchar2);
		uart_print(numchar2);
		uart_print(creturn);
		uart_print(newline);
	}

	return 0;
}
