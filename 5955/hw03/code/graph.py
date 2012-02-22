from __future__ import division, with_statement
from matplotlib.pyplot import plot, show, axis, xlabel, ylabel, legend
import random,sys

ps = [i / 100 for i in range(0,100,1)]
factrs = [(10,10), (1,100), (5,20), (2, 50), (25, 4)]


def sCurve(r, b):
  return map(lambda p: 1-(1-p**r)**b, ps)


if __name__ == '__main__':
  ylist = []

  for fact1,fact2 in factrs:
    ys = sCurve(fact1, fact2)
    ylist.append(ys)
    plot(ps, ys, label='r=%d, b=%d' % (fact1, fact2))
    ys = sCurve(fact2, fact1)
    ylist.append(ys)
    plot(ps, ys, label='r=%d, b=%d' % (fact2, fact1))


  xlabel("value of s")
  ylabel("y = 1 - (1-s**r)**b")
  legend()
  show()


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
