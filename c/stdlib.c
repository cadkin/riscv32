#include"stdlib.h"

extern usize HEAP_SIZE;
extern usize HEAP_START; 

usize PAGE_SIZE = 1024;

void mem_init() {
	usize num_pages = HEAP_SIZE / PAGE_SIZE; 
	Page * ptr = (Page *)HEAP_START; 
	int i;
	for (i = 0; i < (num_pages); i++){
		(ptr + i)->flags = Empty; 
	}
	ALLOC_START = (HEAP_START + num_pages * sizeof(Page) + PAGE_SIZE - 1) & !(PAGE_SIZE - 1);
}

void * alloc(usize pages) {
	usize num_pages = (HEAP_SIZE / PAGE_SIZE); 
	Page * ptr = (Page *)HEAP_START; 
	int i;
	for (i = 0; i < (num_pages - pages); i++) {
		char found = 0; 
		// u8 flag = (ptr + i)->flags; 
		if ((ptr + i)->flags == Empty) {
			found = 1; 
			for (int j = i; j < i + pages; j++) {
				if ((ptr + j)->flags != Empty) {
					found = 0;
					break;
				}
			}
		}

		if (found) {
			for (int k = i; k < i + pages - 1; k++) {
				(ptr + k)->flags = Taken; 
			}
			(ptr + i + pages - 1)->flags = Last | Taken; 

			return (void *)(ALLOC_START + PAGE_SIZE * i);
		}
	}

}

void * zalloc(usize pages) {
	void * ret = alloc(pages); 
	usize size = (PAGE_SIZE * pages) / sizeof(usize); 
	usize * ptr = (usize *)ret;
	for (usize i = 0; i < size; i++) {
		*(ptr + (i * sizeof(usize))) = 0;
	}
	return ret;
}

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

void * malloc(size_t size) {
	void *ptr; 
	char c[size+4]; 
	for (int i = 0; i < (size + 4); i++) 
		c[i] = 0; 
	ptr = &c[0];
	return ptr;
}

int __mulsi3(int a, int b) {
	int product = 0; 
	int i;
	if (b < 0) {
		a = 0 - a; 
		b = 0 - b;
	}
	for (i = 0; i < b; i++) {
		product += a; 
	}
	return product;
}

int __divsi3(int a, int b) {
	int cnt = 0; 
	while(1) {
		if (a < b) return cnt; 
		a = a - b; 
		cnt++;
	}
}

int __udivsi3(int a, int b) {
	int cnt = 0; 
	while(1) {
		if (a < b) return cnt; 
		a = a - b; 
		cnt++;
	}
}

int __modsi3(int a, int b) {
	
	while(1) {
		if (b > a) return a;
		a = a - b;
	}
}