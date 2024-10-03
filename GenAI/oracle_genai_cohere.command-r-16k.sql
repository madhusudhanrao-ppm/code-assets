DECLARE 
  --Endpoint URL (change region if required)
  l_genai_rest_url    VARCHAR2(4000) := 'https://inference.generativeai.us-chicago-1.oci.oraclecloud.com/20231130/actions/chat'; 
  --Oracle APEX Web Credentials  
  l_web_cred        CONSTANT VARCHAR2(50)   := '<Your-Web-Credentials>';   
  -- Input can come from Oracle APEX page item or it can be changed to a hard coded value for testing.
  l_input varchar2(4000) := :P78_Q;  
  l_response_json CLOB;
  l_text varchar2(32000); 

    l_ocigabody varchar2(32000) := ' 
    {
        "compartmentId": "ocid1.compartment.oc1..<Your-Web-Credentials>",
        "servingMode": {
            "servingType": "ON_DEMAND",
            "modelId": "cohere.command-r-16k"
        },
        "chatRequest": {
            "message": "'||l_input||'",
            "maxTokens": 500,
            "isStream": false,
            "apiFormat": "COHERE",
            "temperature": 0.75,
            "frequencyPenalty": 1,
            "presencePenalty": 0,
            "topP": 0.7,
            "topK": 1
        }
    }
    '; 

  CURSOR C1  IS 
            SELECT jt.* 
            FROM   JSON_TABLE(l_response_json, '$'  COLUMNS (text VARCHAR2(32000)  PATH '$.chatResponse[0].text' )) jt;  

BEGIN

  if l_input is not null then

        apex_web_service.g_request_headers.DELETE; 
        apex_web_service.g_request_headers(1).name  := 'Content-Type'; 
        apex_web_service.g_request_headers(1).value := 'application/json'; 
    

         l_response_json := apex_web_service.make_rest_request 
           (p_url                  => l_genai_rest_url, 
            p_http_method          => 'POST', 
            p_body                 => l_ocigabody, 
            p_credential_static_id => l_web_cred);
 

    For row_1 In C1 Loop
           l_text := row_1.text; 
           -- Gen AI Output to Oracle APEX Rich Text Input Page Item (type Markdown)
           :P78_GA := l_text; 
           -- Output can also be printed as shown below in Oracle APEX
           --Htp.p('<pre>'||l_text||'</pre>');
     End Loop;

    end if;

END;