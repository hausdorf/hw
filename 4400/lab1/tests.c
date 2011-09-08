/* Testing Code */

#include <limits.h>
#include <math.h>

/* Routines used by floation point test code */

/* Convert from bit level representation to floating point number */
float u2f(unsigned u) {
  union {
    unsigned u;
    float f;
  } a;
  a.u = u;
  return a.f;
}

/* Convert from floating point number to bit-level representation */
unsigned f2u(float f) {
  union {
    unsigned u;
    float f;
  } a;
  a.f = f;
  return a.u;
}

int test_setEveryFourthBitTo1(void) {
 return 0x88888888;
}
int test_anyOddBitIs1(int x) {
    int i;
    for (i = 1; i < 32; i+=2)
        if (x & (1<<i))
      return 1;
    return 0;
}
int test_everyEvenBitIs0(int x) {
  int i;
  for (i = 0; i < 32; i+=2)
    if ((x & (1<<i)) != 0)
      return 0;
  return 1;
}
int test_replaceByteN(int x, int n, int c)
{
    switch(n) {
    case 0:
      x = (x & 0xFFFFFF00) | c;
      break;
    case 1:
      x = (x & 0xFFFF00FF) | (c << 8);
      break;
    case 2:
      x = (x & 0xFF00FFFF) | (c << 16);
      break;
    default:
      x = (x & 0x00FFFFFF) | (c << 24);
      break;
    }
    return x;
}





int test_countBits(int x) {
  int result = 0;
  int i;
  for (i = 0; i < 32; i++)
    result += (x >> i) & 0x1;
  return result;
}
int test_logicalNot(int x)
{
  return !x;
}
int test_isTMax(int x) {
    return x == 0x7FFFFFFF;
}
int test_fitsInShort(int x)
{
  short int sx = (short int) x;
  return x == sx;
}
int test_determineSign(int x) {
    if ( !x ) return 0;
    return (x < 0) ? -1 : 1;
}
int test_multiplyByThreeEighths(int x)
{
  return (x*3)/8;
}
int test_isPowerOfTwo(int x) {
  int i;
  for (i = 0; i < 31; i++) {
    if (x == 1<<i)
      return 1;
  }
  return 0;
}
unsigned test_floatIsInfinity(unsigned uf) {
  float f = u2f(uf);
  return isinf(f);
}
unsigned test_floatIsNaN(unsigned uf) {
 float f = u2f(uf);
 return isnan(f);
}
unsigned test_floatAbsoluteValue(unsigned uf) {
  float f = u2f(uf);
  unsigned unf = f2u(-f);
  if (isnan(f))
    return uf;
  /* An unfortunate hack to get around a limitation of the BDD Checker */
  if ((int) uf < 0)
      return unf;
  else
      return uf;
}
unsigned test_floatNegate(unsigned uf) {
    float f = u2f(uf);
    float nf = -f;
    if (isnan(f))
 return uf;
    else
 return f2u(nf);
}
unsigned test_floatMultiplyByTwo(unsigned uf) {
  float f = u2f(uf);
  float tf = 2*f;
  if (isnan(f))
    return uf;
  else
    return f2u(tf);
}
int test_floatToInteger(unsigned uf) {
  float f = u2f(uf);
  int x = (int) f;
  return x;
}
