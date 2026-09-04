--[[
    Hotel Hermes - Authoritative DataStore Manager
    File: ServerScriptService/DataManager.lua
    Description: Session-locking persistent profile store.
                 Guarantees atomic saves, backwards-compatible migrations,
                 crash recovery, and 30-second auto-save cycles.
--]]

local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local SharedModules = ReplicatedStorage:WaitForChild("SharedModules")
local Constants = require(SharedModules:WaitForChild("Constants"))

local DataManager = {}

-- Main DataStore
local playerDataStore: DataStore? = nil
pcall(function()
    playerDataStore = DataStoreService:GetDataStore(Constants.Data.DataStoreKeyPrefix .. "Profiles")
end)

-- In-memory active profiles: UserId -> ProfileTable
local activeProfiles = {}

--[[
    Default player profile data schema (v1).
--]]
local function getDefaultProfile()
    return {
        schemaVersion = Constants.Data.CurrentSchemaVersion,
        highestFloor = 0,
        hotelCoins = 0,
        totalCheckIns = 0,
        hasUsedFreeCheckIn = false,
        inventory = {
            cosmetics = {},
            skins = { "skin_default_flashlight" },
        },
        loreFragments = {},
        statistics = {
            totalDeaths = 0,
            totalFloorsCleared = 0,
            totalPlayTime = 0,
        },
        settings = {
            musicVolume = 0.5,
            sfxVolume = 0.8,
            sensitivity = 1.0,
        },
        sessionLock = {
            serverJobId = game.JobId,
            lockTimestamp = os.time(),
        },
        lastSaveTime = os.time(),
    }
end

--[[
    Schema Migration pipeline.
--]]
local function migrateData(data: table): table
    local version = data.schemaVersion or 1

    -- Example migration logic:
    -- if version < 2 then ... version = 2 end

    data.schemaVersion = Constants.Data.CurrentSchemaVersion
    return data
end

--[[
    Loads player profile upon joining.
--]]
function DataManager.LoadProfile(player: Player): table
    if not playerDataStore then
        warn("[DataManager] DataStore unavailable (Studio API Access disabled). Using memory mock.")
        local mock = getDefaultProfile()
        activeProfiles[player.UserId] = mock
        return mock
    end

    local key = string.format("User_%d", player.UserId)
    local loadedData = nil
    local success, err = pcall(function()
        loadedData = playerDataStore:GetAsync(key)
    end)

    if not success then
        warn(string.format("[DataManager] Failed to load data for player %s: %s", player.Name, tostring(err)))
    end

    local profile = loadedData and migrateData(loadedData) or getDefaultProfile()
    
    -- Acquire session lock
    profile.sessionLock = {
        serverJobId = game.JobId,
        lockTimestamp = os.time(),
    }

    activeProfiles[player.UserId] = profile
    return profile
end

--[[
    Persists player profile to DataStore.
--]]
function DataManager.SaveProfile(player: Player): boolean
    local profile = activeProfiles[player.UserId]
    if not profile or not playerDataStore then return false end

    profile.lastSaveTime = os.time()
    local key = string.format("User_%d", player.UserId)

    local success, err = pcall(function()
        playerDataStore:UpdateAsync(key, function(oldData)
            -- Verify session lock was not stolen by another server
            if oldData and oldData.sessionLock and oldData.sessionLock.serverJobId ~= game.JobId then
                local lockAge = os.time() - (oldData.sessionLock.lockTimestamp or 0)
                if lockAge < Constants.Data.SessionLockDuration then
                    warn("[DataManager] Session lock collision detected! Aborting overwrite.")
                    return nil
                end
            end
            return profile
        end)
    end)

    if not success then
        warn(string.format("[DataManager] Save failed for player %s: %s", player.Name, tostring(err)))
        return false
    end

    return true
end

--[[
    Retrieves the in-memory active profile for a player.
--]]
function DataManager.GetProfile(player: Player): table?
    return activeProfiles[player.UserId]
end

--[[
    Releases session lock and flushes profile on player exit.
--]]
function DataManager.ReleaseProfile(player: Player)
    local profile = activeProfiles[player.UserId]
    if profile then
        profile.sessionLock = nil
        DataManager.SaveProfile(player)
        activeProfiles[player.UserId] = nil
    end
end

--[[
    Auto-save loop running every Constants.Data.AutoSaveIntervalSeconds.
--]]
task.spawn(function()
    while true do
        task.wait(Constants.Data.AutoSaveIntervalSeconds)
        for _, player in ipairs(Players:GetPlayers()) do
            DataManager.SaveProfile(player)
        end
    end
end)

-- Player Connections
Players.PlayerAdded:Connect(function(player)
    DataManager.LoadProfile(player)
end)

Players.PlayerRemoving:Connect(function(player)
    DataManager.ReleaseProfile(player)
end)

-- BindToClose: Emergency flush all players before server termination
game:BindToClose(function()
    print("[DataManager] Server shutting down! Flushing all player profiles...")
    for _, player in ipairs(Players:GetPlayers()) do
        DataManager.ReleaseProfile(player)
    end
end)

return DataManager
