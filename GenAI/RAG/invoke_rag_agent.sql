create or replace FUNCTION invoke_rag_agent (v_session_id IN VARCHAR2, v_input_prompt IN VARCHAR2)
RETURN rag_agent_out AS v_rag_agent_out rag_agent_out;
---------- Set variables ---------------------- 
l_body       sys.json_object_t;
l_response   clob;
l_webcend VARCHAR2(50)   := 'YourWebCred'; 
l_result   VARCHAR2(32767);
l_chatendpoint varchar2(200) := 'ocid1.genaiagentendpoint.oc1.us-chicago-1.Your-Endpoint'; 
l_url varchar2(1000) := 'https://agent-runtime.generativeai.us-chicago-1.oci.oraclecloud.com/20240531/agentEndpoints/'||l_chatendpoint||'/actions/chat';  
v_sourcetext varchar2(32767);  
v_location varchar2(32767);  
l_genai_rest_url    VARCHAR2(4000) := 'https://inference.generativeai.us-chicago-1.oci.oraclecloud.com/20231130/actions/chat';  
l_response_json CLOB;
l_text varchar2(32000);
l_chat_id number;
v_filename VARCHAR2(200);

CURSOR c1 is SELECT
            JT.SOURCE_TEXT 
           ,JT.SOURCE_LOCATION
        FROM
                JSON_TABLE ( L_RESPONSE, '$.traces[*]'
                    COLUMNS (
                        NESTED PATH '$.citations[*]'
                            COLUMNS (
                                SOURCE_TEXT VARCHAR2 ( 4000 ) PATH '$.sourceText',
                                SOURCE_LOCATION VARCHAR2 ( 4000 ) PATH '$.sourceLocation.url'
                            )
                    )
                )
            JT;

CURSOR C2gai  IS 
            SELECT jt.* 
            FROM   JSON_TABLE(l_response_json, '$'  COLUMNS (text VARCHAR2(32000)  PATH '$.chatResponse[0].text' )) jt;  

l_ocigabody varchar2(32000) := ' 
    {
        "compartmentId": "ocid1.compartment.oc1..Your-Compartment",
        "servingMode": {
            "servingType": "ON_DEMAND",
            "modelId": "cohere.command-r-08-2024"
        },
        "chatRequest": {
            "message": "'||v_input_prompt||'",
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
---------- Set variables ----------------------
BEGIN
   
  ---------- Main function body -----------------------------
    l_body := sys.json_object_t();
    l_body.put('sessionId', v_session_id);
    l_body.put('shouldStream', false);  
    l_body.put('userMessage', v_input_prompt); 
    apex_web_service.g_request_headers(1).name := 'Content-Type';
    apex_web_service.g_request_headers(1).value := 'application/json'; 
    l_response := apex_web_service.make_rest_request(
                      p_url                  => l_url,
                      p_http_method          => 'POST',
                      p_body => json_object(
                                  key 'sessionId' value v_session_id
                                , key 'shouldStream' value 'false'
                                , key 'userMessage' value apex_escape.json(v_input_prompt)),
                      p_credential_static_id => l_webcend
                  );

    SELECT
        RESPONSE_TEXT
    INTO l_result
    FROM
        JSON_TABLE ( L_RESPONSE, '$.message[*]'
            COLUMNS (
                RESPONSE_TEXT VARCHAR2 ( 32767 ) PATH '$.content.text'
            )
        );   

    -- Write this into a table ---------------
    -- Insert into master table ------
    INSERT INTO RAG_CHATBOT (
        USER_NAME,
        IS_OWN,
        COMMENT_TEXT,
        COMMENT_DATE,
        SESSION_ID,
        PROMPT
    ) VALUES ( v('APP_USER'),
               'No',
               l_result,
               SYSDATE,
               v_session_id,
               v_input_prompt ) RETURNING CHAT_ID INTO l_chat_id;


    -- Write Cittions into a table  ---------------
    -- Insert into detail citation table ------
    FOR I IN (
        SELECT
            JT.SOURCE_TEXT,
            JT.SOURCE_LOCATION
        FROM
                JSON_TABLE ( L_RESPONSE, '$.traces[*]'
                    COLUMNS (
                        NESTED PATH '$.citations[*]'
                            COLUMNS (
                                SOURCE_TEXT VARCHAR2 ( 4000 ) PATH '$.sourceText',
                                SOURCE_LOCATION VARCHAR2 ( 4000 ) PATH '$.sourceLocation.url'
                            )
                    )
                )
            JT
        WHERE
            JT.SOURCE_TEXT IS NOT NULL
            AND JT.SOURCE_LOCATION IS NOT NULL
    ) LOOP
          
        v_filename := SUBSTR(I.SOURCE_LOCATION, INSTR(I.SOURCE_LOCATION, '/', -1) + 1);
        v_filename := REGEXP_SUBSTR(v_filename, '^[^?#]+');

        INSERT INTO RAG_CITATIONS (
            CHAT_ID, PROMPT, SOURCE_TEXT, SOURCE_LOCATION, ASKED_ON,
                    SESSION_ID, FILE_NAME
        ) VALUES ( l_chat_id, v_input_prompt, I.SOURCE_TEXT, I.SOURCE_LOCATION, SYSTIMESTAMP,
                    v_session_id, v_filename);

    END LOOP;


    IF apex_web_service.g_status_code != 200 then  
    raise_application_error(-20111,'Error in invoking REST API');  
    END IF; 

    --- If we do not find any internal document let us ask Gen AI LLM 
    if l_result = 'Unsure about the answer based on the references.' then
        l_result := '';
        v_sourcetext := '<i><font color=red> No Internal documents were found, Getting Results from Public LLM </font></i><br/>';
        v_location := ''; 
        ------------- ADD GENAI fall back
        l_response_json := apex_web_service.make_rest_request 
           (p_url                  => l_genai_rest_url, 
            p_http_method          => 'POST', 
            p_body                 => l_ocigabody, 
            p_credential_static_id => l_webcend);
        For row_1 In C2gai Loop
           l_result := row_1.text; 
          -- :P78_GA := l_text; 
        End Loop;
        l_chat_id := 0; 
        l_result := v_sourcetext||' <br/> '||l_result;
        ------------- ADD GENAI fall back
    end if;  
  ---------- Main function body ----------------------------- 
  v_rag_agent_out := rag_agent_out (l_result, v_sourcetext, l_chat_id);
  
  RETURN v_rag_agent_out;
END;
/
