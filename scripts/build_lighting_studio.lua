--[[
    Hotel Hermes - Complete Lighting & Atmosphere System Setup
    File: scripts/build_lighting_studio.lua
    Configures:
    1. Global horror lighting properties in game.Lighting
    2. Atmosphere, Bloom, and ColorCorrection post-processing
    3. Reverb acoustics in game.SoundService
    4. Per-Room Lighting Templates in ServerStorage.LightingTemplates:
       - "Normal": Warm dim incandescent chandelier/sconce
       - "Flickering": Light fixture with script-driven random jitter & cutoff
       - "Emergency": Pulsing alarm red light
       - "Dark": Absolute pitch-black fixture (flashlight required)
       - "Neon": Amber/Cyan neon glow fixture
--]]

local Lighting = game:GetService("Lighting")
local ServerStorage = game:GetService("ServerStorage")
local SoundService = game:GetService("SoundService")

local results = {}

-- 1. Global Lighting Settings
Lighting.ClockTime = 0
Lighting.GeographicLatitude = 0
Lighting.Ambient = Color3.fromRGB(13, 13, 20)
Lighting.OutdoorAmbient = Color3.fromRGB(10, 10, 15)
Lighting.Brightness = 0
Lighting.FogStart = 10
Lighting.FogEnd = 100
Lighting.FogColor = Color3.fromRGB(5, 5, 13)
Lighting.ExposureCompensation = -0.1
table.insert(results, "✅ Global Lighting configured (Midnight, 0 Brightness, Fog 10-100 studs)")

-- 2. Atmosphere Instance
local atmos = Lighting:FindFirstChildOfClass("Atmosphere")
if not atmos then
    atmos = Instance.new("Atmosphere")
    atmos.Name = "HotelAtmosphere"
    atmos.Parent = Lighting
end
atmos.Density = 0.5
atmos.Offset = 0
atmos.Color = Color3.fromRGB(20, 25, 35)
atmos.Decay = Color3.fromRGB(15, 15, 20)
atmos.Glare = 0
atmos.Haze = 3.0
table.insert(results, "✅ Atmosphere post-processing configured (Density=0.5, Haze=3.0, Blue Decay)")

-- 3. Bloom Effect
local bloom = Lighting:FindFirstChildOfClass("BloomEffect")
if not bloom then
    bloom = Instance.new("BloomEffect")
    bloom.Name = "HotelBloom"
    bloom.Parent = Lighting
end
bloom.Intensity = 0.3
bloom.Size = 16
bloom.Threshold = 1.5
table.insert(results, "✅ Bloom post-processing configured (Intensity=0.3, Size=16, Threshold=1.5)")

-- 4. ColorCorrection Effect
local cc = Lighting:FindFirstChildOfClass("ColorCorrectionEffect")
if not cc then
    cc = Instance.new("ColorCorrectionEffect")
    cc.Name = "HorrorColorGrade"
    cc.Parent = Lighting
end
cc.Brightness = -0.05
cc.Contrast = 0.1
cc.Saturation = -0.3
cc.TintColor = Color3.fromRGB(225, 235, 245)
table.insert(results, "✅ ColorCorrection configured (Desaturated horror tone: Saturation=-0.3, Contrast=0.1)")

-- 5. Audio Acoustic Reverb in SoundService
SoundService.AmbientReverb = Enum.ReverbType.StoneRoom
table.insert(results, "✅ SoundService.AmbientReverb set to StoneRoom (Horror acoustic reverberation)")

-- 6. Per-Room Lighting Templates in ServerStorage.LightingTemplates
local templatesFolder = ServerStorage:FindFirstChild("LightingTemplates")
if not templatesFolder then
    templatesFolder = Instance.new("Folder")
    templatesFolder.Name = "LightingTemplates"
    templatesFolder.Parent = ServerStorage
end
templatesFolder:ClearAllChildren()

