#include"strcpy.h"

char * strcpy(char * dest, const char * src) {
	int i = 0;
	char c; 
	do {
		c = *(src + i); 
		*(dest + i) = c;
		i++;
	} while(c != 0);
	return dest;
}