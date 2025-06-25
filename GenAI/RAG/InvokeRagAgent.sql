DECLARE
    v_session_id varchar2(1000) := :P222_SESSION;
    v_input_prompt varchar2(500) := :P222_INPUT;
    v_rag_agent_out rag_agent_out;
    cleaned_string VARCHAR2(32000);
    raw_html_string VARCHAR2(32000);

BEGIN 
   v_rag_agent_out := invoke_rag_agent ( v_session_id, v_input_prompt );  

    -- Chat Response loading into Rich text page item
    :P222_RESP := v_rag_agent_out.v_rag_response; 
    :P222_CHAT_ID := v_rag_agent_out.v_rag_location; ;

    -- Clean up HTML response to text response so that we can generate Audio or Tranlate later on..
    -- You can also ignore the below code
    raw_html_string := v_rag_agent_out.v_rag_response;

    SELECT apex_escape.striphtml(raw_html_string) into cleaned_string FROM dual; 
    cleaned_string := REGEXP_REPLACE(cleaned_string, '\[.*?\]|\(.*?\)', '');
    cleaned_string := REGEXP_REPLACE(cleaned_string, '<a href=".*?">|</a>', '');
    cleaned_string := REGEXP_REPLACE(cleaned_string, 'https', '');
    cleaned_string := REGEXP_REPLACE(cleaned_string, 'wikipedia org', '');
    cleaned_string := REGEXP_REPLACE(cleaned_string, 'wiki', '');
    cleaned_string := REGEXP_REPLACE(cleaned_string, ' en ', '');
    cleaned_string := REGEXP_REPLACE(cleaned_string, ' s ', '');
    cleaned_string := REGEXP_REPLACE(cleaned_string, '[^a-zA-Z0-9\s]', ' ');
    :P222_RESP_TEXT := cleaned_string;

END;
