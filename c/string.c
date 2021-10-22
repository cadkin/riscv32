#include"string.h"

int strlen(char c[]) {
	char *ptr = &c[0]; 

	int offset = 0;
	while(*(ptr + offset) != '\0') {
		offset++; 
	}
	return offset; 
}