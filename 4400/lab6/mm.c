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
#include <stdbool.h>

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
#define MIN_SIZE 24

/* rounds up to the nearest multiple of ALIGNMENT */
#define ALIGN(size) (((size) + (ALIGNMENT-1)) & ~0x7)

#define BOUNDARY_SIZE 0
#define MAKE_BOUNDARY(block) (PUT(HEADER(block), PACK(BOUNDARY_SIZE, ALLOC, ALLOC)))

#define TAG_SIZE 4
#define PACK(size, alloc, prev_alloc) ((size | alloc) | (prev_alloc << 1))

#define PUT(p, val) (*(word *)(p) = val)
#define GET(p) (*(word *)(p))

#define HEADER(bp) ((heap_index)(bp) - HEADER_SIZE)
#define FOOTER(bp) ((heap_index)(bp) + PAYLOAD_SIZE(bp))
#define PAYLOAD_FROM_HEADER(hp) ((heap_index) hp + HEADER_SIZE)

#define PAYLOAD_SIZE(bp) (UNPACK_SIZE(HEADER(bp)))
#define PAD_SIZE(size) (size + HEADER_SIZE + FOOTER_SIZE)
#define BLOCK_SIZE(bp) (PAD_SIZE(PAYLOAD_SIZE(bp)))
#define UNPACK_SIZE(tag) (GET(tag) & ~0x7)

#define IS_ALLOC(bp) (GET(HEADER(bp)) & 0x1)
#define IS_FREE(bp) (!IS_ALLOC(bp))
#define IS_PREV_ALLOC(bp) ((GET(HEADER(bp)) & 0x2) == 0x2)
#define IS_NEXT_ALLOC(bp) (IS_ALLOC(NEXT(bp)))

#define MARK_ALLOC(bp) (PUT(HEADER(bp), GET(HEADER(bp)) | 0x1))
#define MARK_FREE(bp) (PUT(HEADER(bp), GET(HEADER(bp)) | 0x2))
#define MARK_PREV_ALLOC(bp) (PUT(HEADER(bp), GET(HEADER(bp)) | 0x2))
#define MARK_PREV_FREE(bp) (PUT(HEADER(bp), GET(HEADER(bp)) & ~0x2))

#define SET_FREE(bp) {MARK_FREE(bp); MARK_PREV_FREE(NEXT(bp)); push_free_list(bp);}
#define SET_ALLOC(bp) {delete_from_free_list(bp); MARK_ALLOC(bp); MARK_PREV_ALLOC(NEXT(bp));}

#define NEXT(bp) (bp + BLOCK_SIZE(bp))
#define PREV_FOOTER(bp) (HEADER(bp) - FOOTER_SIZE)
#define PREV(bp) (bp - PAD_SIZE(UNPACK_SIZE(PREV_FOOTER(bp))))

#define FREE_LIST(class) ((heap_index *) (heap_start + (log_2(class) - 3) * 4))

#define GET_FREE_LIST(class) (*FREE_LIST(class))
#define SET_FREE_LIST(class, block) (*FREE_LIST(class) = block)

#define FREE_LIST_NUM(num) ((heap_index *) ((heap_index *) heap_start + num * 4))

#define NEXT_FREE_BLOCK(bp) ((heap_index *) ((heap_index) HEADER(bp) + TAG_SIZE))
#define PREV_FREE_BLOCK(bp) ((heap_index *) ((heap_index) FOOTER(bp) + TAG_SIZE))
#define GET_NEXT_FREE_BLOCK(bp) (*NEXT_FREE_BLOCK(bp))
#define GET_PREV_FREE_BLOCK(bp) (*PREV_FREE_BLOCK(bp))
#define SET_NEXT_FREE_BLOCK(bp, next) (GET_NEXT_FREE_BLOCK(bp) = next)
#define SET_PREV_FREE_BLOCK(bp, prev) (GET_PREV_FREE_BLOCK(bp) = prev)

#define END_FREE_SPACE (IS_PREV_ALLOC(epilogue) ? 0 : BLOCK_SIZE(PREV(epilogue)))

typedef void* heap_index;
typedef unsigned int size_class;
typedef char byte;
typedef int word;

