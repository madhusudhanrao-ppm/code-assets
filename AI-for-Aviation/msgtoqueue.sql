create or replace function msgtoqueue ( l_msg IN varchar2, l_priority IN number ) RETURN number
IS
 
      l_enqueue_options      DBMS_AQ.ENQUEUE_OPTIONS_T;
      l_message_properties   DBMS_AQ.MESSAGE_PROPERTIES_T;
      l_message_handle       RAW (16);
      l_queue_msg            passenger_q_payload;  
      l_q_name varchar2(400) := 'DEMOUSER.Airport_Checkin_Queue'; 

   BEGIN
      l_queue_msg := passenger_q_payload (l_msg);
      l_message_properties.priority := l_priority;  
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
/