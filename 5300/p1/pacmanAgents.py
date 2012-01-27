from pacman import Directions
from game import Agent
import random
import game
import util

class LeftHandAgent:
  def getAction(self, state):
    legal = state.getLegalPacmanActions()
    candidate = state.getPacmanState().configuration.direction
    if candidate == Directions.STOP: candidate = Directions.NORTH
    if legal == []: raise 'No legal moves for Pacman'
    while candidate not in legal:
      candidate = Directions.LEFT[candidate]
    return candidate
  
def asList(grid):
  cells = []
  for y in range(grid.height):
    for x in range(grid.width):
      if grid[x][y]:
        cells.append((x,y))
  return cells

def scoreEvaluation(state):
  return state.getScore()

class DistanceCalculator:
  def __init__(self, layout, default = 10000):
    print "PRECALCULATING...",
    self._distances = {}
    self.default = default
    self.calculateDistances(layout)
    print "DONE."

  def getDistanceOnGrid(self, pos1, pos2):
    key = (pos1, pos2)
    if key in self._distances:
      return self._distances[key]
    return self.default
  
  def isInt(self, pos):
    x, y = pos
    return x == int(x) and y == int(y)
  
  def getDistance(self, pos1, pos2):
    if self.isInt(pos1) and self.isInt(pos2):
      return self.getDistanceOnGrid(pos1, pos2)
    pos1Grids = self.getGrids2D(pos1)
    pos2Grids = self.getGrids2D(pos2)
    bestDistance = self.default
    for pos1Snap, snap1Distance in pos1Grids:
      for pos2Snap, snap2Distance in pos2Grids:
        gridDistance = self.getDistanceOnGrid(pos1Snap, pos2Snap)
        distance = gridDistance + snap1Distance + snap2Distance
        if bestDistance > distance:
          bestDistance = distance
    return bestDistance
          
  def getGrids2D(self, pos):
    grids = []
    for x, xDistance in self.getGrids1D(pos[0]):
      for y, yDistance in self.getGrids1D(pos[1]):
        grids.append(((x, y), xDistance + yDistance))
    return grids
  
  def getGrids1D(self, x):
    intX = int(x)
    if x == int(x):
      return [(x, 0)]
    return [(intX, x-intX), (intX+1, intX+1-x)]
  
  def manhattanDistance(self, x, y ):
    return abs( x[0] - y[0] ) + abs( x[1] - y[1] )

  def calculateDistances(self, layout):
    allNodes = asList(layout.walls)
    remainingNodes = allNodes[:]
    for node in allNodes:
      self._distances[(node, node)] = 0.0
      for otherNode in allNodes:
        if self.manhattanDistance(node, otherNode) == 1.0:
          self._distances[(node, otherNode)] = 1.0
    while len(remainingNodes) > 0:
      node = remainingNodes.pop()
      for node1 in allNodes:
        dist1 = self.getDistanceOnGrid(node1, node)
        for node2 in allNodes:
          oldDist = self.getDistanceOnGrid(node1, node2)
          if dist1 > oldDist:
            continue
          dist2 = self.getDistanceOnGrid(node2, node)
          newDist = dist1 + dist2
          if newDist < oldDist:
            self._distances[(node1, node2)] = newDist
            self._distances[(node2, node1)] = newDist
    
class GreedyAgent(Agent):
  def __init__(self, evaluationFunction=scoreEvaluation):
    self.evaluationFunction = evaluationFunction
    
  def setEvaluation(self, fn):
    self.evaluationFunction = fn
    
  def getAction(self, state):
    # Generate candidate actions
    actions = state.getLegalPacmanActions()
    if Directions.STOP in actions:
      actions.remove(Directions.STOP)
      
    # Find the ones that look the best in the very short term
    maxScore = -10000000
    attainers = []
    for action in actions:
      score = state.generatePacmanSuccessor(action).getScore()
      if score > maxScore:
        maxScore = score
        attainers = [action]
      elif score == maxScore:
        attainers.append(action)
        
    # Return the greedy action, breaking ties if necessary
    if len(attainers) == 1: return attainers[0]
    else: return self.breakTies(attainers, state)
  
  def breakTies(self, attainers, state):
    last = state.getPacmanState().configuration.direction
    if last in attainers:
      return last
    else:
      return random.choice(attainers)
    