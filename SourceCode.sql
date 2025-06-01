-- SourceCode.sql
-- Employee Payroll System - PL/SQL Source Code

-- PROCEDURE 1: Process Monthly Payroll for an Employee
CREATE OR REPLACE PROCEDURE proc_emp_monthly_payroll(
    p_emp_id IN NUMBER,
    p_pay_period IN VARCHAR2,
    p_overtime_hours IN NUMBER DEFAULT 0,
    p_bonus IN NUMBER DEFAULT 0,
    p_allowances IN NUMBER DEFAULT 0,
    p_deductions IN NUMBER DEFAULT 0
) 
IS
    v_employee_exists NUMBER;
    v_payroll_exists NUMBER;
    v_basic_pay NUMBER(10,2);
    v_tax_percentage NUMBER(5,2);
    v_overtime_rate NUMBER(5,2) := 1.5;
    v_overtime_pay NUMBER(10,2);
    v_hourly_rate NUMBER(10,2);
    v_tax_amount NUMBER(10,2);
    v_net_salary NUMBER(10,2);
    v_payroll_id NUMBER;
    v_grade_id NUMBER;
    
    -- Exceptions
    e_employee_not_found EXCEPTION;
    e_payroll_exists EXCEPTION;
    e_invalid_overtime EXCEPTION;
    e_invalid_pay_period EXCEPTION;
BEGIN
    -- Check if employee exists
    SELECT COUNT(*) INTO v_employee_exists
    FROM EMPLOYEES
    WHERE emp_id = p_emp_id;
    
    IF v_employee_exists = 0 THEN
        RAISE e_employee_not_found;
    END IF;
    
    -- Check if pay period format is valid (MM-YYYY)
    IF NOT REGEXP_LIKE(p_pay_period, '^[0-1][0-9]-[0-9]{4}$') THEN
        RAISE e_invalid_pay_period;
    END IF;
    
    -- Check if payroll record already exists for this employee and pay period
    SELECT COUNT(*) INTO v_payroll_exists
    FROM PAYROLL
    WHERE emp_id = p_emp_id AND pay_period = p_pay_period;
    
    IF v_payroll_exists > 0 THEN
        RAISE e_payroll_exists;
    END IF;
    
    -- Check if overtime hours are valid
    IF p_overtime_hours < 0 THEN
        RAISE e_invalid_overtime;
    END IF;
    
    -- Get employee's base salary and grade id
    SELECT base_salary, salary_grade INTO v_basic_pay, v_grade_id
    FROM EMPLOYEES
    WHERE emp_id = p_emp_id;
    
    -- Get tax percentage for the employee's salary grade
    SELECT tax_percentage INTO v_tax_percentage
    FROM SALARY_GRADES
    WHERE grade_id = v_grade_id;
    
    -- Calculate monthly basic pay (assuming base salary is annual)
    v_basic_pay := v_basic_pay / 12;
    
    -- Calculate hourly rate (assuming 160 working hours per month)
    v_hourly_rate := v_basic_pay / 160;
    
    -- Calculate overtime pay
    v_overtime_pay := p_overtime_hours * v_hourly_rate * v_overtime_rate;
    
    -- Calculate tax amount
    v_tax_amount := ((v_basic_pay + v_overtime_pay + p_bonus + p_allowances) * v_tax_percentage) / 100;
    
    -- Calculate net salary
    v_net_salary := v_basic_pay + v_overtime_pay + p_bonus + p_allowances - p_deductions - v_tax_amount;
    
    -- Generate next payroll ID
    SELECT NVL(MAX(payroll_id), 10000) + 1 INTO v_payroll_id
    FROM PAYROLL;
    
    -- Insert payroll record
    INSERT INTO PAYROLL (
        payroll_id, emp_id, pay_period, basic_pay, overtime_hours, overtime_pay,
        bonus, allowances, deductions, tax_amount, net_salary, payment_date, status
    ) VALUES (
        v_payroll_id, p_emp_id, p_pay_period, v_basic_pay, p_overtime_hours, v_overtime_pay,
        p_bonus, p_allowances, p_deductions, v_tax_amount, v_net_salary, SYSDATE, 'Pending'
    );
    
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Payroll processed successfully for employee ID: ' || p_emp_id);
    DBMS_OUTPUT.PUT_LINE('Pay period: ' || p_pay_period);
    DBMS_OUTPUT.PUT_LINE('Basic pay: $' || TO_CHAR(v_basic_pay, '999,999.99'));
    DBMS_OUTPUT.PUT_LINE('Overtime pay: $' || TO_CHAR(v_overtime_pay, '999,999.99'));
    DBMS_OUTPUT.PUT_LINE('Bonus: $' || TO_CHAR(p_bonus, '999,999.99'));
    DBMS_OUTPUT.PUT_LINE('Allowances: $' || TO_CHAR(p_allowances, '999,999.99'));
    DBMS_OUTPUT.PUT_LINE('Deductions: $' || TO_CHAR(p_deductions, '999,999.99'));
    DBMS_OUTPUT.PUT_LINE('Tax amount: $' || TO_CHAR(v_tax_amount, '999,999.99'));
    DBMS_OUTPUT.PUT_LINE('Net salary: $' || TO_CHAR(v_net_salary, '999,999.99'));
    
