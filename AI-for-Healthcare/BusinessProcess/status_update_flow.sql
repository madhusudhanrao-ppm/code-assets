--- Specs -----------

create or replace PACKAGE "BANK_PKG" as
    
    function update_application_status(
        cust_id in varchar2,
        status              in varchar2 )
        return                  varchar2;

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
    begin         
        -- since the income is less than 1000 by business rules they come under default rejection rule
        UPDATE BANK_CUSTOMERS SET ACCOUNT_STATUS = status WHERE ID = cust_id;
        return l_ret; 
    end update_application_status; 
    -- Update application status  
      
end;
/
