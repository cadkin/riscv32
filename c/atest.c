#include"uart.h"

int main(void) {
	// int a = 17; 
	// char c[12];
	// itoa(a, c); 
	// print(c);
	// print("\n\r");
	// while(1) {
	// print("Hello!\n\r");
		// char x[12];
		// print("Enter a number: ");
		// readline(x); 
		// int b = atoi(x);
		// itoa(b, c);
		// print("You entered: ");
		// print(c);
		char x[32];
		int i;
		for (i = 0; i < 32; i++) x[i] = 0;
		print("Say Something: ");
		readline(x, 32); 
		print("You entered: ");
		print(x);
		print("\r\n");
		int c = sizeof(int);
	// }
	return 0;
}