from mcp.server.fastmcp import FastMCP
from dotenv import load_dotenv

load_dotenv("../.env")

# Create an MCP server
mcp = FastMCP(
    name="Calculator",
    host="0.0.0.0",  # only used for SSE transport (localhost)
    port=8050,  # only used for SSE transport (set this to any port)
    stateless_http=True,
) 

# Add a simple calculator tool
@mcp.tool()
def add(a: int, b: int) -> int:
    """Add two numbers together"""
    return a + b


# Run the server
if __name__ == "__main__":
    print("Running server with stdio transport")
    mcp.run(transport="stdio")
    # if transport == "stdio":
    #     print("Running server with stdio transport")
    #     mcp.run(transport="stdio")
    # elif transport == "sse":
    #     print("Running server with SSE transport")
    #     mcp.run(transport="sse")
    # elif transport == "streamable-http":
    #     print("Running server with Streamable HTTP transport")
    #     mcp.run(transport="streamable-http")
    # else:
    #     raise ValueError(f"Unknown transport: {transport}")
    
#uv pip install -r requirements.txt
#(ownmcp-project) madhusudhanrao@MadhuMac ownmcp % uv run server-stdio.py (or server is invoked by client directly see client-stdio.py 
