# multiAgents.py
# --------------
# Licensing Information:  You are free to use or extend these projects for 
# educational purposes provided that (1) you do not distribute or publish 
# solutions, (2) you retain this notice, and (3) you provide clear 
# attribution to UC Berkeley, including a link to 
# http://inst.eecs.berkeley.edu/~cs188/pacman/pacman.html
# 
# Attribution Information: The Pacman AI projects were developed at UC Berkeley.
# The core projects and autograders were primarily created by John DeNero 
# (denero@cs.berkeley.edu) and Dan Klein (klein@cs.berkeley.edu).
# Student side autograding was added by Brad Miller, Nick Hay, and 
# Pieter Abbeel (pabbeel@cs.berkeley.edu).


from util import manhattanDistance
from game import Directions
import random, util

from game import Agent

# new imported module
import math
import datetime

class ReflexAgent(Agent):
    """
      A reflex agent chooses an action at each choice point by examining
      its alternatives via a state evaluation function.

      The code below is provided as a guide.  You are welcome to change
      it in any way you see fit, so long as you don't touch our method
      headers.
    """


    def getAction(self, gameState):
        """
        You do not need to change this method, but you're welcome to.

        getAction chooses among the best options according to the evaluation function.

        Just like in the previous project, getAction takes a GameState and returns
        some Directions.X for some X in the set {North, South, West, East, Stop}
        """
        # Collect legal moves and successor states
        legalMoves = gameState.getLegalActions()

        # Choose one of the best actions
        scores = [self.evaluationFunction(gameState, action) for action in legalMoves]
        bestScore = max(scores)
        bestIndices = [index for index in range(len(scores)) if scores[index] == bestScore]
        chosenIndex = random.choice(bestIndices) # Pick randomly among the best

        "Add more of your code here if you want to"

        return legalMoves[chosenIndex]

    def evaluationFunction(self, currentGameState, action):
        """
        Design a better evaluation function here.

        The evaluation function takes in the current and proposed successor
        GameStates (pacman.py) and returns a number, where higher numbers are better.

        The code below extracts some useful information from the state, like the
        remaining food (newFood) and Pacman position after moving (newPos).
        newScaredTimes holds the number of moves that each ghost will remain
        scared because of Pacman having eaten a power pellet.

        Print out these variables to see what you're getting, then combine them
        to create a masterful evaluation function.
        """
        # Useful information you can extract from a GameState (pacman.py)
        successorGameState = currentGameState.generatePacmanSuccessor(action)
        newPos = successorGameState.getPacmanPosition()
        newFood = successorGameState.getFood()
        newGhostStates = successorGameState.getGhostStates()
        newScaredTimes = [ghostState.scaredTimer for ghostState in newGhostStates]

        "*** YOUR CODE HERE ***"
        # get the closest food distance as food score
        # .asList() in game.py
        if successorGameState.isWin():
            return float("inf")
        foods = newFood.asList()
        food_dist = []
        for f in foods:
            food_dist.append(util.manhattanDistance(newPos, f))
        food_dist.sort()
        food_score = food_dist[0]
        # # method1: consider active and scared_ghost
        # # get closest ghosts position  as ghost score
        # scared_ghost = []
        # active_ghost = []
        # scared_ghost_dist = []
        # active_ghost_dist = []
        # for ghost in successorGameState.getGhostStates():
        #     if ghost.scaredTimer > 0:
        #         scared_ghost.append(ghost)
        #         scared_ghost_dist.append(util.manhattanDistance(newPos, ghost.getPosition()))
        #     else:
        #         active_ghost.append(ghost)
        #         active_ghost_dist.append(util.manhattanDistance(newPos, ghost.getPosition()))
        # if scared_ghost_dist is not None:
        #     scared_ghost_dist.sort()
        # active_ghost_dist.sort()
        # if active_ghost_dist != []:
        #     ghost_score = active_ghost_dist[0]
        # else:
        #     ghost_score = 999
        # if scared_ghost_dist != []:
        #     scared_ghost_score = scared_ghost_dist[0]
        # # print(scared_ghost_dist)
        #
        # # total score
        # score = successorGameState.getScore()
        # # return -inf if collision occurs.
        # if ghost_score is 0: return -float("inf")
        # else:
        #     if scared_ghost_dist != []:
        #         score += float(ghost_score) - float(food_score) + 4 * float(scared_ghost_score)
        #     else:
        #         score += float(ghost_score) - float(food_score)

        # # method2: only consider ghost without scaring
        ghosts_dist = []
        for g in successorGameState.getGhostPositions():
            ghosts_dist.append(util.manhattanDistance(newPos, g))
        ghosts_dist.sort()
        ghost_score = ghosts_dist[0]
        # total score
        score = successorGameState.getScore()
        # return -inf if collision occurs.
        if ghost_score is 0: return -float("inf")
        else:
             score += float(ghost_score) - float(food_score)

        # deduct 5 if stop
        if action == Directions.STOP:
            score -= 5
        # print(score)
        # print(ghost_score)
        # print(food_score)
        # print("=====")
        return score
        # return successorGameState.getScore()

