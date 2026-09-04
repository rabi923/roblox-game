--[[
    Hotel Hermes - Remote Event & Function Declarations
    File: ReplicatedStorage/Remotes/RemoteDeclarations.lua
    Description: Centralized registry that constructs and exposes all networked
                 RemoteEvents and RemoteFunctions with type safety.
--]]

local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RemoteDeclarations = {}

-- List of standard RemoteEvents
local REMOTE_EVENTS = {
    "InteractRequest",      -- Client -> Server: (targetInstance: Instance)
    "NoiseEvent",           -- Client -> Server: (noiseType: string, intensity: number, worldPos: Vector3)
    "FlashlightToggle",     -- Client -> Server: (isOn: boolean)
    "LootPickup",           -- Client -> Server: (containerId: string, itemSlot: number)
    "FloorUpdate",          -- Server -> Client: (floorData: table)
    "UINotification",       -- Server -> Client: (title: string, message: string, colorType: string)
    "GameStateChange",      -- Server -> Client: (newState: string, statePayload: table)
    "CameraJumpscare",      -- Server -> Client: (entityId: string, duration: number)
}

-- High-frequency UnreliableRemoteEvents (Roblox built-in unreliable networking for 10Hz sync)
local UNRELIABLE_REMOTE_EVENTS = {
    "EntityUpdate",         -- Server -> Client: (entityDataArray: table)
    "PlayerBreathingState", -- Client -> Server: (isHiding: boolean, breathHolding: boolean)
}

-- RemoteFunctions (Request/Response pattern)
local REMOTE_FUNCTIONS = {
    "CheckInRequest",       -- Client -> Server: () -> (success: boolean, message: string)
    "CheckOutRequest",      -- Client -> Server: () -> (success: boolean, lootBanked: table)
    "PuzzleInput",          -- Client -> Server: (puzzleId: string, inputPayload: table) -> (solved: boolean, feedback: string)
    "WheelSpinRequest",     -- Client -> Server: () -> (success: boolean, reward: table)
    "GetLeaderboardData",   -- Client -> Server: (scope: string) -> (entries: table)
}

local remotesFolder: Folder

--[[
    Initializes the remote hierarchy.
    On Server: Generates folders and instances if they do not exist.
    On Client: Waits for instances to replicate.
--]]
function RemoteDeclarations.Init()
    if RunService:IsServer() then
        remotesFolder = ReplicatedStorage:FindFirstChild("Remotes")
        if not remotesFolder then
            remotesFolder = Instance.new("Folder")
            remotesFolder.Name = "Remotes"
            remotesFolder.Parent = ReplicatedStorage
        end

        for _, eventName in ipairs(REMOTE_EVENTS) do
            if not remotesFolder:FindFirstChild(eventName) then
                local remote = Instance.new("RemoteEvent")
                remote.Name = eventName
                remote.Parent = remotesFolder
            end
        end

        for _, eventName in ipairs(UNRELIABLE_REMOTE_EVENTS) do
            if not remotesFolder:FindFirstChild(eventName) then
                local remote = Instance.new("UnreliableRemoteEvent")
                remote.Name = eventName
                remote.Parent = remotesFolder
            end
        end

        for _, funcName in ipairs(REMOTE_FUNCTIONS) do
            if not remotesFolder:FindFirstChild(funcName) then
                local remote = Instance.new("RemoteFunction")
                remote.Name = funcName
                remote.Parent = remotesFolder
            end
        end
    else
        remotesFolder = ReplicatedStorage:WaitForChild("Remotes", 10)
        assert(remotesFolder, "[RemoteDeclarations] Timed out waiting for Remotes folder on Client!")
    end

    return RemoteDeclarations
end

--[[
    Retrieves a RemoteEvent by name with timeout safety on client.
--]]
function RemoteDeclarations.GetEvent(name: string): RemoteEvent | UnreliableRemoteEvent
    if not remotesFolder then
        RemoteDeclarations.Init()
    end
    local remote = remotesFolder:WaitForChild(name, 5)
    assert(remote, string.format("[RemoteDeclarations] RemoteEvent '%s' not found!", name))
    return remote
end

--[[
    Retrieves a RemoteFunction by name with timeout safety on client.
--]]
function RemoteDeclarations.GetFunction(name: string): RemoteFunction
    if not remotesFolder then
        RemoteDeclarations.Init()
    end
    local remote = remotesFolder:WaitForChild(name, 5)
    assert(remote, string.format("[RemoteDeclarations] RemoteFunction '%s' not found!", name))
    return remote
end

return RemoteDeclarations
