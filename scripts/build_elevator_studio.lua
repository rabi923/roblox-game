--[[
    Hotel Hermes - Art Deco Elevator Model & Animation Builder
    File: scripts/build_elevator_studio.lua
    Constructs the complete ornate brass elevator cage in Workspace.Elevator with:
    - 10x10 marble checker floor & brass ceiling
    - Art deco brass grille walls
    - Back wall mirror
    - Sliding double doors (Door_Left, Door_Right) with TweenService open/close logic
    - Floor button panel with interactive ProximityPrompt
    - SurfaceGui floor indicator display
    - Ceiling light fixture with warm horror shadow casting
    - Brass "Ding" bell
    - CollectionService tags: ElevatorDoor, ElevatorPanel, ElevatorInterior, Interactable
--]]

local CollectionService = game:GetService("CollectionService")

local elevFolder = workspace:FindFirstChild("Elevator")
if not elevFolder then
    elevFolder = Instance.new("Folder")
    elevFolder.Name = "Elevator"
    elevFolder.Parent = workspace
end

-- Clear any old placeholder in Elevator
elevFolder:ClearAllChildren()

local elevModel = Instance.new("Model")
elevModel.Name = "ElevatorCage"
elevModel.Parent = elevFolder

local function makePart(name, size, cf, material, color, canCollide)
    local p = Instance.new("Part")
    p.Name = name
    p.Size = size
    p.CFrame = cf
    p.Material = material or Enum.Material.Metal
    p.Color = color or Color3.fromRGB(180, 145, 60)
    p.Anchored = true
    p.CanCollide = (canCollide ~= false)
    p.CastShadow = true
    p.Parent = elevModel
    return p
end

-- Base offset in world coordinates
local baseCF = CFrame.new(0, 0, 32) -- Positioned seamlessly adjoining the lobby

-- 1. Elevator Floor (10 x 10)
local floor = makePart("Floor", Vector3.new(10, 1, 10), baseCF * CFrame.new(0, -0.5, 0), Enum.Material.Marble, Color3.fromRGB(30, 30, 35))
elevModel.PrimaryPart = floor

-- 2. Elevator Ceiling
local ceil = makePart("Ceiling", Vector3.new(10, 1, 10), baseCF * CFrame.new(0, 13.5, 0), Enum.Material.Metal, Color3.fromRGB(160, 125, 45))

-- 3. Back Wall with Mirror (Z = -4.8)
makePart("Wall_Back", Vector3.new(9.6, 13, 0.6), baseCF * CFrame.new(0, 6.5, -4.7), Enum.Material.Metal, Color3.fromRGB(140, 110, 40))
local mirror = makePart("BackMirror", Vector3.new(7.0, 9.0, 0.2), baseCF * CFrame.new(0, 6.5, -4.3), Enum.Material.Glass, Color3.fromRGB(220, 235, 245))

-- 4. Left & Right Grille Walls (X = -4.8, 4.8)
makePart("Wall_Left", Vector3.new(0.6, 13, 9.6), baseCF * CFrame.new(-4.7, 6.5, 0), Enum.Material.Metal, Color3.fromRGB(140, 110, 40))
makePart("Wall_Right", Vector3.new(0.6, 13, 9.6), baseCF * CFrame.new(4.7, 6.5, 0), Enum.Material.Metal, Color3.fromRGB(140, 110, 40))

-- 5. Front Wall Frame with Doorway (Z = 4.8)
makePart("FrontFrame_Left", Vector3.new(2.4, 13, 0.6), baseCF * CFrame.new(-3.6, 6.5, 4.7), Enum.Material.Metal, Color3.fromRGB(150, 115, 45))
makePart("FrontFrame_Right", Vector3.new(2.4, 13, 0.6), baseCF * CFrame.new(3.6, 6.5, 4.7), Enum.Material.Metal, Color3.fromRGB(150, 115, 45))
makePart("FrontFrame_Top", Vector3.new(5.2, 3.0, 0.6), baseCF * CFrame.new(0, 11.5, 4.7), Enum.Material.Metal, Color3.fromRGB(150, 115, 45))

-- 6. Sliding Double Doors (DoorLeft, DoorRight) - Animated via TweenService
local doorLeft = makePart("DoorLeft", Vector3.new(2.5, 10.0, 0.4), baseCF * CFrame.new(-1.25, 5.0, 4.5), Enum.Material.Metal, Color3.fromRGB(180, 145, 55))
local doorRight = makePart("DoorRight", Vector3.new(2.5, 10.0, 0.4), baseCF * CFrame.new(1.25, 5.0, 4.5), Enum.Material.Metal, Color3.fromRGB(180, 145, 55))

-- Store closed & open CFrames as Attributes on the doors for TweenService
doorLeft:SetAttribute("ClosedCFrame", doorLeft.CFrame)
doorLeft:SetAttribute("OpenCFrame", doorLeft.CFrame * CFrame.new(-2.3, 0, 0))
doorRight:SetAttribute("ClosedCFrame", doorRight.CFrame)
doorRight:SetAttribute("OpenCFrame", doorRight.CFrame * CFrame.new(2.3, 0, 0))

