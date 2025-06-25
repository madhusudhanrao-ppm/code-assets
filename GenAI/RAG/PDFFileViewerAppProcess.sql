declare

l_file_blob           BLOB;  
-- Use this ID to get File name stored in OCI Object Storage
p_doc_id varchar2(100) := V('P222_RAG_PDF_FILE_ID') ;
p_request_url  varchar2(2000); 
file_extension VARCHAR2(10);
file_type VARCHAR2(100);

begin 

select SOURCE_LOCATION into p_request_url from RAG_FILES where id = p_doc_id;

file_extension := LOWER(SUBSTR(p_request_url, INSTR(p_request_url, '.', -1) + 1));
  CASE file_extension
    WHEN 'txt' THEN file_type := 'text/plain';
    WHEN 'pdf' THEN file_type := 'application/pdf';
    ELSE file_type := 'application/pdf';
  END CASE;

l_file_blob := apex_web_service.make_rest_request_b  
   (p_url                  => UTL_URL.ESCAPE(p_request_url),  
    p_http_method          => 'GET',  
    p_credential_static_id => '<Your-credentials>'); 
 
  owa_util.mime_header(file_type,false);  
  htp.p('Content-Length: ' || dbms_lob.getlength(l_file_blob));   
  owa_util.http_header_close;    
  wpg_docload.download_file(l_file_blob);   

end;
