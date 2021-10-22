#include"memcpy.h" 

void * memcpy(void * dest, void * src, size_t num) {
	size_t i = 0; 
	char c;
	while(i < num) {
		c = ((char *)(src + i))[0];
		char * ptr = (char*)(dest + i);
		*ptr = c;
		// *(dest + i) = *ptr; 
		i++; 
	}
	return dest; 
}