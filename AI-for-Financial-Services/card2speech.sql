create or replace FUNCTION card2speech (card_no IN VARCHAR2 )  RETURN VARCHAR2  
AS  
    speech_endpoint  varchar2(500) := 'https://speech.aiservice.us-phoenix-1.oci.oraclecloud.com/20220101/actions/synthesizeSpeech'; 
    resp dbms_cloud_types.RESP; 
    request_json CLOB; 
    request_body BLOB;       
    p_file_blob    BLOB; 
    x_object_store_url  MACHINE_LEARNING_CONFIGS.GC_OCI_OBJ_STORE_BASE_URL%TYPE; 
    l_response            CLOB;  
    v_rand_no number; 
    v_filename varchar2(100); 
    v_compartment_id varchar2(1000) := '<Your-Compartment-OCID'; 
    --- GenAI variables -------------------------------- 
    l_genai_rest_url    VARCHAR2(4000) := 'https://inference.generativeai.us-chicago-1.oci.oraclecloud.com/20231130/actions/chat';    
    l_web_cred        CONSTANT VARCHAR2(50)   := 'Ind_OCI_WebCred';     
    l_response_json CLOB; 
    l_text varchar2(4000); 
    l_prompt varchar2(1000);   
    v_planetext varchar2(32000); 
    l_ocigabody varchar2(32000);  
    v_voice varchar2(20) := 'Cindy'; 
    v_custname varchar2(50);
    v_amount number;
 
    CURSOR C1  IS  
            SELECT jt.*  
            FROM   JSON_TABLE(l_response_json, '$'  COLUMNS (text VARCHAR2(32000)  PATH '$.chatResponse[0].text' )) jt;  
  
BEGIN 
 
    v_rand_no := round(DBMS_Random.Value(1,10000),0);  
    v_filename := 'Audio'||v_rand_no||'.mp3';  
    x_object_store_url := 'https://objectstorage.us-phoenix-1.oraclecloud.com/n/oradbclouducm/b/medical_transcripts/o/Speech/'||v_filename;   

    select FIRST_NAME  into  v_custname from cc_fd where  CC_NO = card_no; 
    --select FIRST_NAME from cc_fd where CC_NO
      
    v_planetext := v_custname||'. Please collect your Cash before leaving the ATM. Thank you for Banking with us. Have a great day';
    request_json := to_clob( 
        '{ 
          "audioConfig": { 
            "configType": "BASE_AUDIO_CONFIG" 
          }, 
          "compartmentId": "'||v_compartment_id||'", 
          "configuration": { 
            "modelDetails": { 
              "modelName": "TTS_2_NATURAL", 
              "voiceId": "'||v_voice||'" 
            }, 
            "modelFamily": "ORACLE", 
            "speechSettings": { 
              "outputFormat": "MP3", 
              "sampleRateInHz": 23600, 
              "speechMarkTypes": ["WORD"], 
              "textType": "TEXT" 
            } 
          }, 
          "isStreamEnabled": true, 
          "text": "'||v_planetext||'"            
        }' 
    ); 
     
    request_body := apex_util.clob_to_blob(p_clob => request_json,p_charset => 'AL32UTF8');  
    resp := dbms_cloud.send_request( 
        credential_name => 'GENAI_CRED', 
        uri => speech_endpoint, 
        method => dbms_cloud.METHOD_POST, 
        body => request_body 
    );    
    p_file_blob := dbms_cloud.get_response_raw(resp);   
     
    apex_web_service.g_request_headers.DELETE;  
    apex_web_service.g_request_headers(1).name  := 'Content-Type';  
    apex_web_service.g_request_headers(1).value := 'audio/mpeg';   
    -- Call Web Service to PUT file in OCI.  
    l_response := apex_web_service.make_rest_request  
    (p_url                  => UTL_URL.ESCAPE(x_object_store_url),  
    p_http_method          => 'PUT',  
    p_body_blob            => p_file_blob,   
    p_credential_static_id => l_web_cred);  
 
    IF apex_web_service.g_status_code != 200 then  
    raise_application_error(-20111,'Unable to Upload File to OCI.');  
    END IF;  
 
    RETURN v_filename;  
END card2speech;
/