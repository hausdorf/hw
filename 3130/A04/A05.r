### PROBLEM 1

# die.roll simulated the roll of a fair die n times.
die.roll = function(n)
{
	u = runif(n)
	
	x = integer(n)
	
	for(i in 0:n)
	{
		x[u<1] = 6
		x[u<(5/6)] = 5
		x[u<(4/6)] = 4
		x[u<(3/6)] = 3
		x[u<(2/6)] = 2
		x[u<(1/6)] = 1
	}
	
	return(x)
}

# die.sum will simulate a pair of dice rolls n times. If the total
# is the sum we are looking for, that gets tallied.
die.sum = function(repetitions, sum)
{
	tally = 0
	for(i in 1:repetitions)
	{
		x = die.roll(1)[1]
		y = die.roll(2)[1]
		total = x + y
		if(total == sum)
		{
			tally = tally + 1
		}
	}
	return(tally)
}

# ANSWER TO QUESTION: given 100,000 trials,
#print(die.sum(100000, 3))  # F(3) = 5523
#print(die.sum(100000, 4))  # F(4) = 8371
#print(die.sum(100000, 5))  # F(5) = 11,242
#print(die.sum(100000, 6))  # F(6) = 13,903



### PROBLEM 2

rpareto = function(n, alpha)
{
	x = integer(n)
	u = runif(n)
	
	for(i in 1:n)
	{
		x[i] = (alpha/u[i])^(1/(alpha+1))
	}
	
	return(x)
}


### PROBLEM 4

### PART A)
# spinner plays n games of the wheel game given your choice k.
# It first creates a random number for each game an puts it in
# a sequence called u. This represents your actual roll. Then
# it compares those numbers each in turn to the number that you
# picked, k.
#
# If you picked a number >= the number rolled, then you get that
# a number of points equal to the number you chose.
spinner = function(n,k)
{
	u = runif(n)
	
	x = integer(n)
	results = integer(n)

	for(i in 1:4)
	{
		x[u<1] = 4
		x[u<.9] = 3
		x[u<.65] = 2
		x[u<.4] = 1
	}

	for(i in 1:n)
	{
		if(x[i] < k)
		{
			results[i] = 0
		}
		else
		{
			results[i] = k
		}
	}

	return(results)
}

### PART B)
# expected.spinner finds the expected value for some k
# For example, if we pick 1, we should always get 1
# point, which means the expected value is 100,000.
# However, if we pick 2, we don't always get a point,
# so the expected value is different.'
expected.spinner = function(n, k)
{
	results = spinner(n,k)
	x = 0

	for(i in 1:n)
	{
		x = x + results[i]
	}
	
	return(x)
}

# ANSWER TO QUESTION: The optimal choice of k is 2. Observe:
#expected.spinner(100000, 1) # = 1e+05
#expected.spinner(100000, 2)  # = 120350
#expected.spinner(100000, 3)  # = 105396
#expected.spinner(100000, 4)  # = 39992

### PART C)
# X_{k} is probably best and most simply described with Bin(n, p), where
# n is the number of games you play, and p is the related probablity.
# For example, if k = 1 and you play 100,000 games, then Bin(100000, 1)
# prefectly describes the distribution. k = 3 similarly is Bin(100000,3),
# and so on.
#
# Ultimately, this works because each game is independent of all others,
# and the probablity of getting that particular score can be sharpened to
# exactly one probability for success (e.g., .25 for k = 3, and so on),
# and exactly one probability for failture (continuing the example of k = 3,
# the failure probability would be .75). This sort of phenomena, of course,
# is the particular talent of binomial distributions.

### PART D)
# spinner2 actually turns out to be nearly the same function as its
# predecessor. The only real difference is that we simulate a random
# pick, rather than using the user input.
spinner2 = function(n)
{
	u = runif(n)
	
	x = integer(n)
	
	k = runif(n)
	y = integer(n)
	results = integer(n)
	
	for(i in 1:4)
	{
		x[u<1] = 4
		x[u<.9] = 3
		x[u<.65] = 2
		x[u<.4] = 1
	}

	for(i in 1:4)
	{
		y[u<1] = 4
		y[u<.9] = 3
		y[u<.65] = 2
		y[u<.4] = 1
	}

	for(i in 1:n)
	{
		if(x[i] < y[i])
		{
			results[i] = 0
		}
		else
		{
			results[i] = y[i]
		}
	}
	
	return(results)
}

# Same as expected.spinner(), except this one calles spinner2
expected.spinner2 = function(n)
{
	results = spinner2(n)
	x = 0
	prob = 0

	for(i in 1:n)
	{
		if(results[i] == 1)
		{
			prob = 1
		}
		else if(results[i] == 2)
		{
			prob = .25
		}
		else if(results[i] == 3)
		{
			prob = .25
		}
		else
		{
			prob = .1
		}
		x = x + (results[i]*prob)
	}
	
	return(x)
}

# ANSWER TO QUESTION: It's better than always picking 1, but still not great.
# in particular, it's not better than always picking 2.
#expected.spinner2(100000)  # = 75258.95