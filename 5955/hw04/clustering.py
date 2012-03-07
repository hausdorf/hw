from __future__ import with_statement, division
from itertools import product, combinations
from math import sqrt, log, cos, sin, pi
import math
from random import random, uniform, choice
from matplotlib.pyplot import hist, show

FILES = ['C1.txt', 'C2.txt']


def ptwiseSubtract(s1,s2):
  return (s1[0] - s2[0], s1[1] - s2[1])

def ptwiseAdd(s1,s2):
  return (s1[0] + s2[0], s1[1] + s2[1])

def singleLinkDist(S1, S2):
  """
  Defines distance between clusters as shortest distance between two points
  in the two clusters
  """

  dists = [(l2(ptwiseSubtract(s1,s2)), s1, s2) for s1,s2 in product(S1, S2)]
  dists.sort()
  return dists[0][0]

def completeLinkDist(S1, S2):
  """
  Defines distance between clusters as the longest distance between two
  two points in the two clusters.
  """

  dists = [(l2(ptwiseSubtract(s1,s2)), s1, s2) for s1,s2 in product(S1, S2)]
  dists.sort(reverse=True)
  return dists[0][0]

def avgLinkDist(S1, S2):
  cardS1 = len(S1)
  cardS2 = len(S2)

  normalizer = 1 / (cardS1 * cardS2)

  dists = [normalizer * l2(ptwiseSubtract(s1,s2))
      for s1,s2 in product(S1, S2)]

  return sum(dists)

def meanLinkDist(S1, S2):
  cardS1 = len(S1)
  cardS2 = len(S2)

  a_1 = reduce(lambda x,y: ptwiseAdd(x,y), S1)
  a_1 = (a_1[0] * (1 / cardS1), a_1[1] * (1 / cardS1))

  a_2 = reduce(lambda x,y: ptwiseAdd(x,y), S2)
  a_2 = (a_2[0] * (1 / cardS2), a_2[1] * (1 / cardS2))

  return l2(ptwiseSubtract(a_1, a_2))

def l2(a):
  """
  L2 norm based on 1 point
  """

  return sqrt(sum([d**2 for d in a]))

# L2 norm of two 2-d points a and b
def eucDist(a,b):
  """
  Euclidean distance between two points
  """

  rollingSum = 0
  for a_i,b_i in zip(a,b):
    rollingSum = rollingSum + (a_i - b_i)**2

  return sqrt(rollingSum)

def clustPairs(clustset):
  numClusts = len(clustset)
  for i in range(numClusts):
    for j in range(i + 1, numClusts):
      yield i,j, numClusts

def clustDist(distfunc, C1, C2):
  clust1Pts = map(lambda (label,pt): pt, C1)
  clust2Pts = map(lambda (label,pt): pt, C2)
  dist = distfunc(clust1Pts, clust2Pts)

  return dist

def aggCluster(distfunc, ptset, k):
  """
  The ptset is a list of points. We "agglomerate" until we have k clusters.
  """

  clustset = [[(key,val)] for key,val in ptset.items()]

  numClusts = len(clustset)
  while numClusts > k:
    minimum = (float('inf'), -1, -1)

    #for c1,c2 in combinations(clustset, 2):
    for i,j,length in clustPairs(clustset):
      #print i, j, numClusts
      c1 = clustset[i]
      c2 = clustset[j]

      dist = clustDist(distfunc, c1, c2)

      # If this pair of clusters is "closer", change the record
      if minimum[0] > dist:
        minimum = (dist, i, j)

      #print dist, i, j, c1, c2


    # When combining clusters, popping the element that comes first will
    # adjust the index of the second; we avoid by popping further one first
    if minimum[1] < minimum[2]:
      c2 = clustset.pop(minimum[2])
      c1 = clustset.pop(minimum[1])
    else:
      c1 = clustset.pop(minimum[1])
      c2 = clustset.pop(minimum[2])

    combined = c1 + c2

    clustset.append(combined)
    numClusts = len(clustset)

    #print 'min', numClusts, minimum

  return clustset

# Converts the files in FILES to list of points indexed by label
def inputFilesDict():
  for f in FILES:
    pts = {}
    with open(f) as read:
      for line in read.readlines():
        tup = line.strip().split()
        pts[tup[0]] = (float(tup[1]), float(tup[2]))

    yield pts

def inputFilesList():
  for f in FILES:
    pts = []
    with open(f) as read:
      for line in read.readlines():
        tup = line.strip().split()
        pts.append((tup[0],(float(tup[1]), float(tup[2]))))

    yield pts

def printClust(clusters):
  for clust in clusters:
    print 'CLUST'
    for pt in sorted(clust):
      print pt


def q1(ptdicts):
  #print
  #print 'SLC'
  # Single-link clustering
  slc = aggCluster(singleLinkDist, ptdicts[0], 3)

  #print
  #print 'CLC'
  # Complete-link clustering
  clc = aggCluster(completeLinkDist, ptdicts[0], 3)

  #print
  #print 'ALC'
  # Avg-link clustering
  alc = aggCluster(avgLinkDist, ptdicts[0], 3)

  #print
  #print 'MLC'
  # Mean-link clustering
  mlc = aggCluster(meanLinkDist, ptdicts[0], 3)

  return slc,clc,alc,mlc



