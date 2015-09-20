__author__ = 'weiliangxing'
"""
The board.py module is the module that contains all necessary functions to play peg solitaire
In Class Board, three search strategies are implemented:
1) Iterative Deepening Search(IDS)
2) A* with three kinds of different heuristics.
This module read "test.txt" as input test cases, which includes at least three different test cases;
This module write to "result.txt" as the homework report, which includes:
1) a trace of the execution for each search strategy
2) the number of nodes expanded;
3) memory usage
4) running time
The module is developed by Weiliang Xing alone for class cse 537 Artificial Intelligence
The module is the solution for Homework 1, which due to Fe.28. .
The Student ID is 108211104.
The spread of the source code without author's agreement is not allowed.
The author is not responsible for any spread of the source code without the permission.
"""
import datetime
import resource
from copy import deepcopy
from heapq import *


class Board:
    # default_string is used as default input when lacking inputs.
    default_string = ["--OOO--", "--OXO--", "OOXXXOO", "OOOXOOO", "OOOXOOO", "--OOO--", "--OOO--"]

    def __init__(self, input_str=default_string):
        """
        Class Board is developed to solve Peg solitaire problem
        Attributes:
        self.input_str: the input raw data
        self.node: a 7 * 7 two dimensional list representing peg holder status as node
        self.dic: dictionary to associate location in node to index for each peg holder
        self.count_expanded_nodes: number of expanded node when implementing search strategy
        self.count_filled_peg: number of filled peg; used to detect goal state
        self.stack: the stack to store successful tracing solution
        self.expanded: the stack to store expanded nodes
        self.heap: the priority queue using heap to realize A* algorithms
        self.relation_tuple: the tuple storing parent-child relationship; used for A* algorithms
        """
        self.input_str = input_str
        self.node = [[0 for x in range(7)] for x in range(7)]
        self.dic = {}
        self.count_expanded_nodes = 1
        self.count_filled_peg = 0
        self.stack = []
        self.expanded = []
        self.heap = []
        self.relation_tuple = []
        self.config()

    def config(self):
        """
        used to do configuration for the input string
        """
        # convert input string to input integer
        #  '-' to 2; 'O' to 0; 'X' to 1
        for i in range(7):
            for j in range(7):
                if self.input_str[i][j] == '-':
                    self.node[i][j] = 2
                elif self.input_str[i][j] == 'O':
                    self.node[i][j] = 0
                else:
                    self.node[i][j] = 1
                    self.count_filled_peg += 1
        # build self.dic: each coordinate in nodes is used as key with one integer as its value
        self.dic = {(0, 2): 0, (0, 3): 1, (0, 4): 2, (1, 2): 3, (1, 3): 4, (1, 4): 5, (5, 2): 27,
                    (5, 3): 28, (5, 4): 29, (6, 2): 30, (6, 3): 31, (6, 4): 32}
        loc = 0
        for i in range(2, 5):
            for j in range(7):
                self.dic[(i, j)] = 6 + loc
                loc += 1

    def succ(self, node):
        """
        :param node: the input node as the parent
        :return: yields all possible child nodes followed by the game rules
        """

        for i in range(7):
            for j in range(7):
                if node[i][j] == 1:
                    #  jump from top to down
                    if i % 7 <= 4 and node[i+1][j] == 1 and node[i+2][j] == 0:
                        # print("jump_down")
                        # print(self.get_update(node, i, j, (1, 2), (0, 0)))
                        yield self.get_update(node, i, j, (1, 2), (0, 0))
                    #  jump from down to top
                    if i % 7 >= 2 and node[i-1][j] == 1 and node[i-2][j] == 0:
                        # print("jump_up")
                        # print(self.get_update(node, i, j, (-1, -2), (0, 0)))
                        yield self.get_update(node, i, j, (-1, -2), (0, 0))
                    # jump from left to right
                    if j % 7 <= 4 and node[i][j+1] == 1 and node[i][j+2] == 0:
                        # print("jump_right")
                        # print(self.get_update(node, i, j, (0, 0), (1, 2)))
                        yield self.get_update(node, i, j, (0, 0), (1, 2))
                    # jump from right to left
                    if j % 7 >= 2 and node[i][j-1] == 1 and node[i][j-2] == 0:
                        # print("jump_left")
                        # print(self.get_update(node, i, j, (0, 0), (-1, -2)))
                        yield self.get_update(node, i, j, (0, 0), (-1, -2))

    def get_update(self, node, i=0, j=0, delta_i=(0, 0), delta_j=(0, 0)):
        """
        :param node: the parent node
        :param i: the row number where the child node resident
        :param j: the column number where the child node resident
        :param delta_i: offset of the row associate with i
        :param delta_j: offset of the column associate with j
        :return: updated node(child node) after finishing the jump action
        """
        update_node = deepcopy(node)
        update_node[i][j] = 0
        update_node[i+delta_i[0]][j+delta_j[0]] = 0
        update_node[i+delta_i[1]][j+delta_j[1]] = 1
        orgin = self.dic[(i, j)]
        dest = self.dic[(i+delta_i[1], j+delta_j[1])]
        if update_node not in self.expanded:
            self.count_expanded_nodes += 1
        return update_node, (orgin, dest)

    def count_nodes(self, node):
        """
        The function is heuristics for A* algorithm.
        :param node: the target node input
        :return: the number of children nodes of the target node available for next layer.
        The more number is, the higher priority will be.to keep consistent with other heuristics, the number is negated.
        """
        num = 0
        for childTuple in self.succ(node):
            child = childTuple[0]
            if child is None:
                continue
            num += 1
        num = -num
        return num


    def count_isolates(self, node):
        """
        The function is heuristics for A* algorithm
        :param node: the target node input
        :return: the number of isolated pegs in the target node; the less number is, the higher priority will be.
        """
        num = 0
        for i in range(7):
            for j in range(7):
                if node[i][j] == 1:
                    if i % 7 <= 4 and (node[i+1][j] == 1 or node[i+2][j] == 1):
                        continue
                    if j % 7 <= 4 and (node[i][j+1] == 1 or node[i][j+2] == 1):
                        continue
                    if i % 7 >= 2 and (node[i-1][j] == 1 or node[i-2][j] == 1):
                        continue
                    if j % 7 >= 2 and (node[i][j-1] == 1 or node[i][j-2] == 1):
                        continue
                    num += 1
        return num

    def sum_distance(self, node):
        """
        The function is heuristics for A* algorithm
        :param node: the target node input
        :return: the sum of distances from the center to each filled peg hole; the less number is,
        the higher priority will be.
        """
        sum_dis = 0
        for i in range(7):
            for j in range(7):
                if node[i][j] == 1:
                    sum_dis += (i-3)**2 + (j-3)**2
        return sum_dis

    def heuristic(self, node, option=1):
        """
        The function gathers all kinds of heuristics in this class to act as the single interface
        :param node: the target node input
        :param option: the choice to different heuristic methods;
        option = 1: choose function count_nodes
        option = 2: choose function count_isolates
        option = 3: choose function sum_distance
        :return: the score for the target node; the lower score is, the higher priority will be
        """
        if option is 1:
            return self.count_nodes(node)
        if option is 2:
            return self.count_isolates(node)
        if option is 3:
            return self.sum_distance(node)

    def order(self, node, option=1):
        """
        The function set orders for children nodes of the target node based on heuristics and
        store the ordered children nodes tuple into the heap. Also the relation tuple is also build for
        solution tracing.
        :param node: the target node
        :param option: the option for different heuristics
        :return: None
        """
        for childTuple in self.succ(node):
            child = childTuple[0]
            if child is None:
                continue
            if child not in self.expanded:
                self.expanded.append(child)
            heappush(self.heap, (self.heuristic(child, option), childTuple))
            self.relation_tuple.append((childTuple, node))

    def a_star(self, node, option=1):
        """
        The function runs the A* algorithm
        :param node:the target node
        :param option: the option for different heuristics
        :return: None
        """
        self.order(node, option)
        final_node = node
        success_flag = False

        # do priority queue for each incoming child root, ordered by heuristics.
        while self.heap:
            prior_node = heappop(self.heap)
            if Board.goal(prior_node[1][0]):
                final_node = prior_node[1][0]
                success_flag = True
                break
            self.order(prior_node[1][0], option)

        #  backtracking the successful trace
        while success_flag:
            if final_node == node:
                break
            for relation in self.relation_tuple:
                if relation[0][0] == final_node:
                    final_node = relation[1]
                    self.stack.append(relation[0][1])
                    break
        self.stack.reverse()

    @staticmethod
    def goal(node):
        """
        The function determine whether the goal state has been reached
        :param node: the target node
        :return: True if the node is the goal node; False otherwise
        """
        filled_peg = 0
        if node is None:
            return None
        for i in range(7):
            for j in range(7):
                if node[i][j] == 1:
                    filled_peg += 1
        if node[3][3] == 1 and filled_peg == 1:
            return True
        else:
            return False

    def ids(self, node):
        """
        The function use ids algorithm to find the solution
        :param node: the target node; always it is the root node
        :return: None
        """
        # i is the iterative depth for each recursion
        i = 1
        while not Board.goal(node):
            if node is None:
                node = self.node
            node = self.ids_helper(node, i)
            i += 1
        # reverse stack to get the correct trace for successful result
        self.stack.reverse()

    def ids_helper(self, node, depth):
        """
        The helper function for ids algorithm, doing recursion for each depth
        :param node: the target node
        :param depth: integer represents the depth; root is defined to have highest depth(depth), while
        leaf is defined to have lowest depth(0)
        :return: return the node for each recursion; return null if no path is found
        """
        if depth >= 0:
            for childTuple in self.succ(node):
                child = childTuple[0]
                if child is None:
                    continue
                # print("Current Depth: {d}\nCurrent Node:".format(d=depth))
                # for i in range(7):
                #     print(child[i])
                if child not in self.expanded:
                    self.expanded.append(child)
                if Board.goal(child):
                    self.stack.append(childTuple[1])
                    return child
                if depth == 0:
                    continue
                result = self.ids_helper(child, depth-1)
                # print("Current Depth : -1\nCurrent Node:")
                if result:
                    self.stack.append(childTuple[1])
                    # for i in range(7):
                    #     print(result[i])
                    return result
                else:
                    # print(result)
                    continue
        return None

    def run_alg(self, node, option):
        """
        The function to be used as only interface to run algorithms
        :param node: the root node
        :param option: integers indicate different algorithm;
        option = 0: ids; option = 1; A* heuristic 1; option = 2: A* heuristic 2; option = 3: A* heuristic 3;
        :return: None
        """
        if option is 0:
            self.ids(node)
        if option is 1:
            self.a_star(node, option)
        if option is 2:
            self.a_star(node, option)
        if option is 3:
            self.a_star(node, option)

    def write_file(self, f, memory_usage, time_cost, option):
        """
        The function to write the results into the file to generate the report
        :param f: the file object
        :param memory_usage: the integer indicating memory usage for programming running
        :param time_cost: the float indicating time cost.
        :param option: options to choose different algorithm
        :return: None
        """
        if option is 0:
            f.write("\nIDS: \n")
            f.write("The Solution: {solution} \n".format(solution=self.stack))
            f.write("Number of expanded node: {nodes}\n".format(nodes=self.count_expanded_nodes))
            f.write("Memory usage: {memory} kb\n".format(memory=memory_usage))
            f.write("Running Time: {time} milliseconds\n".format(time=time_cost))
        if option is 1:
            f.write("\nA*: \n")
            f.write("The heuristic is： The number of nodes are available for the next step \n")
            f.write("The Solution: {solution} \n".format(solution=self.stack))
            f.write("Number of expanded node: {nodes}\n".format(nodes=self.count_expanded_nodes))
            f.write("Memory usage: {memory} kb\n".format(memory=memory_usage))
            f.write("Running Time: {time} milliseconds\n".format(time=time_cost))
        if option is 2:
            f.write("\nA*: \n")
            f.write("The heuristic is： Number of isolated peg's \n")
            f.write("The Solution: {solution} \n".format(solution=self.stack))
            f.write("Number of expanded node: {nodes}\n".format(nodes=self.count_expanded_nodes))
            f.write("Memory usage: {memory} kb\n".format(memory=memory_usage))
            f.write("Running Time: {time} milliseconds\n".format(time=time_cost))
        if option is 3:
            f.write("\nA*: \n")
            f.write("The heuristic is： the sum of distances from the center \n")
            f.write("The Solution: {solution} \n".format(solution=self.stack))
            f.write("Number of expanded node: {nodes}\n".format(nodes=self.count_expanded_nodes))
            f.write("Memory usage: {memory} kb\n".format(memory=memory_usage))
            f.write("Running Time: {time} milliseconds\n".format(time=time_cost))

def main():
    """
    Main function to open "test.txt" as input by parsing each line;
    and run all algorithms for each data set and write the results to file "result.txt" for report
    :return: None
    """
    test_case = open('test.txt', 'r')
    f = open('result.txt', 'r+')
    for line in test_case.readlines():
        case = line.split(" ")
        f.write("\nOriginal Case: \n")
        f.write(str(case))
        f.write("\nConverted Case: \n")
        f.write(str(Board(case).node))
        n = 0
        while n <= 3:
            start = datetime.datetime.now()
            run_case = Board(case)
            run_case.run_alg(run_case.node, n)
            end = datetime.datetime.now()
            memory_usage = resource.getrusage(resource.RUSAGE_SELF).ru_maxrss
            time_cost = (end - start).total_seconds() * 1000
            run_case.write_file(f, memory_usage, time_cost, n)
            n += 1
    test_case.close()
    f.close()


if __name__ == "__main__": main()