"""
    Higher level demonstration file to solve CSP
    assignment: list of assignments, a dictionary object might help
        let's see if we have to change it later.. we will move this to csp class if necessary later
    csp: contains variables
"""

from CSP import CSP
from DATAMODEL import DataModel

# Formulates the problem and solves it
class TAAssignmentProblem:
    """
        Methods and properties to handle the raw program and calling methods from CSP and DataModel module
        method backtracking_search handles calling all backtracking methods
    """
    # constructor
    def __init__(self, data_file_path):
        self.datamodelobj = DataModel(data_file_path)

    # ref: AIMA 3rd edition page 215
    def backtracking_search(self):
        import time
        import os
        if os.name == 'posix':
            import resource
        
        csp = CSP(self.datamodelobj.ta_info, self.datamodelobj.course_info)
        
        memory_usage0 = 0
        if os.name == 'posix':
            import resource
            memory_usage0 = resource.getrusage(resource.RUSAGE_SELF).ru_maxrss

        # pure backtracking only
        csp.backtrack_init()
        print("Running plain backtracking search")
        print("===============================================")
        start_time = time.clock()
        time_pbs = 0.0
        time_bs_fc = 0.0
        time_bs_fc_cp = 0.0

        if self.backtrack(csp):
            time_pbs = (time.clock() - start_time)*1000
            csp.print_result(1)
            csp.print_result(2)
        else:
            print("Failed to find a solution!")

        if os.name == 'posix':
            memory_usage1 = resource.getrusage(resource.RUSAGE_SELF).ru_maxrss            
        # backtracking with forward checking
        csp.backtrack_init()
        print("\nRunning backtracking search with forward checking")
        print("=======================================================")
        start_time = time.clock()
        if self.backtrack_fc(csp):
            time_bs_fc = (time.clock() - start_time)*1000
            csp.print_result(1)
            csp.print_result(2)
        else:
            print("Failed to find a solution!")

        if os.name == 'posix':
            memory_usage2 = resource.getrusage(resource.RUSAGE_SELF).ru_maxrss
        # backtracking with forward checking and contraint_propagation
        csp.backtrack_init()
        print("\nRunning backtracking search with fc and constraint propagation")
        print("================================================================")
        start_time = time.clock()
        if self.backtrack_mac(csp):
            time_bs_fc_cp = (time.clock() - start_time)*1000
            csp.print_result(1)
            csp.print_result(2)
        else:
            print("Failed to find a solution!")
        if os.name == 'posix':
            memory_usage3 = resource.getrusage(resource.RUSAGE_SELF).ru_maxrss

        print("\nSummary of running time of algorithms\n============================================")
        print("Plain backtracking search:", time_pbs, "milliseconds")
        print("Backtracking search with forward checking:", time_bs_fc, "milliseconds")
        print("Plain backtracking search with forward checking and constraint propagation:", time_bs_fc_cp, "milliseconds")
        print()
        if os.name == 'posix':
            print("\nSummary of memory usage of algorithms\n============================================")
            print("Plain backtracking search", memory_usage1 - memory_usage0, "kb")
            print("Plain bs + fc", memory_usage2 - memory_usage1, "kb")
            print("Plain bs + fc + cp", memory_usage3 - memory_usage2, "kb")
            print()

    def data_model_debug(self):
        print("Course summary")
        total_ta_job_required = 0.0
        for item in self.datamodelobj.course_info:
            print(item.name, item.skills, item.num_ta, item.does_attend)
            total_ta_job_required += item.num_ta
        print("Total TA job required for the courses: ", total_ta_job_required)
        print("===============================================")
        # newlist = self.datamodelobj.ta_info
        # newlist = sorted(self.datamodelobj.ta_info, key=lambda x: x.name, reverse=False)
        """print("TA Info")
        print("========")
        for item in newlist:
            print(item.name, item.time, item.skills)

        for i in self.datamodelobj.ta_table:
            print(i)
            print(self.datamodelobj.ta_table[i])
        print("======")"""

    # ref: AIMA 3rd edition page 215
    def backtrack(self, csp):
        if csp.is_complete_assignment():
            return True
        var = csp.select_unassigned_variable()
        if var == csp.invalid_index:
            print("Variable invalid")
            return False

        # Order of domain values done as well for some constraints such as
        #   maxmimum skill match to be implemented on next revision
        # for value in order_domain_values(var, assignment, csp):
        for value in csp.domain_list[var]:
            # passing var with isconsistent to help check whether new assignment will give more ta_amount than his quota 1.0
            # usually isconsistent does not take a var as argument, this is our implementation to apply that constraint on TA
            if csp.isconsistent(var, value):
                csp.assign(var, value)
                if self.backtrack(csp):
                    return True

                # remove_variable_value_pair(assignment, var, value)
                csp.unassign(var, value)
        return False

    # Backtracking with Forward Checking ref: AIMA 3rd edition page 217
    def backtrack_fc(self, csp):
        if csp.is_complete_assignment():
            return True
        # Order of variables, p216, consider Minimum Remaining Values (MRV) heuristic/most constrained variable/fail-first \
        # heuristic; as for starting degree heuristic can be used
        var = csp.select_unassigned_variable()
        if var == csp.invalid_index:
            print("Variable invalid")
            return False

        # Order of domain values done as well for some constraints such as
        #   maxmimum skill match to be implemented on next revision
        # for value in order_domain_values(var, assignment, csp):
        for value in csp.domain_list[var]:
            # passing var with isconsistent to help check whether new assignment will give more ta_amount than 1.0
            # usually isconsistent does not take a var as argument
            # this is an efficient implementation to apply constraint on TA
            if csp.isconsistent(var, value):
                csp.assign(var, value)
                
                # backup domain
                import copy
                domain_list_copy=copy.deepcopy(csp.domain_list)
                # domain reduction for other variables using forward checking
                # restore domain if this forward_check returns failure as inference or backtrack fails for assigned value
                if not csp.forward_check(var):
                    # restore domain modified by forward checking
                    csp.domain_list = domain_list_copy[:]
                    return False
                
                if self.backtrack_fc(csp):
                    return True

                # remove_inference(inferences, assignment), which is:
                # restore domain modified by forward checking, shallow copy is enough
                csp.domain_list = domain_list_copy[:]
                # remove_variable_value_pair(assignment, var, value)
                csp.unassign(var, value)
        return False

    # Backtracking with Forward Checking and Constraint Propagation ref: AIMA 3rd edition page 218
    # MAC (Maintaining Arc Consistency) algorithm using ac-3 component with backtracking search
    def backtrack_mac(self, csp):
        if csp.is_complete_assignment():
            return True
        # Order of variables, p216, consider Minimum Remaining Values (MRV) heuristic/most constrained variable/fail-first \
        # heuristic; as for starting degree heuristic can be used
        var = csp.select_unassigned_variable()
        if var == csp.invalid_index:
            print("Variable invalid")
            return False

        # Order of domain values done as well for some constraints such as
        #   maxmimum skill match to be implemented on next revision
        # for value in order_domain_values(var, assignment, csp):
        for value in csp.domain_list[var]:
            # passing var with isconsistent to help check whether new assignment will give more ta_amount than 1.0
            # usually isconsistent does not take a var as argument
            # this is an efficient implementation to apply constraint on TA
            if csp.isconsistent(var, value):
                csp.assign(var, value)
                
                # backup domain
                import copy
                domain_list_copy=copy.deepcopy(csp.domain_list)
                # propagate constraints starting with all unassigned neighboring arcs
                # restore domain if this forward_check returns failure as inference or backtrack fails for assigned value
                if not csp.ac3(var):
                    # restore domain modified by forward checking
                    csp.domain_list = domain_list_copy[:]
                    return False
                
                if self.backtrack_mac(csp):
                    return True

                """# skeleton required for arc consistency, path consistency, k-consistency etc p215: figure notes
                # inferences = inference(csp, var, value)
                
                if inferences != failure:
                    add_inferences(inferences, assignment)
                    result = backtrack(assignment, csp)
                    if result != failure:
                        return result"""
                # remove_inference(inferences, assignment), which is:
                # restore domain modified by forward checking, shallow copy is enough
                csp.domain_list = domain_list_copy[:]
                # remove_variable_value_pair(assignment, var, value)
                csp.unassign(var, value)
        return False

# entry method
def main():
    import sys
    if (len(sys.argv)<2):
        print("Please provide input file on command line argument.")
        return
    data_file_path = sys.argv[1]
    ta_assignment_problem = TAAssignmentProblem(data_file_path)
    # ta_assignment_problem.data_model_debug()
    ta_assignment_problem.backtracking_search()

if __name__ == "__main__":
    main()
