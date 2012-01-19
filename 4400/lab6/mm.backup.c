/*
 * mm.c - The malloc package to end all malloc package
 *
 * Please compile with -lm to make sure math.h is included!
 * 
 * In this approach to dynamic memory allocation, we use a segregated free lists
 * approach that partitions blocks into a series of size classes, each of which
 * holds a free list for some range of block sizes.
 *
 * Our size classes are based on powers of two -- 8 bytes, 16 bytes, 32 bytes,
 * etc. While any approach has draw backs, this gives us a very small number of
 * free lists, so we aren't wasting too much of the heap for small traces,
 * while simultaneously covering a wide range of values. Also, because we expect
 * small values to be allocated and freed more often than big ones, the log
 * approach gives us more granular free lists at the low end and broader ones
 * at the high end, where search hopefully won't take as long.
 *
 * We find a free block in the list using first-fit search in the relevant free
 * list. The free lists themselves are implicit doubly-linked lists that use
 * pointers built into the header and footer of each block for traversal, or
 * the constant LIST_END to indicate the end (or, in the reverse direction,
 * beginning of the list). The pointers to the heads of the lists are stored in
 * the very beginning of the heap, effectively creating an array of pointers to
 * free lists.
 *
 * Every block consists of a payload and a header and footer, each of 8 bytes.
 * The first 4 bytes consist of a "tag" whose least significant bit indicates
 * whether the block is (1) allocated or (0) free and whose second least
 * significant bit indicates whether the previous block is (1) allocated or
 * (0) free. The next 4 bytes are the pointer to the next node in the implicit
 * free list. The footer has the same structure, but the second word points to
 * the previous free block.
 *
 * ===== 4 ===== ======= 4 =======    ...   ===== 4 ===== ======= 4 ========
 * +------------+-----------------+---------+------------+-----------------+
 * | s/a/pa tag | next free block | payload | s/a/pa tag | prev free block | 
 * +------------+-----------------+---------+------------+-----------------+
 * ========== HEADER =============    ...   ============ FOOTER ============
 *
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>
#include <unistd.h>
#include <math.h>
#include <stdbool.h>

#include "mm.h"
#include "memlib.h"

/*********************************************************
 * NOTE TO STUDENTS: Before you do anything else, please
 * provide your team information in the following struct.
 ********************************************************/
team_t team = {
    /* Team name (id1+id2)*/
    "noronha+hysen",
    /* First member's full name */
    "Jon Noronha",
    /* First member's email address */
    "noronha@fas.harvard.edu",
    /* Second member's full name (leave blank if none) */
    "Eric Hysen",
    /* Second member's email address (leave blank if none) */
    "hysen@fas.harvard.edu"
};

#define BLOCKFAIL (void*) -1 // Return value if no block found
#define LIST_END (void*) 0  // List terminator
#define NUM_FREE_LISTS 28 //TODO(hysen):FIX THIS

#define FREE 0
#define ALLOC 1
#define ALIGNMENT 8 // single word (4) or double word (8) alignment
#define HEADER_SIZE 8
#define FOOTER_SIZE 8
#define MIN_SIZE 24 // Header + footer + min block size (8)

/* rounds up to the nearest multiple of ALIGNMENT */
#define ALIGN(size) (((size) + (ALIGNMENT-1)) & ~0x7)

/* We have prologue and epilogue blocks on either end to simplify coalescing.
   Each is an empty block. */
#define BOUNDARY_SIZE 0
#define MAKE_BOUNDARY(block) (PUT(HEADER(block),PACK(BOUNDARY_SIZE,ALLOC,ALLOC)))

// Tag is just the size, in bytes, of the "tag" of packed size and allocation information
#define TAG_SIZE 4
#define PACK(size, alloc, prev_alloc) ((size | alloc) | (prev_alloc << 1))

/* Manipulating words */
#define PUT(p, val) (*(word *)(p) = val)
#define GET(p)      (*(word *)(p))

/* 
 * Macros for getting information about a block. In all functions, the block pointer bp
 * is assumed to point to the payload, ie, the pointer that malloc would return and free
 * would call.
 */
#define HEADER(bp)  ((heap_index)(bp) - HEADER_SIZE)
#define FOOTER(bp)  ((heap_index)(bp) + PAYLOAD_SIZE(bp))
#define PAYLOAD_FROM_HEADER(hp) ((heap_index) hp + HEADER_SIZE)

