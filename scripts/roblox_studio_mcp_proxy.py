import sys
import subprocess
import json
import threading
import os
import glob

# Ensure line buffering and unbuffered stdio
if hasattr(sys.stdout, "reconfigure"):
    sys.stdout.reconfigure(line_buffering=True)
if hasattr(sys.stdin, "reconfigure"):
    sys.stdin.reconfigure(line_buffering=True)

def find_studio_mcp():
    local_app_data = os.environ.get("LOCALAPPDATA") or r"C:\Users\abish\AppData\Local"
    versions_dir = os.path.join(local_app_data, "Roblox", "Versions")
    pattern = os.path.join(versions_dir, "version-*", "StudioMCP.exe")
    candidates = glob.glob(pattern)
    if candidates:
        candidates.sort(key=os.path.getmtime, reverse=True)
        return candidates[0]
    return r"C:\Users\abish\AppData\Local\Roblox\Versions\version-9fe94fb0e9d84c25\StudioMCP.exe"

STUDIO_MCP_PATH = find_studio_mcp()

def main():
    proc = subprocess.Popen(
        [STUDIO_MCP_PATH],
        stdin=subprocess.PIPE,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True,
        bufsize=1,
    )

    def forward_stdout():
        try:
            for line in iter(proc.stdout.readline, ""):
                sys.stdout.write(line)
                sys.stdout.flush()
        except Exception:
            pass

    def forward_stderr():
        try:
            for line in iter(proc.stderr.readline, ""):
                sys.stderr.write(line)
                sys.stderr.flush()
        except Exception:
            pass

    t_out = threading.Thread(target=forward_stdout, daemon=True)
    t_err = threading.Thread(target=forward_stderr, daemon=True)
    t_out.start()
    t_err.start()

    try:
        while True:
            line = sys.stdin.readline()
            if not line:
                break

            line_clean = line.strip()
            if not line_clean:
                continue

            try:
                req = json.loads(line_clean)
                if isinstance(req, dict) and req.get("method") == "server/discover":
                    req_id = req.get("id")
                    res = {"jsonrpc": "2.0", "id": req_id, "result": {}}
                    sys.stdout.write(json.dumps(res) + "\n")
                    sys.stdout.flush()
                    continue
            except Exception:
                pass

            try:
                proc.stdin.write(line)
                proc.stdin.flush()
            except Exception:
                break
    except (KeyboardInterrupt, EOFError):
        pass
    finally:
        try:
            proc.terminate()
            proc.wait(timeout=2)
        except Exception:
            proc.kill()

if __name__ == "__main__":
    main()
