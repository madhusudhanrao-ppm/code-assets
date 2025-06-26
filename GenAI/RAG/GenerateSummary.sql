declare

l_file_blob           BLOB;   
p_request_url  varchar2(2000);
file_extension VARCHAR2(10);
file_type VARCHAR2(100);

file_content BLOB;
file_clob CLOB;
amount INTEGER := DBMS_LOB.LOBMAXSIZE;
dest_offset INTEGER := 1;
src_offset INTEGER := 1;
blob_csid NUMBER := DBMS_LOB.DEFAULT_CSID;
lang_context INTEGER := DBMS_LOB.DEFAULT_LANG_CTX;
warning INTEGER;
cleaned_string VARCHAR2(32000);

l_genai_rest_url    VARCHAR2(4000) := 'https://inference.generativeai.us-chicago-1.oci.oraclecloud.com/20231130/actions/chat';  

l_web_cred        CONSTANT VARCHAR2(50)   := 'Ind_OCI_WebCred';   
l_input varchar2(4000) := :P3_INPUT; 
l_response_json CLOB;
l_text varchar2(32000);
l_ocigabody varchar2(32000);

CURSOR C1  IS 
        SELECT jt.* 
        FROM   JSON_TABLE(l_response_json, '$'  COLUMNS (text VARCHAR2(32000)  PATH '$.chatResponse[0].choices.message.content.text' )) jt; 


begin 

select SOURCE_LOCATION into p_request_url from RAG_CITATIONS where id = :P108_CITATION_ID;
 

l_file_blob := apex_web_service.make_rest_request_b  
   (p_url                  => UTL_URL.ESCAPE(p_request_url),  
    p_http_method          => 'GET',  
    p_credential_static_id => 'Ind_OCI_WebCred'); 
 
  DBMS_LOB.CREATETEMPORARY(file_clob, TRUE);
  DBMS_LOB.CONVERTTOCLOB(
    dest_lob => file_clob,
    src_blob => l_file_blob,
    amount => amount,
    dest_offset => dest_offset,
    src_offset => src_offset,
    blob_csid => blob_csid,
    lang_context => lang_context,
    warning => warning
  );
 
  Htp.p('<hr/>');

  cleaned_string := REGEXP_REPLACE(file_clob, '<.*?>', ' '); 
  -- Remove special characters
  cleaned_string := REGEXP_REPLACE(cleaned_string, '[^a-zA-Z0-9\s]', ' ');
  cleaned_string := REGEXP_REPLACE(cleaned_string, 'https', '');
  cleaned_string := REGEXP_REPLACE(cleaned_string, 'wikipedia org', 'Refer Wikipedia');
   
   
  -- Let meta llama generate summary based on input text content provided
  l_ocigabody  := ' { 
    "compartmentId": "ocid1.compartment.oc1..Your-Compartment-Id",
    "servingMode": {
        "servingType": "ON_DEMAND",
        "modelId": "meta.llama-3.2-90b-vision-instruct"
    },

    "chatRequest": {
        "messages": [
            {
                "role": "USER",
                "content": [
                    {
                        "type": "TEXT",
                        "text": "Please provide summary for this article '||cleaned_string||'"
                    }
                ]
            }
        ],
        "apiFormat": "GENERIC",
        "maxTokens": 600,
        "isStream": false,
        "numGenerations": 1,
        "frequencyPenalty": 0,
        "presencePenalty": 0
  }
}'; 


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
 
      :P108_SUMMARY := l_text;

  end;
