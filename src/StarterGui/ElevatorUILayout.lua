--[[
    Hotel Hermes - Elevator Decision Screen Layout
    File: StarterGui/ElevatorUILayout.lua
    Description: Constructs the high-stakes 'Continue or Check Out' modal.
--]]

local ElevatorUILayout = {}

function ElevatorUILayout.Create(): ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "HermesElevatorUI"
    screenGui.ResetOnSpawn = false
    screenGui.Enabled = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    -- Dark backdrop with blur feel
    local backdrop = Instance.new("Frame")
    backdrop.Name = "Backdrop"
    backdrop.Size = UDim2.new(1, 0, 1, 0)
    backdrop.BackgroundColor3 = Color3.fromRGB(5, 5, 8)
    backdrop.BackgroundTransparency = 0.55
    backdrop.Parent = screenGui

    -- Center Panel
    local panel = Instance.new("Frame")
    panel.Name = "CenterPanel"
    panel.Size = UDim2.new(0, 440, 0, 320)
    panel.Position = UDim2.new(0.5, -220, 0.5, -160)
    panel.BackgroundColor3 = Color3.fromRGB(16, 16, 20)
    panel.BorderSizePixel = 0
    panel.Parent = backdrop

    local panelCorner = Instance.new("UICorner")
    panelCorner.CornerRadius = UDim.new(0, 12)
    panelCorner.Parent = panel

    local panelStroke = Instance.new("UIStroke")
    panelStroke.Color = Color3.fromRGB(190, 160, 90)
    panelStroke.Thickness = 1.8
    panelStroke.Parent = panel

    -- Header: Floor Cleared
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "TitleLabel"
    titleLabel.Size = UDim2.new(1, 0, 0, 48)
    titleLabel.Position = UDim2.new(0, 0, 0, 14)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Font = Enum.Font.SpecialElite
    titleLabel.Text = "FLOOR 1 CLEARED"
    titleLabel.TextColor3 = Color3.fromRGB(245, 230, 185)
    titleLabel.TextSize = 26
    titleLabel.Parent = panel

    -- Subtitle
    local subtitleLabel = Instance.new("TextLabel")
    subtitleLabel.Name = "SubtitleLabel"
    subtitleLabel.Size = UDim2.new(1, -40, 0, 36)
    subtitleLabel.Position = UDim2.new(0, 20, 0, 62)
    subtitleLabel.BackgroundTransparency = 1
    subtitleLabel.Font = Enum.Font.Gotham
    subtitleLabel.Text = "The elevator doors are open. Will you venture higher, or check out and secure your findings?"
    subtitleLabel.TextColor3 = Color3.fromRGB(175, 175, 185)
    subtitleLabel.TextSize = 13
    subtitleLabel.TextWrapped = true
    subtitleLabel.Parent = panel

    -- Loot at Risk Box
    local lootBox = Instance.new("Frame")
    lootBox.Name = "LootBox"
    lootBox.Size = UDim2.new(1, -48, 0, 64)
    lootBox.Position = UDim2.new(0, 24, 0, 110)
    lootBox.BackgroundColor3 = Color3.fromRGB(25, 20, 22)
    lootBox.BorderSizePixel = 0
    lootBox.Parent = panel

    local lootCorner = Instance.new("UICorner")
    lootCorner.CornerRadius = UDim.new(0, 6)
    lootCorner.Parent = lootBox

    local lootStroke = Instance.new("UIStroke")
    lootStroke.Color = Color3.fromRGB(140, 60, 60)
    lootStroke.Thickness = 1
    lootStroke.Parent = lootBox

    local lootTitle = Instance.new("TextLabel")
    lootTitle.Name = "LootTitle"
    lootTitle.Size = UDim2.new(1, 0, 0, 24)
    lootTitle.Position = UDim2.new(0, 0, 0, 6)
    lootTitle.BackgroundTransparency = 1
    lootTitle.Font = Enum.Font.GothamBold
    lootTitle.Text = "⚠️ LOOT AT RISK THIS RUN"
    lootTitle.TextColor3 = Color3.fromRGB(235, 120, 120)
    lootTitle.TextSize = 12
    lootTitle.Parent = lootBox

    local lootValue = Instance.new("TextLabel")
    lootValue.Name = "LootValue"
    lootValue.Size = UDim2.new(1, 0, 0, 24)
    lootValue.Position = UDim2.new(0, 0, 0, 30)
    lootValue.BackgroundTransparency = 1
    lootValue.Font = Enum.Font.GothamMedium
    lootValue.Text = "+120 Hotel Coins | 1 Lore Fragment"
    lootValue.TextColor3 = Color3.fromRGB(240, 220, 180)
    lootValue.TextSize = 14
    lootValue.Parent = lootBox

    -- Buttons Container
    local buttonsFrame = Instance.new("Frame")
    buttonsFrame.Name = "ButtonsFrame"
    buttonsFrame.Size = UDim2.new(1, -48, 0, 52)
    buttonsFrame.Position = UDim2.new(0, 24, 1, -74)
    buttonsFrame.BackgroundTransparency = 1
    buttonsFrame.Parent = panel

    -- Continue Button
    local continueBtn = Instance.new("TextButton")
    continueBtn.Name = "ContinueButton"
    continueBtn.Size = UDim2.new(0.48, 0, 1, 0)
    continueBtn.Position = UDim2.new(0, 0, 0, 0)
    continueBtn.BackgroundColor3 = Color3.fromRGB(45, 110, 75)
    continueBtn.BorderSizePixel = 0
    continueBtn.Font = Enum.Font.GothamBold
    continueBtn.Text = "CONTINUE ▲"
    continueBtn.TextColor3 = Color3.fromRGB(240, 255, 240)
    continueBtn.TextSize = 15
    continueBtn.Parent = buttonsFrame

    local contCorner = Instance.new("UICorner")
    contCorner.CornerRadius = UDim.new(0, 8)
    contCorner.Parent = continueBtn

    -- Check Out Button
    local checkOutBtn = Instance.new("TextButton")
    checkOutBtn.Name = "CheckOutButton"
    checkOutBtn.Size = UDim2.new(0.48, 0, 1, 0)
    checkOutBtn.Position = UDim2.new(0.52, 0, 0, 0)
    checkOutBtn.BackgroundColor3 = Color3.fromRGB(150, 115, 45)
    checkOutBtn.BorderSizePixel = 0
    checkOutBtn.Font = Enum.Font.GothamBold
    checkOutBtn.Text = "CHECK OUT 🏨"
    checkOutBtn.TextColor3 = Color3.fromRGB(255, 245, 220)
    checkOutBtn.TextSize = 15
    checkOutBtn.Parent = buttonsFrame

    local checkCorner = Instance.new("UICorner")
    checkCorner.CornerRadius = UDim.new(0, 8)
    checkCorner.Parent = checkOutBtn

    return screenGui
end

return ElevatorUILayout