def scoreEvaluationFunction(currentGameState):
    """
      This default evaluation function just returns the score of the state.
      The score is the same one displayed in the Pacman GUI.

      This evaluation function is meant for use with adversarial search agents
      (not reflex agents).
    """
    return currentGameState.getScore()

class MultiAgentSearchAgent(Agent):
    """
      This class provides some common elements to all of your
      multi-agent searchers.  Any methods defined here will be available
      to the MinimaxPacmanAgent, AlphaBetaPacmanAgent & ExpectimaxPacmanAgent.

      You *do not* need to make any changes here, but you can if you want to
      add functionality to all your adversarial search agents.  Please do not
      remove anything, however.

      Note: this is an abstract class: one that should not be instantiated.  It's
      only partially specified, and designed to be extended.  Agent (game.py)
      is another abstract class.
    """

    def __init__(self, evalFn = 'scoreEvaluationFunction', depth = '2'):
        self.index = 0 # Pacman is always agent index 0
        self.evaluationFunction = util.lookup(evalFn, globals())
        self.depth = int(depth)

class MinimaxAgent(MultiAgentSearchAgent):
    """
      Your minimax agent (question 2)
    """
    count_expanded_nodes = 1
    def getAction(self, gameState):
        """
          Returns the minimax action from the current gameState using self.depth
          and self.evaluationFunction.

          Here are some method calls that might be useful when implementing minimax.

          gameState.getLegalActions(agentIndex):
            Returns a list of legal actions for an agent
            agentIndex=0 means Pacman, ghosts are >= 1

          gameState.generateSuccessor(agentIndex, action):
            Returns the successor game state after an agent takes an action

          gameState.getNumAgents():
            Returns the total number of agents in the game
        """
        "*** YOUR CODE HERE ***"
        #  define several nested methods below

        def random_act():
            """
            The nested method that choose randomly for different directions
            """
            seed = int(math.ceil(4 * random.random()))
            if seed is 0: return Directions.NORTH
            if seed is 1: return Directions.SOUTH
            if seed is 2: return Directions.EAST
            if seed is 3: return Directions.WEST

        # run minimax algorithm
        def minimax(game_state, best_act):
            """
            The nested method:
            running minimax algorithm starting from pacman decision as max root node
            """
            # get action from pacman
            pacman_legal_actions = game_state.getLegalActions(0)
            pacman_legal_actions.remove(Directions.STOP)
            score = 0 - float("inf")
            # for pacman's each potential steps:
            for potential_act in pacman_legal_actions:
                # cout the expanded nodes when expanded node behavior occurs
                self.count_expanded_nodes += 1
                successor_state = game_state.generateSuccessor(0, potential_act)
                temp = score
                score = minimax_helper(successor_state, self.depth, 1)
                if score > temp:
                    best_act = potential_act
            return best_act

         # minimax core
        def minimax_helper(state, d, agent):
            """
            nested method:
            worked as minimax core's helper to do recursion:
            three cases:
            1)ghost 1 - n -1, do min search in children ghost;
            2) ghost n, do min search in children pacman;
            3) pacman, do max search in chilren ghost 1.
            :return the score after each decision for parents' node's decision.
            """
            # base case
            if base_case(state, d):
                return utility(state)
            # get potential actin start from agent (begin at ghost 1)
            actions = state.getLegalActions(agent)
            # mini-agent: min layers by layers:
            if 0 < agent < gameState.getNumAgents() - 1:
                minimax_score = float("inf")
                for act in actions:
                    self.count_expanded_nodes += 1
                    next_state = state.generateSuccessor(agent, act)
                    # same layer recursion(d is same)
                    minimax_score = min(minimax_score, minimax_helper(next_state, d, agent + 1))
                return minimax_score
            # last mini agent:
            if agent == gameState.getNumAgents() - 1:
                minimax_score = float("inf")
                for act in actions:
                    self.count_expanded_nodes += 1
                    next_state = state.generateSuccessor(agent, act)
                    # layer will decrease because the min search will turn to max search
                    minimax_score = min(minimax_score, minimax_helper(next_state, d - 1, 0))
                return minimax_score
            # max agent - pacman
            if agent == 0:
                actions.remove(Directions.STOP)
                max_score = 0 - float("inf")
                for act in actions:
                    self.count_expanded_nodes += 1
                    next_state = state.generateSuccessor(0, act)
                    # layer will decrease because the max search will turn to min search
                    max_score = max(max_score, minimax_helper(next_state, d - 1, 1))
                return max_score

        def base_case(state, depth):
            """
            nested method.
            determine the base case in recursion for minimax algorithm
            :return true if depth is 0 or game is win or lose; otherwise return False
            """
            if (depth is 0) or (state.isWin()) or (state.isLose()):
                return True
            else:
                return False

        def utility(state):
            """
            :return the utility Function for game
            """
            return self.evaluationFunction(state)

        # set default final_action is randomly some action
        final_act = random_act()
        final_act = minimax(gameState, final_act)
        # print(self.count_expanded_nodes)
        print("Number of expanded node for each move: {nodes}".format(nodes=self.count_expanded_nodes))
        self.count_expanded_nodes = 1
        return final_act
        # util.raiseNotDefined()