EXCEPTION
    WHEN e_employee_not_found THEN
        DBMS_OUTPUT.PUT_LINE('ERROR: Employee with ID ' || p_emp_id || ' not found.');
        ROLLBACK;
    WHEN e_payroll_exists THEN
        DBMS_OUTPUT.PUT_LINE('ERROR: Payroll record already exists for employee ID ' || p_emp_id || ' in period ' || p_pay_period);
        ROLLBACK;
    WHEN e_invalid_overtime THEN
        DBMS_OUTPUT.PUT_LINE('ERROR: Overtime hours cannot be negative.');
        ROLLBACK;
    WHEN e_invalid_pay_period THEN
        DBMS_OUTPUT.PUT_LINE('ERROR: Invalid pay period format. Use MM-YYYY format (e.g., 01-2023).');
        ROLLBACK;
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('ERROR: ' || SQLERRM);
        ROLLBACK;
END proc_emp_monthly_payroll;
/




-- PROCEDURE 2 - Process Batch Payroll for All Employees
CREATE OR REPLACE PROCEDURE proc_batch_payroll(
    p_pay_period IN VARCHAR2
)
IS
    -- Define a record type based on EMPLOYEES table
    TYPE emp_record_type IS RECORD (
        emp_id EMPLOYEES.emp_id%TYPE,
        first_name EMPLOYEES.first_name%TYPE,
        last_name EMPLOYEES.last_name%TYPE,
        department EMPLOYEES.department%TYPE
    );
    
    -- Define a cursor to fetch all active employees
    CURSOR c_employees IS
        SELECT emp_id, first_name, last_name, department
        FROM EMPLOYEES
        ORDER BY department, last_name, first_name;
    
    -- Variables
    v_emp_rec emp_record_type;
    v_payroll_exists NUMBER;
    v_processed_count NUMBER := 0;
    v_error_count NUMBER := 0;
    
    
    -- Exceptions
    e_invalid_pay_period EXCEPTION;
    e_no_employees EXCEPTION;
BEGIN
    -- Check if pay period format is valid (MM-YYYY)
    IF NOT REGEXP_LIKE(p_pay_period, '^[0-1][0-9]-[0-9]{4}$') THEN
        RAISE e_invalid_pay_period; 
    END IF;
    
    -- Open cursor and process each employee
    OPEN c_employees;
    
    -- Check if there are any employees
    IF c_employees%NOTFOUND THEN
        CLOSE c_employees;
        RAISE e_no_employees;
    END IF;
    
    DBMS_OUTPUT.PUT_LINE('Starting batch payroll processing for period: ' || p_pay_period);
    DBMS_OUTPUT.PUT_LINE('---------------------------------------------------');
    
    -- Process each employee
    LOOP
        FETCH c_employees INTO v_emp_rec;
        EXIT WHEN c_employees%NOTFOUND;
        
        -- Check if payroll already exists for this employee and period
        -- If period that user enter has any employee have payroll in database then it add into v_payroll_exit
        SELECT COUNT(*) INTO v_payroll_exists
        FROM PAYROLL
        WHERE emp_id = v_emp_rec.emp_id AND pay_period = p_pay_period;
        
        IF v_payroll_exists = 0 THEN
            BEGIN
                -- Process payroll for this employee with default values (no overtime or bonus) using procedure1
                proc_emp_monthly_payroll(v_emp_rec.emp_id, p_pay_period);
                v_processed_count := v_processed_count + 1;
                
                DBMS_OUTPUT.PUT_LINE('Processed: ' || v_emp_rec.first_name || ' ' || v_emp_rec.last_name || 
                                     ' (ID: ' || v_emp_rec.emp_id || ', Dept: ' || v_emp_rec.department || ')');
            EXCEPTION
                WHEN OTHERS THEN
                    v_error_count := v_error_count + 1;
                    DBMS_OUTPUT.PUT_LINE('Error processing employee ID ' || v_emp_rec.emp_id || ': ' || SQLERRM);
            END;
        ELSE
            DBMS_OUTPUT.PUT_LINE('Skipped: Payroll already exists for employee ID ' || v_emp_rec.emp_id || ' in period ' || p_pay_period);
        END IF;
    END LOOP;
    
    -- close the cursor
    CLOSE c_employees;
    
    DBMS_OUTPUT.PUT_LINE('---------------------------------------------------');
    DBMS_OUTPUT.PUT_LINE('Batch processing complete.');
    DBMS_OUTPUT.PUT_LINE('Total employees processed: ' || v_processed_count);
    DBMS_OUTPUT.PUT_LINE('Total errors: ' || v_error_count);
    