CollectionService:AddTag(doorLeft, "ElevatorDoor")
CollectionService:AddTag(doorRight, "ElevatorDoor")
CollectionService:AddTag(doorLeft, "Interactable")
CollectionService:AddTag(doorRight, "Interactable")

-- 7. Floor Indicator Display (SurfaceGui) above door
local dialPart = makePart("FloorIndicatorDisplay", Vector3.new(3.0, 1.6, 0.4), baseCF * CFrame.new(0, 11.2, 5.0), Enum.Material.SmoothPlastic, Color3.fromRGB(20, 20, 25))
local sGui = Instance.new("SurfaceGui")
sGui.Name = "FloorIndicatorGui"
sGui.Face = Enum.NormalId.Front
sGui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
sGui.PixelsPerStud = 50
sGui.Parent = dialPart

local floorText = Instance.new("TextLabel")
floorText.Name = "FloorNumberLabel"
floorText.Size = UDim2.new(1, 0, 1, 0)
floorText.BackgroundTransparency = 1
floorText.Text = "LOBBY"
floorText.TextColor3 = Color3.fromRGB(255, 190, 80)
floorText.Font = Enum.Font.SpecialElite
floorText.TextSize = 36
floorText.Parent = sGui

-- 8. Button Panel (Inside elevator on right wall)
local panel = makePart("ButtonPanel", Vector3.new(0.3, 4.0, 1.8), baseCF * CFrame.new(4.3, 5.5, 1.5), Enum.Material.Metal, Color3.fromRGB(190, 155, 65))
local panelPrompt = Instance.new("ProximityPrompt")
panelPrompt.ActionText = "Select Floor"
panelPrompt.ObjectText = "Elevator Controls"
panelPrompt.HoldDuration = 0.5
panelPrompt.MaxActivationDistance = 8
panelPrompt.Parent = panel

CollectionService:AddTag(panel, "ElevatorPanel")
CollectionService:AddTag(panel, "Interactable")

-- 9. Ceiling Light Fixture
local lamp = makePart("ElevatorLamp", Vector3.new(2, 0.4, 2), baseCF * CFrame.new(0, 12.8, 0), Enum.Material.Neon, Color3.fromRGB(255, 220, 160), false)
local light = Instance.new("PointLight")
light.Name = "ElevatorLight"
light.Color = Color3.fromRGB(250, 215, 160)
light.Brightness = 1.6
light.Range = 22
light.Shadows = true
light.Parent = lamp

-- 10. "Ding" Bell
local bell = makePart("ElevatorDingBell", Vector3.new(0.8, 0.8, 0.4), baseCF * CFrame.new(1.8, 11.2, 5.0), Enum.Material.Metal, Color3.fromRGB(210, 175, 60))
local dingSound = Instance.new("Sound")
dingSound.Name = "DingSound"
dingSound.SoundId = "rbxassetid://9114223170" -- Classic elevator chime sound
dingSound.Volume = 0.8
dingSound.Parent = bell

-- 11. Elevator Interior Trigger Volume (for player detection & catch prevention)
local interior = makePart("ElevatorInteriorVolume", Vector3.new(8.5, 11.0, 8.5), baseCF * CFrame.new(0, 6.0, 0), Enum.Material.ForceField, Color3.fromRGB(100, 255, 100), false)
interior.Transparency = 1
interior.CanTouch = true
CollectionService:AddTag(interior, "ElevatorInterior")

-- 12. Door Controller Script (TweenService open/close helper)
local animScript = Instance.new("Script")
animScript.Name = "DoorAnimationController"
animScript.Source = [[
-- Hotel Hermes - Elevator Door Animation Controller
local TweenService = game:GetService("TweenService")
local model = script.Parent
local doorL = model:FindFirstChild("DoorLeft")
local doorR = model:FindFirstChild("DoorRight")

local tweenInfo = TweenInfo.new(1.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local function setDoorsOpen(open: boolean)
    if not doorL or not doorR then return end
    local targetL = open and doorL:GetAttribute("OpenCFrame") or doorL:GetAttribute("ClosedCFrame")
    local targetR = open and doorR:GetAttribute("OpenCFrame") or doorR:GetAttribute("ClosedCFrame")

    if targetL and targetR then
        TweenService:Create(doorL, tweenInfo, { CFrame = targetL }):Play()
        TweenService:Create(doorR, tweenInfo, { CFrame = targetR }):Play()
    end
end

model:SetAttribute("IsOpen", false)
model:GetAttributeChangedSignal("IsOpen"):Connect(function()
    setDoorsOpen(model:GetAttribute("IsOpen") == true)
end)
]]
animScript.Parent = elevModel

return "Successfully constructed Art Deco Elevator model with Tween animation in Workspace.Elevator!"
