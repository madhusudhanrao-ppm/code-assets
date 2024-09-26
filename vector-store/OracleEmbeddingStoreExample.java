package dev.langchain4j;

import dev.langchain4j.data.embedding.Embedding;
import dev.langchain4j.data.segment.TextSegment;
import dev.langchain4j.model.embedding.EmbeddingModel;
import dev.langchain4j.model.embedding.onnx.allminilml6v2q.AllMiniLmL6V2QuantizedEmbeddingModel;
import dev.langchain4j.rag.content.Content;
import dev.langchain4j.rag.content.retriever.ContentRetriever;
import dev.langchain4j.rag.content.retriever.EmbeddingStoreContentRetriever;
import dev.langchain4j.rag.query.Query;
import dev.langchain4j.store.embedding.EmbeddingStore;
import dev.langchain4j.store.embedding.oracle.CreateOption;
import dev.langchain4j.store.embedding.oracle.OracleEmbeddingStore;
import oracle.ucp.jdbc.PoolDataSource;
import oracle.ucp.jdbc.PoolDataSourceFactory;
import org.testcontainers.oracle.OracleContainer; 
import java.sql.SQLException;

public class OracleEmbeddingStoreExample {

    public static void main(String[] args) throws SQLException {

        PoolDataSource dataSource = PoolDataSourceFactory.getPoolDataSource();
        dataSource.setConnectionFactoryClassName(
                "oracle.jdbc.datasource.impl.OracleDataSource");
        String urlFromEnv = System.getenv("ORACLE_JDBC_URL");
        System.out.println("Loop 0");
        if (urlFromEnv == null) {
            OracleContainer oracleContainer = new OracleContainer("gvenzl/oracle-free:23.5-full")
                    .withDatabaseName("pdb1")
                    .withUsername("vector")
                    .withPassword("Welcome123456");
            oracleContainer.start();
            dataSource.setURL(oracleContainer.getJdbcUrl());
            dataSource.setUser(oracleContainer.getUsername());
            dataSource.setPassword(oracleContainer.getPassword());
            System.out.println("Loop 1");

        } else {
            dataSource.setURL(urlFromEnv);
            dataSource.setUser(System.getenv("ORACLE_JDBC_USER"));
            dataSource.setPassword(System.getenv("ORACLE_JDBC_PASSWORD"));
            System.out.println("Loop 2");
        }

        EmbeddingStore<TextSegment> embeddingStore = OracleEmbeddingStore.builder()
                .dataSource(dataSource)
                .embeddingTable("test_content_retriever",
                        CreateOption.CREATE_OR_REPLACE)
                .build(); 
        EmbeddingModel embeddingModel = new AllMiniLmL6V2QuantizedEmbeddingModel(); 
        ContentRetriever retriever = EmbeddingStoreContentRetriever.builder()
                .embeddingStore(embeddingStore)
                .embeddingModel(embeddingModel)
                .maxResults(2)
                .minScore(0.5)
                .build();

        // Insert or Add Data into embeddingModel Record 1
        System.out.println("Inserting Records to Oracle Database 23ai Embeddings  ");
        System.out.println("======================================================");
        //Guava
        TextSegment segment1 = TextSegment.from("Guava is a common tropical fruit cultivated in many tropical and subtropical regions. The common guava Psidium guajava is a small tree in the myrtle family, " +
                "native to Mexico, Central America, the Caribbean and northern South America");
        Embedding embedding1 = embeddingModel.embed(segment1).content();
        embeddingStore.add(embedding1, segment1);
        System.out.println("Inserting Record no. 1  "+segment1.toString());
        System.out.println("Embedding form of Inserted Data  "+embedding1.toString());
        System.out.println("======================================================");
        //Apples
        TextSegment segment2 = TextSegment.from("Some of the best Apple are from Kinnaur and Shimla in India and Aomori in Japan, Apple comes in various colors like red, green and yellow");
        Embedding embedding2 = embeddingModel.embed(segment2).content();
        embeddingStore.add(embedding2, segment2);
        System.out.println("Inserting Record no. 2 "+segment2.toString());
        System.out.println("======================================================");
        //Mangoes
        TextSegment segment3 = TextSegment.from("Some of the best mangoes are from Sindhudurg, Raigad and Ratnagiri");
        Embedding embedding3 = embeddingModel.embed(segment3).content();
        embeddingStore.add(embedding3, segment3);
        System.out.println("Inserting Record no. 3  "+segment3.toString());
        System.out.println("======================================================");
        //Bananas
        TextSegment segment4 = TextSegment.from("A banana is an elongated, edible fruit botanically a berry produced by several kinds of large herbaceous flowering plants in the genus Musa. " +
                "In some countries, cooking bananas are called plantains,");
        Embedding embedding4 = embeddingModel.embed(segment4).content();
        embeddingStore.add(embedding4, segment4);
        System.out.println("Inserting Record no. 4  "+segment4.toString());
        System.out.println("======================================================");
        System.out.println("======================================================");
        System.out.println("==== Querying Oracle Database 23ai Embeddings ========");
        String question1 = "What is large herbaceous flowering plants";
        Content match = retriever.retrieve(Query.from(question1)).get(0);
        System.out.println("Question: "+question1+ "\nAnswer: "+match.textSegment());
        System.out.println("======================================================");
        String question2 = "Where can i find best Apples";
        Content match2 = retriever.retrieve(Query.from(question2)).get(0);
        System.out.println("Question: "+question2+ "\nAnswer:  "+match2.textSegment());
        System.out.println("======================================================");
        String question3 = "Tell me about Guava";
        Content match3 = retriever.retrieve(Query.from("Tell me about Guava ")).get(0);
        System.out.println("Question: "+question3+ "\nnAnswer:    "+match3.textSegment());
        System.out.println("======================================================"); 
    }
}