// Various ways of measuring block size
#define PAYLOAD_SIZE(bp)  (UNPACK_SIZE(HEADER(bp))) // Payload size of a block
#define PAD_SIZE(size) (size + HEADER_SIZE + FOOTER_SIZE) // Payload size -> block size
#define BLOCK_SIZE(bp) (PAD_SIZE(PAYLOAD_SIZE(bp))) // Actual space a block takes up
#define UNPACK_SIZE(tag) (GET(tag) & ~0x7) // Tag -> size

// Free/alloc status of blocks
#define IS_ALLOC(bp)    (GET(HEADER(bp)) & 0x1) // 1 for allocated, 0 for free
#define IS_FREE(bp)     (!IS_ALLOC(bp))
#define IS_PREV_ALLOC(bp) ((GET(HEADER(bp)) & 0x2) == 0x2)
#define IS_NEXT_ALLOC(bp) (IS_ALLOC(NEXT(bp)))

// Setting free/alloc status
#define MARK_ALLOC(bp)  (PUT(HEADER(bp),GET(HEADER(bp)) | 0x1))
#define MARK_FREE(bp)   (PUT(HEADER(bp),GET(HEADER(bp)) & ~0x1))
#define MARK_PREV_ALLOC(bp) (PUT(HEADER(bp), GET(HEADER(bp)) | 0x2))
#define MARK_PREV_FREE(bp)  (PUT(HEADER(bp), GET(HEADER(bp)) & ~0x2))

/*
 * SET_FREE and SET_ALLOC handle all the necessary bookkeeping of freeing /
 * allocating a block of memory. They update the free list, mark the free
 * bits, and mark the prev-allocated bit of the next block.
 */
#define SET_FREE(bp) {MARK_FREE(bp); MARK_PREV_FREE(NEXT(bp)); push_free_list(bp);}
#define SET_ALLOC(bp) {delete_from_free_list(bp); MARK_ALLOC(bp); MARK_PREV_ALLOC(NEXT(bp));}

/*
 * Heap traversal
 */
#define NEXT(bp) (bp + BLOCK_SIZE(bp))
#define PREV_FOOTER(bp) (HEADER(bp) - FOOTER_SIZE)
#define PREV(bp) (bp - PAD_SIZE(UNPACK_SIZE(PREV_FOOTER(bp))))

/*
 * Free list traversal
 */

// Get a pointer to the head of the free list (dereference to get head)
#define FREE_LIST(class) ((heap_index*) (heap_start + (log_2(class) - 3) * 4))

// Gets the head of the free list
#define GET_FREE_LIST(class) (*FREE_LIST(class))
#define SET_FREE_LIST(class,block) (*FREE_LIST(class) = block)

// Get the Nth free list (as opposed to the free list of size CLASS)
#define FREE_LIST_NUM(num) ((heap_index*) ((heap_index*) heap_start + num * 4))

// Traverse the free list
#define NEXT_FREE_BLOCK(bp) ((heap_index*) ((heap_index) HEADER(bp) + TAG_SIZE))
#define PREV_FREE_BLOCK(bp) ((heap_index*) ((heap_index) FOOTER(bp) + TAG_SIZE))
#define GET_NEXT_FREE_BLOCK(bp) (*NEXT_FREE_BLOCK(bp))
#define GET_PREV_FREE_BLOCK(bp) (*PREV_FREE_BLOCK(bp))
#define SET_NEXT_FREE_BLOCK(bp,next) (GET_NEXT_FREE_BLOCK(bp) = next)
#define SET_PREV_FREE_BLOCK(bp,prev) (GET_PREV_FREE_BLOCK(bp) = prev)

/*
 * Other
 */

/* The amount of free space at the end of the heap
   (i.e., in the block preceding the epilogue block).
   0 if the last block on the heap is allocated. */
#define END_FREE_SPACE (IS_PREV_ALLOC(epilogue) ? 0 : BLOCK_SIZE(PREV(epilogue)))
 
heap_index heap_start;
heap_index prologue;
heap_index epilogue;

