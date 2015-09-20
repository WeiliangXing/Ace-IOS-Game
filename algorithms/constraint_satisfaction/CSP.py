"""
    Constraint Satisfaction Problem Properties and methods
    
    To generalize a CSP will have the constraint graph:
        - Therefore it will have the list of variables.
        - And the list of contraints among those variables.
        
    * We also maintain an assignment mapping for variables
    * Member method isconsistent by definition is liable for maintaining all kind of constraints
        
    # variables and assignment
    Merging data attributes
        Course time
        Course recitations (TA has to attend if TA is assigned to the course)
        Course details
        Course skill requirements
        TA resp
        TA skill
    into
    * Course info
        day, time, recitation_time, number of students, skill requirements
    * TA  info
        skills, resp time
    
    Example output,
        Lauren Smith, CSE101, 0.5, CSE102, 0.5
        John Doe, CSE101, 0.5    
"""

# representation of value for the variable
class DomainValue:
    def __init__(self, class_index, ta_amount):
        self.class_index = class_index
        self.ta_amount = ta_amount

# We rank matches keeping only the courses that have ta_amount
# This class helps to rank by match of skills
class CourseIndexSkillMatch:
    def __init__(self, rank, index):
        self.rank = rank
        self.index = index

# representation of arc (X,Y) among variables, required for AC-3 Algorithm
class Arc:
    def __init__(self, x, y):
        self.x = x
        self.y = y

