--[[
    Hotel Hermes - HUD ScreenGui Layout Generator
    File: StarterGui/HUDLayout.lua
    Description: Programmatically constructs the in-game HUD with modern dark-glassmorphism styling.
--]]

local HUDLayout = {}

function HUDLayout.Create(): ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "HermesHUD"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    -- ========================================================================
    -- 1. FLOOR COUNTER BADGE (Top-Center)
    -- ========================================================================
    local floorFrame = Instance.new("Frame")
    floorFrame.Name = "FloorBadge"
    floorFrame.Size = UDim2.new(0, 160, 0, 42)
    floorFrame.Position = UDim2.new(0.5, -80, 0, 18)
    floorFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
    floorFrame.BackgroundTransparency = 0.25
    floorFrame.BorderSizePixel = 0
    floorFrame.Parent = screenGui

    local floorCorner = Instance.new("UICorner")
    floorCorner.CornerRadius = UDim.new(0, 8)
    floorCorner.Parent = floorFrame

    local floorStroke = Instance.new("UIStroke")
    floorStroke.Color = Color3.fromRGB(80, 70, 50)
    floorStroke.Thickness = 1.2
    floorStroke.Parent = floorFrame

    local floorLabel = Instance.new("TextLabel")
    floorLabel.Name = "FloorLabel"
    floorLabel.Size = UDim2.new(1, 0, 1, 0)
    floorLabel.BackgroundTransparency = 1
    floorLabel.Font = Enum.Font.SpecialElite
    floorLabel.Text = "FLOOR 1"
    floorLabel.TextColor3 = Color3.fromRGB(240, 225, 195)
    floorLabel.TextSize = 20
    floorLabel.Parent = floorFrame

    -- ========================================================================
    -- 2. STAMINA & FLASHLIGHT BARS (Bottom-Center)
    -- ========================================================================
    local statusContainer = Instance.new("Frame")
    statusContainer.Name = "StatusContainer"
    statusContainer.Size = UDim2.new(0, 240, 0, 36)
    statusContainer.Position = UDim2.new(0.5, -120, 1, -64)
    statusContainer.BackgroundTransparency = 1
    statusContainer.Parent = screenGui

    -- Stamina Bar Background
    local staminaBg = Instance.new("Frame")
    staminaBg.Name = "StaminaBarBg"
    staminaBg.Size = UDim2.new(1, 0, 0, 8)
    staminaBg.Position = UDim2.new(0, 0, 0, 4)
    staminaBg.BackgroundColor3 = Color3.fromRGB(24, 24, 28)
    staminaBg.BorderSizePixel = 0
    staminaBg.Parent = statusContainer

    local staminaCorner = Instance.new("UICorner")
    staminaCorner.CornerRadius = UDim.new(0, 4)
    staminaCorner.Parent = staminaBg

    local staminaFill = Instance.new("Frame")
    staminaFill.Name = "StaminaFill"
    staminaFill.Size = UDim2.new(1, 0, 1, 0)
    staminaFill.BackgroundColor3 = Color3.fromRGB(70, 190, 150)
    staminaFill.BorderSizePixel = 0
    staminaFill.Parent = staminaBg

    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, 4)
    fillCorner.Parent = staminaFill

    -- Flashlight Battery Bar Background
    local batteryBg = Instance.new("Frame")
    batteryBg.Name = "BatteryBarBg"
    batteryBg.Size = UDim2.new(1, 0, 0, 4)
    batteryBg.Position = UDim2.new(0, 0, 0, 18)
    batteryBg.BackgroundColor3 = Color3.fromRGB(24, 24, 28)
    batteryBg.BorderSizePixel = 0
    batteryBg.Parent = statusContainer

    local batteryFill = Instance.new("Frame")
    batteryFill.Name = "BatteryFill"
    batteryFill.Size = UDim2.new(1, 0, 1, 0)
    batteryFill.BackgroundColor3 = Color3.fromRGB(230, 195, 80)
    batteryFill.BorderSizePixel = 0
    batteryFill.Parent = batteryBg

    -- ========================================================================
    -- 3. INTERACTION PROMPT (Center Screen)
    -- ========================================================================
    local promptFrame = Instance.new("Frame")
    promptFrame.Name = "InteractPrompt"
    promptFrame.Size = UDim2.new(0, 200, 0, 36)
    promptFrame.Position = UDim2.new(0.5, -100, 0.58, 0)
    promptFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
    promptFrame.BackgroundTransparency = 0.3
    promptFrame.Visible = false
    promptFrame.Parent = screenGui

    local promptCorner = Instance.new("UICorner")
    promptCorner.CornerRadius = UDim.new(0, 6)
    promptCorner.Parent = promptFrame

    local promptLabel = Instance.new("TextLabel")
    promptLabel.Name = "PromptText"
    promptLabel.Size = UDim2.new(1, 0, 1, 0)
    promptLabel.BackgroundTransparency = 1
    promptLabel.Font = Enum.Font.GothamMedium
    promptLabel.Text = "[E] Interact"
    promptLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    promptLabel.TextSize = 14
    promptLabel.Parent = promptFrame

    -- ========================================================================
    -- 4. TOAST NOTIFICATION CONTAINER (Top-Right)
    -- ========================================================================
    local notificationContainer = Instance.new("Frame")
    notificationContainer.Name = "Notifications"
    notificationContainer.Size = UDim2.new(0, 260, 0, 200)
    notificationContainer.Position = UDim2.new(1, -280, 0, 24)
    notificationContainer.BackgroundTransparency = 1
    notificationContainer.Parent = screenGui

    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 8)
    listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Parent = notificationContainer

    return screenGui
end

return HUDLayout
