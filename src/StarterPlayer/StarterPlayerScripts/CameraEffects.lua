--[[
    Hotel Hermes - Camera & Psychological Horror Visuals
    File: StarterPlayer/StarterPlayerScripts/CameraEffects.lua
    Description: Procedural first-person headbobbing, trauma-based screen shake,
                 dynamic FOV distortion, entity proximity vignette, and death camera sequence.
--]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RemoteDeclarations = require(ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("RemoteDeclarations"))

local localPlayer = Players.LocalPlayer
local camera = workspace.CurrentCamera

local CameraEffects = {}

-- Headbob parameters
local BOB_FREQUENCY_WALK = 8.0
local BOB_FREQUENCY_SPRINT = 13.0
local BOB_AMPLITUDE_WALK = 0.045
local BOB_AMPLITUDE_SPRINT = 0.085
local bobTimer = 0

-- Dynamic FOV
local DEFAULT_FOV = 72
local SPRINT_FOV = 82
local CROUCH_FOV = 68
local currentFOVTarget = DEFAULT_FOV

-- Trauma-based Screen Shake (Carmack/Squirrel Eiserloh model)
-- Shake = Trauma^2 for non-linear decay
local trauma = 0 -- Value between 0.0 and 1.0
local TRAUMA_DECAY_RATE = 1.2
local MAX_SHAKE_ROTATION = math.rad(4.0) -- Maximum degrees pitch/yaw shake
local MAX_SHAKE_TRANSLATION = 0.4        -- Studs camera displacement

-- Color correction & Blur instances
local deathBlur: BlurEffect
local horrorColorCorrection: ColorCorrectionEffect

--[[
    Initializes post-processing lighting objects.
--]]
local function setupPostProcessing()
    deathBlur = Lighting:FindFirstChild("HermesDeathBlur") or Instance.new("BlurEffect")
    deathBlur.Name = "HermesDeathBlur"
    deathBlur.Size = 0
    deathBlur.Parent = Lighting

    horrorColorCorrection = Lighting:FindFirstChild("HermesHorrorCC") or Instance.new("ColorCorrectionEffect")
    horrorColorCorrection.Name = "HermesHorrorCC"
    horrorColorCorrection.Brightness = 0
    horrorColorCorrection.Contrast = 0
    horrorColorCorrection.Saturation = 0
    horrorColorCorrection.Parent = Lighting
end

--[[
    Adds camera shake trauma (0.0 to 1.0).
--]]
function CameraEffects.AddTrauma(amount: number)
    trauma = math.clamp(trauma + amount, 0, 1)
end

--[[
    Executes the jumpscare camera effect when caught by an entity.
--]]
local function onCameraJumpscare(entityId: string, duration: number)
    -- Max trauma shake
    CameraEffects.AddTrauma(1.0)
    
    -- Rapid FOV punch inward
    camera.FieldOfView = 50

    -- Visual distortion ramp
    TweenService:Create(deathBlur, TweenInfo.new(duration * 0.5, Enum.EasingStyle.Quad), {
        Size = 24
    }):Play()

    TweenService:Create(horrorColorCorrection, TweenInfo.new(duration * 0.6, Enum.EasingStyle.Quad), {
        Brightness = -0.4,
        Contrast = 0.5,
        Saturation = -0.8
    }):Play()
end

--[[
    Per-render-step camera transform calculations.
--]]
local function onRenderStep(deltaTime: number)
    local char = localPlayer.Character
    if not char then return end

    local humanoid = char:FindFirstChildOfClass("Humanoid")
    local rootPart = char:FindFirstChild("HumanoidRootPart") :: BasePart
    if not humanoid or not rootPart or humanoid.Health <= 0 then return end

    local moveSpeed = rootPart.AssemblyLinearVelocity.Magnitude
    local isMoving = moveSpeed > 0.5

    -- 1. Procedural Headbob
    local bobOffset = Vector3.new()
    local bobRoll = 0
    if isMoving and humanoid.FloorMaterial ~= Enum.Material.Air then
        local freq = (humanoid.WalkSpeed > 15) and BOB_FREQUENCY_SPRINT or BOB_FREQUENCY_WALK
        local amp = (humanoid.WalkSpeed > 15) and BOB_AMPLITUDE_SPRINT or BOB_AMPLITUDE_WALK
        bobTimer = bobTimer + (deltaTime * freq)

        local verticalOffset = math.sin(bobTimer) * amp
        local horizontalOffset = math.cos(bobTimer * 0.5) * (amp * 0.6)
        bobRoll = math.sin(bobTimer * 0.5) * (amp * 0.4)

        bobOffset = Vector3.new(horizontalOffset, verticalOffset, 0)
    else
        bobTimer = 0
    end

    -- 2. Screen Shake (Trauma^2)
    local shakeCFrame = CFrame.new()
    if trauma > 0 then
        local shakeFactor = trauma * trauma
        local timeSample = os.clock() * 25

        local yaw = (math.noise(timeSample, 0, 0) - 0.5) * 2 * MAX_SHAKE_ROTATION * shakeFactor
        local pitch = (math.noise(0, timeSample, 0) - 0.5) * 2 * MAX_SHAKE_ROTATION * shakeFactor
        local roll = (math.noise(0, 0, timeSample) - 0.5) * 2 * MAX_SHAKE_ROTATION * shakeFactor

        local offsetX = (math.noise(timeSample, 10, 0) - 0.5) * 2 * MAX_SHAKE_TRANSLATION * shakeFactor
        local offsetY = (math.noise(10, timeSample, 0) - 0.5) * 2 * MAX_SHAKE_TRANSLATION * shakeFactor

        shakeCFrame = CFrame.new(offsetX, offsetY, 0) * CFrame.Angles(pitch, yaw, roll)
        trauma = math.max(0, trauma - (TRAUMA_DECAY_RATE * deltaTime))
    end

    -- 3. Dynamic FOV Interpolation
    if humanoid.WalkSpeed > 18 then
        currentFOVTarget = SPRINT_FOV
    elseif humanoid.WalkSpeed < 10 then
        currentFOVTarget = CROUCH_FOV
    else
        currentFOVTarget = DEFAULT_FOV
    end
    camera.FieldOfView = camera.FieldOfView + (currentFOVTarget - camera.FieldOfView) * math.clamp(deltaTime * 8, 0, 1)

    -- Apply final CFrame adjustments
    camera.CFrame = camera.CFrame * CFrame.new(bobOffset) * CFrame.Angles(0, 0, bobRoll) * shakeCFrame
end

function CameraEffects.Init()
    setupPostProcessing()

    local jumpscareEvent = RemoteDeclarations.GetEvent("CameraJumpscare")
    jumpscareEvent.OnClientEvent:Connect(onCameraJumpscare)

    RunService:BindToRenderStep("HermesCameraEffects", Enum.RenderPriority.Camera.Value + 1, onRenderStep)
end

CameraEffects.Init()

return CameraEffects
