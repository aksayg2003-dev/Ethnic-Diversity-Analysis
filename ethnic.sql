create database if not exists ethnic_diversity;
use ethnic_diversity;
show tables;

select * from `ethnic diversity`;


-- creating 2 small tables to perform joins --

-- table 1 - (To show region belonging of states) --

create table states_region(
state varchar(150) primary key,
region varchar(50)
);

insert into states_region(state,region) values
('California','West'),
('Texas','South'),
('Washington','West'),
('Ohio','Midwest'),
('Colorado','West'),
('Florida','South'),
('Georgia','South'),
('Illinois','Midwest');

-- table 2 (To show head of department) --

create table department_head(
department varchar(100) primary key,
head_name varchar(100)
);

insert into department_head(department,head_name) values
('Production','Robert King'),
('Marketing','Sarah Johnson'),
('IT','Michael Chen'),
('HR','Emma Davis'),
('Sales','David Lee');

-- Now we have 2 new tables that relate to employees table --

-- inner join ,Show employees + their region --
select
e.Employee_Name,
e.State,
s.region
from `ethnic diversity` e
inner join states_region s
on e.State = s.state;

-- left join , show everybody from left table (employees), even if region missing --

select 
e.Employee_Name,
e.State,
s.region
from `ethnic diversity` e
left join states_region s
on e.State = s.state;

-- right join , shows all rows from right table --

select 
e.Employee_Name,
e.State,
s.region
from `ethnic diversity` e
right join states_region s
on e.State = s.state;

-- Join with Department Head Table--
select
e.Employee_Name,
e.Department,
d.head_name
from `ethnic diversity` e
left join department_head d
on e.Department = d.department;

-- ADVANCED DATA ANALYSIS (HR + Diversity Analytics) --
-- Count Employees by Gender --

select Sex,count(*) as count
from `ethnic diversity`
group by Sex;

-- Count Employees by Race --

select Race,count(*) as total
from `ethnic diversity`
group by Race
order by total desc;

-- filter specific column in the table --
select Employee_Name,Salaries,age from `ethnic diversity`;

-- count total number of employees and sum by total salary --
select count(*) as total_employees,sum(Salaries) as total_salary from `ethnic diversity`;

-- Diversity % by State --
select
State,
Race,
count(*) as count_in_race,
round(100*count(*) / sum(count(*)) over (partition by State),2) as percent_in_state
-- (people of this race in the state / total people in the state) * 100 --
from `ethnic diversity`
group by State,Race
order by percent_in_state desc;

-- Most Common Job Titles --

select Position,count(*) as total
from `ethnic diversity`
group by Position
order by total desc
limit 10;

-- Average ZIP Code by Race --

select Race,avg(Zip) as avg_zip
from `ethnic diversity`
group by Race;

-- Window Functions --
-- finds the top employee (highest EmpID) from each State --
select * from 
(select 
Employee_Name,
State,
EmpID,
row_number() over (partition by State order by EmpID desc) as rn
from `ethnic diversity` 
)t -- THIS is the temporary table name
where rn = 1;

-- Rank Employees by EmpID Inside Each Department --
select 
Employee_Name,
Department,
EmpID,
rank() over (partition by Department order by EmpID desc) as rank_in_dept
from `ethnic diversity`;

-- implementing 3NF --

-- Creating the department table --

create table department(
dept_id int primary key auto_increment,
department_name varchar(150) unique
);

insert into department(department_name) 
select distinct Department from `ethnic diversity`;

-- Creating the position table -- 
create table position (
position_id int primary key auto_increment,
position_name varchar(100) unique
);

insert into position (position_name)
select distinct Position from `ethnic diversity`;

-- Creating the state table --
create table state(
state_id int primary key auto_increment,
state_name varchar(150),
zip int
);

insert into state(state_name,zip)
select distinct State,Zip from `ethnic diversity`;

-- Creating the race table --
create table race(
race_id int primary key auto_increment,
race_name varchar(100) unique
);

insert into race(race_name)
select distinct Race from `ethnic diversity`;

-- creating table for Marital Status --
create table marital_status(
marital_id int primary key auto_increment,
marital_desc varchar(50) unique
);

insert into  marital_status(marital_desc)
select distinct MaritalDesc from `ethnic diversity`;

-- creating table for Citizenship --
create table citizenship(
citizen_id int primary key auto_increment,
citizen_desc varchar(50) unique
);

insert into citizenship(citizen_desc)
select distinct CitizenDesc from `ethnic diversity`;

-- creating table for Employment Status --
create table employment_status(
emp_status_id int primary key auto_increment,
emp_status_desc varchar(50) unique
);

insert into employment_status(emp_status_desc)
select distinct EmploymentStatus from `ethnic diversity`;

-- creating table for gender --
create table gender(
gender_id int primary key auto_increment,
gender_desc varchar(20) unique 
);

insert into gender(gender_desc)
select distinct Sex from `ethnic diversity`;

-- Employee Table (final) --

create table employee(
emp_id int primary key,
employee_name varchar(300),
department_id int,
position_id int,
state_id int,
race_id int,
marital_id INT,
citizen_id INT,
gender_id INT,
emp_status_id INT,
foreign key (department_id) references department(dept_id),
foreign key (position_id) references position (position_id),
foreign key (state_id) references state(state_id),
foreign key (race_id) references race(race_id),
foreign key (marital_id) references marital_status(marital_id),
foreign key (citizen_id) references citizenship(citizen_id),
foreign key (gender_id) references gender(gender_id),
foreign key (emp_status_id) references employment_status(emp_status_id)
);

-- Populate Employee Table --

insert into employee (
emp_id,
employee_name,
department_id,
position_id,
state_id,
race_id,
marital_id,
citizen_id,
gender_id,
emp_status_id
)

select 
EmpID,
Employee_Name,
(select dept_id from department where department_name = e.Department),
(select position_id from position where position_name = e.Position),
(select state_id from state where state_name = e.State and zip = e.Zip),
(select race_id from race where race_name = e.Race),
(select marital_id from marital_status where marital_desc = e.MaritalDesc),
(select citizen_id from citizenship where citizen_desc = e.CitizenDesc),
(select gender_id from gender where gender_desc = e.Sex),
(select emp_status_id from employment_status where emp_status_desc = e.EmploymentStatus)
from `ethnic diversity` e;

select * from `ethnic diversity`;

-- This is clean, efficient, and professionally normalized