--[[
    Hotel Hermes - Complete Tool & Key Item Models Builder
    File: scripts/build_tools_studio.lua
    Constructs all tools, key items, and throwable props in ServerStorage.ToolModels:
    - Flashlight (with SpotLight matching Constants.Flashlight, Handle, lens, and switch)
    - BatteryPack (Flashlight battery recharge item)
    - Keycards (Keycard_Red, Keycard_Blue, Keycard_Green with gold chip)
    - SafeCodeNote (parchment note with clue surface text)
    - ElectricalFuse (cartridge fuse with copper caps)
    - RitualCandle (wax candle with wick and warm point light)
    - WineBottle (throwable glass bottle)
    - CoffeeMug (throwable ceramic mug)
    - CollectionService tags: Tool, Flashlight, KeyItem, Throwable, LootItem, Interactable
--]]

local ServerStorage = game:GetService("ServerStorage")
local CollectionService = game:GetService("CollectionService")

local toolFolder = ServerStorage:FindFirstChild("ToolModels")
if not toolFolder then
    toolFolder = Instance.new("Folder")
    toolFolder.Name = "ToolModels"
    toolFolder.Parent = ServerStorage
end

-- Clear old placeholder models
toolFolder:ClearAllChildren()

local function makePart(parent, name, size, cf, material, color, canCollide)
    local p = Instance.new("Part")
    p.Name = name
    p.Size = size
    p.CFrame = cf or CFrame.new(0, 0, 0)
    p.Material = material or Enum.Material.Metal
    p.Color = color or Color3.fromRGB(50, 50, 55)
    p.Anchored = true
    p.CanCollide = (canCollide ~= false)
    p.CastShadow = true
    p.Parent = parent
    return p
end

-- ============================================================================
-- 1. FLASHLIGHT TOOL MODEL
-- ============================================================================
local flash = Instance.new("Model")
flash.Name = "Flashlight"
flash.Parent = toolFolder

-- Handle (Length 1.2 studs, diameter 0.36 studs)
local handle = makePart(flash, "Handle", Vector3.new(0.36, 0.36, 1.2), CFrame.new(0, 0, 0), Enum.Material.Metal, Color3.fromRGB(45, 48, 52))
local grip = makePart(flash, "Grip", Vector3.new(0.38, 0.38, 0.7), CFrame.new(0, 0, -0.05), Enum.Material.Rubber, Color3.fromRGB(20, 20, 20))
local head = makePart(flash, "Head", Vector3.new(0.55, 0.55, 0.4), CFrame.new(0, 0, 0.7), Enum.Material.Metal, Color3.fromRGB(60, 62, 68))
local lens = makePart(flash, "Lens", Vector3.new(0.48, 0.48, 0.05), CFrame.new(0, 0, 0.9), Enum.Material.Glass, Color3.fromRGB(220, 235, 255), false)
local switch = makePart(flash, "Switch", Vector3.new(0.1, 0.08, 0.2), CFrame.new(0, 0.22, 0.2), Enum.Material.Plastic, Color3.fromRGB(180, 40, 40))

-- SpotLight (Matching Constants.Flashlight specs: Brightness 2.4, Range 48, Angle 55, Off by default)
local spot = Instance.new("SpotLight")
spot.Name = "Beam"
spot.Brightness = 2.4
spot.Range = 48
spot.Angle = 55
spot.Color = Color3.fromRGB(245, 235, 205)
spot.Shadows = true
spot.Enabled = false
spot.Face = Enum.NormalId.Front
spot.Parent = lens

flash.PrimaryPart = handle
CollectionService:AddTag(flash, "Tool")
CollectionService:AddTag(flash, "Flashlight")
CollectionService:AddTag(handle, "Interactable")

-- ============================================================================
-- 2. BATTERY PACK
-- ============================================================================
local battery = Instance.new("Model")
battery.Name = "BatteryPack"
battery.Parent = toolFolder

local bHandle = makePart(battery, "Handle", Vector3.new(0.35, 0.35, 0.75), CFrame.new(0, 0, 0), Enum.Material.Metal, Color3.fromRGB(30, 80, 160))
local bLabel = makePart(battery, "Label", Vector3.new(0.36, 0.36, 0.45), CFrame.new(0, 0, 0), Enum.Material.Plastic, Color3.fromRGB(220, 180, 40))
local bTerm = makePart(battery, "Terminal", Vector3.new(0.15, 0.15, 0.1), CFrame.new(0, 0, 0.4), Enum.Material.Metal, Color3.fromRGB(200, 170, 50))
battery.PrimaryPart = bHandle
CollectionService:AddTag(battery, "LootItem")
CollectionService:AddTag(bHandle, "Interactable")

-- ============================================================================
-- 3. KEYCARDS (Red, Blue, Green)
-- ============================================================================
local function makeKeycard(name, color)
    local card = Instance.new("Model")
    card.Name = name
    card.Parent = toolFolder

    local body = makePart(card, "Handle", Vector3.new(0.55, 0.85, 0.05), CFrame.new(0, 0, 0), Enum.Material.SmoothPlastic, color)
    local chip = makePart(card, "Chip", Vector3.new(0.2, 0.2, 0.06), CFrame.new(0, 0.15, 0), Enum.Material.Metal, Color3.fromRGB(210, 175, 50))
    local stripe = makePart(card, "MagneticStripe", Vector3.new(0.1, 0.85, 0.06), CFrame.new(-0.2, 0, 0), Enum.Material.SmoothPlastic, Color3.fromRGB(20, 20, 20))

    card.PrimaryPart = body
    CollectionService:AddTag(card, "KeyItem")
    CollectionService:AddTag(card, "Tool")
    CollectionService:AddTag(body, "Interactable")
    return card
