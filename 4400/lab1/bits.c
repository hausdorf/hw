/* 
 * CS:APP Data Lab 
 * 
 * Alex Clemmer `clemmer`
 * 
 * bits.c - Source file with your solutions to the Lab.
 *          This is the file you will hand in to your instructor.
 *
 * WARNING: Do not include the <stdio.h> header; it confuses the dlc
 * compiler. You can still use printf for debugging without including
 * <stdio.h>, although you might get a compiler warning. In general,
 * it's not good practice to ignore compiler warnings, but in this
 * case it's OK.  
 */

#if 0
/*
 * Instructions to Students:
 *
 * STEP 1: Read the following instructions carefully.
 */

You will provide your solution to the Data Lab by
editing the collection of functions in this source file.

INTEGER CODING RULES:
 
  Replace the "return" statement in each function with one
  or more lines of C code that implements the function. Your code 
  must conform to the following style:
 
  int Funct(arg1, arg2, ...) {
      /* brief description of how your implementation works */
      int var1 = Expr1;
      ...
      int varM = ExprM;

      varJ = ExprJ;
      ...
      varN = ExprN;
      return ExprR;
  }

  Each "Expr" is an expression using ONLY the following:
  1. Integer constants 0 through 255 (0xFF), inclusive. You are
      not allowed to use big constants such as 0xffffffff.
  2. Function arguments and local variables (no global variables).
  3. Unary integer operations ! ~
  4. Binary integer operations & ^ | + << >>
    
  Some of the problems restrict the set of allowed operators even further.
  Each "Expr" may consist of multiple operators. You are not restricted to
  one operator per line.

  You are expressly forbidden to:
  1. Use any control constructs such as if, do, while, for, switch, etc.
  2. Define or use any macros.
  3. Define any additional functions in this file.
  4. Call any functions.
  5. Use any other operations, such as &&, ||, -, or ?:
  6. Use any form of casting.
  7. Use any data type other than int.  This implies that you
     cannot use arrays, structs, or unions.
 
  You may assume that your machine:
  1. Uses 2s complement, 32-bit representations of integers.
  2. Performs right shifts arithmetically.
  3. Has unpredictable behavior when shifting an integer by more
     than the word size.

EXAMPLES OF ACCEPTABLE CODING STYLE:
  /*
   * pow2plus1 - returns 2^x + 1, where 0 <= x <= 31
   */
  int pow2plus1(int x) {
     /* exploit ability of shifts to compute powers of 2 */
     return (1 << x) + 1;
  }

  /*
   * pow2plus4 - returns 2^x + 4, where 0 <= x <= 31
   */
  int pow2plus4(int x) {
     /* exploit ability of shifts to compute powers of 2 */
     int result = (1 << x);
     result += 4;
     return result;
  }

FLOATING POINT CODING RULES

For the problems that require you to implent floating-point operations,
the coding rules are less strict.  You are allowed to use looping and
conditional control.  You are allowed to use both ints and unsigneds.
You can use arbitrary integer and unsigned constants.

You are expressly forbidden to:
  1. Define or use any macros.
  2. Define any additional functions in this file.
  3. Call any functions.
  4. Use any form of casting.
  5. Use any data type other than int or unsigned.  This means that you
     cannot use arrays, structs, or unions.
  6. Use any floating point data types, operations, or constants.


NOTES:
  1. Use the dlc (data lab checker) compiler (described in the handout) to 
     check the legality of your solutions.
  2. Each function has a maximum number of operators (! ~ & ^ | + << >>)
     that you are allowed to use for your implementation of the function. 
     The max operator count is checked by dlc. Note that '=' is not 
     counted; you may use as many of these as you want without penalty.
  3. Use the btest test harness to check your functions for correctness.
  4. The maximum number of ops for each function is given in the
     header comment for each function. If there are any inconsistencies 
     between the maximum ops in the writeup and in this file, consider
     this file the authoritative source.

