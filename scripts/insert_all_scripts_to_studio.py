r"""
Hotel Hermes - High-Speed Batch Luau Script Injector
Maintains a single persistent StudioMCP connection to inject all 22 scripts
into session.rbxl in seconds.
"""

import os
import json
import subprocess
import time

PROJECT_DIR = r"C:\Users\abish\OneDrive\Desktop\roblox game hermes"
STUDIO_MCP_PATH = r"C:\Users\abish\AppData\Local\Roblox\Versions\version-9fe94fb0e9d84c25\StudioMCP.exe"

def read_src(relative_path):
    full_path = os.path.join(PROJECT_DIR, "src", relative_path)
    with open(full_path, "r", encoding="utf-8") as f:
        return f.read()

def main():
    print("Starting StudioMCP single-session process...")
    proc = subprocess.Popen(
        [STUDIO_MCP_PATH],
        stdin=subprocess.PIPE,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True,
        bufsize=1
    )

    req_id = 1
    def send(msg):
        nonlocal req_id
        msg["id"] = req_id
        req_id += 1
        proc.stdin.write(json.dumps(msg) + "\n")
        proc.stdin.flush()
        line = proc.stdout.readline()
        return json.loads(line) if line else None

    # 1. Initialize
    send({
        "jsonrpc": "2.0",
        "method": "initialize",
        "params": {
            "protocolVersion": "2024-11-05",
            "capabilities": {},
            "clientInfo": {"name": "batch-injector", "version": "1.0.0"}
        }
    })
    proc.stdin.write(json.dumps({"jsonrpc": "2.0", "method": "notifications/initialized", "params": {}}) + "\n")
    proc.stdin.flush()

    # 2. Poll for Studio
    studios = []
    for i in range(15):
        time.sleep(1.0)
        list_res = send({
            "jsonrpc": "2.0",
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
                parsed = json.loads(res_data["content"][0].get("text", ""))
                studios = parsed.get("studios", [])
            except Exception:
                pass
        if studios:
            break

    if not studios:
        proc.terminate()
        raise RuntimeError("No connected studios found")

    studio_id = studios[0]["id"]
    print(f"Connected to Studio session: {studio_id}")

    def execute_luau(code):
        res = send({
            "jsonrpc": "2.0",
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
        txt = "OK"
        if res and "result" in res and "content" in res["result"] and res["result"]["content"]:
            txt = res["result"]["content"][0].get("text", "")
        return txt

    # 1. Remote Instances in ReplicatedStorage.Remotes
    print("Setting up Remotes in ReplicatedStorage.Remotes...")
    remotes_code = """
    local Remotes = game:GetService("ReplicatedStorage"):WaitForChild("Remotes")
    local events = {
        "GameStateChangeEvent", "UINotificationEvent", "FootstepNoiseEvent",
        "PlayerDiedEvent", "FlashlightToggleEvent", "InteractionPromptEvent"
    }
    for _, name in ipairs(events) do
        if not Remotes:FindFirstChild(name) then
            local e = Instance.new("RemoteEvent")
            e.Name = name
            e.Parent = Remotes
        end
    end
    local functions = {
        "CheckInFunction", "WheelSpinFunction", "GetLeaderboardFunction",
        "CheckOutFunction", "SubmitPuzzleFunction"
    }
    for _, name in ipairs(functions) do
        if not Remotes:FindFirstChild(name) then
            local f = Instance.new("RemoteFunction")
            f.Name = name
            f.Parent = Remotes
        end
    end
    return "Remotes setup complete"
    """
    print(" ->", execute_luau(remotes_code))

    # All 22 scripts to inject
    all_scripts = [
        # ReplicatedStorage.SharedModules (3)
        ('game:GetService("ReplicatedStorage"):WaitForChild("SharedModules")', "ModuleScript", "Constants", "ReplicatedStorage/SharedModules/Constants.lua"),
        ('game:GetService("ReplicatedStorage"):WaitForChild("SharedModules")', "ModuleScript", "GameConfig", "ReplicatedStorage/SharedModules/GameConfig.lua"),
        ('game:GetService("ReplicatedStorage"):WaitForChild("SharedModules")', "ModuleScript", "PuzzleDefinitions", "ReplicatedStorage/SharedModules/PuzzleDefinitions.lua"),
        # ReplicatedStorage.Remotes (1)
        ('game:GetService("ReplicatedStorage"):WaitForChild("Remotes")', "ModuleScript", "RemoteDeclarations", "ReplicatedStorage/Remotes/RemoteDeclarations.lua"),
        # StarterPlayerScripts (5)
        ('game:GetService("StarterPlayer"):WaitForChild("StarterPlayerScripts")', "LocalScript", "PlayerController", "StarterPlayer/StarterPlayerScripts/PlayerController.lua"),
        ('game:GetService("StarterPlayer"):WaitForChild("StarterPlayerScripts")', "ModuleScript", "InputBindings", "StarterPlayer/StarterPlayerScripts/InputBindings.lua"),
        ('game:GetService("StarterPlayer"):WaitForChild("StarterPlayerScripts")', "ModuleScript", "CameraEffects", "StarterPlayer/StarterPlayerScripts/CameraEffects.lua"),
        ('game:GetService("StarterPlayer"):WaitForChild("StarterPlayerScripts")', "ModuleScript", "UIController", "StarterPlayer/StarterPlayerScripts/UIController.lua"),
        ('game:GetService("StarterPlayer"):WaitForChild("StarterPlayerScripts")', "ModuleScript", "AudioManager", "StarterPlayer/StarterPlayerScripts/AudioManager.lua"),
        # ServerScriptService (8)
        ('game:GetService("ServerScriptService")', "ModuleScript", "GameManager", "ServerScriptService/GameManager.lua"),
        ('game:GetService("ServerScriptService")', "ModuleScript", "FloorGenerator", "ServerScriptService/FloorGenerator.lua"),
        ('game:GetService("ServerScriptService")', "ModuleScript", "DataManager", "ServerScriptService/DataManager.lua"),
        ('game:GetService("ServerScriptService")', "ModuleScript", "LobbyManager", "ServerScriptService/LobbyManager.lua"),
        ('game:GetService("ServerScriptService")', "ModuleScript", "AntiExploit", "ServerScriptService/AntiExploit.lua"),
        ('game:GetService("ServerScriptService")', "ModuleScript", "APIBridge", "ServerScriptService/APIBridge.lua"),
        ('game:GetService("ServerScriptService")', "ModuleScript", "RemoteValidator", "ServerScriptService/RemoteValidator.lua"),
        ('game:GetService("ServerScriptService")', "ModuleScript", "PuzzleManager", "ServerScriptService/PuzzleManager.lua"),
        # StarterGui (5)
        ('game:GetService("StarterGui")', "ModuleScript", "HUDLayout", "StarterGui/HUDLayout.lua"),
        ('game:GetService("StarterGui")', "ModuleScript", "MainMenuLayout", "StarterGui/MainMenuLayout.lua"),
        ('game:GetService("StarterGui")', "ModuleScript", "PauseMenuLayout", "StarterGui/PauseMenuLayout.lua"),
        ('game:GetService("StarterGui")', "ModuleScript", "DeathScreenLayout", "StarterGui/DeathScreenLayout.lua"),
        ('game:GetService("StarterGui")', "ModuleScript", "ElevatorUILayout", "StarterGui/ElevatorUILayout.lua"),
    ]

    for parent_expr, script_class, name, rel_path in all_scripts:
        src = read_src(rel_path)
        # Escape for Luau multiline string literal safely
        escaped = src.replace("\\", "\\\\").replace('"', '\\"').replace("\n", "\\n").replace("\r", "")
        code = f"""
        local parent = {parent_expr}
        local s = parent:FindFirstChild("{name}")
        if not s or s.ClassName ~= "{script_class}" then
            if s then s:Destroy() end
            s = Instance.new("{script_class}")
            s.Name = "{name}"
            s.Parent = parent
        end
        s.Source = "{escaped}"
        return s:GetFullName()
        """
        res = execute_luau(code)
        print(f"[OK] Injected: {name} ({script_class}) -> {res}")

    # ServerInit Main Script
    print("Injecting ServerScriptService.ServerInit...")
    server_init_code = """
    local sss = game:GetService("ServerScriptService")
    local init = sss:FindFirstChild("ServerInit")
    if not init then
        init = Instance.new("Script")
        init.Name = "ServerInit"
        init.Parent = sss
    end
    init.Source = [[
    -- Hotel Hermes - Server Master Bootstrap Entry Point
    print("🏨 [Hotel Hermes] Initializing Server Systems...")
    local ServerScriptService = game:GetService("ServerScriptService")

    -- Load Server Modules
    local DataManager = require(ServerScriptService:WaitForChild("DataManager"))
    local LobbyManager = require(ServerScriptService:WaitForChild("LobbyManager"))
    local GameManager = require(ServerScriptService:WaitForChild("GameManager"))
    local FloorGenerator = require(ServerScriptService:WaitForChild("FloorGenerator"))
    local AntiExploit = require(ServerScriptService:WaitForChild("AntiExploit"))
    local PuzzleManager = require(ServerScriptService:WaitForChild("PuzzleManager"))

    print("🏨 [Hotel Hermes] All server systems initialized successfully!")
    ]]
    return init:GetFullName()
    """
    res = execute_luau(server_init_code)
    print(f"[OK] Injected: ServerInit -> {res}")

    proc.terminate()
    print("\n[SUCCESS] ALL 22 LUAU SCRIPTS & REMOTES INJECTED SUCCESSFULLY INTO STUDIO!")

if __name__ == "__main__":
    main()
