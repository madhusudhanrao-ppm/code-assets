WITH query as (
    -- source and target constitutes the edge direction  
    select 
    SRC_ID as source , 
    DST_ID as target  
    from RAG_GRAPH_VIEW  
),
page AS (
    -- pagination
    SELECT
        *
    FROM
        query
    ORDER BY
        source,
        target OFFSET :page_start ROWS FETCH NEXT :page_size ROWS ONLY 
        --target OFFSET 1 ROWS FETCH NEXT 100 ROWS ONLY 
),
vertices AS (
    -- fetch customer details and construct JSON
    SELECT
        JSON_OBJECT(
            --'id' VALUE FINBANK_ACCOUNTS.ID,
            'id' VALUE RAG_CHATBOT.CHAT_ID,
            'properties' VALUE JSON_OBJECT(
                'Username' VALUE RAG_CHATBOT.USER_NAME, 
                'Prompt' VALUE RAG_CHATBOT.PROMPT,
                'CommentDate' VALUE RAG_CHATBOT.COMMENT_DATE,
                'TID' VALUE RAG_CHATBOT.CHAT_ID, 
                'Filename' VALUE RAG_CITATIONS.FILE_NAME, 
                 'CitationCount' VALUE RAG_GRAPH_VIEW.SEARCH_COUNT 
            )
        ) AS vertex
    FROM 
        RAG_CHATBOT RAG_CHATBOT  
        LEFT OUTER JOIN RAG_CITATIONS RAG_CITATIONS ON RAG_CHATBOT.CHAT_ID = RAG_CITATIONS.CHAT_ID
        LEFT OUTER JOIN RAG_GRAPH_VIEW RAG_GRAPH_VIEW ON RAG_CHATBOT.CHAT_ID = RAG_GRAPH_VIEW.SRC_ID    
    WHERE 
        RAG_GRAPH_VIEW.SRC_ID in (
            SELECT
                source
            from
                page
        )
        or RAG_GRAPH_VIEW.DST_ID in (
            SELECT
                target
            from
                page
        )

),
edges AS ( 
    SELECT
        JSON_OBJECT('source' VALUE source, 'target' VALUE target) AS edge
    FROM
        page
)
SELECT 
    JSON_OBJECT(
        'vertices' VALUE (
            SELECT
                JSON_ARRAYAGG(vertex returning clob)
            FROM
                vertices
        ),
        'edges' VALUE (
            SELECT
                JSON_ARRAYAGG(edge returning clob)
            FROM
                edges
        ),
        'numResults' VALUE (
            SELECT
                COUNT(*)
            FROM
                query
        ) returning clob
    ) json
FROM
    SYS.DUAL
 
