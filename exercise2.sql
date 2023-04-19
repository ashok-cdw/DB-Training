-- 1.Write a SQL query to remove the details of an employee whose first name ends in ‘even’
DELETE FROM employees WHERE first_name LIKE '%even';
SELECT * FROM employees WHERE first_name LIKE '%even';

-- 2.Write a query in SQL to show the three minimum values of the salary from the table
SELECT DISTINCT salary FROM employees ORDER BY salary LIMIT 3;
 
-- 3.Write a SQL query to remove the employees table from the database
DROP TABLE employees;

-- 4.Write a SQL query to copy the details of this table into a new table with table name as Employee table and to delete the records in employees table
CREATE TABLE employee CLONE employees; 
DESC TABLE employee;
TRUNCATE employees;

-- 5.Write a SQL query to remove the column Age from the table
ALTER TABLE employees ADD age INT;
SELECT * FROM employees;
ALTER TABLE employees DROP COLUMN age;

-- 6.Obtain the list of employees (their full name, email, hire_year) where they have joined the firm before 2000
SELECT CONCAT(first_name, ' ', last_name), email, YEAR(hire_date) FROM employees WHERE YEAR(hire_date) < 2000;
    
-- 7.Fetch the employee_id and job_id of those employees whose start year lies in the range of 1990 and 1999
SELECT employee_id, job_id FROM employees WHERE YEAR(hire_date) BETWEEN 1990 and 1999;

-- 8.Find the first occurrence of the letter 'A' in each employees Email ID
-- Return the employee_id, email id and the letter position
SELECT employee_id, email, CHARINDEX('A', email) AS indexofa FROM employees;
    
-- 9.Fetch the list of employees(Employee_id, full name, email) whose full name holds characters less than 12
SELECT employee_id, CONCAT(first_name, ' ', last_name), email FROM employees WHERE LENGTH(CONCAT(first_name, ' ', last_name)) < 12;
    
-- 10.Create a unique string by hyphenating the first name, last name , and email of the employees to obtain a new field named UNQ_ID
-- Return the employee_id, and their corresponding UNQ_ID;
SELECT employee_id, CONCAT(first_name, '-', last_name, '-', email) AS uniq_id FROM employees;

-- 11.Write a SQL query to update the size of email column to 30
ALTER TABLE employees ALTER email SET DATA TYPE VARCHAR(30);
DESC TABLE employees;

-- 12.Fetch all employees with their first name , email , phone (without extension part) and extension (just the extension)
-- Info : this mean you need to separate phone into 2 parts
-- eg: 123.123.1234.12345 => 123.123.1234 and 12345
-- first half in phone column and second half in extension column

SELECT * FROM employees;
SELECT first_name, email, SPLIT_PART(phone_number, '.', -1) AS extension, SUBSTR(phone_number,0,LENGTH(phone_number)- LENGTH(extension)-1) AS phone FROM employees;
    
-- 13.Write a SQL query to find the employee with second and third maximum salary
SELECT * FROM employees WHERE salary IN 
(SELECT DISTINCT salary FROM employees ORDER BY salary DESC LIMIT 2 OFFSET 1);
    
-- 14.Fetch all details of top 3 highly paid employees who are in department Shipping and IT
SELECT * FROM departments;
SELECT * FROM employees WHERE department_id IN 
(SELECT department_id FROM departments WHERE department_name IN ('Shipping', 'IT')) 
ORDER BY salary DESC LIMIT 3;

-- 15.Display employee id and the positions(jobs) held by that employee (including the current position)
SELECT * FROM employees WHERE employee_id = 101;
SELECT * FROM jobs;
SELECT * FROM job_history WHERE employee_id = 101;
SELECT * FROM (SELECT employees.employee_id, jobs.job_title FROM employees INNER JOIN jobs ON employees.job_id = jobs.job_id UNION
SELECT job_history.employee_id, jobs.job_title FROM job_history INNER JOIN jobs ON jobs.job_id = job_history.job_id) ORDER BY employee_id;

-- 16.Display Employee first name and date joined as WeekDay, Month Day, Year
-- Eg :
-- Emp ID Date Joined
-- 1 Monday, June 21st, 1999
SELECT employee_id, first_name, CONCAT(DAYNAME(hire_date), ', ', MONTHNAME(hire_date), ' ', DAYOFMONTH(hire_date), ',', YEAR(hire_date)) AS date_joined FROM employees;

-- 17.The company holds a new job opening for Data Engineer (DT_ENGG) with a minimum salary of 12,000 and maximum salary of 30,000 . The job position might be removed based on market trends (so, save the changes)
-- Later, update the maximum salary to 40,000 .
-- Save the entries as well.
-- Now, revert back the changes to the initial state, where the salary was 30,000

DELETE FROM jobs WHERE job_id = 'DT_ENGG';
ALTER SESSION SET AUTOCOMMIT = FALSE;
INSERT INTO jobs VALUES ('DT_ENGG', 'Data Engineer', 12000, 30000);
COMMIT;
UPDATE jobs SET max_salary = 40000 WHERE JOB_ID = 'DT_ENGG';
ROLLBACK;
SELECT * FROM jobs;

-- 18.Find the average salary of all the employees who got hired after 8th January 1996 but before 1st January 2000 and round the result to 3 decimals
SELECT ROUND(AVG(salary), 3) AS average_salary FROM employees WHERE hire_date > TO_DATE('8-Jan-1996') AND hire_date < TO_DATE('1-Jan-2000');

-- 19.Display Australia, Asia, Antarctica, Europe along with the regions in the region table (Note: Do not insert data into the table)
-- A. Display all the regions
-- B. Display all the unique regions
SELECT region_name FROM regions 
UNION ALL SELECT 'Australia' AS region_name
UNION ALL SELECT 'Asia' AS region_name
UNION ALL SELECT 'Antarctica' AS region_name
UNION ALL SELECT 'Europe' AS region_name;

SELECT region_name FROM regions
UNION SELECT 'Australia' AS region_name
UNION SELECT 'Asia' AS region_name
UNION SELECT 'Antarctica' AS region_name
UNION SELECT 'Europe' AS region_name;
