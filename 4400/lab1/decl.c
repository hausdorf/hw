#include <stdio.h>
#include <stdlib.h>
#include <limits.h>
#include <math.h>

#define TMin INT_MIN
#define TMax INT_MAX

#include "btest.h"
#include "bits.h"

test_rec test_set[] = {





 {"setEveryFourthBitTo1", (funct_t) setEveryFourthBitTo1, (funct_t) test_setEveryFourthBitTo1, 0,
    "! ~ & ^ | + << >>", 8, 1,
  {{TMin, TMax},{TMin,TMax},{TMin,TMax}}},
 {"anyOddBitIs1", (funct_t) anyOddBitIs1, (funct_t) test_anyOddBitIs1, 1,
    "! ~ & ^ | + << >>", 12, 2,
  {{TMin, TMax},{TMin,TMax},{TMin,TMax}}},
 {"everyEvenBitIs0", (funct_t) everyEvenBitIs0, (funct_t) test_everyEvenBitIs0, 1,
    "! ~ & ^ | + << >>", 12, 2,
  {{TMin, TMax},{TMin,TMax},{TMin,TMax}}},
 {"replaceByteN", (funct_t) replaceByteN, (funct_t) test_replaceByteN, 3,
    "! ~ & ^ | + << >>", 10, 3,
  {{TMin, TMax},{0,3},{0,255}}},
 {"countBits", (funct_t) countBits, (funct_t) test_countBits, 1, "! ~ & ^ | + << >>", 40, 4,
  {{TMin, TMax},{TMin,TMax},{TMin,TMax}}},
 {"logicalNot", (funct_t) logicalNot, (funct_t) test_logicalNot, 1,
    "~ & ^ | + << >>", 12, 4,
  {{TMin, TMax},{TMin,TMax},{TMin,TMax}}},
 {"isTMax", (funct_t) isTMax, (funct_t) test_isTMax, 1, "! ~ & ^ | +", 10, 1,
  {{TMin, TMax},{TMin,TMax},{TMin,TMax}}},
 {"fitsInShort", (funct_t) fitsInShort, (funct_t) test_fitsInShort, 1,
    "! ~ & ^ | + << >>", 8, 1,
  {{TMin, TMax},{TMin,TMax},{TMin,TMax}}},
 {"determineSign", (funct_t) determineSign, (funct_t) test_determineSign, 1, "! ~ & ^ | + << >>", 10, 2,
     {{-TMax, TMax},{TMin,TMax},{TMin,TMax}}},
 {"multiplyByThreeEighths", (funct_t) multiplyByThreeEighths, (funct_t) test_multiplyByThreeEighths, 1,
    "! ~ & ^ | + << >>", 12, 3,
  {{-(1<<28)-1, (1<<28)-1},{TMin,TMax},{TMin,TMax}}},
 {"isPowerOfTwo", (funct_t) isPowerOfTwo, (funct_t) test_isPowerOfTwo, 1, "! ~ & ^ | + << >>", 20, 4,
  {{TMin, TMax},{TMin,TMax},{TMin,TMax}}},
 {"floatIsInfinity", (funct_t) floatIsInfinity, (funct_t) test_floatIsInfinity, 1,
    "$", 8, 1,
     {{1, 1},{1,1},{1,1}}},
 {"floatIsNaN", (funct_t) floatIsNaN, (funct_t) test_floatIsNaN, 1,
    "$", 8, 1,
     {{1, 1},{1,1},{1,1}}},
 {"floatAbsoluteValue", (funct_t) floatAbsoluteValue, (funct_t) test_floatAbsoluteValue, 1,
    "$", 10, 2,
     {{1, 1},{1,1},{1,1}}},
 {"floatNegate", (funct_t) floatNegate, (funct_t) test_floatNegate, 1,
    "$", 10, 2,
     {{1, 1},{1,1},{1,1}}},
 {"floatMultiplyByTwo", (funct_t) floatMultiplyByTwo, (funct_t) test_floatMultiplyByTwo, 1,
    "$", 30, 4,
     {{1, 1},{1,1},{1,1}}},
 {"floatToInteger", (funct_t) floatToInteger, (funct_t) test_floatToInteger, 1,
    "$", 30, 4,
     {{1, 1},{1,1},{1,1}}},
  {"", NULL, NULL, 0, "", 0, 0,
   {{0, 0},{0,0},{0,0}}}
};