/*** HELPER FUNCTIONS ***/
static void* find_free_block(int request_size);
static size_class get_size_class(size_t size);
static heap_index alloc_new_block(size_t size);
static void update_payload_size(heap_index block, size_t new_size);
static heap_index split_block(heap_index block, size_t carve_size);
static void delete_from_free_list(heap_index block);
static heap_index coalesce(heap_index block);
static void push_free_list(heap_index block);

/*** DEBUG FUNCTIONS ***/
static void print_free_lists();
static void print_free_list(size_class class);
static void print_block(heap_index p);
static int check_free_list_consistent(size_class class);
static int check_free_lists_consistent();
static int check_follow_headers();
static int check_free_blocks();
static int mm_check();

// Function for calculating log base 2 without having to use the log function.
// Couresty of http://en.wikipedia.org/wiki/Binary_logarithm#Integer
static int log_2(unsigned int n) {
  int pos = 0;
  if (n >= 1<<16) { n >>= 16; pos += 16; }
  if (n >= 1<< 8) { n >>=  8; pos +=  8; }
  if (n >= 1<< 4) { n >>=  4; pos +=  4; }
  if (n >= 1<< 2) { n >>=  2; pos +=  2; }
  if (n >= 1<< 1) {           pos +=  1; }
  return ((n == 0) ? (-1) : pos);
}

/* 
 * mm_init - initialize the malloc package by initializing the pointers to
 * the free lists and initializing the prologue and epilogue
 */
int mm_init(void)
{
    // Start by allocating space for the free lists, the prologue, and the epilogue
    heap_start = mem_sbrk(NUM_FREE_LISTS * sizeof(heap_index*) + 2*PAD_SIZE(BOUNDARY_SIZE));
    heap_index* current_index = heap_start;

    // Initialize all list pointers to LIST_END
    int i;
    for (i = 0; i < NUM_FREE_LISTS; i++) {
        *current_index = LIST_END;
        current_index++;
    }

    // Initialize prologue and epilogue
    prologue = (heap_index) current_index + HEADER_SIZE; // We point to payload so our macros work
    MAKE_BOUNDARY(prologue);
    epilogue = prologue + PAD_SIZE(BOUNDARY_SIZE);
    MAKE_BOUNDARY(epilogue);
    return 0;
}

/* 
 * mm_malloc - Allocate a block by attempting to find a suitably sized free
 * block in relevant free lists, otherwise allocating a new block, and
 * returning NULL is we are out of memory
 */
void *mm_malloc(size_t size)
{
    int newsize = ALIGN(size);
    
    // Start by checking the free lists for a block of size NEWSIZE
    void *p = find_free_block(newsize);
    
    // If that fails, allocate room for NEWSIZE more bytes
    if (p == BLOCKFAIL)
        p = alloc_new_block(newsize);

    if (p == NULL)
        return p; // We're out of memory :(
        
    // Finalize allocation
    SET_ALLOC(p);
    
    return p;
}

/*
 * mm_free - Free a block by setting it as free, adding it to the relevant
 * free list, and coalescing with adjoining blocks.
 */
void mm_free(void *ptr)
{
    // Bookkeeping to mark a block as free
    SET_FREE(ptr);
    
    // Coalesce in case neighboring blocks are also free
    coalesce(ptr);
}

/*
 * mm_realloc - reallocate memory by handling special cases (when ptr is NULL,
 * size is 0, or we are allocating the same size), and then attempt to use the
 * current memory at and around ptr if possible, otherwise allocating a new
 * block using mm_malloc.  If necessary, copy the data stored at ptr to the
 * new location.
 */
