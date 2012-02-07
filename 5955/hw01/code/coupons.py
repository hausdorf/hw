from __future__ import division, with_statement
from matplotlib.pyplot import plot, show, axis, xlabel, ylabel, hist, grid, title, text
from collections import defaultdict
import random


def rand_gener(domain):
	#random.seed(3)

	while True:
		yield random.randint(0,domain)

def gener_until_full(domain):
	seen = defaultdict(lambda:0)

	c = 0
	for i in rand_gener(domain):
		if len(seen) == domain + 1:
			return seen
		else:
			seen[i] += 1
		c += 1

def expt_n_times(n, domain):
	def proc_list(d):
		hst = []
		for k,v in d.items():
			hst += [k]*v
		return hst

	return [proc_list(gener_until_full(domain)) for i in range(n)]

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
	times_repeat = 300
	domain = 10000
	fulls = expt_n_times(times_repeat, domain)
	ks = [len(e) for e in fulls]

	"""
	#print fulls
	print ks

	print 'E[X]:', sum(ks) / times_repeat

	srtd_ks = sorted(ks)
	l = len(srtd_ks)
	ys = [find_gt_n(srtd_ks, c, e) / l
			for c,e in iter_cnt(srtd_ks)]

	plot(srtd_ks, ys)
	title('Cumulative density of required k trials', fontsize=20)
	xlabel('value of k', fontsize=16)
	ylabel('% of experiments succeeding after k trials', fontsize=16)
	grid()
	show()
	"""

	"""
	hist(fulls[0], domain+1, facecolor='g', alpha=0.75)
	title('Number of times a random number has had value of i', fontsize=20)
	xlabel('the value of i', fontsize=16)
	ylabel('# of times random number has had value', fontsize=16)
	grid()
	show()
	"""


