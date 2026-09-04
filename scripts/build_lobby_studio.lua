--[[
    Hotel Hermes - Complete Lobby Environment Builder
    File: scripts/build_lobby_studio.lua
    Builds the complete grand horror hotel lobby in Workspace.Lobby with:
    - 64x64 checkered black & white marble floor
    - Grand reception desk with "HOTEL HERMES" neon sign & check-in bell
    - Grand decorative staircase with velvet runner
    - Grand chandelier with realistic horror lighting & shadows
    - Waiting lounge with leather armchairs & coffee table
    - Daily Room Service Prize Spin Wheel
    - Ornate brass elevator doors
    - Luggage rack with vintage suitcases
    - Global Leaderboard display frame
    - Atmospheric dust mote particles
    - Player SpawnLocation
    - CollectionService tags: CheckInDesk, RoomServiceWheel, ElevatorDoor, Leaderboard, Interactable
--]]

local CollectionService = game:GetService("CollectionService")

local lobbyFolder = workspace:FindFirstChild("Lobby")
if not lobbyFolder then
    lobbyFolder = Instance.new("Folder")
    lobbyFolder.Name = "Lobby"
    lobbyFolder.Parent = workspace
end

-- Clear any old placeholder objects in Lobby
lobbyFolder:ClearAllChildren()

local function makePart(parent, name, size, cf, material, color, canCollide)
    local p = Instance.new("Part")
    p.Name = name
    p.Size = size
    p.CFrame = cf
    p.Material = material or Enum.Material.Marble
    p.Color = color or Color3.fromRGB(200, 200, 205)
    p.Anchored = true
    p.CanCollide = (canCollide ~= false)
    p.CastShadow = true
    p.Parent = parent
    return p
end

-- 1. Checkered Marble Floor (64 x 64 studs)
local floorModel = Instance.new("Model")
floorModel.Name = "CheckeredFloor"
floorModel.Parent = lobbyFolder

local tileSize = 8
for x = -32 + tileSize/2, 32 - tileSize/2, tileSize do
    for z = -32 + tileSize/2, 32 - tileSize/2, tileSize do
        local isBlack = (math.floor(x/tileSize) + math.floor(z/tileSize)) % 2 == 0
        local tileColor = isBlack and Color3.fromRGB(25, 25, 28) or Color3.fromRGB(220, 220, 225)
        makePart(floorModel, "FloorTile", Vector3.new(tileSize, 1, tileSize), CFrame.new(x, -0.5, z), Enum.Material.Marble, tileColor)
    end
end

-- 2. Perimeter Walls (Height 24 studs, 64x64 studs)
local walls = Instance.new("Model")
walls.Name = "LobbyWalls"
walls.Parent = lobbyFolder

makePart(walls, "Wall_North", Vector3.new(64, 24, 2), CFrame.new(0, 12, -33), Enum.Material.Wood, Color3.fromRGB(45, 30, 20))
makePart(walls, "Wall_South", Vector3.new(64, 24, 2), CFrame.new(0, 12, 33), Enum.Material.Wood, Color3.fromRGB(45, 30, 20))
makePart(walls, "Wall_East", Vector3.new(2, 24, 64), CFrame.new(33, 12, 0), Enum.Material.Wood, Color3.fromRGB(45, 30, 20))
makePart(walls, "Wall_West", Vector3.new(2, 24, 64), CFrame.new(-33, 12, 0), Enum.Material.Wood, Color3.fromRGB(45, 30, 20))
makePart(walls, "Ceiling", Vector3.new(64, 1, 64), CFrame.new(0, 24.5, 0), Enum.Material.Plaster, Color3.fromRGB(28, 25, 22))

-- 3. Grand Reception Desk & "HOTEL HERMES" Neon Sign
local deskModel = Instance.new("Model")
deskModel.Name = "CheckInDesk"
deskModel.Parent = lobbyFolder

local deskCounter = makePart(deskModel, "ReceptionCounter", Vector3.new(20, 4, 5), CFrame.new(0, 2.0, -22), Enum.Material.WoodPlanks, Color3.fromRGB(35, 20, 12))
local deskTrim = makePart(deskModel, "BrassTrim", Vector3.new(20.4, 0.4, 5.4), CFrame.new(0, 4.2, -22), Enum.Material.Metal, Color3.fromRGB(160, 125, 45))

-- Check-In Service Bell
local bell = makePart(deskModel, "ServiceBell", Vector3.new(0.8, 0.5, 0.8), CFrame.new(0, 4.65, -21), Enum.Material.Metal, Color3.fromRGB(220, 180, 50))
local prompt = Instance.new("ProximityPrompt")
prompt.ActionText = "Check In"
prompt.ObjectText = "Front Desk (5 Robux / 1st Free)"
prompt.HoldDuration = 0.5
prompt.MaxActivationDistance = 10
prompt.Parent = bell

