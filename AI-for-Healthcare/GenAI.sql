DECLARE
  
    l_genai_rest_url    VARCHAR2(4000) := 'https://inference.generativeai.us-chicago-1.oci.oraclecloud.com/20231130/actions/chat';   
    l_web_cred        CONSTANT VARCHAR2(50)   := '<your-oracle-apex-web-credentials>';    
    l_response_json CLOB;
    l_text varchar2(4000);
    l_prompt varchar2(1000); 
    l_name varchar2(100) := :P68_NAME;
    l_gender varchar2(10) := :P68_GENDER;
    l_age varchar2(10) := :P68_AGE;
    l_fbs varchar2(100) := :P68_FBS;
    l_history varchar2(100) := :P68_HISTORY;
    l_smoking varchar2(100) := :P68_SMOKING;
    l_excercise varchar2(100) := :P68_EXCERCISE;
    l_bp varchar2(100) := :P68_BP;
    l_ocigabody varchar2(32000); 
 

    CURSOR C1  IS 
            SELECT jt.* 
            FROM   JSON_TABLE(l_response_json, '$'  COLUMNS (text VARCHAR2(32000)  PATH '$.chatResponse[0].text' )) jt; 
          

 BEGIN

    if (l_history = 'yes') then
       l_history := 'I have a family history of Diabetes';
    else  
       l_history := 'I do not have family history of Diabetes';
    end if;

    l_prompt := 'My Name is '||l_name||'. I am a '||l_gender||' aged around '||l_age||', '||l_history||', my heart beat is '||l_bp||' and my fasting blood sugar level is '||l_fbs||'.'||l_excercise||' '||l_smoking||'. Kindly advise on my diet and exercise plan.';
    
    l_ocigabody  := ' 
    {
        "compartmentId": "<your-compartment-ocid>",
        "servingMode": {
            "servingType": "ON_DEMAND",
            "modelId": "cohere.command-r-16k"
        },
        "chatRequest": {
            "message": "'||l_prompt||'",
            "maxTokens": 600,
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

    if l_prompt is not null then

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
     End Loop; 
    
   :P68_OUTPUT := l_text ;
   :P68_PROMPT := l_text ;

    end if;
 
 END;
