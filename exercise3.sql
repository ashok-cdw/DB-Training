-- 1.Write a SQL query to find the total salary of employees who is in Tokyo excluding whose first name is Nancy
SELECT * FROM locations;
SELECT SUM(salary) AS total_salary_of_employees FROM employees emp
INNER JOIN departments dpmt ON emp.department_id = dpmt.department_id 
INNER JOIN locations loc ON dpmt.location_id = loc.location_id WHERE city = 'Seattle' AND emp.first_name != 'Nancy';

-- 2.Fetch all details of employees who has salary more than the avg salary by each department
WITH avg_salary AS (SELECT department_id AS dpmt_id,AVG(salary) AS average FROM employees GROUP BY department_id)
SELECT * FROM employees emp INNER JOIN avg_salary ON emp.department_id = avg_salary.dpmt_id AND emp.salary > avg_salary.average;

-- 3.Write a SQL query to find the number of employees and its location whose salary is greater than or equal to 7000 and less than 10000
SELECT COUNT(emp.employee_id) AS count_of_employee,loc.city AS city FROM employees emp
INNER JOIN departments dpmt ON emp.department_id = dpmt.department_id
INNER JOIN locations loc ON dpmt.location_id = loc.location_id
WHERE emp.salary >= 7000 AND emp.salary < 10000
GROUP BY loc.city;

-- 4.Fetch max salary, min salary and avg salary by job and department. 
-- Info: grouped by department id and job id ordered by department id and max salary
SELECT MAX(salary) AS maximum_salary, MIN(salary) AS minimum_salary, AVG(salary) AS average_salary,department_id,job_id FROM employees
GROUP BY department_id,job_id
ORDER BY department_id,maximum_salary;

-- 5.Write a SQL query to find the total salary of employees whose country_id is ‘US’ excluding whose first name is Nancy
SELECT SUM(emp.salary) AS total_salary_of_employees FROM employees emp
INNER JOIN departments dpmt ON emp.department_id = dpmt.department_id
INNER JOIN locations loc ON dpmt.location_id = loc.location_id
WHERE loc.country_id = 'US' AND emp.first_name != 'Nancy';

-- 6.Fetch max salary, min salary and avg salary by job id and department id but only for folks who worked in more than one role(job) in a department
SELECT MAX(salary) AS maximum_salary, MIN(salary) AS minimum_salary, AVG(salary) AS average_salary,department_id,job_id FROM employees
WHERE employee_id IN (SELECT DISTINCT employee_id FROM job_history)
GROUP BY department_id,job_id;

-- 7.Display the employee count in each department and also in the same result.
-- Info: * the total employee count categorized as "Total"
-- the null department count categorized as "-" *
SELECT COALESCE(CAST(department_id AS STRING),'-') AS department_id, COUNT(employee_id) AS employee_count
FROM employees 
GROUP BY department_id
UNION SELECT 'Total' AS department_id,COUNT(employee_id) AS employee_count FROM employees
ORDER BY department_id;


-- 8.Display the jobs held and the employee count
-- Hint: every employee is part of at least 1 job
-- Hint: use the previous questions answer
-- Sample
-- JobsHeld EmpCount
-- 1 100
-- 2 4

SELECT jobs_held, COUNT(result.employee_id) AS employees_count FROM 
(SELECT emp1.employee_id,COUNT(emp1.employee_id) AS jobs_held FROM employee emp1
LEFT JOIN job_history  emp2 
ON emp1.employee_id=emp2.employee_id 
GROUP BY emp1.employee_id) result
GROUP BY result.jobs_held;

-- 9.Display average salary by department and country
SELECT ctry.country_name, dpmt.department_id, AVG(emp.salary) AS average_salary FROM employees emp 
INNER JOIN departments dpmt ON emp.department_id = dpmt.department_id
INNER JOIN locations loc ON dpmt.location_id = loc.location_id
INNER JOIN countries ctry ON loc.country_id = ctry.country_id
GROUP BY dpmt.department_id,ctry.country_name
ORDER BY dpmt.department_id;

-- 10.Display manager names and the number of employees reporting to them by countries 
-- (each employee works for only one department, and each department belongs to a country)

SELECT CONCAT(emp2.first_name,' ',emp2.last_name) AS manager_name,COUNT(emp1.employee_id) AS number_of_employees_reporting,ctry.country_name FROM employees emp1
INNER JOIN employees emp2 ON emp1.manager_id=emp2.employee_id
INNER JOIN departments dpmt ON dpmt.department_id=emp1.department_id
INNER JOIN locations loc ON loc.location_id=dpmt.location_id
INNER JOIN countries ctry ON ctry.country_id=loc.country_id
GROUP BY emp1.manager_id,emp2.first_name,emp2.last_name,ctry.country_name;


-- 11.Group salaries of employees in 4 buckets eg: 0-10000, 10000-20000,.. 
-- (Like the previous question) but now group by department and categorize it like below.
-- Eg : 
-- DEPT ID 0-10000 10000-20000
-- 50          2               10
-- 60          6                5
SELECT department_id,
COUNT(CASE WHEN salary >= 0 AND salary <= 10000 THEN 1 END) AS "0-10000",
COUNT(CASE WHEN salary > 10000 AND salary <= 20000 THEN 1 END) AS "10000-20000",
COUNT(CASE WHEN salary > 20000 THEN 1 END ) AS "Above 20000"
FROM employees
GROUP BY department_id;

