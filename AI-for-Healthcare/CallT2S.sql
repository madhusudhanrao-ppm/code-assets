DECLARE
  
    l_text varchar2(4000);  
    file_name varchar2(200); 
    v_voice varchar2(100) := :P68_VOICE; 
    v_planetext varchar2(32000) :=  :P68_PROMPT;
     doctor_img varchar2(200); 

 BEGIN
 
    if v_voice is null then 
        v_voice := 'Annabelle';
    end if;

    doctor_img := '#APP_FILES#doctors/'||v_voice||'.jpeg'; 
    -- clean up input text from any special chars
    v_planetext := TRANSLATE(v_planetext, '~!@#$%^&*()_+=\{}[]:”;’<,>./?',' ') ;  
    -- invoke Text to Speech PL/SQL function
    file_name := SPEECH_SYNTHESIZESPEECH_UPLOADFILE (v_planetext,v_voice );
    file_name := 'https://objectstorage.us-phoenix-1.oraclecloud.com/n/oradbclouducm/b/medical_transcripts/o/Speech/'||file_name; 
    l_text := l_text||'<br/> <audio controls preload> <source src="'||file_name||'" type="audio/mpeg"> </audio><img src="'||doctor_img||'" width="250px"/>'; 
    -- Output HTML to Richtext Input page item
    :P68_AUDIO := l_text;
 
 
 END;