/*
 * STEP 2: Modify the following functions according the coding rules.
 * 
 *   IMPORTANT. TO AVOID GRADING SURPRISES:
 *   1. Use the dlc compiler to check that your solutions conform
 *      to the coding rules.
 *   2. Use btest to verify that your solutions produce the correct answers.
 */


#endif
/* 
 * setEveryFourthBitTo1 - return the word with every fourth bit (starting from the LSB) set to 1.
 *   Legal ops: ! ~ & ^ | + << >>
 *   Max ops: 8
 *   Rating: 1
 */
int setEveryFourthBitTo1(void) {
  return 0x88;
}

/* 
 * anyOddBitIs1 - return 1 if any odd-numbered bit in x set to 1,
 *   and return 0 otherwise.
 *   Examples anyOddBitIs1(0x5) = 0, anyOddBitIs1(0x7) = 1
 *   Note that LSB is numbered at bit 0, which is even.
 *   Legal ops: ! ~ & ^ | + << >>
 *   Max ops: 12
 *   Rating: 2
 */
int anyOddBitIs1(int x) {
  return 2;
}
/* 
 * everyEvenBitIs0 - return 1 if every even-numbered bit in x is set to 0, and
 *   return 0 otherwise.
 *   Examples everyEvenBitIs0(0xAAAAAAAA) = 1, everyEvenBitIs0(0xAAAAAAAF) = 0
 *   Legal ops: ! ~ & ^ | + << >>
 *   Max ops: 12
 *   Rating: 2
 */
int everyEvenBitIs0(int x) {
  return 2;
}
/* 
 * replaceByteN(x,n,c) - replace byte numbered n in x with byte c.
 *   Bytes numbered from 0 (LSB) to 3 (MSB).
 *   Examples: replaceByteN(0x12345678,1,0xab) = 0x1234ab78
 *   You can assume 0 <= n <= 3 and 0 <= c <= 255
 *   Legal ops: ! ~ & ^ | + << >>
 *   Max ops: 10
 *   Rating: 3
 */
int replaceByteN(int x, int n, int c) {
  return 2;
}
/*
 * countBits - return the number of 1's in x.
 *   Examples: countBits(5) = 2, countBits(7) = 3
 *   Legal ops: ! ~ & ^ | + << >>
 *   Max ops: 40
 *   Rating: 4
 */
int countBits(int x) {
  return 2;
}
/* 
 * logicalNot - compute !x without using the ! operator.
 *   Examples: logicalNot(3) = 0, logicalNot(0) = 1
 *   Legal ops: ~ & ^ | + << >>
 *   Max ops: 12
 *   Rating: 4 
 */
int logicalNot(int x) {
  return 2;
}
/*
 * isTMax - return 1 if x is the maximum, two's complement number,
 *     and 0 return otherwise. 
 *   Legal ops: ! ~ & ^ | +
 *   Max ops: 10
 *   Rating: 1
 */
int isTMax(int x) {
  return 2;
}
/* 
 * fitsInShort - return 1 if x can be represented as a 16-bit, 
 *   two's complement integer, and return 0 otherwise.
 *   Examples: fitsInShort(33000) = 0, fitsInShort(-32768) = 1
 *   Legal ops: ! ~ & ^ | + << >>
 *   Max ops: 8
 *   Rating: 1
 */
int fitsInShort(int x) {
  return 2;
}
/* 
 * determineSign - return 1 if x is positive, 0 if x is zero, 
 *  and -1 if x is negative.
 *  Examples: determineSign(130) = 1
 *            determineSign(-23) = -1
 *  Legal ops: ! ~ & ^ | + << >>
 *  Max ops: 10
 *  Rating: 2
 */