class AlphaBetaAgent(MultiAgentSearchAgent):
    """
      Your minimax agent with alpha-beta pruning (question 3)
    """
    count_expanded_nodes = 1

    def getAction(self, gameState):
        """
          Returns the minimax action using self.depth and self.evaluationFunction
        """
        "*** YOUR CODE HERE ***"

        #  define several nested methods below
        def random_act():
            """
            The nested method that choose randomly for different directions
            """
            seed = int(math.ceil(4 * random.random()))
            if seed is 0: return Directions.NORTH
            if seed is 1: return Directions.SOUTH
            if seed is 2: return Directions.EAST
            if seed is 3: return Directions.WEST

        # run minimax algorithm with alpha-belta pruning
        def minimax(game_state, best_act):
            """
            The nested method:
            running minimax algorithm with alpha-belta pruning
            starting from pacman decision as max root node
            """
            # get action from pacman
            pacman_legal_actions = game_state.getLegalActions(0)
            pacman_legal_actions.remove(Directions.STOP)
            score = 0 - float("inf")
            # alpha = -inf; belta = inf as initialization state
            alpha = 0 - float("inf")
            belta = float("inf")
            # for pacman's each potential steps:
            for potential_act in pacman_legal_actions:
                self.count_expanded_nodes += 1
                successor_state = game_state.generateSuccessor(0, potential_act)
                temp = score
                score = minimax_helper(successor_state, self.depth, 1, alpha, belta)
                if score > temp:
                    best_act = potential_act
                # belta pruning:
                # compare alpha an children score
                # if chilren score larger than belta, prune the tree and return the action directly
                alpha = max(score, alpha)
                if belta <= score:
                    return best_act
            return best_act

        # minimax core with alpha-belta pruning
        def minimax_helper(state, d, agent, alpha, belta):
            """
            nested method:
            worked as minimax with alpha-belta pruning core's helper to do recursion:
            three cases:
            1)ghost 1 - n -1, do min search in children ghost;
            2) ghost n, do min search in children pacman;
            3) pacman, do max search in chilren ghost 1.
            at end of scanning each chilren node, use alpha-belta to determine pruning the tree or not
            :return the score after each decision for parents' node's decision.
            """
            # base case
            if base_case(state, d):
                return utility(state)
            # get potential actin start from agent (begin at ghost 1)
            actions = state.getLegalActions(agent)
            # mini-agent: min layers by layers:
            if 0 < agent < gameState.getNumAgents() - 1:
                minimax_score = float("inf")
                for act in actions:
                    self.count_expanded_nodes += 1
                    next_state = state.generateSuccessor(agent, act)
                    minimax_score = min(minimax_score, minimax_helper(next_state, d, agent + 1, alpha, belta))
                # alpha pruning:
                # compare belta and an children score
                # if chilren score smaller than alpha, prune tree and return the chilren score directly
                    belta = min(minimax_score, belta)
                    if minimax_score <= alpha:
                        return minimax_score
                return belta
            # last mini agent:
            if agent == gameState.getNumAgents() - 1:
                minimax_score = float("inf")
                for act in actions:
                    self.count_expanded_nodes += 1
                    next_state = state.generateSuccessor(agent, act)
                    minimax_score = min(minimax_score, minimax_helper(next_state, d - 1, 0, alpha, belta))
                # alpha pruning:
                # compare belta and an children score
                # if chilren score smaller than alpha, prune tree and return the chilren score directly
                    belta = min(minimax_score, belta)
                    if minimax_score <= alpha:
                        return minimax_score
                return belta
            # max agent - pacman
            if agent == 0:
                actions.remove(Directions.STOP)
                max_score = 0 - float("inf")
                for act in actions:
                    self.count_expanded_nodes += 1
                    next_state = state.generateSuccessor(0, act)
                    max_score = max(max_score, minimax_helper(next_state, d - 1, 1, alpha, belta))
                # belta pruning:
                # compare alpha an children score
                # if chilren score larger than belta, prune tree and return the chilren score directly
                    alpha = max(max_score, alpha)
                    if belta <= max_score:
                        return max_score
                return alpha

        def base_case(state, depth):
            """
            nested method.
            determine the base case in recursion for minimax algorithm
            :return true if depth is 0 or game is win or lose; otherwise return False
            """
            if (depth is 0) or (state.isWin()) or (state.isLose()):
                return True
            else:
                return False

        def utility(state):
            """
            :return the utility Function for game
            """
            return self.evaluationFunction(state)

        # set default final_action is randomly some action
        final_act = random_act()
        # start timer for each action timing counting.
        start = datetime.datetime.now()
        final_act = minimax(gameState, final_act)
        end = datetime.datetime.now()
        time_cost = (end - start).total_seconds() * 1000
        print("Time for each move: {nodes} milliseconds".format(nodes=time_cost))
        # print(self.count_expanded_nodes)
        # count the number of expanded node in each action; reset to 1 at end of each action
        print("Number of expanded node for each move: {nodes}".format(nodes=self.count_expanded_nodes))
        self.count_expanded_nodes = 1
        return final_act
        # util.raiseNotDefined()

class ExpectimaxAgent(MultiAgentSearchAgent):
    """
      Your expectimax agent (question 4)
    """

    def getAction(self, gameState):
        """
          Returns the expectimax action using self.depth and self.evaluationFunction

          All ghosts should be modeled as choosing uniformly at random from their
          legal moves.
        """
        "*** YOUR CODE HERE ***"
        util.raiseNotDefined()

def betterEvaluationFunction(currentGameState):
    """
      Your extreme ghost-hunting, pellet-nabbing, food-gobbling, unstoppable
      evaluation function (question 5).

      DESCRIPTION: <write something here so we know what you did>
    """
    "*** YOUR CODE HERE ***"
    util.raiseNotDefined()

# Abbreviation
better = betterEvaluationFunction

class ContestAgent(MultiAgentSearchAgent):
    """
      Your agent for the mini-contest
    """

    def getAction(self, gameState):
        """
          Returns an action.  You can use any method you want and search to any depth you want.
          Just remember that the mini-contest is timed, so you have to trade off speed and computation.

          Ghosts don't behave randomly anymore, but they aren't perfect either -- they'll usually
          just make a beeline straight towards Pacman (or away from him if they're scared!)
        """
        "*** YOUR CODE HERE ***"
        util.raiseNotDefined()

