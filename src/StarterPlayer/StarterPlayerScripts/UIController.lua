--[[
    Hotel Hermes - Master Client UI Controller
    File: StarterPlayer/StarterPlayerScripts/UIController.lua
    Description: Orchestrates all player interfaces, binds interaction prompts,
                 animates toast notifications, and binds button events to Remotes.
--]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local SharedModules = ReplicatedStorage:WaitForChild("SharedModules")
local Constants = require(SharedModules:WaitForChild("Constants"))
local RemoteDeclarations = require(ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("RemoteDeclarations"))

local PlayerController = require(script.Parent:WaitForChild("PlayerController"))
local InputBindings = require(script.Parent:WaitForChild("InputBindings"))
local HUDLayout = require(Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("HermesHUDLayout", 5) or script.Parent.Parent.Parent:WaitForChild("StarterGui"):WaitForChild("HUDLayout"))
local ElevatorUILayout = require(script.Parent.Parent.Parent:WaitForChild("StarterGui"):WaitForChild("ElevatorUILayout"))
local DeathScreenLayout = require(script.Parent.Parent.Parent:WaitForChild("StarterGui"):WaitForChild("DeathScreenLayout"))
local MainMenuLayout = require(script.Parent.Parent.Parent:WaitForChild("StarterGui"):WaitForChild("MainMenuLayout"))
local PauseMenuLayout = require(script.Parent.Parent.Parent:WaitForChild("StarterGui"):WaitForChild("PauseMenuLayout"))

local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")

local UIController = {}

-- Active ScreenGuis
local hudGui: ScreenGui
local elevatorGui: ScreenGui
local deathGui: ScreenGui
local mainMenuGui: ScreenGui
local pauseGui: ScreenGui

-- References inside HUD
local staminaFill: Frame
local batteryFill: Frame
local floorLabel: TextLabel
local interactPrompt: Frame
local promptText: TextLabel
local notificationContainer: Frame

-- Remotes
local uiNotificationEvent: RemoteEvent
local gameStateChangeEvent: RemoteEvent
local checkInFunction: RemoteFunction
local checkOutFunction: RemoteFunction

--[[
    Displays a floating toast notification in the upper-right corner.
--]]
function UIController.ShowNotification(title: string, message: string, colorType: string?)
    if not notificationContainer then return end

    local card = Instance.new("Frame")
    card.Name = "ToastCard"
    card.Size = UDim2.new(1, 0, 0, 48)
    card.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
    card.BackgroundTransparency = 0.2
    card.BorderSizePixel = 0
    card.Parent = notificationContainer

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = card

    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 1
    stroke.Color = (colorType == "Warning" and Color3.fromRGB(220, 80, 80))
                or (colorType == "Success" and Color3.fromRGB(80, 210, 130))
                or Color3.fromRGB(180, 150, 90)
    stroke.Parent = card

    local tLabel = Instance.new("TextLabel")
    tLabel.Size = UDim2.new(1, -16, 0, 20)
    tLabel.Position = UDim2.new(0, 8, 0, 4)
    tLabel.BackgroundTransparency = 1
    tLabel.Font = Enum.Font.GothamBold
    tLabel.Text = title
    tLabel.TextColor3 = stroke.Color
    tLabel.TextSize = 13
    tLabel.TextXAlignment = Enum.TextXAlignment.Left
    tLabel.Parent = card

    local mLabel = Instance.new("TextLabel")
    mLabel.Size = UDim2.new(1, -16, 0, 18)
    mLabel.Position = UDim2.new(0, 8, 0, 24)
    mLabel.BackgroundTransparency = 1
    mLabel.Font = Enum.Font.Gotham
    mLabel.Text = message
    mLabel.TextColor3 = Color3.fromRGB(220, 220, 225)
    mLabel.TextSize = 11
    mLabel.TextXAlignment = Enum.TextXAlignment.Left
    mLabel.Parent = card

    -- Slide & fade out after 4 seconds
    task.delay(4.0, function()
        if card and card.Parent then
            local tween = TweenService:Create(card, TweenInfo.new(0.4, Enum.EasingStyle.Quad), {
                BackgroundTransparency = 1
            })
            tween:Play()
            tween.Completed:Connect(function()
                card:Destroy()
            end)
        end
    end)
end

--[[
    Updates Floor count displayed in the HUD badge.
--]]
function UIController.SetFloor(floorNumber: number)
    if floorLabel then
        floorLabel.Text = string.format("FLOOR %d", floorNumber)
    end
end

--[[
    Opens Elevator choice modal.
--]]
function UIController.OpenElevatorDecision(floorCompleted: number, lootSummary: string)
    if not elevatorGui then return end

    local titleLabel = elevatorGui:FindFirstChild("TitleLabel", true) :: TextLabel?
    local lootValue = elevatorGui:FindFirstChild("LootValue", true) :: TextLabel?
    if titleLabel then
        titleLabel.Text = string.format("FLOOR %d CLEARED", floorCompleted)
    end
    if lootValue and lootSummary then
        lootValue.Text = lootSummary
    end

    elevatorGui.Enabled = true
end

--[[
    Closes Elevator modal.
--]]
function UIController.CloseElevatorDecision()
    if elevatorGui then
        elevatorGui.Enabled = false
    end
end

--[[
    Opens Death Screen with stats.
--]]
function UIController.OpenDeathScreen(floorDied: number, statsSummary: string)
    if not deathGui then return end
    local statsLabel = deathGui:FindFirstChild("StatsLabel", true) :: TextLabel?
    if statsLabel then
        statsLabel.Text = string.format("You perished on Floor %d.\n%s", floorDied, statsSummary or "All unsaved run loot has been lost.")
    end
    deathGui.Enabled = true
end

--[[
    Opens Front Desk Check-In menu.
--]]
function UIController.OpenMainMenu(hasUsedFreeCheckIn: boolean)
    if not mainMenuGui then return end
    local btn = mainMenuGui:FindFirstChild("CheckInButton", true) :: TextButton?
    if btn then
        btn.Text = hasUsedFreeCheckIn and "CHECK IN (5 ROBUX)" or "CHECK IN (FREE FIRST TIME)"
    end
    mainMenuGui.Enabled = true
end

--[[
    Binds UI button click events.
--]]
local function bindButtonEvents()
    -- Elevator Continue Button
    local continueBtn = elevatorGui:FindFirstChild("ContinueButton", true) :: TextButton?
    if continueBtn then
        continueBtn.MouseButton1Click:Connect(function()
            UIController.CloseElevatorDecision()
            gameStateChangeEvent:FireServer("CONTINUE_NEXT_FLOOR", {})
        end)
    end

    -- Elevator Check Out Button
    local checkOutBtn = elevatorGui:FindFirstChild("CheckOutButton", true) :: TextButton?
    if checkOutBtn then
        checkOutBtn.MouseButton1Click:Connect(function()
            UIController.CloseElevatorDecision()
            local success, lootBanked = checkOutFunction:InvokeServer()
            if success then
                UIController.ShowNotification("Check-Out Successful", "Your earnings have been banked in the hotel vaults.", "Success")
            end
        end)
    end

    -- Death Screen Lobby Return
    local lobbyBtn = deathGui:FindFirstChild("LobbyButton", true) :: TextButton?
    if lobbyBtn then
        lobbyBtn.MouseButton1Click:Connect(function()
            deathGui.Enabled = false
            gameStateChangeEvent:FireServer("RETURN_TO_LOBBY", {})
        end)
    end

    -- Main Menu Check-In Button
    local checkInBtn = mainMenuGui:FindFirstChild("CheckInButton", true) :: TextButton?
    if checkInBtn then
        checkInBtn.MouseButton1Click:Connect(function()
            mainMenuGui.Enabled = false
            local success, msg = checkInFunction:InvokeServer()
            if success then
                UIController.ShowNotification("Check-In Confirmed", "Elevator doors are now unlocked.", "Success")
            else
                UIController.ShowNotification("Check-In Notice", msg or "Could not process check-in.", "Warning")
            end
        end)
    end

    -- Main Menu Close Button
    local closeBtn = mainMenuGui:FindFirstChild("CloseButton", true) :: TextButton?
    if closeBtn then
        closeBtn.MouseButton1Click:Connect(function()
            mainMenuGui.Enabled = false
        end)
    end

    -- Pause Menu Buttons
    local resumeBtn = pauseGui:FindFirstChild("ResumeButton", true) :: TextButton?
    if resumeBtn then
        resumeBtn.MouseButton1Click:Connect(function()
            pauseGui.Enabled = false
        end)
    end

    local pauseLobbyBtn = pauseGui:FindFirstChild("LobbyButton", true) :: TextButton?
    if pauseLobbyBtn then
        pauseLobbyBtn.MouseButton1Click:Connect(function()
            pauseGui.Enabled = false
            gameStateChangeEvent:FireServer("RETURN_TO_LOBBY", {})
        end)
    end
end

--[[
    Initializes UI instances and starts the frame loop.
--]]
function UIController.Init()
    -- Construct ScreenGuis
    hudGui = HUDLayout.Create()
    hudGui.Parent = playerGui

    elevatorGui = ElevatorUILayout.Create()
    elevatorGui.Parent = playerGui

    deathGui = DeathScreenLayout.Create()
    deathGui.Parent = playerGui

    mainMenuGui = MainMenuLayout.Create()
    mainMenuGui.Parent = playerGui

    pauseGui = PauseMenuLayout.Create()
    pauseGui.Parent = playerGui

    -- Cache elements
    staminaFill = hudGui:FindFirstChild("StaminaFill", true) :: Frame
    batteryFill = hudGui:FindFirstChild("BatteryFill", true) :: Frame
    floorLabel = hudGui:FindFirstChild("FloorLabel", true) :: TextLabel
    interactPrompt = hudGui:FindFirstChild("InteractPrompt", true) :: Frame
    promptText = hudGui:FindFirstChild("PromptText", true) :: TextLabel
    notificationContainer = hudGui:FindFirstChild("Notifications", true) :: Frame

    -- Remotes
    uiNotificationEvent = RemoteDeclarations.GetEvent("UINotification")
    gameStateChangeEvent = RemoteDeclarations.GetEvent("GameStateChange")
    checkInFunction = RemoteDeclarations.GetFunction("CheckInRequest")
    checkOutFunction = RemoteDeclarations.GetFunction("CheckOutRequest")

    uiNotificationEvent.OnClientEvent:Connect(function(title, message, colorType)
        UIController.ShowNotification(title, message, colorType)
    end)

    gameStateChangeEvent.OnClientEvent:Connect(function(newState, payload)
        if newState == "ELEVATOR_DECISION" then
            UIController.OpenElevatorDecision(payload.Floor or 1, payload.LootSummary)
        elseif newState == "PLAYER_CAUGHT" then
            UIController.OpenDeathScreen(payload.Floor or 1, payload.StatsSummary)
        elseif newState == "FLOOR_START" then
            UIController.SetFloor(payload.Floor or 1)
        end
    end)

    bindButtonEvents()

    -- Bind Pause Menu Action
    InputBindings.BindAction(InputBindings.ActionNames.PauseMenu, function(_, inputState)
        if inputState == Enum.UserInputState.Begin then
            if pauseGui then
                pauseGui.Enabled = not pauseGui.Enabled
            end
        end
        return Enum.ContextActionResult.Sink
    end, false)

    -- Frame update for Stamina bar, Flashlight bar, and Interaction Prompt
    RunService.RenderStepped:Connect(function()
        if staminaFill then
            local st = PlayerController.GetStamina()
            staminaFill.Size = UDim2.new(st / Constants.Movement.MaxStamina, 0, 1, 0)
        end

        if batteryFill then
            local bat = PlayerController.GetFlashlightBattery()
            batteryFill.Size = UDim2.new(bat / Constants.Flashlight.MaxBattery, 0, 1, 0)
        end

        if interactPrompt then
            local target = PlayerController.CurrentInteractTarget
            if target then
                local promptName = target:GetAttribute("PromptText") or "Interact"
                promptText.Text = string.format("[E] %s", promptName)
                interactPrompt.Visible = true
            else
                interactPrompt.Visible = false
            end
        end
    end)
end

UIController.Init()

return UIController
