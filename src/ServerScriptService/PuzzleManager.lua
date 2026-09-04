--[[
    Hotel Hermes - Server Puzzle Manager
    File: ServerScriptService/PuzzleManager.lua
    Description: Authoritative server manager tracking active floor puzzle state,
                 validating player input, and triggering elevator unlock events.
--]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SharedModules = ReplicatedStorage:WaitForChild("SharedModules")

local PuzzleDefinitions = require(SharedModules:WaitForChild("PuzzleDefinitions"))
local RemoteDeclarations = require(ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("RemoteDeclarations"))
local RemoteValidator = require(script.Parent:WaitForChild("RemoteValidator"))

local PuzzleManager = {}

-- State: FloorNumber -> { Type = string, State = table, IsSolved = boolean }
local activeFloorPuzzles = {}

local puzzleInputFunction: RemoteFunction
local uiNotificationEvent: RemoteEvent

-- Callbacks registered by GameManager
local onPuzzleSolvedCallback: ((floorNumber: number) -> ())? = nil

--[[
    Initializes a new puzzle for the given floor.
--]]
function PuzzleManager.CreatePuzzleForFloor(floorNumber: number, difficulty: string): table
    local puzzleType = PuzzleDefinitions.SelectPuzzleForFloor(floorNumber)
    local def = PuzzleDefinitions[puzzleType]
    local puzzleState = def.Generate(difficulty)

    activeFloorPuzzles[floorNumber] = {
        Type = puzzleType,
        State = puzzleState,
        IsSolved = false,
    }

    return activeFloorPuzzles[floorNumber]
end

--[[
    Retrieves the current puzzle data for a floor.
--]]
function PuzzleManager.GetFloorPuzzle(floorNumber: number)
    return activeFloorPuzzles[floorNumber]
end

--[[
    Registers callback when any floor puzzle completes.
--]]
function PuzzleManager.OnPuzzleSolved(callback: (floorNumber: number) -> ())
    onPuzzleSolvedCallback = callback
end

--[[
    Handles player submission to a puzzle element (e.g. inserting a key, typing a code).
--]]
local function handlePuzzleInput(player: Player, puzzleId: string, inputPayload: table)
    if not RemoteValidator.CheckRateLimit(player) then
        return false, "Rate limit exceeded"
    end

    local floorNumber = inputPayload.Floor or 1
    local record = activeFloorPuzzles[floorNumber]
    if not record then
        return false, "No active puzzle on this floor"
    end

    if record.IsSolved then
        return true, "Puzzle already solved!"
    end

    local puzzleType = record.Type
    local state = record.State

    if puzzleType == PuzzleDefinitions.Types.KeycardHunt then
        local keyInserted = inputPayload.KeyColor
        if keyInserted and not table.find(state.InsertedKeys, keyInserted) then
            table.insert(state.InsertedKeys, keyInserted)
            uiNotificationEvent:FireClient(player, "Keycard Accepted", string.format("%s Keycard inserted into elevator console.", keyInserted), "Success")
        end
    elseif puzzleType == PuzzleDefinitions.Types.SafeCode then
        local codeAttempt = tostring(inputPayload.CodeAttempt or "")
        state.EnteredCode = codeAttempt
        if state.EnteredCode ~= state.SolutionCode then
            uiNotificationEvent:FireClient(player, "Invalid Code", "The vault lock buzzes with a red light.", "Warning")
        end
    elseif puzzleType == PuzzleDefinitions.Types.ElectricalRepair then
        local switchIndex = inputPayload.SwitchIndex
        local expected = state.Sequence[state.CurrentStep]
        if switchIndex == expected then
            state.CurrentStep = state.CurrentStep + 1
            uiNotificationEvent:FireClient(player, "Breaker Aligned", string.format("Power conduit %d of %d engaged.", state.CurrentStep - 1, state.TotalSwitches), "Success")
        else
            state.CurrentStep = 1 -- Tripped master fuse, reset sequence
            uiNotificationEvent:FireClient(player, "Breaker Tripped!", "A loud spark resets all circuit breakers!", "Warning")
        end
    end

    -- Evaluate solve condition
    local def = PuzzleDefinitions[puzzleType]
    if def.CheckSolved(state) then
        record.IsSolved = true
        uiNotificationEvent:FireAllClients("Floor Power Restored", "The elevator call chime rings out in the hallway.", "Success")
        if onPuzzleSolvedCallback then
            onPuzzleSolvedCallback(floorNumber)
        end
        return true, "Puzzle Solved!"
    end

    return false, "In progress"
end

function PuzzleManager.Init()
    uiNotificationEvent = RemoteDeclarations.GetEvent("UINotification")
    puzzleInputFunction = RemoteDeclarations.GetFunction("PuzzleInput")
    puzzleInputFunction.OnServerInvoke = handlePuzzleInput
end

PuzzleManager.Init()

return PuzzleManager
