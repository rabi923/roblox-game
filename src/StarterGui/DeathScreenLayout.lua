--[[
    Hotel Hermes - Death & Jumpscare Screen Layout
    File: StarterGui/DeathScreenLayout.lua
    Description: Constructs the dramatic elimination screen when caught by an entity.
--]]

local DeathScreenLayout = {}

function DeathScreenLayout.Create(): ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "HermesDeathScreen"
    screenGui.ResetOnSpawn = false
    screenGui.Enabled = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    -- Fullscreen black overlay with fade
    local overlay = Instance.new("Frame")
    overlay.Name = "Overlay"
    overlay.Size = UDim2.new(1, 0, 1, 0)
    overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    overlay.BackgroundTransparency = 0.1
    overlay.BorderSizePixel = 0
    overlay.Parent = screenGui

    -- Center Content
    local contentFrame = Instance.new("Frame")
    contentFrame.Name = "ContentFrame"
    contentFrame.Size = UDim2.new(0, 460, 0, 280)
    contentFrame.Position = UDim2.new(0.5, -230, 0.5, -140)
    contentFrame.BackgroundTransparency = 1
    contentFrame.Parent = overlay

    -- "YOU WERE CAUGHT"
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "TitleLabel"
    titleLabel.Size = UDim2.new(1, 0, 0, 60)
    titleLabel.Position = UDim2.new(0, 0, 0, 10)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Font = Enum.Font.Creepster or Enum.Font.SpecialElite
    titleLabel.Text = "YOU WERE CAUGHT"
    titleLabel.TextColor3 = Color3.fromRGB(200, 30, 30)
    titleLabel.TextSize = 42
    titleLabel.Parent = contentFrame

    -- Floor stats summary
    local statsLabel = Instance.new("TextLabel")
    statsLabel.Name = "StatsLabel"
    statsLabel.Size = UDim2.new(1, 0, 0, 60)
    statsLabel.Position = UDim2.new(0, 0, 0, 80)
    statsLabel.BackgroundTransparency = 1
    statsLabel.Font = Enum.Font.Gotham
    statsLabel.Text = "You perished on Floor 4.\nAll unsaved Hotel Coins from this run have been lost."
    statsLabel.TextColor3 = Color3.fromRGB(180, 180, 190)
    statsLabel.TextSize = 15
    statsLabel.TextWrapped = true
    statsLabel.Parent = contentFrame

    -- Return to Lobby Button
    local lobbyBtn = Instance.new("TextButton")
    lobbyBtn.Name = "LobbyButton"
    lobbyBtn.Size = UDim2.new(0, 220, 0, 48)
    lobbyBtn.Position = UDim2.new(0.5, -110, 1, -60)
    lobbyBtn.BackgroundColor3 = Color3.fromRGB(40, 20, 25)
    lobbyBtn.BorderSizePixel = 0
    lobbyBtn.Font = Enum.Font.GothamBold
    lobbyBtn.Text = "RETURN TO LOBBY"
    lobbyBtn.TextColor3 = Color3.fromRGB(240, 200, 205)
    lobbyBtn.TextSize = 15
    lobbyBtn.Parent = contentFrame

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 8)
    btnCorner.Parent = lobbyBtn

    local btnStroke = Instance.new("UIStroke")
    btnStroke.Color = Color3.fromRGB(160, 50, 60)
    btnStroke.Thickness = 1.2
    btnStroke.Parent = lobbyBtn

    return screenGui
end

return DeathScreenLayout
