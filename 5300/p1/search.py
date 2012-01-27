"""
In search.py, you will implement generic search algorithms which are called 
by Pacman agents (in searchAgents.py).
"""

import util

class SearchProblem:
  """
  This class outlines the structure of a search problem, but doesn't implement
  any of the methods (in object-oriented terminology: an abstract class).
  
  You do not need to change anything in this class, ever.
  """
  
  def getStartState(self):
     """
     Returns the start state for the search problem 
     """
     util.raiseNotDefined()
    
  def isGoalState(self, state):
     """
       state: Search state
    
     Returns True if and only if the state is a valid goal state
     """
     util.raiseNotDefined()

  def getSuccessors(self, state):
     """
       state: Search state
     
     For a given state, this should return a list of triples, 
     (successor, action, stepCost), where 'successor' is a 
     successor to the current state, 'action' is the action
     required to get there, and 'stepCost' is the incremental 
     cost of expanding to that successor
     """
     util.raiseNotDefined()

  def getCostOfActions(self, actions):
     """
      actions: A list of actions to take
 
     This method returns the total cost of a particular sequence of actions.  The sequence must
     be composed of legal moves
     """
     util.raiseNotDefined()
           

def tinyMazeSearch(problem):
  """
  Returns a sequence of moves that solves tinyMaze.  For any other
  maze, the sequence of moves will be incorrect, so only use this for tinyMaze
  """
  from game import Directions
  s = Directions.SOUTH
  w = Directions.WEST
  return  [s,s,w,s,w,w,s,w]


### BEGIN OUR CODE ###

def solution(curr, sol):
  """
  Finds solution given current node and explored tree
  """
  from game import Directions

  movemap = {'South': Directions.SOUTH, 'West': Directions.WEST,
      'East': Directions.EAST, 'North': Directions.NORTH}

  moves = []
  parent = sol[curr]
  moves.insert(0, curr[1])
  while parent[1]:
    moves.insert(0, movemap[parent[1]])
    parent = sol[parent]

  return moves


def generic_search(problem, stype):
  # NOTE: Currently implements DFS by default
  """
  A generic search function that can be DFS, BFS, or A*
  """
  # TODO: REMOVE THIS LIBRARY
  import sys
  from util import Stack

  # If curr is goal state
  if problem.isGoalState(problem.getStartState()):
    return []

  # "Normal" case
  sol = []  # solution
  explored = set()
  parents = {}
  stack = Stack()
  stack.push((problem.getStartState(), None, None))
  parent = None
  # Not goal, parent is set appropriately, stack not empty
  while True:
    if stack.isEmpty():
      raise 'Stack empty'
    else:
      curr = stack.pop()

      if curr[0] in explored:
        continue
      explored.add(curr[0])

      for succ in problem.getSuccessors(curr[0]):
        if succ[0] not in explored:
          parents[succ] = curr
          if problem.isGoalState(succ[0]):
            return solution(succ, parents)
          stack.push(succ)


def depthFirstSearch(problem):
  """
  Search the deepest nodes in the search tree first [p 74].
  
  Your search algorithm needs to return a list of actions that reaches
  the goal.  Make sure to implement a graph search algorithm [Fig. 3.18].
  """
  return generic_search(problem, 'dfs')


def breadthFirstSearch(problem):
  "Search the shallowest nodes in the search tree first. [p 74]"
  "*** YOUR CODE HERE ***"
  util.raiseNotDefined()
      
def uniformCostSearch(problem):
  "Search the node of least total cost first. "
  "*** YOUR CODE HERE ***"
  util.raiseNotDefined()

def nullHeuristic(state, problem=None):
  """
  A heuristic function estimates the cost from the current state to the nearest
  goal in the provided SearchProblem.  This heuristic is trivial.
  """
  return 0

def aStarSearch(problem, heuristic=nullHeuristic):
  "Search the node that has the lowest combined cost and heuristic first."
  "*** YOUR CODE HERE ***"
  util.raiseNotDefined()
    
  
# Abbreviations
bfs = breadthFirstSearch
dfs = depthFirstSearch
astar = aStarSearch
ucs = uniformCostSearch


