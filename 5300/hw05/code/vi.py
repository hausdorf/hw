# Policy iteration algorithm experiments


from __future__ import division
from random import random
from itertools import takewhile


theta = 100
gamma = 1
states = ['1', '2', '3']
reward = {'1': -1, '2': -2, '3': 0}
actions = ['a', 'b']
V = {'1':0, '2':0, '3':0}
P = {'1': {'a': (['1', '2'], [0.2, 0.8]), 'b': (['1', '3'], [0.9, 0.1])},
    '2': {'a': (['1', '2'], [0.8, 0.2]), 'b': (['2', '3'], [0.9, 0.1])},
    '3': {}}


def choice(choices, dist):
  r = random()

  # Build our CDF
  cdf = []
  for i in range(len(dist)):
    cdf.append(dist[i] + sum(dist[:i]))

  # error if CDF malformed/not addint to 1
  if int(cdf[-1]) != 1 or len(choices) != len(dist):
    raise 'CDF in choice() not equal to 1!'

  idx = len([t for t in takewhile(lambda x: x <= r, cdf)])
  if idx < 0:
    return 0
  else:
    return idx

def trans(state, act):
  if state == '1':
    if act == 'a':
      return choice(['1', '2'], [0.2, 0.8])
    elif act == 'b':
      return choice(['1', '3'], [0.9, 0.1])
  if state == '2':
    if act == 'a':
      return choice(['1', '2'], [0.8, 0.2])
    elif act == 'b':
      return choice(['2', '3'], [0.9, 0.1])

def vhelper(choices, probs):
  return sum([pssprime * (reward[sprime] + gamma * V[sprime])
    for sprime,pssprime in zip(choices, probs)])


def polev(pol):
  print 'POLEV'
  while True:
    delta = 0
    for s in states:
      if s == '3':
        continue

      v = V[s]
      Ps = P[s][pol[s]]

      V[s] = sum([pssprime * (reward[sprime] + gamma * V[sprime])
          for sprime,pssprime in zip(Ps[0], Ps[1])])
      print s, V[s], v

      delta = max(delta, abs(v - V[s]))
      #print delta

    if delta < theta:
      print delta
      break

def polimp(pol):
  print 'POL', pol
  print

  while True:
    print 'POLIMP'
    policy_stable = True
    for s in states:
      if s == '3':
        continue

      b = pol[s]

      actVals = [(vhelper(P[s][a][0], P[s][a][1]), a) for a in actions]
      pol[s] = max(actVals)[1]
      print actVals, b, pol[s]

      if b != pol[s]:
        policy_stable = False

    if policy_stable:
      return pol
    else:
      polev(pol)


def utility(stateVect):
  for s in stateVect:
    return


def _TEST_choice():
  N = 100000
  test = [0]*5
  count = [0]*5

  for i in range(N):
    idx = choice(test, [.1, .1, .1, .2, .5])
    count[idx] += 1

  print map(lambda x: x/N, count)


if __name__ == '__main__':
  #_TEST_choice()
  policy = {'1': 'b', '2': 'b'}
  print polimp(policy)
  print
  print

  policy = {'1': 'a', '2': 'a'}
  print polimp(policy)