EXCEPTION
    WHEN e_invalid_pay_period THEN
        DBMS_OUTPUT.PUT_LINE('ERROR: Invalid pay period format. Use MM-YYYY format (e.g. 01-2023).');
    WHEN e_no_employees THEN
        DBMS_OUTPUT.PUT_LINE('ERROR: No employees found in the database.');
    WHEN OTHERS THEN
        IF c_employees%ISOPEN THEN
            CLOSE c_employees;
        END IF;
        DBMS_OUTPUT.PUT_LINE('ERROR: ' || SQLERRM);
END proc_batch_payroll;
/




-- FUNCTION 1: Calculate Annual Tax for an Employee
CREATE OR REPLACE FUNCTION func_calculate_annual_tax(
    p_emp_id IN NUMBER,
    p_year IN VARCHAR2
) RETURN NUMBER
IS
    v_annual_tax NUMBER(12,2) := 0;
    v_employee_exists NUMBER;
    
    -- Cursor to fetch all payroll records for the employee in the specified year
    CURSOR c_payroll IS
        SELECT tax_amount
        FROM PAYROLL
        WHERE emp_id = p_emp_id AND SUBSTR(pay_period, 4, 4) = p_year AND status = 'Paid';
    
    -- Exceptions
    e_invalid_year EXCEPTION;
    e_employee_not_found EXCEPTION;
    e_no_payroll_records EXCEPTION;
BEGIN
    -- Validate year format (4 digits)
    IF NOT REGEXP_LIKE(p_year, '^[0-9]{4}$') THEN
        RAISE e_invalid_year;
    END IF;
    
    -- Check if employee exists
    SELECT COUNT(*) INTO v_employee_exists
    FROM EMPLOYEES
    WHERE emp_id = p_emp_id;
    
    IF v_employee_exists = 0 THEN
        RAISE e_employee_not_found;
    END IF;
    
    -- Calculate total tax from all payroll records for the year
    FOR rec IN c_payroll LOOP
        v_annual_tax := v_annual_tax + rec.tax_amount;
    END LOOP;
    
    -- Check if any payroll records were found
    IF v_annual_tax = 0 THEN
        -- Check if there are any records regardless of status
        DECLARE
            v_any_records NUMBER;
        BEGIN
            SELECT COUNT(*) INTO v_any_records
            FROM PAYROLL
            WHERE emp_id = p_emp_id
            AND SUBSTR(pay_period, 4, 4) = p_year;
            
            IF v_any_records = 0 THEN
                RAISE e_no_payroll_records;
            END IF;
        END;
    END IF;
    
    RETURN v_annual_tax;
    
EXCEPTION
    WHEN e_employee_not_found THEN
        DBMS_OUTPUT.PUT_LINE('ERROR: Employee with ID ' || p_emp_id || ' not found.');
        RETURN NULL;
    WHEN e_invalid_year THEN
        DBMS_OUTPUT.PUT_LINE('ERROR: Invalid year format. Use YYYY format (e.g., 2023).');
        RETURN NULL;
    WHEN e_no_payroll_records THEN
        DBMS_OUTPUT.PUT_LINE('WARNING: No payroll records found for employee ID ' || p_emp_id || ' in year ' || p_year);
        RETURN 0;
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('ERROR: ' || SQLERRM);
        RETURN NULL;
END func_calculate_annual_tax;
/




-- FUNCTION 2: Calculate Total Earning According to payroll_id
CREATE OR REPLACE FUNCTION func_get_total_earnings(p_payroll_id IN NUMBER) RETURN NUMBER IS
    v_total NUMBER(10,2);
BEGIN
    SELECT basic_pay + NVL(overtime_pay,0) + NVL(bonus,0) + NVL(allowances,0)
    INTO v_total
    FROM Payroll
    WHERE payroll_id = p_payroll_id;

    RETURN v_total;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('No payroll record found.');
        RETURN 0;
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Unexpected error: ' || SQLERRM);
        RETURN 0;
END func_get_total_earnings;
/