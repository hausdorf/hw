from __future__ import division
from itertools import combinations
import re
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
  print fi, k, len(shingles)

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

def q1Out():
  filenames = ['D1.txt', 'D2.txt', 'D3.txt', 'D4.txt']
  ks = [(5, splChar), (8, splChar), (4, splWord)]

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



def minHash(n):
  print [float('inf') for i in range(n)]


if __name__ == '__main__':
  q1Out()
  #minHash(10)
