#include "malloc.h"

#define NULL ((void *)0)

/* Struct for free list node. */
typedef struct flist
{
    unsigned int size; /* Number of bytes in free list node. */
    struct flist *next; /* Next node in free list. */
} Flist;

extern char _end; /* Set by linker. */
Flist *begin = NULL; /* Start of free list. */

/* Rounds number up to multiple of 8. */
unsigned int round_up(unsigned int num)
{
    unsigned int rem = num % 8;

    if (rem == 0)
    {
        return num;
    }

    return num + 8 - rem;
}

/* Allocates amount of memory indicated by size for user. */
void *malloc(long unsigned int size)
{
    Flist *curr = NULL;
    Flist *prev = NULL;
    Flist *temp = NULL;
    Flist *new_memory = NULL;
    unsigned int desired_size = 0;
    unsigned int remainder_size = 0;
    unsigned int free_size = 0;

    /* Find number of bytes to be allocated for user (size rounded up to multiple of 8 + 8 bookkeeping bytes). */
    desired_size = round_up(size) + 8;

    /* Traverses free memory list for node that has enough memory desired by user. */
    for(curr = begin; curr != NULL; curr = curr->next)
    {
        /* Allocates whole node for user if node size matches desired size. */
        if(curr->size == desired_size)
        {
            /* Sets next node as new beginning node if current node is beginning of free list. */
            if(prev == NULL)
            {
                begin = curr->next;
            }
            /* Links previous node and next node together if current node is not beginning of free list. */
            else
            {
                prev->next = curr->next;
            }

            /* Returns pointer to allocated memory, skipping bookkeeping bytes. */
            return (char *)curr + 8;
        }
        /* Allocates memory carved off the end of free list node if node size is greater than desired size. */
        else if(curr->size > desired_size)
        {
            /* Finds size of memory to leave on free list and shrinks node down to that size. */
            remainder_size = curr->size - desired_size;
            curr->size = remainder_size;

            /* Finds start of memory to be allocated to user and sets new allocated memory's size to desired size. */
            temp = (void *)((char *)curr + remainder_size);
            temp->size = desired_size;
            
            /* Returns pointer to allocated memory, skipping bookkeeping bytes. */
            return (char *)temp + 8;
        }

        /* Maintains access to pointer of the previous node to current node. */
        prev = curr;
    }

    /* Gets 8192 new bytes of memory, carving part of it to provide to user and putting the rest on the free list if desired size is less than 8192 bytes. */
    if(desired_size < 8192)
    {
        /* Finds size of memory to put on free list. */
        free_size = 8192 - desired_size;

        /* Gets 8192 new bytes of memory and carves memory off the end to return to user. */
        temp = (void *)sbrk(8192);
        new_memory = (void *)((char *)temp + free_size);

        /* Sets size of new free list node and places node on free list. */
        temp->size = free_size;
        temp->next = begin;
        begin = temp;

        /* Sets size of memory to return to user as desired size. */
        new_memory->size = desired_size;
        
        /* Returns pointer to allocated memory, skipping bookkeeping bytes. */
        return (char *)new_memory + 8;
    }

    /* Gets desired amount of bytes and returns all of memory given to user after setting size of memory as desired size. */
    temp = (void *)sbrk(desired_size);
    temp->size = desired_size;

    /* Returns pointer to allocated memory, skipping bookkeeping bytes. */
    return (char *)temp + 8;
}

/* Frees memory at the address given and returns memory node to free list. */
void free(void *ptr)
{
    Flist *temp = NULL;

    /* Finds start of memory, where the bookkeeping bytes start 8 bytes back. */
    temp = (void *)((char *)ptr - 8);

    /* Places memory at beginning of free list. */
    temp->next = begin;
    begin = temp;
}

void *sbrk (int incr)
{
    static char *heap_end;
    char *prev_heap_end;

    if (heap_end == 0)
        heap_end = &_end;

    prev_heap_end = heap_end;
    heap_end += incr;

    return (void *)prev_heap_end;
}