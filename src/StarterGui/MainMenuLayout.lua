--[[
    Hotel Hermes - Main Lobby Check-In Menu Layout
    File: StarterGui/MainMenuLayout.lua
    Description: Constructs the vintage front desk check-in interface.
--]]

local MainMenuLayout = {}

function MainMenuLayout.Create(): ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "HermesMainMenu"
    screenGui.ResetOnSpawn = false
    screenGui.Enabled = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local container = Instance.new("Frame")
    container.Name = "MainContainer"
    container.Size = UDim2.new(0, 480, 0, 380)
    container.Position = UDim2.new(0.5, -240, 0.5, -190)
    container.BackgroundColor3 = Color3.fromRGB(14, 14, 18)
    container.BorderSizePixel = 0
    container.Parent = screenGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = container

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(200, 170, 95)
    stroke.Thickness = 2
    stroke.Parent = container

    -- Title
    local title = Instance.new("TextLabel")
    title.Name = "HotelTitle"
    title.Size = UDim2.new(1, 0, 0, 54)
    title.Position = UDim2.new(0, 0, 0, 18)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.SpecialElite
    title.Text = "HOTEL HERMES"
    title.TextColor3 = Color3.fromRGB(250, 230, 180)
    title.TextSize = 34
    title.Parent = container

    -- Tagline
    local tagline = Instance.new("TextLabel")
    tagline.Name = "Tagline"
    tagline.Size = UDim2.new(1, 0, 0, 24)
    tagline.Position = UDim2.new(0, 0, 0, 70)
    tagline.BackgroundTransparency = 1
    tagline.Font = Enum.Font.Gotham
    tagline.Text = "You can check in, but you can never check out."
    tagline.TextColor3 = Color3.fromRGB(160, 160, 170)
    tagline.TextSize = 13
    tagline.Parent = container

    -- Front Desk Notice Box
    local noticeBox = Instance.new("Frame")
    noticeBox.Name = "NoticeBox"
    noticeBox.Size = UDim2.new(1, -60, 0, 90)
    noticeBox.Position = UDim2.new(0, 30, 0, 110)
    noticeBox.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
    noticeBox.BorderSizePixel = 0
    noticeBox.Parent = container

    local noticeCorner = Instance.new("UICorner")
    noticeCorner.CornerRadius = UDim.new(0, 8)
    noticeCorner.Parent = noticeBox

    local noticeText = Instance.new("TextLabel")
    noticeText.Name = "NoticeText"
    noticeText.Size = UDim2.new(1, -24, 1, -16)
    noticeText.Position = UDim2.new(0, 12, 0, 8)
    noticeText.BackgroundTransparency = 1
    noticeText.Font = Enum.Font.Gotham
    noticeText.Text = "Front Desk Policy:\n• Floors 1 through 3 are complimentary for all guests.\n• Further stays require a 5 Robux session registration key.\n• All banked loot is permanently preserved upon checking out."
    noticeText.TextColor3 = Color3.fromRGB(200, 200, 210)
    noticeText.TextSize = 12
    noticeText.TextXAlignment = Enum.TextXAlignment.Left
    noticeText.TextYAlignment = Enum.TextYAlignment.Top
    noticeText.TextWrapped = true
    noticeText.Parent = noticeBox

    -- Check-In Button
    local checkInBtn = Instance.new("TextButton")
    checkInBtn.Name = "CheckInButton"
    checkInBtn.Size = UDim2.new(1, -60, 0, 52)
    checkInBtn.Position = UDim2.new(0, 30, 0, 225)
    checkInBtn.BackgroundColor3 = Color3.fromRGB(180, 140, 50)
    checkInBtn.BorderSizePixel = 0
    checkInBtn.Font = Enum.Font.GothamBold
    checkInBtn.Text = "CHECK IN (FREE FIRST TIME)"
    checkInBtn.TextColor3 = Color3.fromRGB(255, 255, 240)
    checkInBtn.TextSize = 16
    checkInBtn.Parent = container

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 8)
    btnCorner.Parent = checkInBtn

    -- Close / Walk Away Button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Name = "CloseButton"
    closeBtn.Size = UDim2.new(1, -60, 0, 36)
    closeBtn.Position = UDim2.new(0, 30, 0, 290)
    closeBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 36)
    closeBtn.BorderSizePixel = 0
    closeBtn.Font = Enum.Font.GothamMedium
    closeBtn.Text = "Step Away from Front Desk"
    closeBtn.TextColor3 = Color3.fromRGB(160, 160, 170)
    closeBtn.TextSize = 13
    closeBtn.Parent = container

    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 8)
    closeCorner.Parent = closeBtn

    return screenGui
end

return MainMenuLayout
