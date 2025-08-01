from mcp.server.fastmcp import FastMCP
from dotenv import load_dotenv
import webbrowser
import urllib.parse

load_dotenv("../.venv")

mcp = FastMCP(name="Demo Server 🚀",host="0.0.0.0",port=8050)

@mcp.tool()
def add(a: int, b: int) -> int:
    """Add two numbers"""
    return a + b

# Add a subtraction tool
@mcp.tool()
def subtract(a: int, b: int) -> int:
    """Subtract two numbers"""
    return a - b

# Add a multiplication tool
@mcp.tool()
def multiply(a: int, b: int) -> int:
    """Multiply two numbers"""
    return a * b

# Add a division tool
@mcp.tool()
def divide(a: int, b: int) -> float:
    """Divide two numbers"""
    if b == 0:
        raise ValueError("Cannot divide by zero")
    return a / b
  
# Add a static resource
@mcp.resource("resource://static_resource1")
def static_resource():
    """A static resource"""
    return "This is a static resource 1."

# Add a dynamic resource
@mcp.resource("greeting://dyn_resource1")
def dynamic_resource():
    """A dynamic resource that returns a greeting"""
    return "Hello from the dynamic resource 1!"

# Add a prompt
@mcp.prompt("review_code")
def review_code(code: str) -> str:
    """Review a piece of code"""
    return f"Please review the following code:\n{code}"

if __name__ == "__main__":   
    print("Starting the MCP server...") 
    mcp.run()

#(ownmcp-project) madhusudhanrao@MadhuMac ownmcp % mcp dev server.py
#(ownmcp-project) madhusudhanrao@MadhuMac ownmcp % uv run server.py
