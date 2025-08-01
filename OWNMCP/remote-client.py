import requests

class MCPClient:
    def __init__(self, server_url):
        self.server_url = server_url

    def send_request(self, data):
        response = requests.post(self.server_url, json={"data": data})
        return response.json()

if __name__ == "__main__":
    server_url = "http://<public-ip>:8050/mcp"
    client = MCPClient(server_url)
    response = client.send_request("Hello, MCP!")
    print(response)

# Code running on Oracle Enterprise Linux 8 or Oracle Autonomous Linux on Oracle Cloud Infrastructure and Port 8050 Opened in VCN
# Madhusudhan Rao - Author
# [oracle@indmcpdb ownmcp]$ source .venv/bin/activate
# (ownmcp-project) [oracle@indmcpdb ownmcp]$ uv run remote-server.py