void *mm_realloc(void *ptr, size_t size)
{
    void *old_ptr = ptr;
    void *new_ptr;
    size_t old_size = PAYLOAD_SIZE(old_ptr);
    size_t new_size = ALIGN(size);
    int size_diff = new_size - old_size;

    // If ptr is null, call mm_malloc
    if (!ptr){
        return mm_malloc(size);
    }

    // If size == 0, free
    else if (!size){
        mm_free(ptr);
        return NULL;
    }

    // If we're dividing the block in half or smaller, split the block.
    // (Any smaller reduction isn't really worth the trouble)
    else if (new_size < old_size / 2){
        // Mark the current block as free and put it on a free list
        SET_FREE(old_ptr);

        // Split the block to the new size
        new_ptr = split_block(old_ptr, new_size);
        
        // Delete the newly resived block from the free list and allocate it
        SET_ALLOC(new_ptr);
        return new_ptr;
    }

    // If we're reallocing the same size or just something slightly smaller,
    // do nothing.
    else if (new_size <= old_size){
        return old_ptr;
    }


    
    // If we're reallocing more memory, check the next block
    else {

        heap_index* prev = PREV(old_ptr);
        heap_index* next = NEXT(old_ptr);
        bool prev_free = IS_FREE(prev);
        bool next_free = IS_FREE(next);
        size_t prev_size = PAYLOAD_SIZE(prev);
        size_t next_size = PAYLOAD_SIZE(next);

        /* If the surrounding blocks in the heap are free and big enough to hold
           the additional memory we want to allocate, combine the blocks */
        if ((next_free && next_size >= size_diff) ||
            (prev_free && prev_size >= size_diff) ||
            (next_free && prev_free && (prev_size + next_size) >= size_diff)){
            // Mark the current block as free and put it on a free list
            SET_FREE(old_ptr);

            /* Coalesce the block to combine with the surrounding blocks */
            new_ptr = coalesce(old_ptr);

            /* If the start of the block has changed, then the previous block
               was free and we are now starting there, so we want to copy
               the existing data */
            if (new_ptr != old_ptr)
                memcpy(new_ptr, old_ptr, old_size);
            
            /* Split the new block appropriately, delete it from its
               free list, and mark it as allocated before returning */
            new_ptr = split_block(new_ptr, new_size);
            SET_ALLOC(new_ptr);
            return new_ptr;
        }

        /* If we're requesting more space and that additional space isn't
           available in the surrounding blocks, we have to malloc a new block.
           Since a block that's growing out of its space is likely to grow again
           in the future, we save ourselves some trouble by allocating double the
           space next time. This simple optimization makes for huge performance
           increases on the provided traces, even if it might not always be ideal.
        */
        else {
            new_ptr = mm_malloc(new_size * 2); // Get new pointer
            if (new_ptr == NULL) // Return NULL if we are out of memory
                return NULL;
            memcpy(new_ptr, old_ptr, old_size); // Copy the old data
            mm_free(old_ptr); // Free the old block
            return new_ptr; // Return the new pointer
        }
    }
}


 /*
  * Finds the first available free block whose payload size is >= REQUEST_SIZE.
  * Uses get_size_class to search the appropriate free list and runs a first-fit
  * search through that list, cascading up to larger free lists if necessary. If
  * all free lists are exhausted, return BLOCKFAIL. If a block is found, we split
  * if necessary and then return a pointer to the block.
  */
static void* find_free_block(int request_size) 
{
    // Check for valid input
    if (request_size <= 0)
        return NULL;

    size_class class = get_size_class(request_size);

    /* Loop through increasing free lists until we find a free block,
       starting with the appropriate list for request_size */
    heap_index* list;
    for (list = FREE_LIST(class); (heap_index) list < HEADER(prologue); list++) {
        // The head of the free list
        heap_index current_block = *list;
        
        /* Traverse this free list looking for block of the requisite size.
           When we find it, split and return. */
        while (current_block != LIST_END) {
            
            if (PAYLOAD_SIZE(current_block) >= request_size)
                return split_block(current_block, request_size);

            current_block = GET_NEXT_FREE_BLOCK(current_block);
        }
    }

    /* If we haven't found an appropriate block in any free list searched,
       return BLOCKFAIL so mm_malloc will allocate a new block */
    return BLOCKFAIL;
}

/*
 * Takes a size, in bytes, and returns its size class. The size class
 * is just represented as the minimum size in that class, in bytes. We 
 * may implement this as a macro if our size classes are very simple.
 */
static size_class get_size_class(size_t size) {
    // Find the lowest power of two
    int class = 8;
    do {
        class <<= 1;
    } while (class <= size);

    return class >>= 1;
}

/*
 * Allocates room on the heap for SIZE more bytes. If there is already free
 * space at the end of the heap, it will ask for SIZE - FREE_SPACE and
 * coalesce to make a perfectly sized block. Handles the shifting of epilogue
 * to the end of the heap.
 *
 * Returns NULL if no memory is available and a pointer to the newly allocated
 * block otherwise.
 */
