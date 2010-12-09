###
# PROBLEM 1
###

# PROBLEM 1a
#
# This will be biased, and it will be too low, generally.
# The reason is that we are constantly estimating the total
# based on the highest number we've found, yet, we will
# likely not have found the highest number unless we sample
# a LOT of iPeds.

# PROBLEM 1b
estimate.max = function()
{
	estimateOfN = matrix(, 10000)
	for(i in 1:10000)
	{
		sampling = matrix(sample(1:1000, 50, replace=F), 1, 50)
		maxs = apply(sampling, 1, FUN=max)
		#print(maxs)
		estimateOfN[i] <- maxs
	}
	estimateOfN
}
estimate = estimate.max()
hist(estimate)

# PROBLEM 1c
paste("1(c) Average of max estimates: ", apply(estimate, 2, FUN=mean))

# PROBLEM 1d
estimate.custom = function()
{
	estimateOfN = matrix(, 10000)
	for(i in 1:10000)
	{
		sampling = matrix(sample(1:1000, 50, replace=F), 1, 50)
		maxs = apply(sampling, 1, FUN=max)
		estimateOfN[i] <- (51/50) * maxs[1] - 1
	}
	estimateOfN
}
estimate = estimate.custom()
hist(estimate)

# PROBLEM 1e
#
# E[N^] = (k+1)/k*E[M_k] - 1


# PROBLEM 1f
paste("1(f) Average of custom function: ", apply(estimate, 2, FUN=mean))

###
# PROBLEM 2
###

# PROBLEM 2a
upper = mean(morley$Speed) + (qt(1-0.5*0.05, 99))*(sqrt(var(morley$Speed))/sqrt(100))
lower = mean(morley$Speed) - (qt(1-0.5*0.05, 99))*(sqrt(var(morley$Speed))/sqrt(100))
paste("2(a) Lower: ", lower, " Upper: ", upper)

# PROBLEM 2b
#
# No, not all the experiments are in this interval.

# PROBLEM 2c
#
# The speed of light is not in this interval.

# PROBLEM 2d
#
# An estimator is used to estimate an unknown parameter in some statistical model.
# It is not an absolute indicator of the empirical phenomena they are supposed to
# model, because it cannot be independent of the experimental constraints that
# bind it.

###
# PROBLEM 3
###

# PROBLEM 3a
my.regression = function(x, y)
{
	slope = (length(x)*sum(x*y) - sum(x)*sum(y))/(length(x)*sum(x^2) - (sum(x))^2)
	intercept = mean(y) - slope*mean(x)
	c(slope, intercept)
}

# Plot old faithful scatter, calculate line, and plot against it
plot(eruptions ~ waiting, data=faithful)
line = my.regression(faithful$waiting, faithful$eruptions)
abline(line[2], line[1])

# PROBLEM 3b
#
# Around 4 minutes.

# PROBLEM 3c
#
# Run and see for yourself that it works:
faithful.model= lm(eruptions ~ waiting, data=faithful)
print("lm results: ")
print(faithful.model$coefficients)
paste("my coefficient: ", line[2], " my intercept: ", line[1])

