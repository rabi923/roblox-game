--[[
    Hotel Hermes - Pause & Settings Menu Layout
    File: StarterGui/PauseMenuLayout.lua
    Description: Constructs the Pause, Controls Reference, and Settings interface.
--]]

local PauseMenuLayout = {}

function PauseMenuLayout.Create(): ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "HermesPauseMenu"
    screenGui.ResetOnSpawn = false
    screenGui.Enabled = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    -- Background dim overlay
    local overlay = Instance.new("Frame")
    overlay.Name = "Overlay"
    overlay.Size = UDim2.new(1, 0, 1, 0)
    overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    overlay.BackgroundTransparency = 0.4
    overlay.BorderSizePixel = 0
    overlay.Parent = screenGui

    -- Main Container
    local container = Instance.new("Frame")
    container.Name = "MainContainer"
    container.Size = UDim2.new(0, 480, 0, 420)
    container.Position = UDim2.new(0.5, -240, 0.5, -210)
    container.BackgroundColor3 = Color3.fromRGB(16, 16, 22)
    container.BorderSizePixel = 0
    container.Parent = overlay

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = container

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(180, 150, 80)
    stroke.Thickness = 1.5
    stroke.Parent = container

    -- Title
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, 0, 0, 48)
    title.Position = UDim2.new(0, 0, 0, 15)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.SpecialElite
    title.Text = "PAUSE & SETTINGS"
    title.TextColor3 = Color3.fromRGB(240, 220, 170)
    title.TextSize = 26
    title.Parent = container

    -- Controls Guide Box
    local controlsBox = Instance.new("Frame")
    controlsBox.Name = "ControlsBox"
    controlsBox.Size = UDim2.new(1, -50, 0, 140)
    controlsBox.Position = UDim2.new(0, 25, 0, 70)
    controlsBox.BackgroundColor3 = Color3.fromRGB(24, 24, 32)
    controlsBox.BorderSizePixel = 0
    controlsBox.Parent = container

    local controlsCorner = Instance.new("UICorner")
    controlsCorner.CornerRadius = UDim.new(0, 8)
    controlsCorner.Parent = controlsBox

    local controlsText = Instance.new("TextLabel")
    controlsText.Name = "ControlsText"
    controlsText.Size = UDim2.new(1, -20, 1, -16)
    controlsText.Position = UDim2.new(0, 10, 0, 8)
    controlsText.BackgroundTransparency = 1
    controlsText.Font = Enum.Font.Gotham
    controlsText.Text = "HOTEL CONTROLS:\n• [W, A, S, D] / Joystick — Movement\n• [Left Shift] / ButtonL3 — Sprint (Consumes Stamina, Makes Noise)\n• [C / L-Ctrl] / ButtonB — Crouch (Silent & Stealthy)\n• [E] / ButtonX — Interact with Objects & Doors\n• [F] / ButtonY — Toggle Flashlight\n• [P / Esc] / ButtonStart — Pause Menu"
    controlsText.TextColor3 = Color3.fromRGB(200, 200, 215)
    controlsText.TextSize = 12
    controlsText.TextXAlignment = Enum.TextXAlignment.Left
    controlsText.TextYAlignment = Enum.TextYAlignment.Top
    controlsText.TextWrapped = true
    controlsText.Parent = controlsBox

    -- Volume Slider / Label
    local volumeLabel = Instance.new("TextLabel")
    volumeLabel.Name = "VolumeLabel"
    volumeLabel.Size = UDim2.new(1, -50, 0, 24)
    volumeLabel.Position = UDim2.new(0, 25, 0, 225)
    volumeLabel.BackgroundTransparency = 1
    volumeLabel.Font = Enum.Font.GothamMedium
    volumeLabel.Text = "Master Audio: 100%"
    volumeLabel.TextColor3 = Color3.fromRGB(220, 220, 225)
    volumeLabel.TextSize = 13
    volumeLabel.TextXAlignment = Enum.TextXAlignment.Left
    volumeLabel.Parent = container

    -- Resume Button
    local resumeBtn = Instance.new("TextButton")
    resumeBtn.Name = "ResumeButton"
    resumeBtn.Size = UDim2.new(1, -50, 0, 44)
    resumeBtn.Position = UDim2.new(0, 25, 0, 265)
    resumeBtn.BackgroundColor3 = Color3.fromRGB(160, 130, 60)
    resumeBtn.BorderSizePixel = 0
    resumeBtn.Font = Enum.Font.GothamBold
    resumeBtn.Text = "RESUME GAME"
    resumeBtn.TextColor3 = Color3.fromRGB(255, 255, 240)
    resumeBtn.TextSize = 15
    resumeBtn.Parent = container

    local resumeCorner = Instance.new("UICorner")
    resumeCorner.CornerRadius = UDim.new(0, 8)
    resumeCorner.Parent = resumeBtn

    -- Return to Lobby / Quit Button
    local lobbyBtn = Instance.new("TextButton")
    lobbyBtn.Name = "LobbyButton"
    lobbyBtn.Size = UDim2.new(1, -50, 0, 40)
    lobbyBtn.Position = UDim2.new(0, 25, 0, 320)
    lobbyBtn.BackgroundColor3 = Color3.fromRGB(38, 38, 48)
    lobbyBtn.BorderSizePixel = 0
    lobbyBtn.Font = Enum.Font.GothamMedium
    lobbyBtn.Text = "Return to Lobby"
    lobbyBtn.TextColor3 = Color3.fromRGB(200, 190, 190)
    lobbyBtn.TextSize = 14
    lobbyBtn.Parent = container

    local lobbyCorner = Instance.new("UICorner")
    lobbyCorner.CornerRadius = UDim.new(0, 8)
    lobbyCorner.Parent = lobbyBtn

    return screenGui
end

return PauseMenuLayout
