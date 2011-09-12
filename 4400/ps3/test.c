int accum = 0;

int foo(int *ptr, int a, short b, char c)
{
	*ptr += a >> c;
	return -*ptr & b;
}
