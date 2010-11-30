x = matrix(rnorm(100), 10)
print(x)
m = apply(x, MARGIN=1, FUN=max)
print(m)
