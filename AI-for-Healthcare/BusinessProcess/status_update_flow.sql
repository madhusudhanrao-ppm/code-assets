--- Specs -----------

create or replace PACKAGE "BANK_PKG" as
    
    function update_application_status(
        cust_id in varchar2,
        status              in varchar2 )
        return                  varchar2;

    function update_card_status(
        cc_no in varchar2,
        status in varchar2,
        comments in varchar2  ) return varchar2;

end;
/
 

---- Package Body --------
--- Accept input as temporary customer id (cust_id) and status = Reject or Approved
create or replace PACKAGE BODY "BANK_PKG" as 
    c_app_id       constant varchar2(6) := 'APP_ID';


     -- Update application status  
    function update_application_status(
                cust_id in varchar2,  
                status in varchar2)
                return varchar2
    is 
        l_ret varchar2(100) := 'TRUE';  
        l_current_user varchar2(200) := apex_application.g_user; 
        l_email varchar2(128);
    begin         
        -- since the income is less than 1000 by business rules they come under default rejection rule
        UPDATE BANK_CUSTOMERS SET ACCOUNT_STATUS = status WHERE ID = cust_id;

        -- if the application status is approved then change the role from user to bank customer
        -- Bank Customers will be in Role 2 ( depending upon your customer roles table role_id )
        if status = 'Approved' then
            SELECT EMAIL INTO l_email FROM BANK_CUSTOMERS WHERE ID = cust_id;
            UPDATE COMMON_USERS SET ROLE_ID = 2 WHERE EMAIL = l_email;
        end if;
         

        return l_ret; 
    end update_application_status; 


    -- Update card status  
     function update_card_status(
                cc_no in varchar2,  
                status in varchar2,
                comments in varchar2)
                return varchar2
    is 
        l_ret varchar2(100) := 'TRUE';  
        --l_current_user varchar2(200) := apex_application.g_user; 
    begin         
        -- since the income is less than 1000 by business rules they come under default rejection rule
        UPDATE cc_fd SET status = status, comments = comments WHERE cc_no = cc_no;
        return l_ret; 
    end update_card_status; 
      
end;
/
