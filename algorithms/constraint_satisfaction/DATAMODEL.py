"""
    Represents data model for input dataset
    Represents following info for the provided input data file
    - Course time
    - Course recitations
    - Course details
    - Course skill requirements
    - TA responsibilities
    - TA skill
"""

# Represent day and hour of class
class ClassSchedule:
    def __init__(self, week_day, minute):
        self.week_day = week_day
        self.minute = minute

class CourseInfo:
    """
    The class for courses information
    We merge 3 representations here,
    - Course time
    - Course details
    - Course skill requirements
    
    name: the name of the course
    time: (weekday, time) in tuples if there are several times
              weekday is Mon-Fri, denoted by 1 - 5; time is changed to float
              i.e. Tue, 11:30 PM -> (2,23.5)
    skills: skills required by course in tuples
    num_ta: number of ta required by course, range from 0 to 2.0
    does_attend: boolean value whether the course needs attend
    recitation_time: for courses' recitation information
    """
    def __init__(self, course_name, course_time, skills, num_ta, should_attend, recitation_time):
        self.name = course_name
        self.time = course_time
        self.skills = skills
        self.num_ta = num_ta
        self.does_attend = should_attend
        self.recitation_time = recitation_time


class TAInfo:
    """
    The class for TA information, merges following representations
    - TA responsibilities
    - TA skill
    
    self.name: the name of TA
    self.time: (weekday, time) in tuples if there are several times
              weekday is Mon-Fri, denoted by 1 - 5; time is changed to float
              i.e. Tue, 11:30 PM -> (2,23.5)
    self.skills: skills TA owns in tuples
    """
    def __init__(self, name, ta_time, skills):
        self.name = name
        self.time = ta_time
        self.skills = skills


