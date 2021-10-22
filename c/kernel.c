//This is a kernel program for the Mini-Risc-V that is used to load 
//binaries onto the core over serial communication. 
// #include"print.h"
#include"uart.h" 

typedef unsigned int uint;

uint base_addr = 0x10000; 

uint uart_read_word() {
	char buf[4];
	int i;
	for (i = 0; i < 4; i++)
		buf[i] = uart_read_blocking(); 
	char * ptr = &buf[0]; 
	return *((uint *)ptr); 
}

int load_program() {
	uint buf; 
	uint magic = 0xdeadbeef; 
	//receive magic word
	buf = uart_read_word(); 
	//restart kernel if magic word not received
	if (buf != magic) {
		uart_print(":(\n");
		return 0;
	}
	//end of memory. If we reach here, the program is too large. Restart Kernel
	uint mem_end = 65536;
	uint w = 0; 
	while (w < mem_end) {
		// if (w == mem_end) {
		// 	uart_print("program too large. Restarting Kernel...\n");
		// 	return 0; 
		// }
		buf = uart_read_word(); 
		// print(buf); 
		if (buf == magic) {
			uart_print("program loaded\n");
			return base_addr; 
		}
		uint * p = (uint *)(base_addr + w); 
		*p = buf; 
		w += 4; 
	} 
	uart_print("program too large. Restarting kernel...\n");
	return 0; 
}


int main(void) {
	uart_init();
	uart_print("loading program\n");
	return load_program();
	// print_program_memory();
	// return retval;
}
