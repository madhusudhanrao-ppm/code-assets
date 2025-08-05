from mcp.server.fastmcp import FastMCP
from langchain_community.chat_models.oci_generative_ai import ChatOCIGenAI
from dotenv import load_dotenv 
import urllib.parse
 

load_dotenv("../.venv")

mcp = FastMCP(name="Demo Server 🚀",host="0.0.0.0",port=8050)

llm = ChatOCIGenAI(
    model_id="cohere.command-r-plus-08-2024", 
    service_endpoint="https://inference.generativeai.us-chicago-1.oci.oraclecloud.com",
    compartment_id="ocid1.compartment.oc1..aaaaaaaaud6yourcompartmentidmj54u32q", # replace with your OCID
)

@mcp.tool()
def oracle_genai_tool(ai_input: str) -> str:
    """Oracle Gen AI"""
    ai_response = llm.invoke(f"{ai_input}", temperature=0.7)  
    return f"AI Response:{ai_response}" 

# Add a prompt
@mcp.prompt("oracle_gen_ai_input")
def oracle_genai_prompt(ai_input: str) -> str: 
    ai_response = llm.invoke(f"{ai_input}", temperature=0.7)  
    return f"AI Response:{ai_response}" 

if __name__ == "__main__":   
    print("Starting the MCP server...") 
    mcp.run()
 
#mcp dev oracle_gen_ai_mcp_server.py
