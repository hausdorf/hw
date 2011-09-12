#include <stdio.h>
#include <limits.h>

/* Convert from floating point number to bit-level representation */
unsigned f2u(float f) {
	union {
		unsigned u;
		float f;
	} a;
	a.f = f;
	return a.u;
}

int doit(unsigned x)
{
	int a, b, c, d;

	a = 0xFF << 23;
	b = ~0x0 << 22;
	c = !!(a & x);
	d = !!(b & x);
	printf("%x\n", c);
	printf("x %f x %x a %x  b %x c %x c&d %x\n", x, x, a, b, c, c & d);

	return b;
}

int main()
{
	float s = -1.0;
	//doit(0.0);
	//doit(1.0);
	//doit(s);
	doit(f2u(0x7F800000));
	doit(f2u(8388608));
	doit(f2u(1.0/(1.0-1.0)));
}