heap_index heap_start;
heap_index prologue;
heap_index epilogue;

static void *find_free_block(int request_size);
static size_class get_size_class(size_t size);
static heap_index alloc_new_block(size_t size);
static void update_payload_size(heap_index block, size_t new_size);
static heap_index split_block(heap_index block, size_t carve_size);
static void delete_from_free_list(heap_index block);
static heap_index coalesce(heap_index block);
static void push_free_list(heap_index block);

static int log_2(unsigned int n)
{
    int pos = 0;
    if (n >= 1<<16) { n >>= 16; pos += 16; }
    if (n >= 1<< 8) { n >>=  8; pos +=  8; }
    if (n >= 1<< 4) { n >>=  4; pos +=  4; }
    if (n >= 1<< 2) { n >>=  2; pos +=  2; }
    if (n >= 1<< 1) {           pos +=  1; }
    return ((n == 0) ? (-1) : pos);
}


int mm_init(void)
{
    heap_start = mem_sbrk(NUM_FREE_LISTS * sizeof(heap_index *) + 2*PAD_SIZE(BOUNDARY_SIZE));
    heap_index *current_index = heap_start;

    int i;
    for (i = 0; i < NUM_FREE_LISTS; i++) {
        *current_index = LIST_END;
        current_index++;
    }

    prologue = (heap_index) current_index + HEADER_SIZE;
    MAKE_BOUNDARY(prologue);
    epilogue = prologue + PAD_SIZE(BOUNDARY_SIZE);
    MAKE_BOUNDARY(epilogue);

    return 0;
}

void *mm_malloc(size_t size)
{
    int newsize = ALIGN(size);

    void *p = find_free_block(newsize);

    if (p == BLOCKFAIL)
        p = alloc_new_block(newsize);

    if (p == NULL)
        return p;

    SET_ALLOC(p);

    return p;
}


void mm_free(void *ptr)
{
    SET_FREE(ptr);

    coalesce(ptr);
}

void *mm_realloc(void *ptr, size_t size)
{
    void *old_ptr = ptr;
    void *new_ptr;
    size_t old_size = PAYLOAD_SIZE(old_ptr);
    size_t new_size = ALIGN(size);
    int size_diff = new_size - old_size;

    if (!ptr) {
        return mm_malloc(size);
    }
    else if (!size) {
        mm_free(ptr);
        return NULL;
    }
    else if (new_size < old_size / 2) {
        SET_FREE(old_ptr);

        new_ptr = split_block(old_ptr, new_size);

        SET_ALLOC(new_ptr);
        return new_ptr;
    }
    else if (new_size <= old_size) {
        return old_ptr;
    }
    else {
        heap_index *prev = PREV(old_ptr);
        heap_index *next = NEXT(old_ptr);
        bool prev_free = IS_FREE(prev);
        bool next_free = IS_FREE(next);
        size_t prev_size = PAYLOAD_SIZE(prev);
        size_t next_size = PAYLOAD_SIZE(next);

        if ((next_free && next_size >= size_diff) ||
            (prev_free && prev_size >= size_diff) ||
            (next_free && prev_free && (prev_size + next_size) >= size_diff)) {

            SET_FREE(old_ptr);

            new_ptr = coalesce(old_ptr);

            if (new_ptr != old_ptr)
                memcpy(new_ptr, old_ptr, old_size);

            new_ptr = split_block(new_ptr, new_size);
            SET_ALLOC(new_ptr);
            return new_ptr;
        }
        else {
            new_ptr = mm_malloc(new_size * 2);
            if (new_ptr == NULL)
                return NULL;
            memcpy(new_ptr, old_ptr, old_size);
            mm_free(old_ptr);
            return new_ptr;
        }
    }
}

static void *find_free_block(int request_size)
{
    if (request_size <= 0)
        return NULL;

    size_class class = get_size_class(request_size);

    heap_index *list;
    for (list = FREE_LIST(class); (heap_index) list < HEADER(prologue); list++) {
        heap_index current_block = *list;

        while (current_block != LIST_END) {
            if (PAYLOAD_SIZE(current_block) >= request_size)
                return split_block(current_block, request_size);
            current_block = GET_NEXT_FREE_BLOCK(current_block);
        }
    }
    return BLOCKFAIL;
}

