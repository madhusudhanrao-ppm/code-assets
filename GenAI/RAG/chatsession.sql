declare
  c_agent_endpoint_id constant varchar2(1024) := 'ocid1.genaiagentendpoint.oc1.us-chicago-1.Your-EndPoint';
  l_response clob;
  l_chat_session_id varchar2(200);
begin
  
  -- Set Mime Type of the file in the Request Header.  
  apex_web_service.g_request_headers.DELETE;  
  apex_web_service.g_request_headers(1).name  := 'Content-Type';  
  apex_web_service.g_request_headers(1).value := 'application/json';  

  l_response := apex_web_service.make_rest_request(
    p_http_method => 'POST'
    , p_url =>
        'https://agent-runtime.generativeai.us-chicago-1.oci.oraclecloud.com'
        || '/20240531/agentEndpoints/'
        || c_agent_endpoint_id
        || '/sessions'
    , p_credential_static_id => 'Ind_OCI_WebCred'
    , p_body => json_object(
        key 'displayName' value 'Tester'
        , key 'description' value 'Agent service tester'
    )
  );

  SELECT
    ID into l_chat_session_id
    FROM
    JSON_TABLE(l_response, '$'
        COLUMNS (
            ID VARCHAR2(4000) PATH '$.id'
        )
    ) JT;

     -- Save the RAG session id in a variable or page item
    :P222_SESSION := l_chat_session_id; 

end;
 