def minmax(pointset, k):
  c_i = [('a', pointset['a'])]

  for i in range(1,k):
    maxPt = (float('-inf'),)

  print c1
  return

def kmeanspp(pointlist, k, u):
  points = map(lambda (label,pt): pt, pointlist)
  labels = map(lambda (label,pt): label, pointlist)

  c_i = [points[0]]

  for i in range(1, k):
    wps = {}
    for label,pt in pointlist:
      wp = [(eucDist(pt, c)**2, label) for c in c_i]
      wp.sort(reverse=True)
      wps[label] = wp[0][0]

    W = sum([v for k,v in wps.items()])
    v = u[i-1] * W
    sumW = 0
    for i in range(len(pointlist)):
      label,pt = pointlist[i]
      sumW += wps[label]

      if sumW >= v:
        break

    sumW2 = sum([wps[labels[j]] for j in range(i + 1, len(pointlist))])
    print sumW, sumW2

  return

def q2(ptdicts, ptlists):
  #minmax(ptdicts[1], 3)
  kmeanspp(ptlists[1], 3, [0.35, 0.6])
  return


def gaussian(u1, u2):
  y1 = sqrt(-2 * log(u1)) * cos(2 * pi * u2)
  y2 = sqrt(-2 * log(u1)) * sin(2 * pi * u2)

  return y1, y2

def generGaussNorms(n, dim, p):
  # Generate some n points of `dim` dimensions
  pts = []
  for i in range(n):
    pts.append(tuple([gaussian(random(),random())[0] for d in range(dim)]))

  lps = map(lambda x: norm(x, p), pts)

  return lps

def histPts(ptlist, n, d, p):
  import matplotlib.pyplot as plt
  import numpy as np

  """
  x = []
  for i in range(10000):
    x.append(gaussian(random(), random())[0])
  """

  hist,bins=np.histogram(ptlist,bins=50)

  width=0.7*(bins[1]-bins[0])
  center=(bins[:-1]+bins[1:])/2
  plt.bar(center,hist,align='center',width=width)
  plt.title("L%d norm of %d points with d=%d" % (p, n, d), fontsize=18)
  plt.xlabel('norms of vectors')
  plt.ylabel('frequency of a particular norm')
  plt.show()

def generUniNorms(n, dim, p, ys):
  # Generate some n points of `dim` dimensions
  pts = []
  for i in range(n):
    pts.append([uniform(ys[0], ys[1]) for d in range(dim)])

  lps = map(lambda x: norm(x, p), pts)

  return lps

def infnorm(x):
  abss = map(abs, x)
  return max(abss)

def generInfUniNorms(n, dim, p, ys):
  # Generate some n points of `dim` dimensions
  pts = []
  for i in range(n):
    pts.append([uniform(ys[0], ys[1]) for d in range(dim)])

  lps = map(lambda x: infnorm(x), pts)

  return lps



def norm(a, p):
  return math.pow(sum([abs(d)**p for d in a]), 1.0/p)

def q3a():
  n = 10000
  ds = [1, 2, 3, 5, 10, 50]
  ps = [1, 2]

  for d in ds:
    for p in ps:
      lps = generGaussNorms(n, d, p)
      histPts(lps, n, d, p)

def q3b():
  n = 10000
  ys = [-1,1]
  ds = [1,2,3,5,10,50]
  ps = [0.5,1,2,3]  # DO NOT forget the infinity norm!

  i = 1

  print "I & D & P & pr \\\\"
  for d in ds:
    for p in ps:
      lps = generUniNorms(n, d, p, ys)
      lt1 = filter(lambda x: x < 1, lps)
      pr = len(lt1)/n

      print "%d & %d & %d & %f \\\\" % (i, d, p, pr)
      print "\hline"
      i += 1

    lps = generInfUniNorms(n, d, p, ys)
    lt1 = filter(lambda x: x < 1, lps)
    print "%d & %s & %0.1f & %f \\\\" % (i, 'inf', p, pr)
    print "\hline"
    i += 1

def plotClusts(clustsets):
  import matplotlib.pyplot as plt

  color = ['red','blue','yellow']

  x = []
  y = []
  fig = plt.figure()
  for clustset in clustsets:
    host = fig.add_subplot(111)
    for i in range(len(clustset)):
      print 'CLUST', i
      for label,pt in clustset[i]:
        print pt
        x.append(pt[0])
        y.append(pt[1])

        _ = host.scatter(x, y, color=color[i])
    plt.show()



if __name__ == '__main__':
  ptdicts = [ptdict for ptdict in inputFilesDict()]
  ptlists = [ptlist for ptlist in inputFilesList()]

  #slc,clc,alc,mlc = q1(ptdicts)
  #clusts = q1(ptdicts)
  #plotClusts(clusts)

  q2(ptdicts, ptlists)

  #q3a()
  #q3b()
