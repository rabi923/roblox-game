--[[
    Hotel Hermes - Procedural Floor Generator
    File: ServerScriptService/FloorGenerator.lua
    Description: Assembles randomized modular floor layouts using grid-based room
                 interconnections, spawns puzzle anchors and loot, and cleans up instances.
--]]

local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")

local SharedModules = ReplicatedStorage:WaitForChild("SharedModules")
local Constants = require(SharedModules:WaitForChild("Constants"))
local GameConfig = require(SharedModules:WaitForChild("GameConfig"))
local PuzzleManager = require(script.Parent:WaitForChild("PuzzleManager"))

local FloorGenerator = {}

-- Active Floors: FloorNumber -> { Model = Model, SpawnPoint = Vector3, ElevatorPoint = Vector3 }
local activeFloors = {}

local floorPrefabsFolder: Folder? = nil

-- Cardinal Direction offsets on a 2D grid
local DIRECTIONS = {
    North = { X = 0, Z = -1, Rotation = 0 },
    East  = { X = 1, Z = 0,  Rotation = 90 },
    South = { X = 0, Z = 1,  Rotation = 180 },
    West  = { X = -1, Z = 0, Rotation = 270 },
}

--[[
    Fallback procedural room builder if Blender prefabs are not yet loaded in ServerStorage.
    Ensures the game runs 100% testable even before 3D assets are imported!
--]]
local function createMockRoom(roomType: string, position: Vector3): Model
    local model = Instance.new("Model")
    model.Name = roomType .. "_Room"

    local cellSize = Constants.Architecture.CellSize
    local wallHeight = Constants.Architecture.WallHeight

    -- Floor Part
    local floorPart = Instance.new("Part")
    floorPart.Name = "Floor"
    floorPart.Size = Vector3.new(cellSize, 1, cellSize)
    floorPart.Position = position + Vector3.new(0, -0.5, 0)
    floorPart.Anchored = true
    floorPart.Material = Enum.Material.WoodPlanks
    floorPart.Color = Color3.fromRGB(38, 30, 24)
    floorPart.Parent = model

    -- Ceiling Part
    local ceilPart = Instance.new("Part")
    ceilPart.Name = "Ceiling"
    ceilPart.Size = Vector3.new(cellSize, 1, cellSize)
    ceilPart.Position = position + Vector3.new(0, wallHeight + 0.5, 0)
    ceilPart.Anchored = true
    ceilPart.Material = Enum.Material.Plaster
    ceilPart.Color = Color3.fromRGB(25, 22, 20)
    ceilPart.Parent = model

    -- Dim Ambient Light fixture
    local lightFixture = Instance.new("Part")
    lightFixture.Name = "LightFixture"
    lightFixture.Size = Vector3.new(2, 1, 2)
    lightFixture.Position = position + Vector3.new(0, wallHeight - 0.5, 0)
    lightFixture.Anchored = true
    lightFixture.Color = Color3.fromRGB(240, 210, 160)
    lightFixture.Material = Enum.Material.Neon
    lightFixture.Parent = model

    local pointLight = Instance.new("PointLight")
    pointLight.Brightness = 1.4
    pointLight.Color = Color3.fromRGB(245, 220, 180)
    pointLight.Range = 22
    pointLight.Shadows = true
    pointLight.Parent = lightFixture

    model.PrimaryPart = floorPart
    return model
end

--[[
    Generates and instantiates a complete procedural floor.
--]]
function FloorGenerator.GenerateFloor(floorNumber: number): table
    local difficulty = GameConfig.GetFloorDifficulty(floorNumber)
    local targetRoomCount = difficulty.RoomCount

    local floorContainer = Instance.new("Model")
    floorContainer.Name = string.format("Floor_%d", floorNumber)
    floorContainer.Parent = workspace

    -- 2D Grid map: "gridX,gridZ" -> true
    local occupiedGrid = {}
    local roomPositions = {}

    -- Start elevator foyer at (0,0)
    occupiedGrid["0,0"] = true
    table.insert(roomPositions, { X = 0, Z = 0, Type = "ElevatorFoyer" })

    -- Random walk branching to place rooms
    local currentX, currentZ = 0, 0
    local dirKeys = { "North", "East", "South", "West" }

    while #roomPositions < targetRoomCount do
        local dirKey = dirKeys[math.random(1, #dirKeys)]
        local offset = DIRECTIONS[dirKey]
        local nextX = currentX + offset.X
        local nextZ = currentZ + offset.Z
        local key = string.format("%d,%d", nextX, nextZ)

        if not occupiedGrid[key] then
            occupiedGrid[key] = true
            local roomType = (math.random() > 0.4) and "GuestRoom" or "Hallway"
            table.insert(roomPositions, { X = nextX, Z = nextZ, Type = roomType })
            currentX = nextX
            currentZ = nextZ
        else
            -- Backtrack or branch from a random existing room
            local randomExisting = roomPositions[math.random(1, #roomPositions)]
            currentX = randomExisting.X
            currentZ = randomExisting.Z
        end
    end

    -- World vertical Y-offset for this floor (stacking floors)
    local floorHeightStuds = (floorNumber - 1) * 28 + 100 -- Elevated above lobby
    local cellSize = Constants.Architecture.CellSize

    local elevatorPosition = Vector3.new(0, floorHeightStuds, 0)
    local playerSpawnPosition = elevatorPosition + Vector3.new(0, 3, 0)

    -- Instantiate rooms
    for _, roomData in ipairs(roomPositions) do
        local worldPos = Vector3.new(roomData.X * cellSize, floorHeightStuds, roomData.Z * cellSize)
        local roomModel = createMockRoom(roomData.Type, worldPos)
        roomModel.Parent = floorContainer
    end

    -- Setup Puzzle for this floor
    PuzzleManager.CreatePuzzleForFloor(floorNumber, difficulty.PuzzleComplexity)

    local floorRecord = {
        FloorNumber = floorNumber,
        Model = floorContainer,
        SpawnPoint = playerSpawnPosition,
        ElevatorPoint = elevatorPosition,
        Difficulty = difficulty,
    }

    activeFloors[floorNumber] = floorRecord
    return floorRecord
end

--[[
    Destroys floor instances to free server memory.
--]]
function FloorGenerator.DestroyFloor(floorNumber: number)
    local record = activeFloors[floorNumber]
    if record and record.Model then
        record.Model:Destroy()
        activeFloors[floorNumber] = nil
    end
end

--[[
    Gets active floor record.
--]]
function FloorGenerator.GetFloor(floorNumber: number)
    return activeFloors[floorNumber]
end

return FloorGenerator