# Provides methods and properties to solve the CSP
class CSP:
    def __init__(self, var_list, course_list):
        # Variables are the members from ta_info list from DataModel class
        # assignment maps with Variables
        self.var_list = var_list
        self.course_list = course_list
        self.invalid_index = 999999
        self.var_size = len(var_list)
        # assignment dictionary will return value class
        # initially set them to null
        # Key is index
        # value is list of classes
        # replace assignment dictionary as list, list is more memory efficient than dictionary
        self.assignment = []
        self.domain_list = []
        self.remaining_ta = []
        self.class_ta_rank = []

    # Initialize objects that are used each time backtrack is called
    def backtrack_init(self):
        self.assignment = []
        for i in range(self.var_size):
            # self.assignment[i] = None
            self.assignment.append([])

        self.remaining_ta = []
        for i in range(len(self.course_list)):
            self.remaining_ta.append(self.course_list[i].num_ta)

        self.domain_list = []
        self.compute_variable_domains()

    # select a variable that is not assigned yet
    def select_unassigned_variable(self):
        # for key, value in self.assignment.items():
        for i in range(len(self.assignment)):
            item_list = self.assignment[i]
            if not item_list:
                return i;
        return self.invalid_index
        
    """ Assign variable
        if no object is assigned yet,
            create a list pushing class object created using provided value index/course_index
            assign the list to dictionary for the variable using variable_index
        Otherwise
            append value to the list
    """
    def assign(self, variable_index, value):
        self.remaining_ta[value.class_index] -= value.ta_amount
        # course_index = value.class_index
        if not self.assignment[variable_index]:
            value_list = []
            # value = DomainValue(course_index, self.course_list[course_index].num_ta)
            value_list.append(value)
            self.assignment[variable_index] = value_list
        else:
            value_list = self.assignment[variable_index]
            # value = DomainValue(course_index, self.course_list[course_index].num_ta)
            value_list.append(value)
            # probably not necessary
            self.assignment[variable_index] = value_list
            
    """ Remove (var, value) pair from assignment
        if there are multiple objects in the list remove the one requested to remove
        if there is single object set it to None
    """
    def unassign(self, variable_index, value):
        self.remaining_ta[value.class_index] += value.ta_amount
        if not self.assignment[variable_index]:
            print("invalid unassignment")
            return
        value_list = self.assignment[variable_index]
        if len(value_list) > 1:
            # value = DomainValue(course_index, self.course_list[course_index].num_ta)
            try:
                value_list.remove(value)
            except ValueError:
                print("remove is not working! panic!!")

            # probably not necessary
            self.assignment[variable_index] = value_list
        else:
            self.assignment[variable_index] = []

    """ This is the method where constraints come into play
        Returns true
            if no constraint is violated
        Returns false
            if single constraint is violated
            
        Testing naive implementation:
            if a course is assigned to any other variable and has been requested to assign again we return false
    """
    def isconsistent(self, var_index, value):
        # uncomment if we need fabs
        # from math import fabs
        
        # apply constraint: TA cannot have more than 1.0 job total
        value_list = self.assignment[var_index]
        total_ta_job = 0.0
        for item in value_list:
            total_ta_job += item.ta_amount
        # 1.0001 helps us to bypass float equality problem
        if total_ta_job + value.ta_amount > 1.0001:
            return False;

        # apply constraint only if class is required to be attended
        if self.course_list[value.class_index].does_attend:
            ta_time = self.var_list[var_index].time
            # apply time constraint:
            #  TA's own class time cannot conflict with the course's recitation time he is assigned as TA
            recitation_time = self.course_list[value.class_index].recitation_time
            # if class has recitation
            if recitation_time != None:
                # check time conflict, at this point
                if ta_time.week_day == recitation_time.week_day and abs(ta_time.minute-recitation_time.minute)<90:
                        return False
            # apply time constraint: TA's own class time cannot conflict with the course time he is assigned as TA
            course_time_list = self.course_list[value.class_index].time
            if any(ta_time.week_day == course_time.week_day and abs(ta_time.minute-course_time.minute)<90 for course_time \
                in course_time_list):
                return False
            
        """ apply constraint remaining TA job for a course should be more or equal
            so if it's less return False
            In other words, it checks if class is already assigned to other TAs, if assigned then check if it has \
            remaining_ta amount less than what is requested """
        for value_list in self.assignment:
            if value_list and any(item.class_index==value.class_index and self.remaining_ta[value.class_index] < \
                item.ta_amount for item in value_list):
                return False;
            """ debug prints
                elif value_list != None:
                print("value: ", value.class_index, value.ta_amount)
                print("value list")
                for item in value_list:
                    print(item.class_index, item.ta_amount)"""
                    
        return True

    """ This is the method where we check if variables are assigned
        Returns true
            if assigned
        If there are some contraints requirements too on assignment completion \
            they should be applied too using this method
    """
    def is_complete_assignment(self):
        for key in range(len(self.assignment)):
            value_list = self.assignment[key]
            if not value_list:
                return False;
        return True

    # compute domain for each variable and store in a list mapped to variable indices, domain_list
    def compute_variable_domains(self):
        for var_index in range(self.var_size):
            value_list = []
            sorted_course_index = self.get_ranked_course_list(var_index)
            for rank_index in range(len(sorted_course_index)):
                # 2 because a TA can take 0.5 or 1.0 where max is 1.0 amount of TA job
                for i in range(min(2, int(self.course_list[sorted_course_index[rank_index].index].num_ta/0.5))):
                    possible_ta_amount = (i+1)*0.5
                    value = DomainValue(sorted_course_index[rank_index].index, possible_ta_amount)
                    value_list.append(value)
            self.domain_list.append(value_list)
        # self.domain_debug(0)

    """
        rank courses according to match of skills
        exclude courses that have ta_amount < 0.5
        ranked list will have index to self.course_list
        for each variable rank courses
    """
    def get_ranked_course_list(self, var_index):
        ta_skills = self.var_list[var_index].skills
        course_skill_match_rank = []
        # for each compute match
        for i in range(len(self.course_list)):
            if self.course_list[i].num_ta > 0.499:
                num_skill_match = self.get_skill_match(ta_skills, self.course_list[i].skills)
                course_index_obj = CourseIndexSkillMatch(num_skill_match, i)
                course_skill_match_rank.append(course_index_obj)
        course_skill_match_rank = sorted(course_skill_match_rank, key=lambda x: x.rank, reverse=True)
        return course_skill_match_rank
        
    # given two sets of skills calculate match among them in percentage
    def get_skill_match(self, skill_01, skill_02):
        match = 0
        for x in skill_01:
            for y in skill_02:
                if x == y:
                    match += 1
        return match*100/len(skill_02)

    # efficient forward checking algorithm
    def forward_check(self, var_index):
        # X = self.var_list[var_index]
        # for each unassigned variable Y
        # this loop is similar to the one in method select_unassigned_variable
        for i in range(len(self.assignment)):
            item_list = self.assignment[i]
            if not item_list:
                # here's variable Y = self.var_list[i]
                # make arc consistent with X
                # this is pairwise version of method isconsistent
                for value in self.domain_list[i]:
                    if not self.isconsistent(i, value):
                        self.domain_list[i].remove(value)
                # infer failure
                if len(self.domain_list[i]) < 1:
                    return False
        return True


    # Arc-Consistency-3 algorithm
    def ac3(self, var_index):
        from queue import Queue
        
        # Put arcs (X, Y) into queue
        # X = self.var_list[var_index]
        # for each unassigned variable Y push arc (X, Y) to queue
        queue = Queue()
        for i in range(len(self.assignment)):
            item_list = self.assignment[i]
            if not item_list:
                # here's variable Y = self.var_list[i], create arc: (Y, X)
                arc = Arc(i, var_index)
                queue.put(arc)
        
        # get each arch from queue and propagate
        while not queue.empty():
            arc = queue.get()
            # if for the arc it is possible to reduce domain of X
            if self.revise_ac3(arc):
                # if no value in domain of X, we reached a failure!
                if len(self.domain_list[arc.x]) < 1:
                    return False
                # Because domain of X has been updated propagate this to neighbors in future \
                # by pushing those arcs into queue
                for i in range(len(self.assignment)):
                    item_list = self.assignment[i]
                    if i != arc.x and not item_list:
                        arc = Arc(i, arc.x)
                        queue.put(arc)
        return True        


    # Revise component of Arc-Consistency-3 algorithm
    # output: modifies domain of x
    def revise_ac3(self, arc):
        revised = False
        # for each value of domain of X
        for value_x in self.domain_list[arc.x]:
            # if value can be assigned to X
            if self.isconsistent(arc.x, value_x):
                self.assign(arc.x, value_x)
                # check consistency fo each value from the domain of Y, if there is no value in domain of Y that is \
                # consistent with X's value then we remove the value from X's domain
                if not any(self.isconsistent(arc.y, value_y) for value_y in self.domain_list[arc.y]):
                    try:
                        self.domain_list[arc.x].remove(value_x)
                    except ValueError:
                        print("remove is not working! panic!!")
                    revised = True

                self.unassign(arc.x, value_x)
        return revised
    
    # Prints to debug the domain
    def domain_debug(self, index = None):
        if index == None:
            for var_index in range(self.var_size):
                value_list = self.domain_list[var_index]
                for item in value_list:
                    print(item.class_index, item.ta_amount)
        else:
            print("Domain for ",self.var_list[index].name,":")
            value_list = self.domain_list[index]
            for item in value_list:
                print(self.course_list[item.class_index].name, item.ta_amount)

    def sort_by_class(self):
        type2_assignment_list = []
        self.class_ta_rank = []
        
        for index in range(len(self.course_list)):
            type2_assignment_list.append([])
            self.class_ta_rank.append(CourseIndexSkillMatch(0, index))

        for index in range(len(self.assignment)):
            value_list = self.assignment[index]
            for value in value_list:
                type2_value = DomainValue(index, value.ta_amount)
                type2_assignment_list[value.class_index].append(type2_value)
                self.class_ta_rank[value.class_index].rank += 1

        self.class_ta_rank = sorted(self.class_ta_rank, key=lambda x: x.rank, reverse=True)
        return type2_assignment_list
        
                
    def print_result(self, type):
        if type == 1:
            print("\nSolution found to CSP.\n")
            print("List of assignments returned by CSP")
            print("======================================")
            for index in range(len(self.assignment)):
                """ Debug prints
                print(self.var_list[index].name, self.var_list[index].time.week_day, self.var_list[index].time.minute, \
                   self.course_list[value_list[0].class_index].name, value_list[0].ta_amount)
                print("time for the course: ")
                time_list = self.course_list[value_list[0].class_index].time
                for time in time_list:
                    print(time.week_day, time.minute)"""
                print(self.var_list[index].name, end="")
                value_list = self.assignment[index]
                for value in value_list:
                    print(", ", self.course_list[value.class_index].name, ", ", value.ta_amount, sep="", end="")
                print()
            

        else:
            type2_assignment_list = self.sort_by_class()
            print("\nList of assignments sorted by class")
            print("======================================")
            for class_rank_obj in self.class_ta_rank:
                index = class_rank_obj.index
                if self.course_list[index].num_ta > 0.0:
                    print(self.course_list[index].name, end="")
                    value_list = type2_assignment_list[index]
                    for value in value_list:
                        # ta_index = value.class_index
                        print(", ", self.var_list[value.class_index].name, ", ", value.ta_amount, sep="", end="")
                    if self.remaining_ta[index] > 0.0:
                        print(", needed", self.remaining_ta[index])
                    else:
                        print()