static size_class get_size_class(size_t size)
{
    int class = 8;
    do {
        class <<= 1;
    } while (class <= size);

    return class >>= 1;
}

static heap_index alloc_new_block(size_t size)
{
    size_t block_size = PAD_SIZE(size);

    size_t size_needed = block_size - END_FREE_SPACE;

    heap_index p = mem_sbrk(size_needed);

    p = epilogue;
    MARK_FREE(p);
    update_payload_size(p, size_needed - 16);
    push_free_list(p);

    epilogue += size_needed;
    MAKE_BOUNDARY(epilogue);
    MARK_PREV_FREE(epilogue);

    p = coalesce(p);

    return split_block(p, size);
}

static void update_payload_size(heap_index block, size_t new_size)
{
    word new_tag = PACK(new_size, IS_ALLOC(block), IS_PREV_ALLOC(block));
    PUT(HEADER(block), new_tag);
    PUT(FOOTER(block), new_tag);
}

static heap_index split_block(heap_index block, size_t carve_size)
{
    size_t initial_size = PAYLOAD_SIZE(block);

    if (initial_size >= carve_size + MIN_SIZE) {
        delete_from_free_list(block);

        update_payload_size(block, carve_size);

        heap_index new_block = NEXT(block);
        size_t new_size = initial_size - BLOCK_SIZE(block);
        update_payload_size(new_block, new_size);
        SET_FREE(new_block);

        push_free_list(block);
    }

    return block;
}

static void delete_from_free_list(heap_index block)
{
    heap_index prev = GET_PREV_FREE_BLOCK(block);
    heap_index next = GET_NEXT_FREE_BLOCK(block);

    if (prev == LIST_END)
        SET_FREE_LIST(get_size_class(PAYLOAD_SIZE(block)), next);
    else
        SET_NEXT_FREE_BLOCK(prev, next);

    if (next != LIST_END)
        SET_PREV_FREE_BLOCK(next, prev);
}

static heap_index coalesce(heap_index block)
{
    bool prev_alloc = IS_PREV_ALLOC(block);
    bool next_alloc = IS_NEXT_ALLOC(block);
    size_t size = PAYLOAD_SIZE(block);

    if (prev_alloc && next_alloc) {
        return block;
    }
    else if (prev_alloc) {
        heap_index next = NEXT(block);

        delete_from_free_list(block);
        delete_from_free_list(next);

        size += PAD_SIZE(PAYLOAD_SIZE(next));
        PUT(HEADER(block), PACK(size, FREE, IS_PREV_ALLOC(block)));
        PUT(FOOTER(next), PACK(size, FREE, IS_PREV_ALLOC(block)));

        push_free_list(block);
        return block;
    }
    else if (next_alloc) {
        heap_index prev = PREV(block);

        delete_from_free_list(block);
        delete_from_free_list(prev);

        size += PAD_SIZE(PAYLOAD_SIZE(prev));
        PUT(FOOTER(block), PACK(size, FREE, IS_PREV_ALLOC(prev)));
        PUT(HEADER(prev), PACK(size, FREE, IS_PREV_ALLOC(prev)));

        push_free_list(prev);

        return prev;
    }
    else {
        heap_index prev = PREV(block);
        heap_index next = NEXT(block);

        delete_from_free_list(block);
        delete_from_free_list(prev);
        delete_from_free_list(next);

        size += PAD_SIZE(PAYLOAD_SIZE(prev)) + PAD_SIZE(PAYLOAD_SIZE(next));
        PUT(HEADER(prev), PACK(size, FREE, IS_PREV_ALLOC(prev)));
        PUT(FOOTER(next), PACK(size, FREE, IS_PREV_ALLOC(prev)));

        push_free_list(prev);
        return prev;
    }
}

static void push_free_list(heap_index block)
{
    size_class class = get_size_class(PAYLOAD_SIZE(block));
    heap_index head = GET_FREE_LIST(class);

    SET_NEXT_FREE_BLOCK(block, head);

    if (head != LIST_END)
        SET_PREV_FREE_BLOCK(head, block);

    SET_PREV_FREE_BLOCK(block, LIST_END);

    SET_FREE_LIST(class, block);
}
