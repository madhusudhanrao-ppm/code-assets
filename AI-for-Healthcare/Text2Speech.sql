create or replace FUNCTION speech_synthesizespeech_uploadfile (v_text_input IN VARCHAR2, v_voice IN varchar2)  RETURN VARCHAR2
--RETURN BLOB 
AS 
    speech_endpoint  varchar2(500) := 'https://speech.aiservice.us-phoenix-1.oci.oraclecloud.com/20220101/actions/synthesizeSpeech';
    resp dbms_cloud_types.RESP;
    request_json CLOB;
    request_body BLOB;     
    GC_WC_CREDENTIAL_ID CONSTANT VARCHAR2(50)   := '<your-oracle-apex-web-credentials>'; 
    p_file_blob    BLOB;
    x_object_store_url  varchar2(400);
    l_response            CLOB; 
    v_rand_no number;
    v_filename varchar2(100);

BEGIN
  
    v_rand_no := round(DBMS_Random.Value(1,10000),0); 
    v_filename := 'Audio'||v_rand_no||'.mp3';

    --- Generate Speech MP3 file from Text Input
    request_json := to_clob(
        '{
          "audioConfig": {
            "configType": "BASE_AUDIO_CONFIG"
          },
          "compartmentId": "<your-compartment-ocid>",
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
          "text": "'||v_text_input||'"             
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

    -- Upload file to OCI Object storage
    x_object_store_url := 'https://objectstorage.us-phoenix-1.oraclecloud.com/n/oradbclouducm/b/medical_transcripts/o/Speech/'||v_filename;  

    -- Set Mime Type of the file in the Request Header. 
    apex_web_service.g_request_headers.DELETE; 
    apex_web_service.g_request_headers(1).name  := 'Content-Type'; 
    apex_web_service.g_request_headers(1).value := 'audio/mpeg'; 

    -- Call Web Service to PUT file in OCI. 
    l_response := apex_web_service.make_rest_request 
    (p_url                  => UTL_URL.ESCAPE(x_object_store_url), 
    p_http_method          => 'PUT', 
    p_body_blob            => p_file_blob,  
    p_credential_static_id => GC_WC_CREDENTIAL_ID); 

    IF apex_web_service.g_status_code != 200 then 
    raise_application_error(-20111,'Unable to Upload File to OCI Object storage.'); 
    END IF; 

      RETURN v_filename; 
END speech_synthesizespeech_uploadfile;
/