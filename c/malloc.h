#ifndef MALLOCH
#define MALLOCH

void *malloc(long unsigned int size);
void free(void *ptr);
void *sbrk (int incr);

#endif
