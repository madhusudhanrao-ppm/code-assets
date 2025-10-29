create or replace package body video_ai_pk is  
-------------------------------------------------------------------------------  
-- NAME        : VISION_AI_PK   
-- Author : Madhusudhan Rao 
-- Date Oct 29th 2025
-------------------------------------------------------------------------------  

   procedure initialize (
      v_id in machine_learning_configs.id%type
   ) as 
-- ----------------------------------------------------------------- 
   begin
      select gc_oci_obj_store_base_url,
             gc_oci_doc_ai_url,
             gc_oci_doc_ai_timeout_secs,
             gc_wc_credential_id,
             gc_oci_req_ai_payload
        into
         v_gc_oci_obj_store_base_url,
         v_gc_oci_doc_ai_url,
         v_gc_oci_doc_ai_timeout_secs,
         v_gc_wc_credential_id,
         v_gc_oci_req_ai_payload
        from machine_learning_configs
       where id = v_id;
   end initialize; 
    
-------------------------------------------------------------------------------- 
   procedure put_file (
      p_mime_type        in varchar2,
      p_file_blob        in blob,
      p_file_name        in varchar2,
      x_object_store_url out varchar2
   ) is
      l_response clob;
   begin
      x_object_store_url := video_ai_pk.v_gc_oci_obj_store_base_url || p_file_name;   
  
  -- Set Mime Type of the file in the Request Header.  
      apex_web_service.g_request_headers.delete;
      apex_web_service.g_request_headers(1).name := 'Content-Type';
      apex_web_service.g_request_headers(1).value := p_mime_type;  
  
  -- Call Web Service to PUT file in OCI.  
      l_response := apex_web_service.make_rest_request(
         p_url                  => utl_url.escape(x_object_store_url),
         p_http_method          => 'PUT',
         p_body_blob            => p_file_blob,  
    --p_credential_static_id => GC_WC_CREDENTIAL_ID);  
         p_credential_static_id => gc_wc_credential_id
      );

      if apex_web_service.g_status_code != 200 then
         raise_application_error(
            -20111,
            'Unable to Upload File to OCI.'
         );
      end if;

   exception
      when others then
         raise;
   end put_file;  
   
--------------------------------------------------------------------------------  
   procedure upload_file (
      p_apex_file_name   in varchar2,
      x_file_name        out varchar2,
      x_object_store_url out varchar2,
      x_document_id      out ai_docs.document_id%type
   ) is

      cursor cr_file_info is
      select filename,
             blob_content,
             mime_type
        from apex_application_temp_files
       where name = p_apex_file_name;

      lr_file_info cr_file_info%rowtype;
   begin  
  
  -- Get the File BLOB Content and File Name uploaded from APEX.  
      open cr_file_info;
      fetch cr_file_info into lr_file_info;
      close cr_file_info;
      x_file_name := lr_file_info.filename;  
    
  -- Post file to OCI Object Store.  
      put_file(
         p_mime_type        => lr_file_info.mime_type,
         p_file_blob        => lr_file_info.blob_content,
         p_file_name        => lr_file_info.filename,
         x_object_store_url => x_object_store_url
      );  
  
  -- Create Document Record  
      insert into ai_docs (
         file_name,
         mime_type,
         object_store_url
      ) values ( lr_file_info.filename,
                 lr_file_info.mime_type,
                 x_object_store_url ) returning document_id into x_document_id;

   exception
      when others then
         raise;
   end upload_file;  

 

--------------------------------------------------------------------------------  
   procedure process_file (
      p_apex_file_name in varchar2,
      v_id             in machine_learning_configs.id%type,
      x_document_id    out ai_docs.document_id%type
   ) is
      l_object_store_url varchar2(1000);
      l_file_name        varchar2(100);
   begin
      initialize(v_id); 
  
  -- Get file and upload to OCI Object Storage.  
      upload_file(
         p_apex_file_name   => p_apex_file_name,
         x_file_name        => l_file_name,
         x_object_store_url => l_object_store_url,
         x_document_id      => x_document_id
      );  
 

      -- Call Video AI  
      video_ai(
         p_file_name   => l_file_name,
         p_document_id => x_document_id
      );
   exception
      when others then
         raise;
   end process_file;  

--------------------------------------------------------------------------------  
-- Declare video_ai in specs as well ........  
   procedure video_ai (
      p_file_name   in varchar2,
      p_document_id in cndemo_document_ai_docs.document_id%type
   ) is
      l_request_json  varchar2(32000);
      l_response_json clob;  
 -- lr_document_data      cr_document_data%ROWTYPE;  
      l_json_obj      json_object_t;
      l_id            varchar2(4000);
   begin
      l_request_json := replace(
         v_gc_oci_req_ai_payload,
         '#FILE_NAME#',
         p_file_name
      );
      apex_web_service.g_request_headers.delete;
      apex_web_service.g_request_headers(1).name := 'Content-Type';
      apex_web_service.g_request_headers(1).value := 'application/json';  
    
      -- Call the Document AI analyzeDocument REST Web Service.  
      l_response_json := apex_web_service.make_rest_request(
         p_url                  => 'https://vision.aiservice.us-phoenix-1.oci.oraclecloud.com/20220125/videoJobs',
         p_http_method          => 'POST',
         p_body                 => l_request_json,
         p_credential_static_id => 'Ind_OCI_WebCred'
      );

      if apex_web_service.g_status_code != 200 then
         raise_application_error(
            -20112,
            'Unable to call Video AI.'
         );
      end if;

      l_json_obj := json_object_t.parse(l_response_json);
      l_id := l_json_obj.get_string('id');
      insert into videoanalysis (
         job_id,
         job_status,
         video_name
      ) values ( l_id,
                 'STARTED',
                 p_file_name );


   exception
      when others then
         raise;
   end video_ai;  
  
