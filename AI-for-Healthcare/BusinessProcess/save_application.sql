declare 

l_bank_customer BANK_CUSTOMERS.CUSTOMER_NAME%TYPE := :P58_CUSTOMER_NAME;
l_dob BANK_CUSTOMERS.DOB%TYPE := :P58_DOB;
l_account_number BANK_CUSTOMERS.ACCOUNT_NUMBER%TYPE := round(DBMS_Random.Value(1,990000),0);  
l_gender BANK_CUSTOMERS.GENDER%TYPE := :P58_GENDER;
l_martial_status BANK_CUSTOMERS.MARITAL_STATUS%TYPE := :P58_MARITAL_STATUS;
l_relation_ref BANK_CUSTOMERS.REFERENCE_RELATION%TYPE := :P58_REFERENCE_RELATION;
l_ref_name BANK_CUSTOMERS.REFERENCE_NAME%TYPE := :P58_REFERENCE_NAME; 
l_edu_qualif BANK_CUSTOMERS.EDUCATIONAL_QUALIFICATION%TYPE := :P58_EDUCATIONAL_QUALIFICATION;
l_occ_type BANK_CUSTOMERS.OCCUPATION_TYPE%TYPE := :P58_OCCUPATION_TYPE;
l_income_level BANK_CUSTOMERS.CUST_INCOME_LEVEL%TYPE := :P58_CUST_INCOME_LEVEL;
l_street BANK_CUSTOMERS.STREET_ADDRESS%TYPE := :P58_STREET_ADDRESS;
l_city BANK_CUSTOMERS.CITY%TYPE := :P58_CITY;
l_state BANK_CUSTOMERS.STATE_PROVINCE%TYPE := :P58_STATE; 
l_postcode BANK_CUSTOMERS.CUST_POSTAL_CODE%TYPE := :P58_POSTAL_CODE;
l_phone BANK_CUSTOMERS.PHONE_NUMBER%TYPE := :P58_MOBILE_NUMBER;
l_country BANK_CUSTOMERS.COUNTRY%TYPE := :P58_COUNTRY; 
l_bank BANK_CUSTOMERS.BANK_NAME%TYPE := :P58_BANK_NAME; 
o_cust_id BANK_CUSTOMERS.ID%TYPE;

l_task_id number;
l_user varchar2(100) := v('APP_USER');
l_workflow_id number;

begin
    insert into BANK_CUSTOMERS (CUSTOMER_NAME, DOB, ACCOUNT_TYPE, ACCOUNT_NUMBER, GENDER, MARITAL_STATUS, REFERENCE_RELATION, REFERENCE_NAME,
    EDUCATIONAL_QUALIFICATION, OCCUPATION_TYPE, CUST_INCOME_LEVEL, STREET_ADDRESS, CITY, STATE_PROVINCE, CUST_POSTAL_CODE, PHONE_NUMBER, COUNTRY,
    CURRENT_BALANCE, BANK_NAME  ) 
    values 
    (l_bank_customer, l_dob, 'Savings Bank', l_account_number, l_gender, l_martial_status, l_relation_ref, l_ref_name, l_edu_qualif, l_occ_type, l_income_level,
    l_street, l_city, l_state, l_postcode, l_phone, l_country, 10000, l_bank )
    RETURNING ID INTO o_cust_id;  

    commit;
 
   --- Invoke Workflow -------------------
   l_workflow_id := 
    apex_workflow.start_workflow 
      (p_static_id      => 'MYBANKWF',
       p_detail_pk      => o_cust_id,
       p_initiator      => UPPER(l_user),
       p_parameters     => apex_workflow.t_workflow_parameters
                            (1 => apex_workflow.t_workflow_parameter(static_id => 'P_ACCOUNT_NUMBER', string_value => l_account_number),
                             2 => apex_workflow.t_workflow_parameter(static_id => 'P_CUSTOMER_ID', string_value => o_cust_id),
                             3 => apex_workflow.t_workflow_parameter(static_id => 'P_CUSTOMER_NAME', string_value => l_bank_customer),
                             4 => apex_workflow.t_workflow_parameter(static_id => 'P_INCOME_LEVEL', string_value => l_income_level)),
       p_debug_level => apex_debug.c_log_level_info);

    :P58_ACCOUNT_NUMBER := l_account_number;
    :P58_CUST_ID := o_cust_id;
end;