static heap_index alloc_new_block(size_t size) {
    size_t block_size = PAD_SIZE(size);
    
    size_t size_needed = block_size - END_FREE_SPACE;
        
    // Allocate SIZE more bytes of memory, plus header and footer, minus any free space already at end
    heap_index p = mem_sbrk(size_needed);
    
    // New free zone starts where the old epilogue was
    p = epilogue;
    MARK_FREE(p);    
    update_payload_size(p, size_needed - 16);
    push_free_list(p);

    // Scoot epilogue over to its new home
    epilogue += size_needed;
    MAKE_BOUNDARY(epilogue);
    MARK_PREV_FREE(epilogue);

    // Coalesce
    p = coalesce(p);
    
    // Split if necessary, then return
    return split_block(p, size);
}

/*
 * Takes a BLOCK and sets its payload size, in header and footer, to NEW_SIZE.
 * DOES NOT put it in a free list--caller should handle this.
 */
static void update_payload_size(heap_index block, size_t new_size) {
    word new_tag = PACK(new_size,IS_ALLOC(block),IS_PREV_ALLOC(block));
    PUT(HEADER(block),new_tag);
    PUT(FOOTER(block),new_tag);
}

/*
 * Takes a BLOCK of sufficient size (or returns the original block if
 * this condition is not met) and splits it into two pieces, the first
 * of which has size CARVE_SIZE. 
 *
 * split_block handles all free list operaitons internally. The block to be
 * split is removed from its free list and two resulting blocks are pushed onto
 * their respective list. This could perhaps be optimized more, since splitting
 * is usually called before allocating the first block, but we felt this makes
 * for a cleaner interface. It also updates the headers and footers of both 
 * blocks as necessary.
 */
static heap_index split_block(heap_index block, size_t carve_size) {
    size_t initial_size = PAYLOAD_SIZE(block);
    // if we need to split
    if (initial_size >= carve_size + MIN_SIZE) {
    
        // Delete the original node from its old free list
        delete_from_free_list(block);
    
        // Set the first block to its new size
        update_payload_size(block, carve_size);

        // Create the new free block and set its size
        heap_index new_block = NEXT(block);
        size_t new_size = initial_size - BLOCK_SIZE(block);
        update_payload_size(new_block, new_size);
        SET_FREE(new_block);
    
        // Add the blocks to the proper free lists
        push_free_list(block);
        
  }
  
  return block;
}

/*
 * Deletes BLOCK from its free list by setting the pointers on either
 * side to hop over it.
 */
static void delete_from_free_list(heap_index block) {
    heap_index prev = GET_PREV_FREE_BLOCK(block);
    heap_index next = GET_NEXT_FREE_BLOCK(block);
    
    // If we're deleting the head, update the free list pointer
    if (prev == LIST_END)
        SET_FREE_LIST(get_size_class(PAYLOAD_SIZE(block)), next);
    else
        SET_NEXT_FREE_BLOCK(prev,next);
    
    // If we're deleting the tail, we don't have to do anything more
    if (next != LIST_END)
        SET_PREV_FREE_BLOCK(next,prev);
}

/*
 * Takes a block to be freed and checks the blocks on either side of it,
 * combining with these blocks if they are free. Removes any blocks it
 * consolidates from their respective free lists. Sets the header and
 * footer of the new block it creates and returns a pointer to that
 * header.
 *
 * To make for a simple interface, coalesce handles all updates of the free
 * list and headers. Specifically, it deletes any blocks it consolidates from
 * their free lists and puts the new block that results onto its proper free
 * list.
 */