-------------------------------------------------------------------------------- 

   function get_video_job_status (
      p_file_name in varchar2
   ) return varchar2 is
      l_status          varchar2(100);
      l_this_jobid      varchar2(300);
      l_request_json    varchar2(32000);
      l_response_json   clob;
      l_response2_json  clob;
      l_json_obj        json_object_t;
      l_id              varchar2(32000);
      l_lifecycle_state varchar2(32000);
      job_id            varchar2(32000);
      l_object_name     varchar2(32000);
      l_json_file_url   varchar2(32000);
      l_video_labels    json_array_t;
      l_video_objects   json_array_t;
      l_video_text   json_array_t;
      l_label           json_object_t;
      l_name            varchar2(32000);
      l_video_url       varchar2(32000);
      l_video_string    varchar2(32000);
      cursor c1 is
      select *
        from videoanalysis
       where job_status = 'STARTED'
          or job_status = 'IN_PROGRESS';
   begin
  -- Get the video job status here
      l_request_json := replace(
         v_gc_oci_req_ai_payload,
         '#FILE_NAME#',
         p_file_name
      ); 
  -- For example:
     -- Htp.p('Hi');
      for row_1 in c1 loop
         l_this_jobid := row_1.job_id;
         l_response_json := apex_web_service.make_rest_request(
            p_url                  => 'https://vision.aiservice.us-phoenix-1.oci.oraclecloud.com/20220125/videoJobs/'
                     || l_this_jobid
                     || '',
            p_http_method          => 'GET',
            p_body                 => l_request_json,
            p_credential_static_id => 'Ind_OCI_WebCred'
         );



         l_json_obj := json_object_t.parse(l_response_json);
         l_object_name := json_value(l_response_json,
           '$.inputLocation.objectLocations[0].objectName');
         l_lifecycle_state := l_json_obj.get_string('lifecycleState'); 

         -- Htp.p(l_lifecycle_state);

                -------------- If Status is Succeeded get all the video data 
         if l_lifecycle_state = 'SUCCEEDED' then
            l_json_file_url := 'https://objectstorage.us-phoenix-1.oraclecloud.com/n/tenancy/b/bucket/o/VA/'
                               || l_this_jobid
                               || '/'
                               || l_object_name
                               || '.json';
            l_response2_json := apex_web_service.make_rest_request(
               p_url         => l_json_file_url,
               p_http_method => 'GET'
            );
            l_json_obj := json_object_t.parse(l_response2_json);
 

            l_video_string := l_video_string || 'Video Label: <br/><br/>';
            l_video_labels := l_json_obj.get_array('videoLabels');
            for i in 0..l_video_labels.get_size - 1 loop
               l_label := treat(l_video_labels.get(i) as json_object_t);
               l_name := l_label.get_string('name');
               l_video_string := l_video_string
                                 || l_name
                                 || ', ';
            end loop;
 

            l_video_string := l_video_string || '<br/><br/> Video Objects:  <br/><br/>';
            l_video_objects := l_json_obj.get_array('videoObjects');
            for i in 0..l_video_objects.get_size - 1 loop
               l_label := treat(l_video_objects.get(i) as json_object_t);
               l_name := l_label.get_string('name');
               l_video_string := l_video_string
                                 || l_name
                                 || ',  ';
            end loop;

         

            l_video_string := l_video_string || '<br/><br/> Video Text:  <br/><br/>';
            l_video_text := l_json_obj.get_array('videoText');
            for i in 0..l_video_text.get_size - 1 loop
               l_label := treat(l_video_text.get(i) as json_object_t);
               l_name := l_label.get_string('text'); 
                if LENGTH(l_name) > 2 then 
                    l_video_string := l_video_string
                                 || l_name
                                 || ',  ';
                end if;
            end loop;

          

            l_video_url := 'https://objectstorage.us-phoenix-1.oraclecloud.com/n/tenancy/b/bucket/o/' || l_object_name;
            update videoanalysis
               set job_status = l_lifecycle_state,
                   object_name = l_object_name,
                   video_url = l_video_url,
                   video_analytics = l_video_string
             where job_id = l_this_jobid;
           --  Htp.p(l_video_string);
         else
            update videoanalysis
               set job_status = l_lifecycle_state,
                   object_name = l_object_name
             where job_id = l_this_jobid;
         end if;

         if apex_web_service.g_status_code != 200 then
            raise_application_error(
               -20112,
               'Unable to call Video AI.'
            );
         end if;


      end loop;

      return l_status;
   exception
      when others then
         return 'Error getting video job status: ' || sqlerrm;
   end get_video_job_status;
    
    
--------------------------------------------------------------------------------  
   function get_file (
      p_request_url in varchar2
   ) return blob is
      l_file_blob blob;
   begin  
  
  -- Call OCI Web Service to get the requested file.  
      l_file_blob := apex_web_service.make_rest_request_b(
         p_url                  => utl_url.escape(p_request_url),
         p_http_method          => 'GET',
         p_credential_static_id => gc_wc_credential_id
      );

      if apex_web_service.g_status_code != 200 then
         raise_application_error(
            -20112,
            'Unable to Get File.'
         );
      end if;

      return l_file_blob;
   exception
      when others then
         raise;
   end get_file;  
    
--------------------------------------------------------------------------------  
    


end;
/
