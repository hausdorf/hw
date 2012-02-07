from __future__ import division, with_statement
from matplotlib.pyplot import plot, show, axis, xlabel, ylabel
import random


def rand_gener(domain):
	#random.seed(3)

	while True:
		yield random.randint(0,domain)

def gener_until_collision(domain):
	seen = set()

	c = 0
	for i in rand_gener(domain):
		if i in seen:
			return c
		else:
			seen.add(i)
		c += 1

def expt_n_times(n, domain):
	return [gener_until_collision(domain) for i in range(n)]

def iter_cnt(gen):
	i = 1
	for e in gen:
		yield i, e
		i += 1

def find_gt_n(list, s, n):
	for i,e in iter_cnt(list[s:]):
		if e > n:
			return i+s
	return s


if __name__ == '__main__':
	times_repeat = 10000
	domain = 1000000
	collisions = expt_n_times(times_repeat, domain)

	"""
	print 'E[X]:', sum(collisions) / times_repeat

	xs = [i for i in range(times_repeat)]

	srtd_collisions = sorted(collisions)
	l = len(srtd_collisions)
	ys = [find_gt_n(srtd_collisions, c, e) / l
			for c,e in iter_cnt(srtd_collisions)]

	plot(srtd_collisions, ys)
	xlabel('value of k')
	ylabel('% of experiments succeeding after k trials')
	show()
	"""
