CREATE DATABASE projects_hr;

USE projects_hr;

SELECT * FROM hr

-- data cleaning and preprocessing--

ALTER TABLE hr
CHANGE COLUMN ï»¿id emp_id VARCHAR(20) NULL;

DESCRIBE hr

SET sql_safe_updates = 0;

UPDATE hr
SET birthdate = CASE
		WHEN birthdate LIKE '%/%' THEN date_format(str_to_date(birthdate,'%m/%d/%Y'),'%Y-%m-%d')
        WHEN birthdate LIKE '%-%' THEN date_format(str_to_date(birthdate,'%m-%d-%Y'),'%Y-%m-%d')
        ELSE NULL
		END;
	
ALTER TABLE hr
MODIFY COLUMN birthdate DATE;


-- change the data format and datatype of hire_date column

UPDATE hr
SET hire_date = CASE
		WHEN hire_date LIKE '%/%' THEN date_format(str_to_date(hire_date,'%m/%d/%Y'),'%Y-%m-%d')
        WHEN hire_date LIKE '%-%' THEN date_format(str_to_date(hire_date,'%m-%d-%Y'),'%Y-%m-%d')
        ELSE NULL
		END;
        
ALTER TABLE hr
MODIFY COLUMN hire_date DATE;

-- change the date format and datatpye of termdate column
UPDATE hr
SET termdate = date(str_to_date(termdate, '%Y-%m-%d %H:%i:%s UTC'))
WHERE termdate IS NOT NULL AND termdate !='';

UPDATE hr
SET termdate = NULL
WHERE termdate = '';


-- create age column
ALTER TABLE hr
ADD column age INT;

UPDATE hr
SET age = timestampdiff(YEAR,birthdate,curdate())

SELECT min(age), max(age) FROM hr

-- 1. What is the gender breakdown of employees in the company
SELECT * FROM hr

SELECT gender, COUNT(*) AS count 
FROM hr
WHERE termdate IS NULL
GROUP BY gender;

-- 2. What is the race breakdown of employees in the company
SELECT race , COUNT(*) AS count
FROM hr
WHERE termdate IS NULL
GROUP BY race

-- 3. What is the age distribution of employees in the company
SELECT 
	CASE
		WHEN age>=18 AND age<=24 THEN '18-24'
        WHEN age>=25 AND age<=34 THEN '25-34'
        WHEN age>=35 AND age<=44 THEN '35-44'
        WHEN age>=45 AND age<=54 THEN '45-54'
        WHEN age>=55 AND age<=64 THEN '55-64'
        ELSE '65+'
	END AS age_group,
    COUNT(*) AS count
    FROM hr
    WHERE termdate IS NULL
    GROUP BY age_group
    ORDER BY age_group;
    
-- 4. How many employees work at HQ vs remote
SELECT location,COUNT(*) AS count
FROm hr
WHERE termdate IS NULL
GROUP BY location;


-- 5. What is the average length of employement who have been teminated.
SELECT ROUND(AVG(year(termdate) - year(hire_date)),0) AS length_of_emp
FROM hr
WHERE termdate IS NOT NULL AND termdate <= curdate()

-- 6. How does the gender distribution vary acorss dept. and job titles
SELECT *  FROM hr

SELECT department,jobtitle,gender,COUNT(*) AS count
FROM hr
WHERE termdate IS NOT NULL
GROUP BY department, jobtitle,gender
ORDER BY department, jobtitle,gender

SELECT department,gender,COUNT(*) AS count
FROM hr
WHERE termdate IS NOT NULL
GROUP BY department,gender
ORDER BY department,gender

-- 7. What is the distribution of jobtitles acorss the company
SELECT jobtitle, COUNT(*) AS count
FROm hr
WHERE termdate IS NULL
GROUP BY jobtitle

-- 8. Which dept has the higher turnover/termination rate

SELECT * FROM hr

SELECT department,
		COUNT(*) AS total_count,
        COUNT(CASE
				WHEN termdate IS NOT NULL AND termdate <= curdate() THEN 1 
				END) AS terminated_count,
		ROUND((COUNT(CASE
					WHEN termdate IS NOT NULL AND termdate <= curdate() THEN 1 
                    END)/COUNT(*))*100,2) AS termination_rate
		FROM hr
        GROUP BY department
        ORDER BY termination_rate DESC
        
        
-- 9. What is the distribution of employees across location_state
SELECT location_state, COUNT(*) AS count
FROm hr
WHERE termdate IS NULL
GROUP BY location_state

SELECT location_city, COUNT(*) AS count
FROm hr
WHERE termdate IS NULL
GROUP BY location_city

-- 10. How has the companys employee count changed over time based on hire and termination date.

SELECT hiredate, total_hired, termination, (total_hired-termination) AS net_change,
ROUND(((total_hired-termination) / total_hired *100),2) AS net_percentage_change
FROM (SELECT YEAR(hire_date)AS hiredate, COUNT(*) AS total_hired, 
SUM(CASE WHEN termdate IS NOT NULL AND termdate <= curdate() THEN 1 ELSE 0 END)AS termination
FROM hr
GROUP BY YEAR(hire_date)) AS subquery
GROUP BY hiredate
ORDER BY hiredate;

-- 11. What is the tenure distribution for each department?
SELECT * FROM hr;
SELECT department, ROUND(AVG(DATEDIFF(CURDATE(), termdate)/365),0) as avg_tenure
FROM hr
WHERE termdate <= CURDATE() AND termdate <> '0000-00-00' AND age >= 18
GROUP BY department

## Summary of Findings

-- There are more male employees
-- White race is the most dominant while Native Hawaiian and American Indian are the least dominant.
-- The youngest employee is 20 years old and the oldest is 57 years old
-- 5 age groups were created (18-24, 25-34, 35-44, 45-54, 55-64). A large number of employees were between 25-34 followed by 35-44 while the smallest group was 55-64.
-- A large number of employees work at the headquarters versus remotely.
-- The average length of employment for terminated employees is around 7 years.
-- The gender distribution across departments is fairly balanced but there are generally more male than female employees.
-- The Marketing department has the highest turnover rate followed by Training. The least turn over rate are in the Research and development, Support and Legal departments.
-- A large number of employees come from the state of Ohio.
-- The net change in employees has increased over the years.
-- The average tenure for each department is about 8 years with Legal and Auditing having the highest and Services, Sales and Marketing having the lowest.

-- ## Limitations
-- Some records had negative ages and these were excluded during querying(967 records). Ages used were 18 years and above.
-- Some termdates were far into the future and were not included in the analysis(1599 records). The only term dates used were those less than or equal to the current date.
  