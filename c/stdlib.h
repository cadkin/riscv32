#ifndef STDLIB
#define STDLIB

typedef unsigned int size_t;
typedef unsigned int u32;
typedef unsigned int usize;
typedef unsigned char u8;

usize ALLOC_START;

// usize PAGE_SIZE = 4096;

typedef struct {
	u8 flags;
} Page;

enum PageBits { 
	Empty = 0, 
	Taken = 1 << 0, 
	Last = 1 << 1, 
	};

void * memcpy(void * dest, void * source, size_t num); 
void * malloc(size_t size);

void * alloc(usize pages);
void * zalloc(usize pages);
void mem_init(); 
#endif