static heap_index coalesce(heap_index block) {
    bool prev_alloc = IS_PREV_ALLOC(block);
    bool next_alloc = IS_NEXT_ALLOC(block);   
    size_t size = PAYLOAD_SIZE(block);
    
    // Case 1: Nothing to coalesces
    if (prev_alloc && next_alloc) {
        return block;
    }
    
    // Case 2: Coalesce with next block
    else if (prev_alloc) {
        heap_index next = NEXT(block);
        
        // Maintain free lists
        delete_from_free_list(block);
        delete_from_free_list(next);
        
        // Update header of BLOCK so that size stretches to encompass NEXT
        size += PAD_SIZE(PAYLOAD_SIZE(next));
        PUT(HEADER(block), PACK(size,FREE,IS_PREV_ALLOC(block)));
        PUT(FOOTER(next), PACK(size,FREE,IS_PREV_ALLOC(block))); 
        
        push_free_list(block);
        return block;
    }
    
    // Case 3: Coalesce with prev block
    else if (next_alloc) {
        heap_index prev = PREV(block);
        
        // Maintain free lists
        delete_from_free_list(block);
        delete_from_free_list(prev);
        
        // Update header of PREV so that size stretches to encompass BLOCK
        size += PAD_SIZE(PAYLOAD_SIZE(prev));
        PUT(FOOTER(block), PACK(size,FREE,IS_PREV_ALLOC(prev)));
        PUT(HEADER(prev), PACK(size,FREE,IS_PREV_ALLOC(prev)));
        
        push_free_list(prev);
        return prev;
    }
    
    // Coalesce both ends
    else {
        heap_index prev = PREV(block);
        heap_index next = NEXT(block);
        
        // Maintain free lists
        delete_from_free_list(block);
        delete_from_free_list(prev);
        delete_from_free_list(next);
        
        // Update header of PREV so that size stretches encompass BLOCK and NEXT
        size += PAD_SIZE(PAYLOAD_SIZE(prev)) + PAD_SIZE(PAYLOAD_SIZE(next));
        PUT(HEADER(prev), PACK(size,FREE,IS_PREV_ALLOC(prev)));
        PUT(FOOTER(next), PACK(size,FREE,IS_PREV_ALLOC(prev)));
        
        push_free_list(prev);
        return prev;
    }
}

/*
 * Takes a block and pushes it onto the front of the relevant free
 * list. Also sets the pointer to the start of the relevant free list
 * to this block.
 */
static void push_free_list(heap_index block){
    size_class class = get_size_class(PAYLOAD_SIZE(block));
    heap_index head = GET_FREE_LIST(class);
    
    // Set next pointer of BLOCK to the current free list head
    SET_NEXT_FREE_BLOCK(block,head);

    if (head != LIST_END)
        SET_PREV_FREE_BLOCK(head,block);

    // Head of a list should have the prev free block to point to list end
    SET_PREV_FREE_BLOCK(block, LIST_END);

    // Make the free list's new head BLOCK
    SET_FREE_LIST(class,block);
}

/******** DEBUGGING FUNCTIONS ********/

/*
 * Prints all free lists in order of increasing size class, using
 * print_free_list.
 */
static void print_free_lists(){
    printf("\n");
    int i;
    for (i = 0; i < NUM_FREE_LISTS; i++) {
        print_free_list(pow(2,(i + 3)));
    }
}


/*
 * Given a size class, prints the free list for that size class in order, 
 * using one line per node.
 * FREE LIST (size_class 128):
 * "address=0x%8x next=0x%8x prev=0x%8x size = 136"
 * "address=0x%8x next=0x%8x prev=0x%8x size = 248"
 * ... and so on
 */
static void print_free_list(size_class class){
    printf("FREE LIST (size_class 2^%d = %u)\n", log_2(class), class);
    heap_index p = GET_FREE_LIST(class);
    while(p != LIST_END){
        print_block(p);
        p = GET_NEXT_FREE_BLOCK(p);
    }
}

/*
 * Print the block info for address p, used by several debugging functions.
 */
static void print_block(heap_index p){
  printf("address=%p next=%p prev=%p size = %d allocated = %d prev_allocated = %d next_free = %p prev_free = %p\n", 
         p, NEXT(p), PREV(p), PAYLOAD_SIZE(p), IS_ALLOC(p), IS_PREV_ALLOC(p), GET_NEXT_FREE_BLOCK(p), GET_PREV_FREE_BLOCK(p));
}

