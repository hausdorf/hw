# staticInferenceModule.py
# ------------------------
# Licensing Information: Please do not distribute or publish solutions to this
# project. You are free to use and extend these projects for educational
# purposes. The Pacman AI projects were developed at UC Berkeley, primarily by
# John DeNero (denero@cs.berkeley.edu) and Dan Klein (klein@cs.berkeley.edu).
# For more info, see http://inst.eecs.berkeley.edu/~cs188/sp09/pacman.html

from util import *
import util
import random
import ghostbusters

class StaticInferenceModule:
  """
  A static inference module must compute two quantities, conditioned on provided observations:
  
    -- The posterior distribution over ghost locations.  This will be a distribution over tuples of
       where the ghosts are.  If there is only one ghost, this distribution will be over the
       (singleton tuples of) the board locations.  If there are two ghosts, this distribution will
       assign a probability to each pair of locations, and so on.  Since the ghosts are interchangeable,
       the probability for, say, ((0,1), (3,2)) will be the same as that for ((3,2), (0,1)).
       
    -- The posterior distribution over the readings at a location, given the existing readings.  Be
       careful that your computation does the right thing when the 'new' location is actually in the
       existing observations, at which point the posterior should put probability one of the known
       reading.

  This is an abstract class, which you should not modify.
  """
  
  def __init__(self, game):
    """
    Inference modules know what game they are reasoning about.
    """
    self.game = game
  
  def getGhostTupleDistributionGivenObservations(self, observations):
    """
    Compute the distribution over ghost tuples, given the evidence.
    
    Note that the observations are given as a dictionary.
    """
    util.raiseNotDefined()
    
  def getReadingDistributionGivenObservations(self, observations, newLocation):
    """
    Compute the distribution over readings for the new location, given the
    current observations (given as a dictionary).
    """
    util.raiseNotDefined()

class ExactStaticInferenceModule(StaticInferenceModule):
  """
  You will implement an exact inference module for the static ghostbusters game.
  
  See the abstract 'StaticInferenceModule' class for descriptions of the methods.
  
  The current implementation below is broken, returning all uniform distributions.
  """
  
  def getGhostTupleDistributionGivenObservations(self, observations):
    """
    Here is some help...
      self.game.getGhostTuples() will give you a list of ghost tuples
      self.game.getInitialDistribution() will give you a distribution over
        ghost tuples; namely if you say p = s.g.gID() and t is tuple from
        getGhostTuples, then p[t] will be its probability
      self.game.getReadingDistributionGivenGhostTuple(t,s) will give you
        a distribution over readings (red, green, etc.) for the ghost tuple
        t and sensor location s

    What you want to do is create a Counter() that you will return.  If this
    counter is called dist, then dist[t] should be the probability of a
    ghost at tuple t (where t is from getGhostTuples) given the observations.
    """
    
    #print observations
    #print ''
    "*** YOUR CODE HERE ***"
    possibleGhostTuples = self.game.getGhostTuples()
    initial = self.game.getInitialDistribution()
    #print initial
    #print ''
    
    dist = initial.copy()
    
    for observedLoc in observations.keys():
        observedReading = observations[observedLoc]
        #print observedLoc
        for possibleGhostTuple in possibleGhostTuples:
            #print possibleGhostTuple
            readingDist = self.game.getReadingDistributionGivenGhostTuple(possibleGhostTuple, observedLoc)
            #print readingDist
            dist[possibleGhostTuple] = dist[possibleGhostTuple]*readingDist[observedReading]
        #print ''
    
    #print ''
    
    dist.normalize()
    #print dist
    
    return dist



  def getReadingDistributionGivenObservations(self, observations, newLocation):
    """
    For this part, you want to return a counter dist, so that 
    dist[r] is the probability of reading r (from ghostbusters.Readings.getReadings)
    given the observations and the proposed new location.

    You'll probably want to use getReadingDistributionGivenGhostTuple (as before),
    your own getGhostTupleDistributionGivenObservations to compute these probabilities.
    To iterate over relevant things, there's ghostbusters.Readings.getReadings() to
    look at all possible readings.
    """

    "*** YOUR CODE HERE ***"
    ghDist = self.getGhostTupleDistributionGivenObservations(observations)
    readings = ghostbusters.Readings.getReadings()
    possGhostTups = self.game.getGhostTuples()
    dist = Counter()

    probGh = ghDist[(newLocation,)]

    # We want to evaluate P(R_{i,j} | {r}), the probability of sensing
    # some reading given previous observations. Thus, we look at every
    # observation and evaluate this probability
    for r in readings:
      for loc in possGhostTups:
        readDist = self.game.getReadingDistributionGivenGhostTuple(loc, newLocation)
        dist[r] += readDist[r] * ghDist[loc]

    dist.normalize()

    return dist
