DECLARE 
  card_number VARCHAR2(100) := ''; 
  card_number_begin number := '1'; 
  i NUMBER := 1; 
  l_status varchar2(10) := 'OnHold';
BEGIN 
     
    card_number_begin :=  CASE 
                          WHEN round(dbms_random.value(1,2)) = 1 THEN '4' -- Visa starts with 4
                          WHEN round(dbms_random.value(1,2)) = 2 THEN '5' -- Mastercard starts with 2 or 5 
                    END;  
    if card_number_begin is null then
        card_number_begin := 2; -- Mastercard starts with 2 or 5
    end if;  
    
  -- Generate remaining digits 
    WHILE i < 16 LOOP  
        card_number :=  card_number ||  round(DBMS_Random.Value(0,9),0);    
        i := i + 1; 
    END LOOP;  
  
--   -- Add the check digit 
   card_number := card_number_begin || card_number; 
   
   insert into CC_FD (CUST_ID, FIRST_NAME, CC_NO, STATUS ) values (:cust_id, :customer_name, card_number, l_status );
    
   commit;

END; 
