SELECT * FROM USER_QUEUES 
where QUEUE_TYPE='NORMAL_QUEUE'  

------------

DECLARE
 po_t dbms_aqadm.aq$_purge_options_t;
 q_table varchar2(100) := :P1_SELECTED_Q;
BEGIN
  dbms_aqadm.purge_queue_table(q_table, NULL, po_t);
END;

----------

DECLARE
 purge_opt dbms_aqadm.aq$_purge_options_t; 
 q_table varchar2(100) := :P1_SELECTED_Q; 
BEGIN
  -- Purge table ----
   dbms_aqadm.PURGE_QUEUE_TABLE(q_table, NULL, purge_opt);
  -- drop q table 
   DBMS_AQADM.DROP_QUEUE_TABLE( queue_table => q_table, force  => TRUE   ); 
END;

------------

DECLARE 
q_name varchar2(200) := :P1_SELECTED_Q;
v_n number; 
BEGIN 
       if q_name is not null then
        v_n := viewqueue ( q_name ); 
        end if;
END;

--------

create or replace function viewqueue ( name_in IN varchar2 ) RETURN number
IS
l_aisql AICHAT.AISQL%TYPE;
l_qry varchar2(4000); 
CUR1 SYS_REFCURSOR;  
l_rc              SYS_REFCURSOR; 
l_cursor_number   INTEGER;
l_col_cnt         INTEGER;
l_desc_tab        DBMS_SQL.desc_tab;
l_col_num         INTEGER;
l_colcount number := 0; 
tbl_name varchar2(200) := 'AQ$'||name_in;
v_recipients varchar2(200) := 'SINGLE'; 
bgcolor varchar2(100) := 'red';
fgcolor varchar2(100) := 'black';

TYPE myrec5 IS RECORD 
 (
   col1 VARCHAR(100),
   col2 VARCHAR(100),
   col3 VARCHAR(100),
   col4 VARCHAR(100),
   col5 VARCHAR(100),
   col6 VARCHAR(100)  
 ); 
 myrecord5 myrec5; 

 TYPE myrec6 IS RECORD 
 (
   col1 VARCHAR(100),
   col2 VARCHAR(100),
   col3 VARCHAR(100),
   col4 VARCHAR(100),
   col5 VARCHAR(100), 
   col6 VARCHAR(100),
   col7 VARCHAR(100)
 ); 
 myrecord6 myrec6; 

