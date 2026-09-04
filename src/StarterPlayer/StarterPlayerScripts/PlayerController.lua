--[[
    Hotel Hermes - Player Controller
    File: StarterPlayer/StarterPlayerScripts/PlayerController.lua
    Description: Client player locomotion state machine, crouch & sprint mechanics,
                 stamina lifecycle, flashlight simulation, and acoustic noise broadcasting.
--]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local CollectionService = game:GetService("CollectionService")

local SharedModules = ReplicatedStorage:WaitForChild("SharedModules")
local Constants = require(SharedModules:WaitForChild("Constants"))
local RemoteDeclarations = require(ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("RemoteDeclarations"))
local InputBindings = require(script.Parent:WaitForChild("InputBindings"))

local localPlayer = Players.LocalPlayer
local camera = workspace.CurrentCamera

local PlayerController = {}

-- State variables
local currentStamina = Constants.Movement.MaxStamina
local isCrouching = false
local isSprinting = false
local isExhausted = false
local isFlashlightOn = false
local flashlightBattery = Constants.Flashlight.MaxBattery
local lastSprintTime = 0
local lastNoiseEmitTime = 0

-- References
local character: Model? = nil
local humanoid: Humanoid? = nil
local rootPart: BasePart? = nil
local flashlightLight: SpotLight? = nil
local activeInteractable: Instance? = nil

-- Remotes
local noiseEvent: RemoteEvent
local interactEvent: RemoteEvent
local flashlightEvent: RemoteEvent

--[[
    Creates or attaches the player's personal flashlight to their character.
--]]
local function setupFlashlight(char: Model)
    local torso = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso") or char:FindFirstChild("HumanoidRootPart")
    if not torso then return end

    -- Destroy old light if respawned
    local existing = torso:FindFirstChild("HermesFlashlightLight")
    if existing then existing:Destroy() end

    local light = Instance.new("SpotLight")
    light.Name = "HermesFlashlightLight"
    light.Brightness = Constants.Flashlight.Brightness
    light.Color = Constants.Flashlight.Color
    light.Range = Constants.Flashlight.Range
    light.Angle = Constants.Flashlight.Angle
    light.Shadows = true
    light.Enabled = isFlashlightOn
    light.Parent = torso

    flashlightLight = light
end

--[[
    Adjusts Humanoid properties and HipHeight for Crouch / Walk / Sprint transitions.
--]]
local function updateLocomotionProperties()
    if not humanoid then return end

    if isCrouching then
        humanoid.WalkSpeed = Constants.Movement.CrouchSpeed
        TweenService:Create(humanoid, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {
            HipHeight = Constants.Movement.CrouchingHipHeight
        }):Play()
    elseif isSprinting and not isExhausted then
        humanoid.WalkSpeed = Constants.Movement.SprintSpeed
        TweenService:Create(humanoid, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {
            HipHeight = Constants.Movement.StandingHipHeight
        }):Play()
    else
        humanoid.WalkSpeed = Constants.Movement.WalkSpeed
        TweenService:Create(humanoid, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {
            HipHeight = Constants.Movement.StandingHipHeight
        }):Play()
    end
end

--[[
    Toggles crouching state.
--]]
local function handleCrouchAction(actionName, inputState)
    if inputState == Enum.UserInputState.Begin then
        isCrouching = not isCrouching
        if isCrouching then
            isSprinting = false -- Cannot sprint while crouching
        end
        updateLocomotionProperties()
    end
    return Enum.ContextActionResult.Sink
end

--[[
    Handles sprint input down/up.
--]]
local function handleSprintAction(actionName, inputState)
    if inputState == Enum.UserInputState.Begin then
        if not isExhausted and not isCrouching then
            isSprinting = true
            updateLocomotionProperties()
        end
    elseif inputState == Enum.UserInputState.End then
        isSprinting = false
        updateLocomotionProperties()
    end
    return Enum.ContextActionResult.Sink
end

--[[
    Toggles the flashlight on/off.
--]]
local function handleFlashlightAction(actionName, inputState)
    if inputState == Enum.UserInputState.Begin then
        if flashlightBattery > 0 then
            isFlashlightOn = not isFlashlightOn
            if flashlightLight then
                flashlightLight.Enabled = isFlashlightOn
            end
            flashlightEvent:FireServer(isFlashlightOn)
        end
    end
    return Enum.ContextActionResult.Sink
end

--[[
    Handles interaction trigger with nearby tagged objects.
--]]
local function handleInteractAction(actionName, inputState)
    if inputState == Enum.UserInputState.Begin and activeInteractable then
        interactEvent:FireServer(activeInteractable)
    end
    return Enum.ContextActionResult.Sink
end

--[[
    Scans for nearby interactables tagged with Constants.Tags.Interactable in camera view.
--]]
local function updateInteractionTarget()
    if not rootPart then return end

    local bestTarget: Instance? = nil
    local bestDist = 9.0 -- Maximum interaction distance

    local taggedList = CollectionService:GetTagged(Constants.Tags.Interactable)
    for _, obj in ipairs(taggedList) do
        local part = obj:IsA("BasePart") and obj or (obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")))
        if part then
            local dist = (rootPart.Position - part.Position).Magnitude
            if dist < bestDist then
                -- Check forward view angle
                local dirToPart = (part.Position - camera.CFrame.Position).Unit
                local lookDir = camera.CFrame.LookVector
                local dot = lookDir:Dot(dirToPart)
                if dot > 0.6 then -- In front of camera
                    bestDist = dist
                    bestTarget = obj
                end
            end
        end
    end

    activeInteractable = bestTarget
    -- Signals UI layer (handled by UIController via bindable event or getter)
    PlayerController.CurrentInteractTarget = activeInteractable
end

--[[
    Frame update: Stamina drain/regen, flashlight battery depletion, and noise broadcasting.
--]]
local function onHeartbeat(deltaTime: number)
    if not humanoid or not rootPart or humanoid.Health <= 0 then return end

    local moveVector = humanoid.MoveDirection
    local isMoving = moveVector.Magnitude > 0.1
    local now = os.clock()

    -- 1. Stamina simulation
    if isMoving and isSprinting and not isCrouching then
        currentStamina = math.max(0, currentStamina - (Constants.Movement.StaminaSprintDrainRate * deltaTime))
        lastSprintTime = now
        if currentStamina <= 0 then
            isExhausted = true
            isSprinting = false
            updateLocomotionProperties()
        end
    else
        if now - lastSprintTime > Constants.Movement.StaminaRegenDelay then
            currentStamina = math.min(Constants.Movement.MaxStamina, currentStamina + (Constants.Movement.StaminaRegenRate * deltaTime))
            if isExhausted and currentStamina >= Constants.Movement.RecoveryThreshold then
                isExhausted = false
            end
        end
    end

    -- 2. Flashlight battery simulation
    if isFlashlightOn and flashlightLight then
        flashlightBattery = math.max(0, flashlightBattery - (Constants.Flashlight.DrainRatePerSecond * deltaTime))
        if flashlightBattery <= 0 then
            isFlashlightOn = false
            flashlightLight.Enabled = false
            flashlightEvent:FireServer(false)
        elseif flashlightBattery < Constants.Flashlight.LowBatteryThreshold then
            -- Micro-flicker effect when battery is low
            if math.random() < 0.08 then
                flashlightLight.Enabled = not flashlightLight.Enabled
            end
        end
    end

    -- 3. Acoustic noise emission (Broadcasting to Server Entity AI)
    if isMoving and (now - lastNoiseEmitTime > 0.35) then
        lastNoiseEmitTime = now
        local noiseType = "Walk"
        local radius = Constants.Movement.NoiseRadius.Walk

        if isCrouching then
            noiseType = "Crouch"
            radius = Constants.Movement.NoiseRadius.Crouch
        elseif isSprinting then
            noiseType = "Sprint"
            radius = Constants.Movement.NoiseRadius.Sprint
        end

        noiseEvent:FireServer(noiseType, radius, rootPart.Position)
    end

    -- 4. Interactable scanning
    updateInteractionTarget()
end

--[[
    Binds all controls and connections on character spawn.
--]]
local function onCharacterAdded(newChar: Model)
    character = newChar
    humanoid = newChar:WaitForChild("Humanoid") :: Humanoid
    rootPart = newChar:WaitForChild("HumanoidRootPart") :: BasePart

    -- Disable default jumping mechanics
    humanoid.JumpPower = Constants.Movement.JumpPower
    humanoid.UseJumpPower = true

    setupFlashlight(newChar)
    updateLocomotionProperties()

    -- Reset states
    currentStamina = Constants.Movement.MaxStamina
    isCrouching = false
    isSprinting = false
    isExhausted = false
end

function PlayerController.Init()
    -- Initialize Remotes
    noiseEvent = RemoteDeclarations.GetEvent("NoiseEvent")
    interactEvent = RemoteDeclarations.GetEvent("InteractRequest")
    flashlightEvent = RemoteDeclarations.GetEvent("FlashlightToggle")

    -- Bind User Inputs
    InputBindings.BindAction(InputBindings.ActionNames.Crouch, handleCrouchAction, true, "Crouch")
    InputBindings.BindAction(InputBindings.ActionNames.Sprint, handleSprintAction, true, "Sprint")
    InputBindings.BindAction(InputBindings.ActionNames.ToggleFlashlight, handleFlashlightAction, true, "Flashlight")
    InputBindings.BindAction(InputBindings.ActionNames.Interact, handleInteractAction, true, "Interact")

    if localPlayer.Character then
        onCharacterAdded(localPlayer.Character)
    end
    localPlayer.CharacterAdded:Connect(onCharacterAdded)

    RunService.Heartbeat:Connect(onHeartbeat)
end

-- State Accessors for UI / Camera modules
function PlayerController.GetStamina(): number
    return currentStamina
end

function PlayerController.GetFlashlightBattery(): number
    return flashlightBattery
end

function PlayerController.IsCrouching(): boolean
    return isCrouching
end

function PlayerController.IsSprinting(): boolean
    return isSprinting
end

PlayerController.Init()

return PlayerController
