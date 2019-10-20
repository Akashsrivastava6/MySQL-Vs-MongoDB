#!/bin/bash

#performing simple query on MySQL
START_TIME=$SECONDS
mysql -h'127.0.0.1' -u root -pakashsri 17201082_db -e "select * from departments where dept_no='D007';">test
ELAPSED_TIME=$(($SECONDS-$START_TIME))
echo "Time Taken by MySQL for a simple query : $ELAPSED_TIME seconds"

#performing simple query on MongoDB
START_TIME=$SECONDS
mongo db1 --eval "db.departments.find({dept_no:d007},{})">test
ELAPSED_TIME=$(($SECONDS-$START_TIME))
echo "Time Taken by MongoDB for a simple query : $ELAPSED_TIME seconds"

#performing complex Query on MySQL
START_TIME=$SECONDS
mysql -h'127.0.0.1' -u root -pakashsri 17201082_db -e "select * from employees e, salaries s,dept_emp d1,departments d2
where e.emp_no=s.emp_no and d1.emp_no=e.emp_no and d1.dept_no=d2.dept_no order by s.salary desc limit 1;">test
ELAPSED_TIME=$(($SECONDS-$START_TIME))
echo "Time Taken by MySQL for a complex query : $ELAPSED_TIME seconds"

#Performing complex query on MongoDBi
START_TIME=$SECONDS
mongo db1 --eval 'db.salaries.aggregate([{$sort:{salary:-1}},{$limit:1},{$lookup:{from:"employees",
localField:"emp_no",foreignField:"emp_no",as:"sal_emp"}},{$unwind:"$sal_emp"},{$lookup:{from:"dept_emp",
localField:"sal_emp.emp_no",foreignField:"emp_no",as:"dept_emp"}},{$unwind:"$dept_emp"},{$lookup:{from:"departments",
localField:"dept_emp.dept_no",foreignField:"dept_no",as:"dept_dept"}},{$unwind:"$dept_dept"}]).pretty()'>test
ELAPSED_TIME=$(($SECONDS-$START_TIME))
echo "Time Taken by MongoDB for a complex query : $ELAPSED_TIME seconds"
rm test