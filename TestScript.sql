-- TestScript.sql
-- Employee Payroll System - Test Scripts (Anonymous PL/SQL Blocks)

SET SERVEROUTPUT ON;

-- Test 1: Testing proc_emp_monthly_payroll procedure
-- This will process payroll for Employee ID 1001 for February 2023 with overtime and bonus
DECLARE
    v_emp_id NUMBER := 1001;
    v_pay_period VARCHAR2(7) := '02-2023';
    v_overtime_hours NUMBER := 8.5;
    v_bonus NUMBER := 500;
    v_allowances NUMBER := 250;
    v_deductions NUMBER := 125;
BEGIN
    DBMS_OUTPUT.PUT_LINE('TEST 1: Processing payroll for a single employee');
    DBMS_OUTPUT.PUT_LINE('---------------------------------------------------');
    
    proc_emp_monthly_payroll(
        p_emp_id => v_emp_id,
        p_pay_period => v_pay_period,
        p_overtime_hours => v_overtime_hours,
        p_bonus => v_bonus,
        p_allowances => v_allowances,
        p_deductions => v_deductions
    );
    
    -- Try to process the same payroll again (should generate an error)
    DBMS_OUTPUT.PUT_LINE('---------------------------------------------------');
    DBMS_OUTPUT.PUT_LINE('Attempting to process the same payroll again (should fail):');
    proc_emp_monthly_payroll(
        p_emp_id => v_emp_id,
        p_pay_period => v_pay_period
    );
    
    -- Try with invalid employee ID (should generate an error)
    DBMS_OUTPUT.PUT_LINE('---------------------------------------------------');
    DBMS_OUTPUT.PUT_LINE('Attempting to process payroll for non-existent employee (should fail):');
    proc_emp_monthly_payroll(
        p_emp_id => 9999,
        p_pay_period => v_pay_period
    );
    
    -- Try with invalid pay period format (should generate an error)
    DBMS_OUTPUT.PUT_LINE('---------------------------------------------------');
    DBMS_OUTPUT.PUT_LINE('Attempting to process payroll with invalid pay period format (should fail):');
    proc_emp_monthly_payroll(
        p_emp_id => v_emp_id,
        p_pay_period => '2-2023' 
    );
    
    -- Try with negative overtime hours (should generate an error)
    DBMS_OUTPUT.PUT_LINE('---------------------------------------------------');
    DBMS_OUTPUT.PUT_LINE('Attempting to process payroll with negative overtime hours (should fail):');
    proc_emp_monthly_payroll(
        p_emp_id => v_emp_id,
        p_pay_period => '03-2023',
        p_overtime_hours => -5
    );
END;
/




-- Test 2: Testing proc_batch_payroll procedure
-- This will process payroll for all employees for March 2023
DECLARE
    v_pay_period VARCHAR2(7) := '03-2023';
BEGIN
    DBMS_OUTPUT.PUT_LINE('TEST 2: Processing batch payroll for all employees');
    DBMS_OUTPUT.PUT_LINE('---------------------------------------------------');
    
    proc_batch_payroll(p_pay_period => v_pay_period);
    
    -- Try to process the same pay period again (some should be skipped)
    DBMS_OUTPUT.PUT_LINE('---------------------------------------------------');
    DBMS_OUTPUT.PUT_LINE('Attempting to process the same pay period again (some should be skipped):');
    proc_batch_payroll(p_pay_period => v_pay_period);
    
    -- Try with invalid pay period format
    DBMS_OUTPUT.PUT_LINE('---------------------------------------------------');
    DBMS_OUTPUT.PUT_LINE('Attempting to process batch payroll with invalid pay period format (should fail):');
    proc_batch_payroll(p_pay_period => '3-2023');  -- Invalid format, should be MM-YYYY
END;
/




-- Test 3: Testing func_calculate_annual_tax function
-- This will calculate annual tax for Employee ID 1001 for year 2023
DECLARE
    v_emp_id NUMBER := 1001;
    v_year VARCHAR2(4) := '2023';
    v_annual_tax NUMBER;
BEGIN
    DBMS_OUTPUT.PUT_LINE('TEST 3: Calculating annual tax for an employee');
    DBMS_OUTPUT.PUT_LINE('---------------------------------------------------');
    
    -- Calculate annual tax for employee 1001 for year 2023
    v_annual_tax := func_calculate_annual_tax(
        p_emp_id => v_emp_id,
        p_year => v_year
    );
    
    DBMS_OUTPUT.PUT_LINE('Annual tax for Employee ID ' || v_emp_id || ' for year ' || v_year || ': ' || 
                        TO_CHAR(NVL(v_annual_tax, 0), '999,999.99'));
    
    -- Test with a non-existent employee
    DBMS_OUTPUT.PUT_LINE('---------------------------------------------------');
    DBMS_OUTPUT.PUT_LINE('Testing with non-existent employee (should show error):');
    v_annual_tax := func_calculate_annual_tax(
        p_emp_id => 9909,
        p_year => v_year
    );
    
    IF v_annual_tax IS NULL THEN
        DBMS_OUTPUT.PUT_LINE('Function returned NULL as expected.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Function returned: ' || TO_CHAR(v_annual_tax, '999,999.99'));
    END IF;
    
    -- Test with invalid year format
    DBMS_OUTPUT.PUT_LINE('---------------------------------------------------');
    DBMS_OUTPUT.PUT_LINE('Testing with invalid year format (should show error):');
    v_annual_tax := func_calculate_annual_tax(
        p_emp_id => v_emp_id,
        p_year => '25' 
    );
    
    IF v_annual_tax IS NULL THEN
        DBMS_OUTPUT.PUT_LINE('Function returned NULL as expected.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Function returned: ' || TO_CHAR(v_annual_tax, '999,999.99'));
    END IF;
    
    -- Test with a year that has no payroll records
    DBMS_OUTPUT.PUT_LINE('---------------------------------------------------');
    DBMS_OUTPUT.PUT_LINE('Testing with a year that has no payroll records (should return 0):');
    v_annual_tax := func_calculate_annual_tax(
        p_emp_id => v_emp_id,
        p_year => '2025'  
    );
    
    DBMS_OUTPUT.PUT_LINE('Annual tax for Employee ID ' || v_emp_id || ' for year 2025: ' || 
                        TO_CHAR(NVL(v_annual_tax, 0), '999,999.99'));
END;
/



-- Test 4: Testing func_get_total_earnings
-- This will calculate total earning for payroll_id 10002
DECLARE v_total_earnings NUMBER;

BEGIN v_total_earnings := func_get_total_earnings(10002);
    DBMS_OUTPUT.PUT_LINE('TEST 4: Calculate total earning for payroll_id 10002');
    DBMS_OUTPUT.PUT_LINE('---------------------------------------------------');
    DBMS_OUTPUT.PUT_LINE('Total earnings for Payroll ID 10002: ' || v_total_earnings);

END;

/