local function makeFixture(name, color, brightness, range, material)
    local model = Instance.new("Model")
    model.Name = name

    local base = Instance.new("Part")
    base.Name = "FixtureBase"
    base.Size = Vector3.new(1.2, 0.4, 1.2)
    base.Material = Enum.Material.Metal
    base.Color = Color3.fromRGB(40, 40, 45)
    base.Anchored = true
    base.CanCollide = false
    base.Parent = model

    local bulb = Instance.new("Part")
    bulb.Name = "Bulb"
    bulb.Size = Vector3.new(0.8, 0.8, 0.8)
    bulb.Position = base.Position - Vector3.new(0, 0.5, 0)
    bulb.Material = material or Enum.Material.Neon
    bulb.Color = color
    bulb.Anchored = true
    bulb.CanCollide = false
    bulb.Parent = model

    local light = Instance.new("PointLight")
    light.Name = "LightSource"
    light.Color = color
    light.Brightness = brightness
    light.Range = range
    light.Shadows = true
    light.Parent = bulb

    model.PrimaryPart = base
    model.Parent = templatesFolder
    return model, light, bulb
end

-- Template A: "Normal" (Warm dim vintage hotel illumination)
makeFixture("Normal", Color3.fromRGB(255, 220, 160), 1.4, 24, Enum.Material.Neon)
table.insert(results, "✅ Template 'Normal' created")

-- Template B: "Flickering" (Atmospheric jitter controller)
local flickModel, flickLight, flickBulb = makeFixture("Flickering", Color3.fromRGB(250, 210, 150), 1.4, 24, Enum.Material.Neon)
local flickScript = Instance.new("Script")
flickScript.Name = "FlickerController"
flickScript.Source = [[
-- Hotel Hermes - Procedural Light Flicker Controller
local light = script.Parent:FindFirstChild("Bulb") and script.Parent.Bulb:FindFirstChild("LightSource")
local bulb = script.Parent:FindFirstChild("Bulb")
if not light or not bulb then return end

local baseBrightness = light.Brightness
local baseColor = bulb.Color

task.spawn(function()
    while true do
        task.wait(math.random(1, 5) + math.random())
        -- Rapid micro-flickers
        local bursts = math.random(3, 8)
        for i = 1, bursts do
            local off = math.random() > 0.4
            light.Brightness = off and 0.1 or baseBrightness * (0.3 + math.random() * 0.7)
            bulb.Color = off and Color3.fromRGB(30, 25, 20) or baseColor
            task.wait(math.random(3, 10) / 100)
        end
        light.Brightness = baseBrightness
        bulb.Color = baseColor
    end
end)
]]
flickScript.Parent = flickModel
table.insert(results, "✅ Template 'Flickering' created (with procedural jitter script)")

-- Template C: "Emergency" (Alarm crimson pulsing)
local emergModel, emergLight, emergBulb = makeFixture("Emergency", Color3.fromRGB(255, 35, 35), 2.0, 28, Enum.Material.Neon)
local emergScript = Instance.new("Script")
emergScript.Name = "EmergencyPulseController"
emergScript.Source = [[
-- Hotel Hermes - Emergency Pulse Controller
local TweenService = game:GetService("TweenService")
local light = script.Parent:FindFirstChild("Bulb") and script.Parent.Bulb:FindFirstChild("LightSource")
if not light then return end

local tweenIn = TweenService:Create(light, TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { Brightness = 2.5, Range = 30 })
local tweenOut = TweenService:Create(light, TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { Brightness = 0.4, Range = 14 })

task.spawn(function()
    while true do
        tweenIn:Play()
        tweenIn.Completed:Wait()
        tweenOut:Play()
        tweenOut.Completed:Wait()
    end
end)
]]
emergScript.Parent = emergModel
table.insert(results, "✅ Template 'Emergency' created (with red sine wave pulse script)")

-- Template D: "Dark" (Dead fixture, flashlight mandatory)
local darkModel, darkLight, darkBulb = makeFixture("Dark", Color3.fromRGB(30, 28, 25), 0, 0, Enum.Material.Glass)
darkLight.Enabled = false
darkBulb.Material = Enum.Material.Glass
table.insert(results, "✅ Template 'Dark' created (Dead fixture, 0 brightness)")

-- Template E: "Neon" (Amber/cyan neon signage glow)
makeFixture("Neon", Color3.fromRGB(255, 110, 45), 2.2, 30, Enum.Material.Neon)
table.insert(results, "✅ Template 'Neon' created (Vibrant amber horror glow)")

return table.concat(results, "\n")
