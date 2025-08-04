from langchain_community.chat_models.oci_generative_ai import ChatOCIGenAI

llm = ChatOCIGenAI(
    model_id="cohere.command-r-plus-08-2024", 
    service_endpoint="https://inference.generativeai.sa-saopaulo-1.oci.oraclecloud.com",
    compartment_id="ocid1.compartment.oc1..aaaaaaaaudXXdn6XXXXXXXixcmj54u32q", # replace with your OCID
)

response = llm.invoke("Who built pyramids", temperature=0.7)
print(response)
