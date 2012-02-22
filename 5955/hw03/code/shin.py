from __future__ import division
from itertools import combinations
from random import randint
import re, hashlib, random, string
import sys


def takeK(l, k):
  length = len(l)
  payload = []

  for i in range(length):
    if i + k > length:
      return payload
    else:
      payload.append(tuple(l[i:i+k]))

def shingle(fi, spl, k):
  f = open(fi)

  txt = [line for line in f.readlines()]
  tokens = sum(map(spl, txt), [])

  shingles = set(takeK(tokens, k))
  #print fi, k, len(shingles)

  f.close()
  return shingles

def splWord(x):
  return re.split(' ', x)

def splChar(x):
  return list(x)

def shingleDoc(fi, params):
  return [shingle(fi, spl, k) for k,spl in params]



def allShingles(finames, ks):
  return {k : shingleDoc(k, ks) for k in finames}

def q1Out(filenames, ks):
  docs = allShingles(filenames, ks)

  for c in combinations(filenames, 2):
    doc1 = docs[c[0]]
    doc2 = docs[c[1]]
    print c

    for i in range(len(ks)):

      intersect = doc1[i].intersection(doc2[i])
      union = doc1[i].union(doc2[i])
      #print len(union), len(intersect), len(intersect) / len(union)
      jacc = len(intersect) / len(union)

      print 'k: %d %f' % (ks[i][0], jacc)



def generHash(m):
  alph = randint(0, m)
  r = randint(0, m)
  seed = ''.join(random.choice(string.ascii_uppercase + string.digits) for x in range(5))
  #return lambda x: (alph * x + 1) % m
  #return lambda x: (alph * x + r) % m
  return lambda x: int(hashlib.md5(str(x) + seed).hexdigest(), 16) % m

def minHash(union, shings, ks, hashes, m):
  n = len(hashes)
  t = len(shings)

  vals = [[float('inf') for i in range(t)] for q in range(n)]

  for i in range(len(union)):
    item = union[i]

    for j in range(len(shings)):
      if item not in shings[j]:
        continue

      for k in range(len(hashes)):
        sig = vals[k][j]
        permuted = hashes[k](i)

        if sig > permuted:
          vals[k][j] = permuted

  return vals

def printAllmh(allmh):
  for vals in allmh:
    print 'T: ', len(vals)
    for row in vals:
      for e in row:
        print e, '\t',
      print
    print

def normL0(allmh, ndocs):
  key = [c for c in combinations([i for i in range(ndocs)], 2)]
  print 'KEY: ', map(lambda (x,y): (x+1, y+1), key)
  print

  for vals in allmh:
    norm = [0]*len(key)
    t = len(vals)
    print 'T: ', len(vals)
    for row in vals:
      ind = 0
      for doc1,doc2 in key:
        if row[doc1] == row[doc2]:
          norm[ind] += 1
        ind += 1
    norm = map(lambda x: x / t, norm)
    print norm

def s2MinHash(filenames, ks, ts, hashes, m):
  # Shingles of S2
  s2 = [allShingles(filenames, ks)[fn][1] for fn in filenames]

  # build union set
  union = set()
  for sh in s2:
    union = union.union(sh)
  union = list(union)


  allmh = [minHash(union, s2, ks, hashes[:t], m) for t in ts]
  printAllmh(allmh)
  #print len(allmh)

  normL0(allmh, len(filenames))



if __name__ == '__main__':
  m = 40127
  filenames = ['D1.txt', 'D2.txt', 'D3.txt', 'D4.txt']
  ks = [(5, splChar), (8, splChar), (4, splWord)]
  ts = [10, 50, 100, 300, 600]
  hashes = [generHash(m) for i in range(max(ts))]

  #q1Out(filenames, ks)
  s2MinHash(filenames, ks, ts, hashes, m)
