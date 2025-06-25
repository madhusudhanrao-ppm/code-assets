declare
l_job_id varchar2(500);
l_response CLOB; 
l_status VARCHAR2(20);

CURSOR C1  IS 
            SELECT job_id from RAG_FILES where status = 'ACCEPTED' or status = 'IN_PROGRESS'; 

begin 

    apex_web_service.clear_request_headers;
    apex_web_service.set_request_headers(
        p_name_01  => 'Content-Type',
        p_value_01 => 'application/pdf'
    );

For row_1 In C1 Loop
           l_job_id := row_1.job_id;  
           --------- Based on Job Id check status --------
           -- Get the Data Ingestion Job Id from Database table that was created and saved during file upload process. 
            l_response := apex_web_service.make_rest_request(
                p_url => 'https://agent.generativeai.us-chicago-1.oci.oraclecloud.com/20240531/dataIngestionJobs/' || l_job_id,
                p_http_method => 'GET',
                p_credential_static_id => '<Your-Credentials>'
            );
            l_status := json_value(l_response, '$.lifecycleState');
           --------- Based on Job Id check status --------
           --------- Update  STATUS
           update RAG_FILES set status = l_status where job_id = l_job_id;
     End Loop;

end;