-- 12.Display employee count by country and the avg salary 
-- Eg : 
-- Emp Count       Country        Avg Salary
-- 10              Germany      34242.8
SELECT ctry.country_name, COUNT(employee_id) as employee_count, ROUND(AVG(salary),2) AS average_salary
FROM employee emp
INNER JOIN departments dpmt ON emp.department_id=dpmt.department_id
INNER JOIN locations loc ON dpmt.location_id=loc.location_id
INNER JOIN countries ctry ON loc.country_id=ctry.country_id
GROUP BY ctry.country_name;

-- 13.Display region and the number off employees by department
-- Eg : 
-- Dept ID   America   Europe  Asia
-- 10            22               -            -
-- 40             -                 34         -
-- (Please put "-" instead of leaving it NULL or Empty)
SELECT emp.department_id,
COALESCE(NULLIF(CAST(COUNT(CASE WHEN region_name = 'Europe' then 1 end) as string),'0'),'-') AS "Europe",
COALESCE(NULLIF(CAST(COUNT(CASE WHEN region_name = 'Americas' then 1 end) as string),'0'),'-') AS "Americas",
COALESCE(NULLIF(CAST(COUNT(CASE WHEN region_name = 'Asia' then 1 end) as string),'0'),'-') AS "Asia",
COALESCE(NULLIF(CAST(COUNT(CASE WHEN region_name = 'Middle East and Africa' then 1 end ) AS string),'0'),'-') AS "Middle East and Africa"
FROM employees emp
JOIN departments dpmt ON emp.department_id=dpmt.department_id
JOIN locations loc ON dpmt.location_id=loc.location_id
JOIN countries cntry ON loc.country_id=cntry.country_id
JOIN regions reg ON cntry.region_id=reg.region_id
GROUP BY emp.department_id HAVING COUNT(emp.employee_id) > 0
ORDER BY emp.department_id;


-- 14 Select the list of all employees who work either for one or more departments
-- or have not yet joined / allocated to any department
SELECT employee_id,IFF(COUNT(department_id) = 0, 'Have not yet joined / allocated to any department','Work either for one or more departments') AS employee_working_department FROM employees 
GROUP BY employee_id,department_id;

-- 15 write a SQL query to find the employees and their respective managers.
-- Return the first name, last name of the employees and their managers
SELECT emp1.first_name, emp1.last_name, CONCAT(emp2.first_name,' ',emp2.last_name) AS respective_manager_name FROM employees emp1 
LEFT JOIN employees emp2 ON emp1.manager_id = emp2.employee_id;

-- 16 write a SQL query to display the department name, city, and state province for each department.
SELECT dpmt.department_name,loc.city,loc.state_province FROM departments dpmt
INNER JOIN locations loc ON dpmt.location_id = loc.location_id;

-- 17 write a SQL query to list the employees (first_name , last_name, department_name) 
-- who belong to a department or don't
SELECT emp.first_name,emp.last_name,dpmt.department_name, IFF(emp.department_id IS NULL, 'Not belong to any department','Belong to a department') AS belonging
FROM employees emp LEFT JOIN departments dpmt ON emp.department_id=dpmt.department_id;

-- 18 The HR decides to make an analysis of the employees working in every department.
-- Help him to determine the salary given in average per department 
-- and the total number of employees working in a department.
-- List the above along with the department id, department name
SELECT emp.department_id,dpmt.department_name,COUNT(emp.employee_id) AS total_number_of_employees,AVG(emp.salary) AS average_salary_per_department FROM employees emp 
INNER JOIN departments dpmt ON emp.department_id = dpmt.department_id 
GROUP BY emp.department_id,dpmt.department_name;

-- 19 Write a SQL query to combine each row of the employees with each row of the jobs to obtain a consolidated results.
-- (i.e.) Obtain every possible combination of rows from the employees and the jobs relation
SELECT * FROM employees CROSS JOIN jobs;

-- 20.Write a query to display first_name, last_name, and email of employees who are from Europe and Asia
SELECT emp.first_name,emp.last_name,emp.email,rgns.region_name FROM employees emp
INNER JOIN departments dpmt ON dpmt.department_id=emp.department_id
INNER JOIN locations loc ON loc.location_id=dpmt.location_id
INNER JOIN countries ctry ON ctry.country_id=loc.country_id
INNER JOIN regions rgns ON ctry.region_id=rgns.region_id
WHERE region_name IN ('Europe','Asia');

-- 21.Write a query to display full name with alias as FULL_NAME 
-- (Eg: first_name = 'John' and last_name='Henry' - full_name = "John Henry")
-- who are from oxford city and their second last character of their last name is 'e'
-- and are not from finance and shipping department.
SELECT CONCAT(emp.first_name,' ',emp.last_name) AS full_name FROM employees emp
INNER JOIN departments dpmt ON emp.department_id = dpmt.department_id 
INNER JOIN locations loc ON dpmt.location_id = loc.location_id 
WHERE loc.city = 'Oxford' AND emp.last_name LIKE '%e_' AND dpmt.department_name NOT IN ('Shipping','Finance');

-- 22.Display the first name and phone number of employees who have less than 50 months of experience
SELECT first_name, phone_number FROM employees WHERE MONTHS_BETWEEN(CURRENT_DATE(),hire_date) < 50;

-- 23.Display Employee id, first_name, last name, hire_date and salary for employees
-- who has the highest salary for each hiring year.(For eg: John and Deepika joined on year 2023,
-- and john has a salary of 5000, and Deepika has a salary of 6500.
-- Output should show Deepika’s details only).

-- SELECT MAX(salary) FROM employees WHERE YEAR(hire_date) = '1994';
SELECT emp.employee_id, emp.first_name, emp.last_name, emp.hire_date, emp.salary FROM employees emp 
WHERE emp.salary = (SELECT MAX(salary) FROM employees WHERE YEAR(hire_date) = YEAR(emp.hire_date)) ORDER BY YEAR(hire_date);
