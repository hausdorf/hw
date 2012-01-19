/*
 * mm-naive.c - The fastest, least memory-efficient malloc package.
 * 
 * In this naive approach, a block is allocated by simply incrementing
 * the brk pointer.  A block is pure payload. There are no headers or
 * footers.  Blocks are never coalesced or reused. Realloc is
 * implemented directly using mm_malloc and mm_free.
 *
 * NOTE TO STUDENTS: Replace this header comment with your own header
 * comment that gives a high level description of your solution.
 */
#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include <unistd.h>
#include <string.h>

#include "mm.h"
#include "memlib.h"

/*********************************************************
 * NOTE TO STUDENTS: Before you do anything else, please
 * provide your team information in the following struct.
 ********************************************************/
team_t team = {
    /* Team name */
    "JIM IS AMAZING",
    /* First member's full name */
    "Alex Clemmer",
    /* First member's email address */
    "clemmer.alexander@gmail.com",
    /* Second member's full name (leave blank if none) */
    "",
    /* Second member's email address (leave blank if none) */
    ""
};

#define BLOCKFAIL (void *) -1
#define LIST_END (void *) 0
#define NUM_FREE_LISTS 28

#define FREE 0
#define ALLOC 1

/* single word (4) or double word (8) alignment */
#define ALIGNMENT 8
#define HEADER_SIZE 8
#define FOOTER_SIZE 8

/* rounds up to the nearest multiple of ALIGNMENT */
#define ALIGN(size) (((size) + (ALIGNMENT-1)) & ~0x7)


#define SIZE_T_SIZE (ALIGN(sizeof(size_t)))

/*  --- BEGIN CUSTOM MACROS --- */

// Types of allocation packed into tag
#define FREE 0
#define ALLOC 1

// Builds tag
#define PACK(size, alloc) ((size) | (alloc))

// Read/write word at p
#define GET(p)      (*(unsigned int *)(p))
#define PUT(p, val) (*(unsigned int *)(p) = (val))

// Prologue and epilogue are the bookends
#define BOOKEND_SZ 0
#define BOOKENDS(blk) (PUT(HDR(blk), PACK(BOOKEND_SZ, ALLOC) | (ALLOC << 1)))
#define PUT_PRLG(blk) (PUT(HDR(blk), PACK(BOOKEND_SZ, ALLOC) | (ALLOC << 1)))
#define PUT_EPLG(blk) (PUT(HDR(blk), PACK(BOOKEND_SZ, ALLOC) | (ALLOC << 1)))

// Block-related macros
#define HDR(p) ((void *)(p) - HDR_SZ)
#define HDR_SZ 8
#define FTR(p) ((void *)(p) + PYLD_SZ(p))
#define FTR_SZ 8

#define PYLD_SZ(p) (GET(HDR(p)) & ~0x7)
#define PD_SZ(sz) (sz + HDR_SZ + FTR_SZ)

// Free lists
#define NFLISTS 10  // TODO: This is not optimized

/*  --- END CUSTOM MACROS --- */

typedef void* hpidx;

void *hpstart; /* Start of heap */
void *prlg;
void *eplg;

/* 
 * mm_init - initialize the malloc package.
 */
int mm_init(void)
{
    void **curr;
    int i;

    // Alloc all space for lists, etc., and set all list pointers to NULL.
    if ((hpstart = mem_sbrk(NFLISTS * sizeof(void *) + 2 * PD_SZ(BOOKEND_SZ))) == NULL)
        return -1;

    // NULLify all list ptrs starting at beginning of heap
    for (i = 0, curr = hpstart; i < NFLISTS; curr++, i++)
        *curr = NULL;

    // Set up bookends
    prlg = (void *) curr + HDR_SZ;
    PUT_PRLG(prlg);
    eplg = prlg + PD_SZ(BOOKEND_SZ);
    PUT_EPLG(eplg);

    return 0;
}

/* 
 * mm_malloc - Allocate a block by incrementing the brk pointer.
 *     Always allocate a block whose size is a multiple of the alignment.
 */
void *mm_malloc(size_t size)
{
    int newsize = ALIGN(size + SIZE_T_SIZE);
    void *p = mem_sbrk(newsize);
    if ((int)p == -1)
	return NULL;
    else {
        *(size_t *)p = size;
        return (void *)((char *)p + SIZE_T_SIZE);
    }
}

/*
 * mm_free - Freeing a block does nothing.
 */
void mm_free(void *ptr)
{
}

/*
 * mm_realloc - Implemented simply in terms of mm_malloc and mm_free
 */
void *mm_realloc(void *ptr, size_t size)
{
    void *oldptr = ptr;
    void *newptr;
    size_t copySize;
    
    newptr = mm_malloc(size);
    if (newptr == NULL)
      return NULL;
    copySize = *(size_t *)((char *)oldptr - SIZE_T_SIZE);
    if (size < copySize)
      copySize = size;
    memcpy(newptr, oldptr, copySize);
    mm_free(oldptr);
    return newptr;
}