CollectionService:AddTag(deskModel, "CheckInDesk")
CollectionService:AddTag(bell, "Interactable")

-- "HOTEL HERMES" Neon Sign
local signPlaque = makePart(deskModel, "SignPlaque", Vector3.new(18, 4, 0.6), CFrame.new(0, 14, -31.8), Enum.Material.Metal, Color3.fromRGB(20, 15, 12))
local signText = makePart(deskModel, "NeonText", Vector3.new(16, 2.5, 0.2), CFrame.new(0, 14, -31.4), Enum.Material.Neon, Color3.fromRGB(255, 95, 40))
local signLight = Instance.new("PointLight")
signLight.Color = Color3.fromRGB(255, 100, 50)
signLight.Brightness = 2.2
signLight.Range = 28
signLight.Shadows = true
signLight.Parent = signText

-- 4. Grand Staircase (Decorative with Red Velvet Runner)
local stairModel = Instance.new("Model")
stairModel.Name = "GrandStaircase"
stairModel.Parent = lobbyFolder

for i = 1, 14 do
    local y = (i - 1) * 1.0 + 0.5
    local z = -28 + (i - 1) * 1.5
    makePart(stairModel, "Step_" .. i, Vector3.new(14, 1, 1.6), CFrame.new(22, y, z), Enum.Material.Marble, Color3.fromRGB(20, 20, 24))
    makePart(stairModel, "Runner_" .. i, Vector3.new(6, 0.1, 1.6), CFrame.new(22, y + 0.55, z), Enum.Material.Fabric, Color3.fromRGB(120, 15, 15))
end

-- 5. Grand Broken Chandelier
local chModel = Instance.new("Model")
chModel.Name = "GrandChandelier"
chModel.Parent = lobbyFolder

local chFrame = makePart(chModel, "ChandelierBody", Vector3.new(8, 3, 8), CFrame.new(0, 20, 0), Enum.Material.Metal, Color3.fromRGB(140, 110, 40))
local chBulb = makePart(chModel, "ChandelierBulb", Vector3.new(3, 1, 3), CFrame.new(0, 18.5, 0), Enum.Material.Neon, Color3.fromRGB(255, 220, 160), false)

local chLight = Instance.new("PointLight")
chLight.Name = "FlickerLight"
chLight.Color = Color3.fromRGB(250, 215, 160)
chLight.Brightness = 1.8
chLight.Range = 45
chLight.Shadows = true
chLight.Parent = chBulb

-- Dust motes particle emitter
local dust = Instance.new("ParticleEmitter")
dust.Name = "DustMotes"
dust.Rate = 12
dust.Speed = NumberRange.new(0.4, 1.2)
dust.Lifetime = NumberRange.new(4, 7)
dust.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.1), NumberSequenceKeypoint.new(1, 0.15)})
dust.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.8), NumberSequenceKeypoint.new(1, 1.0)})
dust.Color = ColorSequence.new(Color3.fromRGB(240, 220, 180))
dust.SpreadAngle = Vector2.new(180, 180)
dust.Parent = chFrame

-- 6. Waiting Lounge (Leather Armchairs & Table)
local lounge = Instance.new("Model")
lounge.Name = "WaitingLounge"
lounge.Parent = lobbyFolder

-- Armchair Left
makePart(lounge, "Armchair1_Seat", Vector3.new(4, 1.4, 4), CFrame.new(-18, 0.7, 5), Enum.Material.Fabric, Color3.fromRGB(70, 15, 15))
makePart(lounge, "Armchair1_Back", Vector3.new(4, 3.2, 1), CFrame.new(-18, 2.5, 7), Enum.Material.Fabric, Color3.fromRGB(70, 15, 15))

-- Armchair Right
makePart(lounge, "Armchair2_Seat", Vector3.new(4, 1.4, 4), CFrame.new(-18, 0.7, -5), Enum.Material.Fabric, Color3.fromRGB(70, 15, 15))
makePart(lounge, "Armchair2_Back", Vector3.new(4, 3.2, 1), CFrame.new(-18, 2.5, -7), Enum.Material.Fabric, Color3.fromRGB(70, 15, 15))

-- Coffee Table
makePart(lounge, "CoffeeTable", Vector3.new(5, 1.4, 4), CFrame.new(-18, 0.7, 0), Enum.Material.WoodPlanks, Color3.fromRGB(35, 20, 12))