class DataModel:
    """
    The class models the data; read from file; and load them
    Outputs:
    self.course_info: a list of CourseInfo objects.
    self.recitation_info: a list of RecitationInfo objects.
    self.ta_info: a list of TAInfo objects.
    """

    def __init__(self, in_file_path):
        self.course_info = []
        self.ta_info = []

        # self.course_table: a dictionary contains all information for the course.
        # the order in one term is (course_name: (course_time), <(recitation_time)>,
        #  (#ofTA, should_attend), (course_skills))
        # self.ta_table: a dictionary contains all information for the TA.
        #  the order is (TA_name: (TA_time), (TA_skills))
        self.course_table = {}
        self.ta_table = {}

        # read file
        with open(in_file_path, 'r') as f:
            read_data = f.read()
        read_data_lines = read_data.splitlines()

        #  read each line to extract information into dictionary
        self.read_lines(read_data_lines)

        #  extract information from dictionary to objects lists
        for i in self.course_table:
            v = self.course_table[i]
            c_schedule = self.schedule(v[0])
            if len(v) == 4:
                r_schedule = self.schedule(v[1])
                course = CourseInfo(i, c_schedule, v[3], v[2][0], v[2][1], r_schedule)
            if len(v) == 3:
                course = CourseInfo(i, c_schedule, v[2], v[1][0], v[1][1], None)
            self.course_info.append(course)

        for i in self.ta_table:
            v = self.ta_table[i]
            t_schedule = self.schedule(v[0])
            ta = TAInfo(i, t_schedule, v[1])
            self.ta_info.append(ta)

    def schedule(self, time_tuple):
        if len(time_tuple) == 0:
            s = None
        elif len(time_tuple) == 1:
            s = ClassSchedule(time_tuple[0][0], time_tuple[0][1])
        else:
            s = []
            for t in time_tuple:
                s.append(ClassSchedule(t[0], t[1]))
        return s

    def read_lines(self, lines):
        """
        the method to read each line of input, extract information into dictionaries.
        counter: track each line counting.
        table_counter: track each table counting.
        :param lines: input lines
        :return:None
        """
        counter = 0
        table_counter = 1
        item_tuple = ()
        while counter < len(lines):
            # separate each table by counting empty line by table_counter
            if len(lines[counter]) is 0:
                table_counter += 1
                counter += 1
                continue

            # add time of each course into dictionary;
            # note that time is represented by ((weekdy1(int), time1(mins)), (weekdy2(int), time2(mins)),...)
            if table_counter is 1:
                case = lines[counter].split(", ")
                time_tuple = ()
                for i in range(1, len(case)):
                    if i % 2 is 1: #weekday
                        local_time_tuple = ()
                        weekday = self.weekdays(case[i])
                        local_time_tuple += (weekday,)
                    else:
                        local_time_tuple += (self.convert_time(case[i]),)
                        # local_time_tuple += (case[i],)
                        time_tuple += (local_time_tuple,)
                        local_time_tuple = ()
                item_tuple += (time_tuple,)
                self.course_table[case[0]] = item_tuple
                item_tuple = ()

            # add time of each recitation to corresponding course in dictionary;
            elif table_counter is 2:
                case = lines[counter].split(", ")
                if case[0] in self.course_table.keys():
                    time_tuple = ()
                    for i in range(1, len(case)):
                        if i % 2 is 1:
                            local_time_tuple = ()
                            weekday = self.weekdays(case[i])
                            local_time_tuple += (weekday,)
                        else:
                            local_time_tuple += (self.convert_time(case[i]),)
                            # local_time_tuple += (case[i],)
                            time_tuple += (local_time_tuple,)
                            local_time_tuple = ()
                    self.course_table[case[0]] += (time_tuple,)

            # add number of TA and should_attend as tuple to the corresponding course in dictionary
            elif table_counter is 3:
                case = lines[counter].split(", ")
                combine = ()
                if case[0] in self.course_table.keys():
                    ta_num = 0
                    if 25 <= int(case[1]) < 40:
                        ta_num = 0.5
                    if 40 <= int(case[1]) < 60:
                        ta_num = 1.5
                    if 60 <= int(case[1]):
                        ta_num = 2.0
                    combine += (ta_num,)
                    if case[2] == 'yes':
                        combine += (True,)
                    else:
                        combine += (False,)
                    self.course_table[case[0]] += (combine,)
                combine = ()

            # add skills to corresponding course in dictionary
            elif table_counter is 4:
                case = lines[counter].split(", ")
                combine = ()
                if case[0] in self.course_table.keys():
                    for i in range(1, len(case)):
                        combine += (case[i],)
                    self.course_table[case[0]] += (combine,)
                combine =()

            # add responsibility time to corresponding TA in dictionary
            elif table_counter is 5:
                case = lines[counter].split(", ")
                time_tuple = ()
                for i in range(1, len(case)):
                    if i % 2 is 1: #weekday
                        local_time_tuple = ()
                        weekday = self.weekdays(case[i])
                        local_time_tuple += (weekday,)
                    else:
                        local_time_tuple += (self.convert_time(case[i]),)
                        # local_time_tuple += (case[i],)
                        time_tuple += (local_time_tuple,)
                        local_time_tuple = ()
                item_tuple += (time_tuple,)
                self.ta_table[case[0]] = item_tuple
                item_tuple = ()

            # add skills to corresponding TA in dictionary
            elif table_counter is 6:
                case = lines[counter].split(", ")
                combine = ()
                if case[0] in self.ta_table.keys():
                    for i in range(1, len(case)):
                        combine += (case[i],)
                    self.ta_table[case[0]] += (combine,)
                combine = ()
            else:
                print("wrong table_counter input!")
            counter += 1

    def weekdays(self, str_in):
        """
        the method to turn string of weekday to corresponding integer
        :param str_in: input weekday string
        :return: the corresponding integer
        """
        strs = str_in.lower()
        num = 0
        if strs == "mon":
            num = 1
        elif strs == "tue":
            num = 2
        elif strs == "wed":
            num = 3
        elif strs == "th" or strs == "thu":
            num = 4
        elif strs == "fri":
            num = 5
        elif strs == "sat":
            num = 6
        elif strs == "sun":
            num = 7
        else:
            num = -1
        return num

    def convert_time(self, input_str):
        """
        the method to turn time string to corresponding comparable float
        :param input_str: input time string
        :return: the corresponding float number
        """
        import re

        arr = [int(s) for s in re.split(':|\s', input_str) if s.isdigit()]
        sub_str = [str(s) for s in re.split(':|\s', input_str) if s.isupper()]

        if sub_str[0] == 'PM' and arr[0] != 12:
            arr[0] += 12
        my_time = arr[0] * 60 + arr[1]
        # my_time = float(arr[0] + float(arr[1]) / 60)
        return my_time
