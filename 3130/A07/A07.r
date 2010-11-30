# Assignment 07
# ALEX CLEMMER U0458675

print("Alex Clemmer u0458675")

n = 20
k = 10000
t = seq(-9, 81, 0.01)

###########
# PROBLEM 1
###########

# PROBLEM 1 PART (a): Over a large distribution, we will have a
# normal distribution, and the expected value will be the median (0).
# The variance will be the square of the each individual variance
# divided by n.

# PROBLEM 1 (b): See the pdf and code below. The sample mean
# and variance should be around 0 and 1/sqrt(k), respectively.
# This turns out to be a pretty good approximation.

# Find the average mean of 10 elements, and repeat 100 times
rnorm.ave = function()
{
	x = matrix(rnorm(100000), 10000, 10)
	m = apply(x, MARGIN=1, FUN=mean)
}

# Plot the average means
hist(rnorm.ave(), freq=FALSE, main="Average of Means of rnorm")
lines(t, dnorm(t, 0, 1/sqrt(10)), col='red')

# PROBLEM 1 (c): The theoretical distribution is a Chi-Square.
# The variance is 18/9 (or 2k/k) and the mean is 9/9 (or k/k).

# PROBLEM 1 (d): See plot in pdf and code below. The mean and
# variance are pretty straightforward: they are k and 2k,
# respectively (or 9 and 18)

# Find the average variance
rnorm.var = function()
{
	x = matrix(rnorm(100000), 10000, 10)
	m = apply(x, MARGIN=1, FUN=var)
}

# Plot the average variance
hist(rnorm.var(), freq=FALSE, main="Average of Variances of rnorm")
lines((1/9)*t, 9*dchisq(t, 9), col='blue')

# PROBLEM 1 (e):

paste("Problem 1e -- P(\bar{x}_{10} < -0.5): ", pnorm(-0.5, 0, 1/sqrt(10)))

# PROBLEM 1 (f):

p = rnorm.ave()
t = 0
for(i in p)
{
	if(i < -.5)
	{
		t = t + 1
	}
}
t = t/10000
paste("Problem 1f -- Probability via the statistics: ", t)

###########
# PROBLEM 2
###########

# PROBLEM 2 (a): See code below. This distribution is
# clearly not symmetric.

# "Collect" minimums
runif.min = function()
{
	x = matrix(runif(30000), 10000, 3)
	#print(x)
	m = apply(x, MARGIN=1, FUN=min)
	#print(m)
}

# Plot the minimums
hist(runif.min(), freq=FALSE, main="Mins of runif(3)")

# PROBLEM 2 (b): 

paste("Problem 2b -- Mean of runif.min(): ", mean(runif.min()))
paste("Problem 2b -- Variance of runif.min(): ", var(runif.min()))

# PROBLEM 2 (c): 

r = runif.min()
z = 0
for(i in r)
{
	if(i > 0.6)
	{
		z = z+1
	}
}
z = z/10000
paste("Problem 2c -- P(min > .6)", z)

###########
# PROBLEM 3
###########

###########
# PROBLEM 3 (a): Clearly the first one had the largest IQR, with
# somewhere around 1080-720 being the range of Q3 to Q1.
###########

boxplot(Speed ~ Expt, morley, xlab = "Experiment No.", ylab = "Speed of light")

###########
# PROBLEM 3 (b): #3 clearly had the most outliers.
###########

###########
# PROBLEM 3 (c): They are inaccurate. But the more times the experiment
# is repeated, the closer you get to the real number.
###########

###########
# PROBLEM 3 (d):
###########

paste("Problem 3d -- Mean of morley speeds: ", mean(morley$Speed))
paste("Problem 3d -- Variance of morley speeds: ", var(morley$Speed))

###########
# PROBLEM 3 (e):
###########

p = matrix(morley$Speed, 20, 5)
q = apply(p, MARGIN=2, FUN=mean)
#print(p)
print("Problem 3e -- Mean of each individual morley Expt: ")
#print(q)
paste("Problem 3e -- Mean of all means of the morley Expts: ", mean(q))
paste("Problem 3e -- Variance of all means of the morley Expts: ", var(q))

###########
# PROBLEM 3 (f): The variance should be proportionally reduced,
# as what we're left with is a set of 5 means, which excluding
# the one outlier, are pretty close together.
###########

###########
# PROBLEM 3 (g): The variance does match the theoretical variance:
###########

# Clearly experiment 5 is the outlier.
boxplot(q, ylab="Speed indicated by experiment")

# Remove #5 and re-plot
q = q[-(1)]
boxplot(q, ylab="Speed indicated by experiment without first expt")

# for variances:
p = matrix(morley$Speed, 20, 5)
q = apply(p, MARGIN=2, FUN=var)
boxplot(q, ylab="variance in speed")
q = q[-(1)]
boxplot(q, ylab="variance in speed without first expt")
