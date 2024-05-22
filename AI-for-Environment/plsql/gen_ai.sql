--  Code Author Madhusudhan Rao
create or replace Function genai_function ( country_input IN varchar2 ) 
RETURN varchar2
IS  
  
    params CLOB;
    output CLOB;
    long_text VARCHAR2(4000);
     
BEGIN 
     
    Htp.p(country_input);
    params := '{
        "provider" : "ocigenai",
        "credential_name" : "OCI_CRED", 
        "url" : "https://inference.generativeai.us-chicago-1.oci.oraclecloud.com/20231130/actions/generateText",
        "model" : "cohere.command",
        "inferenceRequest": {
            "maxTokens": 300,
            "temperature": 1
          }
    }';
  
    output := DBMS_VECTOR_CHAIN.UTL_TO_GENERATE_TEXT(country_input, json(params));
      
    long_text := ' <hr/> '||output;
    Htp.p(long_text); 
    return (long_text);
 
END;
/