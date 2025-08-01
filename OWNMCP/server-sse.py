from mcp.server.fastmcp import FastMCP
from dotenv import load_dotenv

load_dotenv("../.env")

# Create an MCP server
mcp = FastMCP(
    name="Calculator",
    host="localhost",  # only used for SSE transport (localhost)
    port=8050,  # only used for SSE transport (set this to any port)
    transport="sse",  # Set the transport to SSE
    #stateless_http=True,
)


# Add a simple calculator tool
@mcp.tool()
def add(a: int, b: int) -> int:
    """Add two numbers together"""
    return a + b


# Run the server
if __name__ == "__main__":
    mcp.run(transport="sse")
    
#uv pip install -r requirements.txt
#(ownmcp-project) madhusudhanrao@MadhuMac ownmcp % uv run server-sse.py
