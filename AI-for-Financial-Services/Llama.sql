declare
    l_blob_content blob;
    l_mime_type varchar2(200);
    l_file_name varchar2(200);
    l_base64_content clob;
    l_response_text clob;
    l_request_body clob; 
    l_text varchar2(32000); 
    l_api_url varchar2(2000) := 'https://inference.generativeai.us-chicago-1.oci.oraclecloud.com/20231130/actions/chat';
    l_compartment_id varchar2(1000) := '<Your compartment OCID>';
    l_model_id varchar2(100) := 'meta.llama-3.2-90b-vision-instruct';
    l_id number;
    l_cardno number;
    l_first_name varchar2(50);
    l_status varchar2(20);
    l_filename varchar2(50);

begin
   
    select blob_content, mime_type, filename, id
    into l_blob_content,l_mime_type, l_file_name, l_id
    from apex_application_temp_files
    where name = :P48_IMAGE_UPLOAD;
 
    -- Set the Image ID to a page item, here we are using page item P48_ID
    :P48_ID := l_id;
 
    dbms_lob.createtemporary(l_base64_content, true); 
  
SELECT
    REPLACE(REPLACE(APEX_WEB_SERVICE.BLOB2CLOBBASE64(l_blob_content),
                    CHR(10),
                    ''),
            CHR(13),
            '')
into l_base64_content
    from dual;

    -- Build JSON request body for meta.llama-3.2-90b-vision-instruct
   l_request_body := ' 
    {
        "compartmentId": l_compartment_id,
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
                        "text": "what is the card number"
                    },
                     {
                        "type": "IMAGE",
                        "imageUrl": {
                            "url": "data:image/png;base64,'||l_base64_content||'"
                        }
                     }   
                 ]

            }
        ],
            "maxTokens": 2500,
            "isStream": false,
            "apiFormat": "GENERIC",
            "temperature": 0.75,
            "frequencyPenalty": 1,
            "presencePenalty": 0,
            "topP": 0.7,
            "topK": 1
        }
    }';
 
    apex_web_service.g_request_headers(1).name := 'Content-Type';
    apex_web_service.g_request_headers(1).value := 'application/json';

    -- Make the API call
    l_response_text := apex_web_service.make_rest_request(
        p_url => 'https://inference.generativeai.us-chicago-1.oci.oraclecloud.com/20231130/actions/chat',
        p_http_method => 'POST',
        p_body => l_request_body,
        p_credential_static_id => 'Ind_OCI_WebCred'--'credentials_for_ociai'
    );
 
 SELECT jt.text INTO l_text
    FROM dual,
         JSON_TABLE(
             l_response_text,
             '$.chatResponse.choices[*].message.content[*]'
             COLUMNS (
                 text CLOB PATH '$.text'
             )
         ) jt;

    -- get card number from image
    select regexp_replace(l_text, '[^[:digit:]]', '') into l_cardno from dual;
    -- get customer details from a table based on card  number uploaded
    select first_name, status into l_first_name, l_status from cc_fd where cc_no =  l_cardno and rownum = 1;
    -- Optional Generate Speech AI Output
    --l_filename := card2speech (l_cardno );
  
    :P48_CARDNO := l_cardno; 
    :P48_STATUS := l_status;
    :P48_FILENAME := l_filename;

    if (l_status = 'Blocked') then    
        :P48_CUSTNAME := 'Card has been Blocked..';   
    else  
        :P48_CUSTNAME := 'Welcome '||l_first_name; 
    end if;


    -- Add success message
    apex_application.g_notification := 'API called successfully!';
 
end;