end

makeKeycard("Keycard_Red", Color3.fromRGB(200, 40, 40))
makeKeycard("Keycard_Blue", Color3.fromRGB(40, 90, 200))
makeKeycard("Keycard_Green", Color3.fromRGB(40, 170, 60))

-- ============================================================================
-- 4. SAFE CODE NOTE
-- ============================================================================
local note = Instance.new("Model")
note.Name = "SafeCodeNote"
note.Parent = toolFolder

local nBody = makePart(note, "Handle", Vector3.new(0.65, 0.85, 0.04), CFrame.new(0, 0, 0), Enum.Material.Fabric, Color3.fromRGB(235, 220, 190))
local noteGui = Instance.new("SurfaceGui")
noteGui.Face = Enum.NormalId.Top
noteGui.PixelsPerStud = 50
noteGui.Parent = nBody

local noteLbl = Instance.new("TextLabel")
noteLbl.Size = UDim2.new(1, 0, 1, 0)
noteLbl.BackgroundTransparency = 1
noteLbl.Text = "7 - 4 - 9"
noteLbl.TextColor3 = Color3.fromRGB(60, 30, 20)
noteLbl.Font = Enum.Font.SpecialElite
noteLbl.TextSize = 24
noteLbl.Parent = noteGui

note.PrimaryPart = nBody
CollectionService:AddTag(note, "KeyItem")
CollectionService:AddTag(nBody, "Interactable")

-- ============================================================================
-- 5. ELECTRICAL FUSE
-- ============================================================================
local fuse = Instance.new("Model")
fuse.Name = "ElectricalFuse"
fuse.Parent = toolFolder

local fBody = makePart(fuse, "Handle", Vector3.new(0.25, 0.25, 0.65), CFrame.new(0, 0, 0), Enum.Material.Glass, Color3.fromRGB(220, 230, 240))
local fCap1 = makePart(fuse, "Cap_North", Vector3.new(0.27, 0.27, 0.15), CFrame.new(0, 0, 0.3), Enum.Material.Metal, Color3.fromRGB(180, 110, 60))
local fCap2 = makePart(fuse, "Cap_South", Vector3.new(0.27, 0.27, 0.15), CFrame.new(0, 0, -0.3), Enum.Material.Metal, Color3.fromRGB(180, 110, 60))

fuse.PrimaryPart = fBody
CollectionService:AddTag(fuse, "KeyItem")
CollectionService:AddTag(fBody, "Interactable")

-- ============================================================================
-- 6. RITUAL CANDLE
-- ============================================================================
local candle = Instance.new("Model")
candle.Name = "RitualCandle"
candle.Parent = toolFolder

local cBody = makePart(candle, "Handle", Vector3.new(0.35, 0.8, 0.35), CFrame.new(0, 0.4, 0), Enum.Material.Plastic, Color3.fromRGB(230, 215, 180))
local cFlame = makePart(candle, "Flame", Vector3.new(0.12, 0.2, 0.12), CFrame.new(0, 0.9, 0), Enum.Material.Neon, Color3.fromRGB(255, 150, 40), false)
local cLight = Instance.new("PointLight")
cLight.Brightness = 1.4
cLight.Range = 14
cLight.Color = Color3.fromRGB(255, 160, 60)
cLight.Shadows = true
cLight.Parent = cFlame

candle.PrimaryPart = cBody
CollectionService:AddTag(candle, "KeyItem")
CollectionService:AddTag(candle, "Tool")
CollectionService:AddTag(cBody, "Interactable")

-- ============================================================================
-- 7. THROWABLE WINE BOTTLE
-- ============================================================================
local bottle = Instance.new("Model")
bottle.Name = "WineBottle"
bottle.Parent = toolFolder

local bPart = makePart(bottle, "Handle", Vector3.new(0.44, 1.2, 0.44), CFrame.new(0, 0.6, 0), Enum.Material.Glass, Color3.fromRGB(40, 110, 50))
local bNeck = makePart(bottle, "Neck", Vector3.new(0.18, 0.5, 0.18), CFrame.new(0, 1.35, 0), Enum.Material.Glass, Color3.fromRGB(40, 110, 50))
bottle.PrimaryPart = bPart
CollectionService:AddTag(bottle, "Throwable")
CollectionService:AddTag(bottle, "Tool")
CollectionService:AddTag(bPart, "Interactable")

-- ============================================================================
-- 8. THROWABLE COFFEE MUG
-- ============================================================================
local mug = Instance.new("Model")
mug.Name = "CoffeeMug"
mug.Parent = toolFolder

local mBody = makePart(mug, "Handle", Vector3.new(0.55, 0.65, 0.55), CFrame.new(0, 0.32, 0), Enum.Material.SmoothPlastic, Color3.fromRGB(225, 225, 220))
local mHandle = makePart(mug, "Loop", Vector3.new(0.15, 0.35, 0.25), CFrame.new(0.32, 0.32, 0), Enum.Material.SmoothPlastic, Color3.fromRGB(225, 225, 220))
mug.PrimaryPart = mBody
CollectionService:AddTag(mug, "Throwable")
CollectionService:AddTag(mug, "Tool")
CollectionService:AddTag(mBody, "Interactable")

return "Successfully constructed all Tool and Key Item models in ServerStorage.ToolModels!"
