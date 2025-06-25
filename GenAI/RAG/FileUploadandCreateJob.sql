DECLARE
    l_file_content BLOB;
    l_response     CLOB;
    l_body         CLOB;
    l_request_url varchar2(32767);
    l_content_length number;
    l_request_object blob;
    l_request_filename varchar2(500);
    upload_failed_exception exception;
    l_job_status varchar2(20);
    l_job_id VARCHAR2(255);
    l_rag_pdf_fileid varchar2(500);

BEGIN
    

    -- Proceed with file upload and job initiation if the job is not in progress
    SELECT blob_content, filename 
    INTO l_request_object, l_request_filename 
    FROM apex_application_temp_files 
    WHERE name = :P222_FILEUPLOAD; 

    l_request_url := 'https://objectstorage.us-chicago-1.oraclecloud.com/n/<your-namespace>/b/<your-bucket>/o/RAG/'||l_request_filename;
     
    apex_web_service.clear_request_headers;
    apex_web_service.set_request_headers(
        p_name_01  => 'Content-Type',
        p_value_01 => 'application/pdf'
    );
    
    l_response := apex_web_service.make_rest_request(
        p_url => l_request_url,
        p_http_method => 'PUT',
        p_body_blob => l_request_object,
        p_credential_static_id => '<your-apex-web-credentials>'
    );

    -- Clear any existing headers
    apex_web_service.clear_request_headers;

    -- Set the Content-Type header
    apex_web_service.set_request_headers(
        p_name_01  => 'Content-Type',
        p_value_01 => 'application/json'
    );

    -- Create the request body
    l_body := json_object(
        'compartmentId' VALUE 'ocid1.compartment.oc1..<your-compartment-id>',
        'dataSourceId'  VALUE 'ocid1.genaiagentdatasource.oc1.us-chicago-1.<your-datasource-id>'
    );

    -- Make the API call using Web Credentials
    l_response := apex_web_service.make_rest_request(
        p_url => 'https://agent.generativeai.us-chicago-1.oci.oraclecloud.com/20240531/dataIngestionJobs',
        p_http_method => 'POST',
        p_body => l_body,
        p_credential_static_id => 'Ind_OCI_WebCred'
    );

    -- Parse the response to get the status
    l_job_status := json_value(l_response, '$.lifecycleState');
 
    --  First, get the ID of the most recent job
    l_response := apex_web_service.make_rest_request(
        p_url => 'https://agent.generativeai.us-chicago-1.oci.oraclecloud.com/20240531/dataIngestionJobs?compartmentId=ocid1.compartment.oc1..<your-compartment-ocid>&sortOrder=DESC&sortBy=timeCreated&limit=1',
        p_http_method => 'GET',
        p_credential_static_id => 'Ind_OCI_WebCred'
    );

     -- Parse the response to get the job ID
    l_job_id := json_value(l_response, '$.items[0].id');

    
    apex_application.g_print_success_message := 'File uploaded and data ingestion job started successfully.'; 

    -- Save All information in database table
    insert into RAG_FILES (FILE_NAME, SOURCE_LOCATION, JOB_ID, STATUS) values (l_request_filename, l_request_url, l_job_id, l_job_status) 
        returning ID into l_rag_pdf_fileid;

    -- Return the File Upload Status (Optional) default is ACCEPTED
    :P222_RAG_PDF_FILE_ID := l_rag_pdf_fileid;
    
EXCEPTION
    WHEN OTHERS THEN
        apex_debug.error('An error occurred: %s', SQLERRM);
        apex_application.g_print_success_message := 'An error occurred while processing your request. Please try again later.';
END;
