-- SQLscripts.sql
-- Employee Payroll System - Table Creation and Data Population Scripts

-- Drop existing tables if they exist 
BEGIN
   EXECUTE IMMEDIATE 'DROP TABLE PAYROLL';
EXCEPTION
   WHEN OTHERS THEN NULL;
END;
/

BEGIN
   EXECUTE IMMEDIATE 'DROP TABLE EMPLOYEES';
EXCEPTION
   WHEN OTHERS THEN NULL;
END;
/

BEGIN
   EXECUTE IMMEDIATE 'DROP TABLE SALARY_GRADES';
EXCEPTION
   WHEN OTHERS THEN NULL;
END;
/

-- Create Salary_Grades table
CREATE TABLE Salary_Grades (
    grade_id NUMBER PRIMARY KEY,
    grade_name VARCHAR2(20) NOT NULL,
    min_salary NUMBER(10,2) NOT NULL,
    max_salary NUMBER(10,2) NOT NULL,
    tax_percentage NUMBER(5,2) DEFAULT 10.00,
    CONSTRAINT check_min_max_salary CHECK (min_salary < max_salary)
);

-- Create Employees table
CREATE TABLE Employees (
    emp_id NUMBER PRIMARY KEY,
    first_name VARCHAR2(50) NOT NULL,
    last_name VARCHAR2(50) NOT NULL,
    email VARCHAR2(100) UNIQUE NOT NULL,
    phone VARCHAR2(15),
    hire_date DATE DEFAULT SYSDATE NOT NULL,
    department VARCHAR2(50),
    position VARCHAR2(50),
    salary_grade NUMBER NOT NULL,
    base_salary NUMBER(10,2) NOT NULL,
    CONSTRAINT fk_salary_grade FOREIGN KEY (salary_grade) REFERENCES SALARY_GRADES(grade_id),
    CONSTRAINT check_base_salary CHECK (base_salary > 0)
);

-- Create Payroll table
CREATE TABLE Payroll (
    payroll_id NUMBER PRIMARY KEY,
    emp_id NUMBER NOT NULL,
    pay_period VARCHAR2(7) NOT NULL, 
    basic_pay NUMBER(10,2) NOT NULL,
    overtime_hours NUMBER(5,2) DEFAULT 0,
    overtime_pay NUMBER(10,2) DEFAULT 0,
    bonus NUMBER(10,2) DEFAULT 0,
    allowances NUMBER(10,2) DEFAULT 0,
    deductions NUMBER(10,2) DEFAULT 0,
    tax_amount NUMBER(10,2) DEFAULT 0,
    net_salary NUMBER(10,2) NOT NULL,
    payment_date DATE DEFAULT SYSDATE,
    status VARCHAR2(20) DEFAULT 'Pending',
    CONSTRAINT fk_emp_id FOREIGN KEY (emp_id) REFERENCES EMPLOYEES(emp_id),
    CONSTRAINT check_pay_period CHECK (REGEXP_LIKE(pay_period, '^[0-1][0-9]-[0-9]{4}$')),
    CONSTRAINT check_overtime_hours CHECK (overtime_hours >= 0),
    CONSTRAINT check_basic_pay CHECK (basic_pay > 0)
);

-- Insert data into Salary_Grades table
INSERT INTO Salary_Grades (grade_id, grade_name, min_salary, max_salary, tax_percentage)
VALUES (1, 'Entry Level', 30000.00, 45000.00, 10.00);

INSERT INTO Salary_Grades (grade_id, grade_name, min_salary, max_salary, tax_percentage)
VALUES (2, 'Junior', 45000.01, 65000.00, 15.00);

INSERT INTO Salary_Grades (grade_id, grade_name, min_salary, max_salary, tax_percentage)
VALUES (3, 'Mid-Level', 65000.01, 85000.00, 20.00);

INSERT INTO Salary_Grades (grade_id, grade_name, min_salary, max_salary, tax_percentage)
VALUES (4, 'Senior', 85000.01, 110000.00, 25.00);

INSERT INTO Salary_Grades (grade_id, grade_name, min_salary, max_salary, tax_percentage)
VALUES (5, 'Executive', 110000.01, 200000.00, 30.00);

-- Insert data into Employees table
INSERT INTO Employees (emp_id, first_name, last_name, email, phone, hire_date, department, position, salary_grade, base_salary)
VALUES (1001, 'Kamal', 'Perera', 'kamal.perera@gmail.com', '077-1234567', TO_DATE('15-JAN-2020', 'DD-MON-YYYY'), 'IT', 'Developer', 2, 60000.00);

