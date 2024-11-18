create or replace PROCEDURE GeneratePassengerDetails  
AS 
v_passenger_name varchar2(200);
v_passport_number varchar2(20);
v_destination varchar2(100); 
v_priority varchar2(50); 
v_NAME_EN UNESCO_SITES.NAME_EN%TYPE; 
v_STATES_NAME_EN UNESCO_SITES.STATES_NAME_EN%TYPE; 
v_clob clob; 
l_q_msg varchar2(200);
v_priority_int number;
ret number;

BEGIN 

     
     select  name  into v_passenger_name  from (select name from  RBANK_CUSTOMERS where country_id = 'US' ORDER BY DBMS_RANDOM.RANDOM) WHERE  rownum < 2;
     v_passport_number := dbms_random.string('x',10); 

     select   NAME_EN, STATES_NAME_EN into v_NAME_EN, v_STATES_NAME_EN 
               from (select NAME_EN, STATES_NAME_EN from UNESCO_SITES where STATES_NAME_EN = 'United States of America' ORDER BY DBMS_RANDOM.RANDOM) 
               WHERE  rownum < 2;  

     SELECT  
       CASE round(dbms_random.value(1,4))  
            WHEN 1 THEN 'Priority Security Lines'  
            WHEN 2 THEN 'Fast Track Services' 
            WHEN 3 THEN 'Lounge Access' 
            WHEN 4 THEN 'Meet and Greet Services' 
            WHEN 5 THEN 'Private Transportation'  END 
       AS priority into v_priority FROM dual;
 
    v_destination := v_NAME_EN||','||v_states_name_en;

    Insert into passenger_list   (PASSENGER_NAME, PASSPORT_NUMBER , DESTINATION, PRIORITY ) values  (v_passenger_name, v_passport_number,	v_destination, v_priority );
    l_q_msg := 'Name: '||v_passenger_name ||' Passport No: '||v_passport_number;

    if v_priority = 'Priority Security Lines' then
        v_priority_int := 1;
    elsif v_priority = 'Fast Track Services' then
        v_priority_int := 2;
    elsif v_priority = 'Lounge Access' then
        v_priority_int := 3; 
    elsif v_priority = 'Meet and Greet Services' then
        v_priority_int := 4;
    elsif v_priority = 'Private Transportation' then
        v_priority_int := 5;
    end if;


    -- Send msg and priority to Queue 
    ret := msgtoqueue (l_q_msg, v_priority_int);

END;
/