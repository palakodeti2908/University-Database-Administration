
-- to add the PK
ALTER TABLE student_table
ADD Primary KEY (ID);

ALTER TABLE department_table
ADD Primary KEY (Department_Code);

ALTER TABLE extra_curricular_activities_table
ADD Primary KEY (Department_Code);

ALTER TABLE admission_table
ADD Primary KEY (Admission_ID);

ALTER TABLE faculty_table
ADD Primary KEY (Faculty_ID);

ALTER TABLE course_table
ADD Primary KEY (Course_ID);

ALTER TABLE enrollment_table
ADD Primary KEY (Enrollment_ID);

ALTER TABLE project_table
ADD Primary KEY (Project_ID);

-- to add the FK
ALTER TABLE student_table
ADD FOREIGN KEY (Admission_ID) REFERENCES admission_table(Admission_ID),
ADD FOREIGN KEY (Project_ID) REFERENCES project_table(Project_ID),
ADD FOREIGN KEY (Department_Code) REFERENCES department_table(Department_Code);

ALTER TABLE faculty_table
ADD FOREIGN KEY (Course_ID) REFERENCES course_table(Course_ID);

ALTER TABLE enrollment_table
ADD FOREIGN KEY (Course_ID) REFERENCES course_table(Course_ID),
ADD FOREIGN KEY (Student_ID) REFERENCES student_table(ID),
ADD FOREIGN KEY (Department_Code) REFERENCES department_table(Department_Code);

ALTER TABLE project_table
ADD FOREIGN KEY (Faculty_ID) REFERENCES faculty_table(Faculty_ID);


select * from student_table;
select * from department_table;
select * from extra_curricular_activities_table;
select * from acadamics_table;
select * from admission_table;
select * from faculty_table;
select * from course_table;
select * from enrollment_table;
select * from project_table;


#1 Retrieve the info about the courses handled by the faculty
select b.Course_Name,a.Course_ID, count(a.faculty_Id) as faculty_handling
from faculty_table a
join course_table b
using (course_id)
group by a.course_id;

#2 Retrieving the top 5 students who's having GPA between 3.8 and 4 (By using joins)
select S.ID, S.First_name, A.GPA from student_table S
left join acadamics_table A
on S.ID = A.Student_ID
where A.GPA between 3.8 and 4.0
order by A.GPA desc
limit 5;

#3 Query to get the students and their head count who joined the university in 2022 partitioned by the type of admission using "WINDOW FUNCTIONS"
select A.Student_ID, S.First_name, S.last_Name,A.Admission_Type,
count(*) over(partition by Admission_Type) as no_of_reg_admissions_in_2022
from admission_table A
left join student_table S
on S.ID = A.Student_ID
where Admission_Date like '%2022%'
order by A.Admission_Type desc;


#4 Retrieving the number of government funder projects under specific course that are handled by each professor using CTE and nested queries
with cte as (select * from project_table
where Project_Funding in ('Public'))
select F.Faculty_name, F.Faculty_ID, F.Course_ID,
(select count(*) from cte as P where P.Faculty_ID = F.Faculty_ID) as Number_of_Government_Funded_Projects
from faculty_table F
order by Number_of_Government_Funded_Projects desc;


#5 Query that returns the GPA, the class average, and the difference from the class average of all students
 #which will make the professor to know the mean and the difference from the mean score while assigning grades 
 #Using Windows CTE and aggregate functions 
with cte as 
(select Student_ID, Attendance, GPA, Course_related_internships,
cast(avg(GPA) over() as float4)
as class_average_GPA,
cast(GPA - avg(GPA) over() as float4)
 as difference_from_average from acadamics_table)
select * from cte
order by Student_ID, difference_from_average;

#6 Retrieve students and their names who can be qualified for TA/RA should have attendance >= 90 and should have 3.8-4 GPA
with cte as (select Student_ID, Attendance, GPA from acadamics_table A
where Attendance >= 90
order by Attendance desc)
select S.ID, S.First_name, cte.GPA, cte.Attendance,
count(*) over(order by cte.GPA desc rows between unbounded preceding and current row) as qualified_students
from student_table S
left join cte
on cte.Student_ID = S.ID
where cte.Student_ID = S.ID and cte.GPA between 3.85 and 4.0
order by cte.GPA desc;


#7 By using exists, retrieving the students who are in the university's hockey team representing in the tournaments 

SELECT id, first_name, Last_name
FROM student_table 
WHERE EXISTS
 (SELECT sports_id, sports as Sport
		FROM extra_curricular_activities_table 
		WHERE extra_curricular_activities_table.Student_ID = student_table.ID 
		and Sports_ID = 22 );
    

# Retrieving number of students falling under each sports department 
select sports as Sports, count(student_ID) as No_of_Students
 from extra_curricular_activities_table
 group by sports;

# For Pie Chart
select sports as Sports, count(student_ID) as Percentage_No_of_Students
 from extra_curricular_activities_table
 group by sports;

# To retreive Course wise GPA of all the students in the class
select a.course_id,a.Course_Name,b.GPA
from course_table a
join enrollment_table c
on a.Course_ID=c.Course_ID
join acadamics_table b
on c.student_id = b.student_id;

# Number fo course registrations 

with cte as(
select Student_id, count(Course_id) as num_registered_courses
from enrollment_table
group by Student_id
)
select * from cte
where num_registered_courses = 2;