INSERT INTO Employees (emp_id, first_name, last_name, email, phone, hire_date, department, position, salary_grade, base_salary)
VALUES (1002, 'Nadeesha', 'Fernando', 'nadeesha.fernando@yahoo.com', '071-9876543', TO_DATE('05-MAR-2021', 'DD-MON-YYYY'), 'HR', 'HR Manager', 3, 75000.00);

INSERT INTO Employees (emp_id, first_name, last_name, email, phone, hire_date, department, position, salary_grade, base_salary)
VALUES (1003, 'Tharindu', 'Jayasinghe', 'tharindu.j@outlook.com', '075-4567890', TO_DATE('12-JUN-2019', 'DD-MON-YYYY'), 'Finance', 'Accountant', 2, 55000.00);

INSERT INTO Employees (emp_id, first_name, last_name, email, phone, hire_date, department, position, salary_grade, base_salary)
VALUES (1004, 'Ruwani', 'Gunasekara', 'ruwani.gunasekara@gmail.com', '076-1122334', TO_DATE('08-AUG-2018', 'DD-MON-YYYY'), 'Marketing', 'Marketing Specialist', 2, 58000.00);

INSERT INTO Employees (emp_id, first_name, last_name, email, phone, hire_date, department, position, salary_grade, base_salary)
VALUES (1005, 'Sachintha', 'Dissanayake', 'sachintha.d@gmail.com', '070-3344556', TO_DATE('20-NOV-2017', 'DD-MON-YYYY'), 'IT', 'Senior Developer', 4, 92000.00);

INSERT INTO EmployeesS (emp_id, first_name, last_name, email, phone, hire_date, department, position, salary_grade, base_salary)
VALUES (1006, 'Liya', 'Manawadu', 'liya.m@gmail.com', '555-6789', TO_DATE('14-APR-2022', 'DD-MON-YYYY'), 'IT', 'Junior Developer', 1, 42000.00);

-- Insert data into Payroll table
INSERT INTO Payroll (payroll_id, emp_id, pay_period, basic_pay, overtime_hours, overtime_pay, bonus, allowances, deductions, tax_amount, net_salary, payment_date, status)
VALUES (10001, 1001, '01-2023', 5000.00, 5.0, 625.00, 0.00, 200.00, 100.00, 860.75, 4864.25, TO_DATE('01-FEB-2023', 'DD-MON-YYYY'), 'Paid');

INSERT INTO Payroll (payroll_id, emp_id, pay_period, basic_pay, overtime_hours, overtime_pay, bonus, allowances, deductions, tax_amount, net_salary, payment_date, status)
VALUES (10002, 1002, '01-2023', 6250.00, 0.0, 0.00, 500.00, 300.00, 150.00, 1380.00, 5520.00, TO_DATE('01-FEB-2023', 'DD-MON-YYYY'), 'Paid');

INSERT INTO Payroll (payroll_id, emp_id, pay_period, basic_pay, overtime_hours, overtime_pay, bonus, allowances, deductions, tax_amount, net_salary, payment_date, status)
VALUES (10003, 1003, '01-2023', 4583.33, 2.0, 229.17, 0.00, 150.00, 120.00, 727.88, 4114.62, TO_DATE('01-FEB-2023', 'DD-MON-YYYY'), 'Paid');

INSERT INTO Payroll (payroll_id, emp_id, pay_period, basic_pay, overtime_hours, overtime_pay, bonus, allowances, deductions, tax_amount, net_salary, payment_date, status)
VALUES (10004, 1004, '01-2023', 4833.33, 0.0, 0.00, 200.00, 180.00, 100.00, 768.50, 4344.83, TO_DATE('01-FEB-2023', 'DD-MON-YYYY'), 'Paid');

INSERT INTO Payroll (payroll_id, emp_id, pay_period, basic_pay, overtime_hours, overtime_pay, bonus, allowances, deductions, tax_amount, net_salary, payment_date, status)
VALUES (10005, 1005, '01-2023', 7666.67, 0.0, 0.00, 1000.00, 500.00, 200.00, 2291.67, 6675.00, TO_DATE('01-FEB-2023', 'DD-MON-YYYY'), 'Paid');

COMMIT;

-- Display sample data to verify the tables
SELECT * FROM Salary_Grades;
SELECT * FROM Employees;
SELECT * FROM Payroll;
