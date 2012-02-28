alpha = 0.6
gamma = 0.9
actions = ['slow', 'fast']
states = ['cool', 'warm', 'off']

Q = {('cool', 'slow'):0, ('cool', 'fast'):0, ('warm', 'slow'):0,
    ('warm', 'fast'):0}  # table of action values
Nsa = {k:v for k,v in Q.iteritems()}  # Counts
s = None  # prev state
a = None  # prev action
r = None  # prev reward


def f(u, n):
  if n < Ne:
    return Rplus
  else:
    return u


def qlearn(sp, rp):
  global s
  global a
  global r

  if terminal(s):
    Q[(s, None)] = rp


  if s != None:
    Nsa[(s, None)] += 1
    mx = max([Q[(sp, ap)] - Q[(s, a)] for ap in actions])
    setVal = Q[(s, a)] + alpha * (Nsa[(s,a)]) * (r + gamma * mx)
    print setVal
    Q[(s, a)] = setVal

  amx = max([(f(Q[(sp, sp)], Nsa[(sp, ap)]), ap) for ap in actions])[1]
  s, a, r = sp, , rp

  return


if __name__ == '__main__':
  qlearn()