BEGIN 

    SELECT distinct RECIPIENTS into v_recipients FROM USER_QUEUES where QUEUE_TABLE = name_in;
 

    l_aisql := 'SELECT QUEUE, MSG_ID, MSG_PRIORITY, MSG_STATE, ENQ_TIMESTAMP, DEQ_TIMESTAMP  FROM '||tbl_name||' order by MSG_PRIORITY';  

    if v_recipients = 'MULTIPLE' then
        l_aisql := 'SELECT QUEUE, MSG_ID, MSG_PRIORITY, MSG_STATE, ENQ_TIMESTAMP, DEQ_TIMESTAMP, CONSUMER_NAME  FROM '||tbl_name||' order by MSG_PRIORITY';   
    end if;

    Htp.p (l_aisql||'<br/>');


    
                  l_qry := trim(l_aisql);  
                  Htp.p('<table border=0 cellspacing=2 cellpadding=2>'); 
                  OPEN l_rc FOR l_qry; 
                  l_cursor_number   := DBMS_SQL.to_cursor_number (l_rc); 
                  DBMS_SQL.describe_columns (l_cursor_number, l_col_cnt, l_desc_tab); 
                  l_col_num         := l_desc_tab.FIRST; 
                  IF (l_col_num IS NOT NULL) THEN
                    Htp.p('<tr>'); 
                    LOOP 
                       Htp.p(' <th><b>  '||l_desc_tab (l_col_num).col_name||'  </b> </th>   ');
                      l_colcount := l_colcount+1;
                      l_col_num   := l_desc_tab.NEXT (l_col_num);
                      EXIT WHEN (l_col_num IS NULL);
                    END LOOP;
                   Htp.p('</tr>'); 
                  END IF; 
                  DBMS_SQL.close_cursor (l_cursor_number); 
 
                  if (l_colcount = 6) then 
                        OPEN CUR1 FOR l_qry; 
                        LOOP
                        FETCH CUR1 INTO myrecord5;  
                            Htp.p('<tr  bgcolor=#F5F4F1  ><td>    '||myrecord5.col1||'    </td>
                                      <td>  '||myrecord5.col2||'  </td>
                                      <td>  '||myrecord5.col3||'  </td>
                                      <td>  '||myrecord5.col4||'  </td>
                                      <td>  '||myrecord5.col5||'  </td>
                                      <td>  '||myrecord5.col6||'  </td>
                                      <tr>');
                        EXIT WHEN CUR1%NOTFOUND; 
                        END LOOP;
                        Htp.p('</table>');       
                        CLOSE cur1; 
                    end if;  

                    if (l_colcount = 7) then 
                        OPEN CUR1 FOR l_qry; 
                        LOOP
                        FETCH CUR1 INTO myrecord6;  

                            if myrecord6.col3 = 'READY' then
                                bgcolor := '#F5F4F1';
                                fgcolor := 'black';
                            else
                                bgcolor := '#8B8B8A';
                                fgcolor := 'black';
                            end if;

                            Htp.p('<tr  bgcolor='||bgcolor||' color='||fgcolor||'><td>    '||myrecord6.col1||'    </td>
                                      <td>  '||myrecord6.col2||'  </td>
                                      <td>   '||myrecord6.col3||'  </td> ');  
                             Htp.p('  <td>  '||myrecord6.col4||'  </td>
                                      <td>  '||myrecord6.col5||'  </td>
                                      <td>  '||myrecord6.col6||'  </td>
                                      <td>  '||myrecord6.col7||'  </td>
                                      <tr>');
                        EXIT WHEN CUR1%NOTFOUND; 
                        END LOOP;
                        Htp.p('</table>');       
                        CLOSE cur1; 
                    end if;  


                Htp.p('</table>');   

    return 1;
END;
/

---------------------

DECLARE
   
      r_dequeue_options    DBMS_AQ.DEQUEUE_OPTIONS_T;
      r_message_properties DBMS_AQ.MESSAGE_PROPERTIES_T;
      v_message_handle     RAW(200);
      o_payload            passenger_q_payload;  
      v_dbusername varchar2(100) := V('DB_USERNAME') ;  
      v_qname varchar2(100) := v_dbusername||'.'||:P1_SINGLE_R;
   
   BEGIN 
    DBMS_AQ.DEQUEUE(
        queue_name         => v_qname,
        dequeue_options    => r_dequeue_options,
        message_properties => r_message_properties,
        payload            => o_payload, 
        msgid              => v_message_handle
         ); 
      :P1_SINGLE_R_MSG := '*** DEQUEUE message => ' || o_payload.message || ' ';
  
     COMMIT;
  
  END;

-------------

DECLARE
   
      r_dequeue_options    DBMS_AQ.DEQUEUE_OPTIONS_T;
      r_message_properties DBMS_AQ.MESSAGE_PROPERTIES_T;
      v_message_handle     RAW(16);
      o_payload            passenger_q_payload; 
      v_subs_name varchar2(100) := :P1_SUBSCRIBER_NAME;
      v_dbusername varchar2(100) := V('DB_USERNAME') ; 
      v_qname varchar2(100) := v_dbusername||'.'||:P1_MULTIPLE_R;
   
   BEGIN
    r_dequeue_options.consumer_name := v_subs_name; 
    r_dequeue_options.navigation := DBMS_AQ.FIRST_MESSAGE;
    DBMS_AQ.DEQUEUE(
        queue_name         => v_qname,
        dequeue_options    => r_dequeue_options,
        message_properties => r_message_properties,
        payload            => o_payload, 
        msgid              => v_message_handle
         );
          
      COMMIT;
      :P1_MULTI_MSG := '*** Dequeued message is [' || o_payload.message || '] ***' ;
     
  
  END;

  ---------------

  DECLARE
    v_qn varchar2(100) := :P1_QUEUE_NAME;
    v_qtab varchar2(100) := :P1_QT;
    v_qcomm varchar2(1000) := :P1_COMMENT; 
    v_qtype varchar2(100) := :P1_TYPE;
    v_qtype_bool boolean := false;
BEGIN 

    if v_qtype = 'Multi' then
        v_qtype_bool := true;
    end if;


    DBMS_AQADM.create_queue_table (
      queue_table          => v_qtab,
      queue_payload_type   => 'passenger_q_payload',
      sort_list          => 'PRIORITY,ENQ_TIME', 
      multiple_consumers   => v_qtype_bool,
      comment              => v_qcomm,
      secure => false);
 
    DBMS_AQADM.create_queue (queue_name    => v_qn,
                            queue_table   => v_qtab); 
    -- Start the event queue.
    DBMS_AQADM.start_queue (queue_name => v_qn);  
END;

--------------

DECLARE
      l_enqueue_options      DBMS_AQ.ENQUEUE_OPTIONS_T;
      l_message_properties   DBMS_AQ.MESSAGE_PROPERTIES_T;
      l_message_handle       RAW (16);
      l_queue_msg            passenger_q_payload;
      l_msg varchar2(400) := :P1_MESSAGE;
      v_dbusername varchar2(100) := V('DB_USERNAME') ; 
      l_q_name varchar2(400) := v_dbusername||'.'||:P1_Q_NAME;
      v_priority varchar2(100) := :P1_PRIORITY;
   BEGIN
      l_queue_msg := passenger_q_payload (l_msg);
      l_message_properties.priority := v_priority;  
      DBMS_AQ.ENQUEUE (queue_name           => l_q_name,
                       enqueue_options      => l_enqueue_options,
                       message_properties   => l_message_properties,
                       payload              => l_queue_msg,
                       msgid                => l_message_handle);
      COMMIT;
   EXCEPTION
      WHEN OTHERS
      THEN DBMS_OUTPUT.put_line ( SQLERRM || ' - ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
END;

----------

select distinct CONSUMER_NAME   from USER_QUEUE_SUBSCRIBERS where queue_name = :P1_Q_NAME

------------

DECLARE
v_subs_name varchar2(100) := :P1_SUBS_NAME;
v_q_name varchar2(100) := :P1_MULTIPLE_R2;
BEGIN 
  DBMS_AQADM.ADD_SUBSCRIBER 
  (queue_name => v_q_name, 
  subscriber => SYS.AQ$_AGENT(v_subs_name, v_q_name,NULL));  
END;

----------