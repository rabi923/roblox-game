--[[
    Hotel Hermes - Master Server Game State Machine
    File: ServerScriptService/GameManager.lua
    Description: Orchestrates core run lifecycle, unsaved loot tracking,
                 floor progression, elevator transitions, and player catch/elimination.
--]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local SharedModules = ReplicatedStorage:WaitForChild("SharedModules")
local Constants = require(SharedModules:WaitForChild("Constants"))
local RemoteDeclarations = require(ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("RemoteDeclarations"))

local DataManager = require(script.Parent:WaitForChild("DataManager"))
local FloorGenerator = require(script.Parent:WaitForChild("FloorGenerator"))
local PuzzleManager = require(script.Parent:WaitForChild("PuzzleManager"))

local GameManager = {}

-- Player Run Sessions: UserId -> SessionData
-- { State = string, CurrentFloor = number, UnsavedCoins = number, UnsavedLore = table, StartTime = number }
local activeSessions = {}

local gameStateChangeEvent: RemoteEvent
local uiNotificationEvent: RemoteEvent
local checkOutFunction: RemoteFunction

--[[
    Starts a new hotel floor run for a player.
--]]
function GameManager.StartRun(player: Player)
    local profile = DataManager.GetProfile(player)
    if not profile then return false, "Profile not loaded" end

    local startingFloor = 1
    local floorRecord = FloorGenerator.GenerateFloor(startingFloor)

    activeSessions[player.UserId] = {
        State = "FLOOR_ACTIVE",
        CurrentFloor = startingFloor,
        UnsavedCoins = 0,
        UnsavedLore = {},
        StartTime = os.time(),
    }

    -- Teleport player into the elevator of Floor 1
    local char = player.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CFrame = CFrame.new(floorRecord.SpawnPoint)
    end

    gameStateChangeEvent:FireClient(player, "FLOOR_START", { Floor = startingFloor })
    uiNotificationEvent:FireClient(player, "Checked In", "Floor 1 awaits. Find the keycards to power the elevator.", "Success")
    return true
end

--[[
    Called by PuzzleManager when the floor puzzle is solved.
--]]
local function onFloorPuzzleSolved(floorNumber: number)
    for userId, session in pairs(activeSessions) do
        if session.CurrentFloor == floorNumber and session.State == "FLOOR_ACTIVE" then
            session.State = "FLOOR_COMPLETE"
            local player = Players:GetPlayerByUserId(userId)
            if player then
                -- Award floor clear bonus
                local coinReward = 40 + (floorNumber * 15)
                session.UnsavedCoins = session.UnsavedCoins + coinReward

                local lootSummary = string.format("+%d Hotel Coins gathered this run", session.UnsavedCoins)
                gameStateChangeEvent:FireClient(player, "ELEVATOR_DECISION", {
                    Floor = floorNumber,
                    LootSummary = lootSummary,
                })
            end
        end
    end
end

--[[
    Handles player decision to proceed to Floor N+1.
--]]
function GameManager.ContinueToNextFloor(player: Player)
    local session = activeSessions[player.UserId]
    if not session or session.State ~= "FLOOR_COMPLETE" then return end

    local oldFloor = session.CurrentFloor
    local nextFloor = oldFloor + 1

    -- Assemble next floor
    local floorRecord = FloorGenerator.GenerateFloor(nextFloor)
    session.CurrentFloor = nextFloor
    session.State = "FLOOR_ACTIVE"

    -- Teleport character
    local char = player.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CFrame = CFrame.new(floorRecord.SpawnPoint)
    end

    -- Clean up previous floor instances
    FloorGenerator.DestroyFloor(oldFloor)

    gameStateChangeEvent:FireClient(player, "FLOOR_START", { Floor = nextFloor })
    uiNotificationEvent:FireClient(player, string.format("Arrived: Floor %d", nextFloor), "The hotel air grows colder.", "Warning")
end

--[[
    Handles player decision to Check Out and bank all gathered loot.
--]]
function GameManager.CheckOutAndBank(player: Player): (boolean, table)
    local session = activeSessions[player.UserId]
    if not session then
        return false, {}
    end

    local profile = DataManager.GetProfile(player)
    if not profile then return false, {} end

    -- Bank all unsaved loot permanently
    local bankedCoins = session.UnsavedCoins
    profile.hotelCoins = profile.hotelCoins + bankedCoins

    if session.CurrentFloor > profile.highestFloor then
        profile.highestFloor = session.CurrentFloor
    end
    profile.statistics.totalFloorsCleared = profile.statistics.totalFloorsCleared + session.CurrentFloor

    DataManager.SaveProfile(player)

    -- Destroy floor instance
    FloorGenerator.DestroyFloor(session.CurrentFloor)
    activeSessions[player.UserId] = nil

    -- Teleport back to Lobby
    local char = player.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local lobbySpawn = workspace:FindFirstChild("Lobby") and workspace.Lobby:FindFirstChild("SpawnLocation")
        local spawnPos = lobbySpawn and lobbySpawn.Position + Vector3.new(0, 3, 0) or Vector3.new(0, 5, 0)
        char.HumanoidRootPart.CFrame = CFrame.new(spawnPos)
    end

    gameStateChangeEvent:FireClient(player, "LOBBY_RETURN", {})
    return true, { BankedCoins = bankedCoins, HighestFloor = profile.highestFloor }
end

--[[
    Handles player caught by an entity (Elimination).
--]]
function GameManager.OnPlayerCaught(player: Player, entityName: string)
    local session = activeSessions[player.UserId]
    if not session then return end

    local profile = DataManager.GetProfile(player)
    if profile then
        profile.statistics.totalDeaths = profile.statistics.totalDeaths + 1
        DataManager.SaveProfile(player)
    end

    local floorDied = session.CurrentFloor
    local lostCoins = session.UnsavedCoins

    -- Wipe unsaved session loot!
    FloorGenerator.DestroyFloor(session.CurrentFloor)
    activeSessions[player.UserId] = nil

    gameStateChangeEvent:FireClient(player, "PLAYER_CAUGHT", {
        Floor = floorDied,
        StatsSummary = string.format("Caught by %s. %d Hotel Coins lost.", entityName or "an Entity", lostCoins),
    })

    -- Return to lobby after delay
    task.delay(Constants.Entity.JumpscareDuration + 1.0, function()
        local char = player.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            char.HumanoidRootPart.CFrame = CFrame.new(0, 5, 0)
        end
    end)
end

function GameManager.Init()
    gameStateChangeEvent = RemoteDeclarations.GetEvent("GameStateChange")
    uiNotificationEvent = RemoteDeclarations.GetEvent("UINotification")
    checkOutFunction = RemoteDeclarations.GetFunction("CheckOutRequest")

    checkOutFunction.OnServerInvoke = function(player)
        return GameManager.CheckOutAndBank(player)
    end

    gameStateChangeEvent.OnServerEvent:Connect(function(player, actionType, payload)
        if actionType == "CONTINUE_NEXT_FLOOR" then
            GameManager.ContinueToNextFloor(player)
        elseif actionType == "RETURN_TO_LOBBY" then
            local char = player.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                char.HumanoidRootPart.CFrame = CFrame.new(0, 5, 0)
            end
        end
    end)

    PuzzleManager.OnPuzzleSolved(onFloorPuzzleSolved)
end

GameManager.Init()

return GameManager