/*
 * Print the heap
 */
 static void print_heap(){
    printf("--NOW PRINTING HEAP--\n");
    heap_index p = heap_start;

    //print the initial list of pointers to our free lists
    int i;
    for (i = 0; i < NUM_FREE_LISTS; i++) {
        size_class class = pow(2, (i + 3));
        printf("FREE LIST POINTER FOR CLASS: %d ==> %p\n", class, *(heap_index*)p);
        p += 4; // Move 4 bytes
    }  
    p += 8;
    //print prologue block
    if(p != prologue){
        printf("\n\nERROR: We should be at the prologue, but ptr=%p and \
        prologue=%p\n\n", p, prologue);
    }
    printf("PROLOGUE: %d\n", GET(HEADER(p)));
    p = NEXT(p);
    
    //loop and print heap contents
    while(p < epilogue){
        print_block(p);
        p = NEXT(p);
    }
    
    //print epilogue
    if(p != epilogue){
        printf("\n\nERROR: We should be at the epilogue, but ptr=%p and \
        epilogue=%p\n\n", p, epilogue);
    }
    printf("EPILOGUE: %d\n", GET(HEADER(p)));
}

/*
 * Check, for each node in the free list for a size_class, that all blocks
 * are correctly set as free and have the correct size. Return 0 if error,
 * printing it, or non-zero otherwise.
 */
static int check_free_list_consistent(size_class class){
  heap_index* p = GET_FREE_LIST(class);
  while (p != LIST_END){
    if (!IS_FREE(p)){
      printf("ERROR: Free list node not marked as free.\n");
      print_block(p);
      return 0;
    }
    if (UNPACK_SIZE(HEADER(p)) != UNPACK_SIZE(FOOTER(p))){
      printf("ERROR: Free list node not size-consistent. \n");
      print_block(p);
      return 0;
    }
    p = NEXT_FREE_BLOCK(p);
  }
  return 1;
}

/*
 * Runs check_free_list_consistent for all free lists.
 */
static int check_free_lists_consistent(){
  printf("Checking free list consistency.");
  int i;
  for (i = 0; i < NUM_FREE_LISTS; i++) {
    size_class class = pow(2, (i + 3));
    if (!check_free_list_consistent(class)){
      return 0;
    }
  }
  printf("List consistency checking done.");
  return 1;
}
  
/*
 * Starts from the beginning of the heap and traverses the implicit list
 * implied by the header sizes. For each node, check that the header is
 * valid and then jump to the next header. Return 0 if we go off the edge
 * of the heap or if we stop before the end of the heap.
 */
static int check_follow_headers(){
  heap_index p = prologue;
  while(p < epilogue){
    if (UNPACK_SIZE(HEADER(p)) != UNPACK_SIZE(FOOTER(p))){
      printf("ERROR: Block is not size-consistent. \n");
      print_block(p);
      return 0;
    }
    p = NEXT(p);
  }
  if(p != epilogue){
    printf("ERROR: Following the heap forwards brought us past the epilogue.\n");
    return 0;
  }
  while(p > prologue){
    p = PREV(p);
  }
  if(p != prologue){
    printf("ERROR: Following the heap backwards brought us before the prologue.\n");
  }
  return 1;
}

/*
 * Starts from the beginning heap and traverses the implicit list implied
 * by the header sizes. For each free block encountered, check that it
 *    - Appears in the relevant free list
 *    - Does not have a free block before it
 * Returns 0 if either of these conditions is ever violated and 1 otherwise.  
 */
static int check_free_blocks(){
    heap_index p = prologue;
    while(p < epilogue){
        if(IS_FREE(p)){
        //check that p appears in the free list if it is free
            size_class class = get_size_class(PAYLOAD_SIZE(p));
            heap_index list_ptr = GET_FREE_LIST(class);
            while(list_ptr != p){
                if(list_ptr == LIST_END){
                    printf("Free block not found in free list.\n");
                    print_block(list_ptr);
                    return 0;
                }
                list_ptr = NEXT_FREE_BLOCK(list_ptr);
            }
        //check that prev and next blocks are not free
        if(IS_FREE(PREV(p)) || IS_FREE(NEXT(p))){
            printf("Free block not properly coalesced.\n");
            print_block(p);
            return 0;
        }
    }
    p = NEXT(p);
  }
  return 1;
}

/*
 * Convenenience function for running the 3 checks above.
 * See the header comments for other functions under the DEBUG FUNCTIONS
 * comment for more details about how these checks run.
 */
static int mm_check(){
    if(check_free_lists_consistent() &&
       check_follow_headers() &&
       check_free_blocks()) {
        printf("THE HEAP IS CONSISTENT!");
        return 1;
    } else {
        return 0;
    }
}


