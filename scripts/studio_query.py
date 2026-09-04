import sys
import subprocess
import json
import time

STUDIO_MCP_PATH = r"C:\Users\abish\AppData\Local\Roblox\Versions\version-9fe94fb0e9d84c25\StudioMCP.exe"

def run_luau(code):
    proc = subprocess.Popen(
        [STUDIO_MCP_PATH],
        stdin=subprocess.PIPE,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True,
        encoding="utf-8",
        errors="replace",
        bufsize=1
    )

    def send(msg):
        proc.stdin.write(json.dumps(msg) + "\n")
        proc.stdin.flush()
        line = proc.stdout.readline()
        return json.loads(line) if line else None

    # 1. Initialize
    init_res = send({
        "jsonrpc": "2.0",
        "id": 1,
        "method": "initialize",
        "params": {
            "protocolVersion": "2024-11-05",
            "capabilities": {},
            "clientInfo": {"name": "hermes-bridge", "version": "1.0.0"}
        }
    })

    # 2. Initialized notification
    proc.stdin.write(json.dumps({"jsonrpc": "2.0", "method": "notifications/initialized", "params": {}}) + "\n")
    proc.stdin.flush()

    # 3. Poll for connected Studio instance
    studios = []
    for i in range(12):
        time.sleep(1.0)
        list_res = send({
            "jsonrpc": "2.0",
            "id": i + 2,
            "method": "tools/call",
            "params": {"name": "list_roblox_studios", "arguments": {}}
        })
        if not list_res or "result" not in list_res:
            continue

        res_data = list_res["result"]
        if "studios" in res_data:
            studios = res_data["studios"]
        elif "content" in res_data and res_data["content"]:
            try:
                content_text = res_data["content"][0].get("text", "")
                parsed = json.loads(content_text)
                studios = parsed.get("studios", [])
            except Exception:
                pass

        if studios:
            break

    if not studios:
        proc.terminate()
        return {"error": "No connected studios found after polling", "raw": list_res}

    studio_id = studios[0]["id"]
    studio_name = studios[0].get("name", "Unknown")

    # 4. Execute Luau
    exec_res = send({
        "jsonrpc": "2.0",
        "id": 99,
        "method": "tools/call",
        "params": {
            "name": "execute_luau",
            "arguments": {
                "studio_id": studio_id,
                "datamodel_type": "Edit",
                "code": code
            }
        }
    })

    proc.terminate()
    return {
        "studio_name": studio_name,
        "studio_id": studio_id,
        "result": exec_res
    }

if __name__ == "__main__":
    if len(sys.argv) > 1 and sys.argv[1].endswith(".lua"):
        with open(sys.argv[1], "r", encoding="utf-8") as f:
            test_code = f.read()
    elif len(sys.argv) > 1:
        test_code = sys.argv[1]
    else:
        test_code = 'return "Connected: " .. game.Name'
    out = run_luau(test_code)
    print(json.dumps(out, indent=2))
