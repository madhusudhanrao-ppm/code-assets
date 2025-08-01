from fastapi import FastAPI
from pydantic import BaseModel

app = FastAPI()

class MCPRequest(BaseModel):
    data: str

@app.post("/mcp")
async def handle_mcp_request(request: MCPRequest):
    # Process the MCP request
    # Keep this server running in background as uv run remote-server.py
    response = {"result": "Call from Remote Client"}
    return response