-- 7. Room Service Prize Wheel
local wheelModel = Instance.new("Model")
wheelModel.Name = "RoomServiceWheel"
wheelModel.Parent = lobbyFolder

local wheelStand = makePart(wheelModel, "WheelStand", Vector3.new(2, 5, 2), CFrame.new(-26, 2.5, 18), Enum.Material.Wood, Color3.fromRGB(40, 25, 15))
local wheelDisk = makePart(wheelModel, "WheelDisk", Vector3.new(0.6, 6, 6), CFrame.new(-26, 6.0, 18), Enum.Material.Plastic, Color3.fromRGB(210, 160, 40))

local wheelPrompt = Instance.new("ProximityPrompt")
wheelPrompt.ActionText = "Spin Wheel"
wheelPrompt.ObjectText = "Daily Room Service Wheel (24h)"
wheelPrompt.HoldDuration = 0.5
wheelPrompt.MaxActivationDistance = 10
wheelPrompt.Parent = wheelDisk

CollectionService:AddTag(wheelModel, "RoomServiceWheel")
CollectionService:AddTag(wheelDisk, "Interactable")

-- 8. Ornate Brass Elevator Doors (Lobby Entrance to Floors)
local elevDoorModel = Instance.new("Model")
elevDoorModel.Name = "ElevatorDoor"
elevDoorModel.Parent = lobbyFolder

local doorFrame = makePart(elevDoorModel, "ElevatorFrame", Vector3.new(12, 14, 2), CFrame.new(0, 7, 31.8), Enum.Material.Metal, Color3.fromRGB(150, 115, 45))
local doorLeft = makePart(elevDoorModel, "DoorLeft", Vector3.new(4.5, 12, 0.5), CFrame.new(-2.3, 6, 31.2), Enum.Material.Metal, Color3.fromRGB(180, 145, 60))
local doorRight = makePart(elevDoorModel, "DoorRight", Vector3.new(4.5, 12, 0.5), CFrame.new(2.3, 6, 31.2), Enum.Material.Metal, Color3.fromRGB(180, 145, 60))

local elevPrompt = Instance.new("ProximityPrompt")
elevPrompt.ActionText = "Enter Elevator"
elevPrompt.ObjectText = "Elevator to Tower Floors"
elevPrompt.HoldDuration = 0.5
elevPrompt.MaxActivationDistance = 12
elevPrompt.Parent = doorFrame

CollectionService:AddTag(elevDoorModel, "ElevatorDoor")
CollectionService:AddTag(doorFrame, "Interactable")

-- 9. Global Leaderboard Wall Frame
local lbModel = Instance.new("Model")
lbModel.Name = "Leaderboard"
lbModel.Parent = lobbyFolder

local lbFrame = makePart(lbModel, "LeaderboardFrame", Vector3.new(14, 10, 0.6), CFrame.new(-31.8, 8, 0), Enum.Material.Wood, Color3.fromRGB(30, 18, 10))
local lbSurface = makePart(lbModel, "LeaderboardSurface", Vector3.new(13, 9, 0.2), CFrame.new(-31.4, 8, 0), Enum.Material.SmoothPlastic, Color3.fromRGB(15, 15, 18))
CollectionService:AddTag(lbModel, "Leaderboard")

-- 10. Luggage Rack with Vintage Suitcases
local luggage = Instance.new("Model")
luggage.Name = "LuggageRack"
luggage.Parent = lobbyFolder

makePart(luggage, "CartRack", Vector3.new(6, 4.5, 3), CFrame.new(12, 2.25, 20), Enum.Material.Metal, Color3.fromRGB(170, 135, 50))
makePart(luggage, "Suitcase1", Vector3.new(3.5, 1.2, 2.2), CFrame.new(12, 1.2, 20), Enum.Material.Fabric, Color3.fromRGB(80, 45, 25))
makePart(luggage, "Suitcase2", Vector3.new(3.0, 1.0, 1.8), CFrame.new(12, 2.3, 20), Enum.Material.Fabric, Color3.fromRGB(35, 40, 50))

-- 11. Player SpawnLocation
local spawn = Instance.new("SpawnLocation")
spawn.Name = "LobbySpawn"
spawn.Size = Vector3.new(8, 0.5, 8)
spawn.Position = Vector3.new(0, 0.25, 12)
spawn.Anchored = true
spawn.CanCollide = true
spawn.Material = Enum.Material.Marble
spawn.Color = Color3.fromRGB(220, 220, 225)
spawn.Neutral = true
spawn.Duration = 0
spawn.Parent = lobbyFolder

return "Successfully built complete Hotel Hermes Lobby environment in Workspace.Lobby!"