int determineSign(int x) {
  return 2;
}
/*
 * multiplyByThreeEighths - multiply by 3/8 rounding toward 0, which 
 *   should exactly duplicate effect of C expression (x*3/8),
 *   including overflow behavior.
 *   Examples: multiplyByThreeEighths(77) = 28
 *             multiplyByThreeEighths(-22) = -8
 *             multiplyByThreeEighths(1073741824) = -134217728 (overflow)
 *   Legal ops: ! ~ & ^ | + << >>
 *   Max ops: 12
 *   Rating: 3
 */
int multiplyByThreeEighths(int x) {
  return 2;
}
/*
 * isPowerOfTwo - return 1 if x is a power of 2, and return 0 otherwise.
 *   Examples: isPower2(5) = 0, isPower2(8) = 1, isPower2(0) = 0
 *   Note that no negative number is a power of 2.
 *   Legal ops: ! ~ & ^ | + << >>
 *   Max ops: 20
 *   Rating: 4
 */
int isPowerOfTwo(int x) {
  return 2;
}
/* 
 * floatIsInfinity - return 1 if floating-point argument f is infinity
 *   (positive or negative), and return 0 otherwise.
 *   The argument uf is passed as an unsigned int, but it is to be 
 *   interpreted as the bit-level representation of a single-precision 
 *   floating-point value.
 *   Legal ops: any integer/unsigned operations incl. ||, &&. also if, while
 *   Max ops: 8
 *   Rating: 1
 */
unsigned floatIsInfinity(unsigned uf) {
  return 2;
}
/* 
 * floatIsNaN - return 1 if floating-point argument f is NaN, and
 *   return 0 otherwise.
 *   The argument uf is passed as an unsigned int, but it is to be 
 *   interpreted as the bit-level representation of a single-precision 
 *   floating-point value.
 *   Legal ops: any integer/unsigned operations incl. ||, &&. also if, while
 *   Max ops: 8
 *   Rating: 1
 */
unsigned floatIsNaN(unsigned uf) {
  return 2;
}
/* 
 * floatAbsoluteValue - return bit-level equivalent of absolute value of f for
 *   floating point argument f.
 *   Both the argument and result are passed as unsigned int's, but
 *   they are to be interpreted as the bit-level representations of
 *   single-precision floating point values.
 *   When argument is NaN, return argument.
 *   Legal ops: any integer/unsigned operations incl. ||, &&. also if, while
 *   Max ops: 10
 *   Rating: 2
 */
unsigned floatAbsoluteValue(unsigned uf) {
  return 2;
}
/* 
 * floatNegate - return bit-level equivalent of expression -f for
 *   floating point argument f.
 *   Both the argument and result are passed as unsigned int's, but
 *   they are to be interpreted as the bit-level representations of
 *   single-precision floating point values.
 *   When argument is NaN, return argument.
 *   Legal ops: any integer/unsigned operations incl. ||, &&. also if, while
 *   Max ops: 10
 *   Rating: 2
 */
unsigned floatNegate(unsigned uf) {
  return 2;
}
/* 
 * floatMultiplyByTwo - return bit-level equivalent of expression 2*f for
 *   floating point argument f.
 *   Both the argument and result are passed as unsigned int's, but
 *   they are to be interpreted as the bit-level representation of
 *   single-precision floating point values.
 *   When argument is NaN, return argument
 *   Legal ops: any integer/unsigned operations incl. ||, &&. also if, while
 *   Max ops: 30
 *   Rating: 4
 */
unsigned floatMultiplyByTwo(unsigned uf) {
  return 2;
}
/* 
 * floatToInteger - return bit-level equivalent of expression (int) f
 *   for floating point argument f.
 *   Argument is passed as unsigned int, but
 *   it is to be interpreted as the bit-level representation of a
 *   single-precision floating point value.
 *   Anything out of range (including NaN and infinity) should return
 *   0x80000000u.
 *   Legal ops: any integer/unsigned operations incl. ||, &&. also if, while
 *   Max ops: 30
 *   Rating: 4
 */
int floatToInteger(unsigned uf) {
  return 2;
}
