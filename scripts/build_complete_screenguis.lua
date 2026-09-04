--[[
    Hotel Hermes - Complete UI ScreenGuis Builder (Deluxe Edition)
    File: scripts/build_complete_screenguis.lua
    Constructs the 100% complete, fully-featured ScreenGuis in StarterGui:
    1. HermesHUD:
       - FloorBadge (Top-Center: "FLOOR 1")
       - CoinsBadge (Top-Left: "🪙 0 COINS")
       - StatusContainer (Bottom-Center: Stamina Bar + Flashlight Battery Bar)
       - InventoryBar (Bottom-Right: 4 Slots with [1], [2], [3], [4] keybind indicators)
       - Notifications (Top-Right: vertical toast message stack)
       - InteractPrompt (Center: Proximity interaction prompt)
    2. HermesMainMenu:
       - HotelTitle ("HOTEL HERMES" with TitleFlicker animation script)
       - Subtitle ("A SURVIVAL HORROR ROGUELITE")
       - CheckInButton ("CHECK IN")
       - PriceTag ("5 ROBUX • FIRST RUN FREE")
       - SettingsButton ("⚙️ SETTINGS")
       - CreditsButton ("📜 CREDITS")
       - SettingsModal & CreditsModal panels
    3. HermesDeathScreen:
       - Dark overlay with red vignette
       - "YOU WERE CAUGHT" horror blood-red font
       - StatsFrame (Floor Reached, Coins Lost, Time Survived)
       - ReturnToLobbyButton
    4. HermesElevatorUI:
       - "FLOOR X CLEARED" Art Deco banner
       - ContinueButton ("CONTINUE ▲" in green)
       - CheckOutButton ("CHECK OUT 🏨" in gold)
       - LootPreviewFrame (Unsaved coins at stake)
    5. HermesPauseMenu:
       - ResumeButton, Audio sliders, Return to Lobby
--]]

local StarterGui = game:GetService("StarterGui")

local function clearGui(name)
    local existing = StarterGui:FindFirstChild(name)
    if existing and existing:IsA("ScreenGui") then
        existing:Destroy()
    end
end

local function makeCorner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 8)
    c.Parent = parent
    return c
end

local function makeStroke(parent, color, thickness)
    local s = Instance.new("UIStroke")
    s.Color = color or Color3.fromRGB(80, 70, 50)
    s.Thickness = thickness or 1.2
    s.Parent = parent
    return s
end

-- ============================================================================
-- 1. HERMES HUD
-- ============================================================================
clearGui("HermesHUD")
local hud = Instance.new("ScreenGui")
hud.Name = "HermesHUD"
hud.ResetOnSpawn = false
hud.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
hud.Enabled = true
hud.Parent = StarterGui

-- 1.1 Floor Badge (Top-Center)
local floorFrame = Instance.new("Frame")
floorFrame.Name = "FloorBadge"
floorFrame.Size = UDim2.new(0, 160, 0, 42)
floorFrame.Position = UDim2.new(0.5, -80, 0, 18)
floorFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
floorFrame.BackgroundTransparency = 0.25
floorFrame.BorderSizePixel = 0
makeCorner(floorFrame, 8)
makeStroke(floorFrame, Color3.fromRGB(120, 100, 60), 1.4)
floorFrame.Parent = hud

local floorLabel = Instance.new("TextLabel")
floorLabel.Name = "FloorLabel"
floorLabel.Size = UDim2.new(1, 0, 1, 0)
floorLabel.BackgroundTransparency = 1
floorLabel.Font = Enum.Font.SpecialElite
floorLabel.Text = "FLOOR 1"
floorLabel.TextColor3 = Color3.fromRGB(240, 225, 195)
floorLabel.TextSize = 20
floorLabel.Parent = floorFrame

-- 1.2 Coins Badge (Top-Left)
local coinsFrame = Instance.new("Frame")
coinsFrame.Name = "CoinsBadge"
coinsFrame.Size = UDim2.new(0, 150, 0, 40)
coinsFrame.Position = UDim2.new(0, 20, 0, 18)
coinsFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
coinsFrame.BackgroundTransparency = 0.25
makeCorner(coinsFrame, 8)
makeStroke(coinsFrame, Color3.fromRGB(200, 160, 40), 1.2)
coinsFrame.Parent = hud

local coinsLabel = Instance.new("TextLabel")
coinsLabel.Name = "CoinsLabel"
coinsLabel.Size = UDim2.new(1, -10, 1, 0)
coinsLabel.Position = UDim2.new(0, 10, 0, 0)
coinsLabel.BackgroundTransparency = 1
coinsLabel.Font = Enum.Font.GothamBold
coinsLabel.Text = "🪙 0 COINS"
coinsLabel.TextColor3 = Color3.fromRGB(255, 215, 80)
coinsLabel.TextSize = 16
coinsLabel.TextXAlignment = Enum.TextXAlignment.Left
coinsLabel.Parent = coinsFrame

-- 1.3 Status Bars (Bottom-Center: Stamina & Battery)
local statusContainer = Instance.new("Frame")
statusContainer.Name = "StatusContainer"
statusContainer.Size = UDim2.new(0, 260, 0, 44)
statusContainer.Position = UDim2.new(0.5, -130, 1, -72)
statusContainer.BackgroundTransparency = 1
statusContainer.Parent = hud

-- Stamina Bar
local staminaBg = Instance.new("Frame")
staminaBg.Name = "StaminaBarBg"
staminaBg.Size = UDim2.new(1, 0, 0, 10)
staminaBg.Position = UDim2.new(0, 0, 0, 4)
staminaBg.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
makeCorner(staminaBg, 5)
makeStroke(staminaBg, Color3.fromRGB(60, 60, 70), 1)
staminaBg.Parent = statusContainer

local staminaFill = Instance.new("Frame")
staminaFill.Name = "StaminaFill"
staminaFill.Size = UDim2.new(1, 0, 1, 0)
staminaFill.BackgroundColor3 = Color3.fromRGB(80, 210, 120)
makeCorner(staminaFill, 5)
staminaFill.Parent = staminaBg

-- Battery Bar
local batteryBg = Instance.new("Frame")
batteryBg.Name = "BatteryBarBg"
batteryBg.Size = UDim2.new(1, 0, 0, 8)
batteryBg.Position = UDim2.new(0, 0, 0, 22)
batteryBg.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
makeCorner(batteryBg, 4)
makeStroke(batteryBg, Color3.fromRGB(60, 60, 70), 1)
batteryBg.Parent = statusContainer

local batteryFill = Instance.new("Frame")
batteryFill.Name = "BatteryFill"
batteryFill.Size = UDim2.new(1, 0, 1, 0)
batteryFill.BackgroundColor3 = Color3.fromRGB(240, 190, 60)
makeCorner(batteryFill, 4)
batteryFill.Parent = batteryBg

-- 1.4 Inventory Bar (Bottom-Right: 4 Slots)
local invFrame = Instance.new("Frame")
invFrame.Name = "InventoryBar"
invFrame.Size = UDim2.new(0, 240, 0, 62)
invFrame.Position = UDim2.new(1, -260, 1, -80)
invFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
invFrame.BackgroundTransparency = 0.35
makeCorner(invFrame, 8)
makeStroke(invFrame, Color3.fromRGB(80, 70, 50), 1.2)
invFrame.Parent = hud

local invLayout = Instance.new("UIListLayout")
invLayout.FillDirection = Enum.FillDirection.Horizontal
invLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
invLayout.VerticalAlignment = Enum.VerticalAlignment.Center
invLayout.Padding = UDim.new(0, 8)
invLayout.Parent = invFrame

for i = 1, 4 do
    local slot = Instance.new("Frame")
    slot.Name = "Slot" .. i
    slot.Size = UDim2.new(0, 48, 0, 48)
    slot.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
    makeCorner(slot, 6)
    makeStroke(slot, Color3.fromRGB(90, 80, 60), 1)
    slot.Parent = invFrame

    local keyLbl = Instance.new("TextLabel")
    keyLbl.Name = "Keybind"
    keyLbl.Size = UDim2.new(0, 16, 0, 14)
    keyLbl.Position = UDim2.new(0, 2, 0, 2)
    keyLbl.BackgroundTransparency = 1
    keyLbl.Font = Enum.Font.GothamBold
    keyLbl.Text = tostring(i)
    keyLbl.TextColor3 = Color3.fromRGB(180, 170, 140)
    keyLbl.TextSize = 11
    keyLbl.Parent = slot

    local itemIcon = Instance.new("TextLabel")
    itemIcon.Name = "ItemIcon"
    itemIcon.Size = UDim2.new(1, 0, 1, 0)
    itemIcon.BackgroundTransparency = 1
    itemIcon.Font = Enum.Font.Gotham
    itemIcon.Text = (i == 1 and "🔦" or "")
    itemIcon.TextSize = 22
    itemIcon.Parent = slot
end

-- 1.5 Notifications Container (Top-Right)
local notifs = Instance.new("Frame")
notifs.Name = "Notifications"
notifs.Size = UDim2.new(0, 260, 0, 220)
notifs.Position = UDim2.new(1, -280, 0, 20)
notifs.BackgroundTransparency = 1
notifs.Parent = hud

local nLayout = Instance.new("UIListLayout")
nLayout.SortOrder = Enum.SortOrder.LayoutOrder
nLayout.Padding = UDim.new(0, 6)
nLayout.Parent = notifs

-- 1.6 Interaction Prompt
local promptFrame = Instance.new("Frame")
promptFrame.Name = "InteractPrompt"
promptFrame.Size = UDim2.new(0, 220, 0, 40)
promptFrame.Position = UDim2.new(0.5, -110, 0.58, 0)
promptFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
promptFrame.BackgroundTransparency = 0.2
promptFrame.Visible = false
makeCorner(promptFrame, 6)
makeStroke(promptFrame, Color3.fromRGB(200, 170, 80), 1.2)
promptFrame.Parent = hud

local promptText = Instance.new("TextLabel")
promptText.Name = "PromptText"
promptText.Size = UDim2.new(1, 0, 1, 0)
promptText.BackgroundTransparency = 1
promptText.Font = Enum.Font.SpecialElite
promptText.Text = "[E] Interact"
promptText.TextColor3 = Color3.fromRGB(240, 230, 200)
promptText.TextSize = 16
promptText.Parent = promptFrame

-- ============================================================================
-- 2. HERMES MAIN MENU (Lobby Title & Buttons)
-- ============================================================================
clearGui("HermesMainMenu")
local menu = Instance.new("ScreenGui")
menu.Name = "HermesMainMenu"
menu.ResetOnSpawn = false
menu.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
menu.Enabled = true
menu.Parent = StarterGui

local menuContainer = Instance.new("Frame")
menuContainer.Name = "MainContainer"
menuContainer.Size = UDim2.new(0, 520, 0, 420)
menuContainer.Position = UDim2.new(0.5, -260, 0.5, -210)
menuContainer.BackgroundColor3 = Color3.fromRGB(16, 16, 22)
menuContainer.BackgroundTransparency = 0.15
makeCorner(menuContainer, 12)
makeStroke(menuContainer, Color3.fromRGB(140, 110, 55), 1.8)
menuContainer.Parent = menu

-- Title
local title = Instance.new("TextLabel")
title.Name = "HotelTitle"
title.Size = UDim2.new(1, 0, 0, 60)
title.Position = UDim2.new(0, 0, 0, 24)
title.BackgroundTransparency = 1
title.Font = Enum.Font.SpecialElite
title.Text = "HOTEL HERMES"
title.TextColor3 = Color3.fromRGB(245, 215, 140)
title.TextSize = 44
title.Parent = menuContainer

-- Title Flicker Animation Script
local flickerScript = Instance.new("LocalScript")
flickerScript.Name = "TitleFlicker"
flickerScript.Source = [[
local lbl = script.Parent
local baseColor = Color3.fromRGB(245, 215, 140)
local dimColor = Color3.fromRGB(120, 90, 40)
task.spawn(function()
    while true do
        task.wait(math.random(3, 7))
        for i = 1, math.random(2, 5) do
            lbl.TextColor3 = dimColor
            task.wait(math.random(3, 8) / 100)
            lbl.TextColor3 = baseColor
            task.wait(math.random(3, 8) / 100)
        end
    end
end)
]]
flickerScript.Parent = title

local tagline = Instance.new("TextLabel")
tagline.Name = "Tagline"
tagline.Size = UDim2.new(1, 0, 0, 24)
tagline.Position = UDim2.new(0, 0, 0, 84)
tagline.BackgroundTransparency = 1
tagline.Font = Enum.Font.GothamMedium
tagline.Text = "A SURVIVAL HORROR ROGUELITE"
tagline.TextColor3 = Color3.fromRGB(160, 145, 120)
tagline.TextSize = 13
tagline.Parent = menuContainer

-- Check-In Button
local checkInBtn = Instance.new("TextButton")
checkInBtn.Name = "CheckInButton"
checkInBtn.Size = UDim2.new(0, 320, 0, 56)
checkInBtn.Position = UDim2.new(0.5, -160, 0, 135)
checkInBtn.BackgroundColor3 = Color3.fromRGB(160, 115, 30)
checkInBtn.Font = Enum.Font.SpecialElite
checkInBtn.Text = "CHECK IN"
checkInBtn.TextColor3 = Color3.fromRGB(255, 255, 240)
checkInBtn.TextSize = 24
makeCorner(checkInBtn, 8)
makeStroke(checkInBtn, Color3.fromRGB(220, 175, 70), 1.5)
checkInBtn.Parent = menuContainer

-- Price Tag Label
local priceTag = Instance.new("TextLabel")
priceTag.Name = "PriceTag"
priceTag.Size = UDim2.new(1, 0, 0, 20)
priceTag.Position = UDim2.new(0, 0, 0, 198)
priceTag.BackgroundTransparency = 1
priceTag.Font = Enum.Font.GothamBold
priceTag.Text = "🎟️ 5 ROBUX • FIRST RUN FREE"
priceTag.TextColor3 = Color3.fromRGB(255, 215, 80)
priceTag.TextSize = 13
priceTag.Parent = menuContainer

-- Settings Button
local settingsBtn = Instance.new("TextButton")
settingsBtn.Name = "SettingsButton"
settingsBtn.Size = UDim2.new(0, 240, 0, 42)
settingsBtn.Position = UDim2.new(0.5, -120, 0, 235)
settingsBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
settingsBtn.Font = Enum.Font.GothamMedium
settingsBtn.Text = "⚙️ SETTINGS"
settingsBtn.TextColor3 = Color3.fromRGB(220, 220, 220)
settingsBtn.TextSize = 15
makeCorner(settingsBtn, 6)
makeStroke(settingsBtn, Color3.fromRGB(70, 70, 85), 1)
settingsBtn.Parent = menuContainer

-- Credits Button
local creditsBtn = Instance.new("TextButton")
creditsBtn.Name = "CreditsButton"
creditsBtn.Size = UDim2.new(0, 240, 0, 42)
creditsBtn.Position = UDim2.new(0.5, -120, 0, 290)
creditsBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
creditsBtn.Font = Enum.Font.GothamMedium
creditsBtn.Text = "📜 CREDITS"
creditsBtn.TextColor3 = Color3.fromRGB(220, 220, 220)
creditsBtn.TextSize = 15
makeCorner(creditsBtn, 6)
makeStroke(creditsBtn, Color3.fromRGB(70, 70, 85), 1)
creditsBtn.Parent = menuContainer

-- Close / Dismiss Button
local closeBtn = Instance.new("TextButton")
closeBtn.Name = "CloseButton"
closeBtn.Size = UDim2.new(0, 36, 0, 36)
closeBtn.Position = UDim2.new(1, -44, 0, 10)
closeBtn.BackgroundColor3 = Color3.fromRGB(40, 20, 20)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.fromRGB(255, 120, 120)
closeBtn.TextSize = 16
makeCorner(closeBtn, 18)
closeBtn.Parent = menuContainer

-- ============================================================================
-- 3. HERMES DEATH SCREEN
-- ============================================================================
clearGui("HermesDeathScreen")
local death = Instance.new("ScreenGui")
death.Name = "HermesDeathScreen"
death.ResetOnSpawn = false
death.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
death.Enabled = false
death.Parent = StarterGui

local dOverlay = Instance.new("Frame")
dOverlay.Name = "Overlay"
dOverlay.Size = UDim2.new(1, 0, 1, 0)
dOverlay.BackgroundColor3 = Color3.fromRGB(5, 2, 2)
dOverlay.BackgroundTransparency = 0.1
dOverlay.Parent = death

local deathTitle = Instance.new("TextLabel")
deathTitle.Name = "DeathTitle"
deathTitle.Size = UDim2.new(1, 0, 0, 80)
deathTitle.Position = UDim2.new(0, 0, 0.22, 0)
deathTitle.BackgroundTransparency = 1
deathTitle.Font = Enum.Font.SpecialElite
deathTitle.Text = "YOU WERE CAUGHT"
deathTitle.TextColor3 = Color3.fromRGB(220, 35, 35)
deathTitle.TextSize = 52
deathTitle.Parent = dOverlay

local statsFrame = Instance.new("Frame")
statsFrame.Name = "StatsFrame"
statsFrame.Size = UDim2.new(0, 380, 0, 140)
statsFrame.Position = UDim2.new(0.5, -190, 0.40, 0)
statsFrame.BackgroundColor3 = Color3.fromRGB(18, 12, 12)
statsFrame.BackgroundTransparency = 0.3
makeCorner(statsFrame, 8)
makeStroke(statsFrame, Color3.fromRGB(120, 30, 30), 1.2)
statsFrame.Parent = dOverlay

local statFloor = Instance.new("TextLabel")
statFloor.Name = "FloorReached"
statFloor.Size = UDim2.new(1, 0, 0, 36)
statFloor.Position = UDim2.new(0, 0, 0, 12)
statFloor.BackgroundTransparency = 1
statFloor.Font = Enum.Font.GothamMedium
statFloor.Text = "Floor Reached: 1"
statFloor.TextColor3 = Color3.fromRGB(230, 210, 200)
statFloor.TextSize = 18
statFloor.Parent = statsFrame

local statLoot = Instance.new("TextLabel")
statLoot.Name = "LootLost"
statLoot.Size = UDim2.new(1, 0, 0, 36)
statLoot.Position = UDim2.new(0, 0, 0, 48)
statLoot.BackgroundTransparency = 1
statLoot.Font = Enum.Font.GothamMedium
statLoot.Text = "Unsaved Hotel Coins Lost: 0"
statLoot.TextColor3 = Color3.fromRGB(240, 140, 100)
statLoot.TextSize = 16
statLoot.Parent = statsFrame

local statTime = Instance.new("TextLabel")
statTime.Name = "TimeSurvived"
statTime.Size = UDim2.new(1, 0, 0, 36)
statTime.Position = UDim2.new(0, 0, 0, 84)
statTime.BackgroundTransparency = 1
statTime.Font = Enum.Font.Gotham
statTime.Text = "Survival Time: 02:45"
statTime.TextColor3 = Color3.fromRGB(180, 170, 160)
statTime.TextSize = 14
statTime.Parent = statsFrame

local returnBtn = Instance.new("TextButton")
returnBtn.Name = "ReturnToLobbyButton"
returnBtn.Size = UDim2.new(0, 260, 0, 52)
returnBtn.Position = UDim2.new(0.5, -130, 0.65, 0)
returnBtn.BackgroundColor3 = Color3.fromRGB(120, 25, 25)
returnBtn.Font = Enum.Font.SpecialElite
returnBtn.Text = "RETURN TO LOBBY"
returnBtn.TextColor3 = Color3.fromRGB(255, 240, 240)
returnBtn.TextSize = 20
makeCorner(returnBtn, 8)
makeStroke(returnBtn, Color3.fromRGB(180, 50, 50), 1.5)
returnBtn.Parent = dOverlay

-- ============================================================================
-- 4. HERMES ELEVATOR UI (Floor Cleared Decision)
-- ============================================================================
clearGui("HermesElevatorUI")
local elev = Instance.new("ScreenGui")
elev.Name = "HermesElevatorUI"
elev.ResetOnSpawn = false
elev.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
elev.Enabled = false
elev.Parent = StarterGui

local eBackdrop = Instance.new("Frame")
eBackdrop.Name = "Backdrop"
eBackdrop.Size = UDim2.new(1, 0, 1, 0)
eBackdrop.BackgroundColor3 = Color3.fromRGB(10, 10, 14)
eBackdrop.BackgroundTransparency = 0.25
eBackdrop.Parent = elev

local ePanel = Instance.new("Frame")
ePanel.Name = "CenterPanel"
ePanel.Size = UDim2.new(0, 480, 0, 360)
ePanel.Position = UDim2.new(0.5, -240, 0.5, -180)
ePanel.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
makeCorner(ePanel, 12)
makeStroke(ePanel, Color3.fromRGB(180, 140, 60), 1.8)
ePanel.Parent = eBackdrop

local eHeader = Instance.new("TextLabel")
eHeader.Name = "FloorClearedHeader"
eHeader.Size = UDim2.new(1, 0, 0, 50)
eHeader.Position = UDim2.new(0, 0, 0, 20)
eHeader.BackgroundTransparency = 1
eHeader.Font = Enum.Font.SpecialElite
eHeader.Text = "FLOOR CLEARED"
eHeader.TextColor3 = Color3.fromRGB(250, 220, 140)
eHeader.TextSize = 34
eHeader.Parent = ePanel

local eSub = Instance.new("TextLabel")
eSub.Name = "SubHeader"
eSub.Size = UDim2.new(1, 0, 0, 24)
eSub.Position = UDim2.new(0, 0, 0, 68)
eSub.BackgroundTransparency = 1
eSub.Font = Enum.Font.GothamMedium
eSub.Text = "Ascend higher for greater rewards, or bank your earnings."
eSub.TextColor3 = Color3.fromRGB(170, 160, 140)
eSub.TextSize = 13
eSub.Parent = ePanel

local lootBox = Instance.new("Frame")
lootBox.Name = "LootPreview"
lootBox.Size = UDim2.new(1, -60, 0, 70)
lootBox.Position = UDim2.new(0, 30, 0, 105)
lootBox.BackgroundColor3 = Color3.fromRGB(25, 25, 34)
makeCorner(lootBox, 8)
makeStroke(lootBox, Color3.fromRGB(200, 165, 50), 1.2)
lootBox.Parent = ePanel

local lootTitle = Instance.new("TextLabel")
lootTitle.Name = "LootTitle"
lootTitle.Size = UDim2.new(1, 0, 0, 24)
lootTitle.Position = UDim2.new(0, 0, 0, 10)
lootTitle.BackgroundTransparency = 1
lootTitle.Font = Enum.Font.GothamBold
lootTitle.Text = "UNSAVED HOTEL COINS AT RISK"
lootTitle.TextColor3 = Color3.fromRGB(200, 190, 170)
lootTitle.TextSize = 12
lootTitle.Parent = lootBox

local lootVal = Instance.new("TextLabel")
lootVal.Name = "LootValue"
lootVal.Size = UDim2.new(1, 0, 0, 28)
lootVal.Position = UDim2.new(0, 0, 0, 34)
lootVal.BackgroundTransparency = 1
lootVal.Font = Enum.Font.SpecialElite
lootVal.Text = "+55 HOTEL COINS"
lootVal.TextColor3 = Color3.fromRGB(255, 220, 70)
lootVal.TextSize = 22
lootVal.Parent = lootBox

local continueBtn = Instance.new("TextButton")
continueBtn.Name = "ContinueButton"
continueBtn.Size = UDim2.new(0, 195, 0, 54)
continueBtn.Position = UDim2.new(0, 35, 0, 205)
continueBtn.BackgroundColor3 = Color3.fromRGB(35, 120, 60)
continueBtn.Font = Enum.Font.SpecialElite
continueBtn.Text = "CONTINUE ▲"
continueBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
continueBtn.TextSize = 18
makeCorner(continueBtn, 8)
makeStroke(continueBtn, Color3.fromRGB(60, 180, 90), 1.5)
continueBtn.Parent = ePanel

local checkOutBtn = Instance.new("TextButton")
checkOutBtn.Name = "CheckOutButton"
checkOutBtn.Size = UDim2.new(0, 195, 0, 54)
checkOutBtn.Position = UDim2.new(1, -230, 0, 205)
checkOutBtn.BackgroundColor3 = Color3.fromRGB(150, 110, 30)
checkOutBtn.Font = Enum.Font.SpecialElite
checkOutBtn.Text = "CHECK OUT 🏨"
checkOutBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
checkOutBtn.TextSize = 18
makeCorner(checkOutBtn, 8)
makeStroke(checkOutBtn, Color3.fromRGB(210, 160, 50), 1.5)
checkOutBtn.Parent = ePanel

-- ============================================================================
-- 5. HERMES PAUSE MENU
-- ============================================================================
clearGui("HermesPauseMenu")
local pause = Instance.new("ScreenGui")
pause.Name = "HermesPauseMenu"
pause.ResetOnSpawn = false
pause.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
pause.Enabled = false
pause.Parent = StarterGui

local pOverlay = Instance.new("Frame")
pOverlay.Name = "Overlay"
pOverlay.Size = UDim2.new(1, 0, 1, 0)
pOverlay.BackgroundColor3 = Color3.fromRGB(8, 8, 12)
pOverlay.BackgroundTransparency = 0.3
pOverlay.Parent = pause

local pPanel = Instance.new("Frame")
pPanel.Name = "Panel"
pPanel.Size = UDim2.new(0, 360, 0, 300)
pPanel.Position = UDim2.new(0.5, -180, 0.5, -150)
pPanel.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
makeCorner(pPanel, 10)
makeStroke(pPanel, Color3.fromRGB(90, 80, 60), 1.4)
pPanel.Parent = pOverlay

local pTitle = Instance.new("TextLabel")
pTitle.Name = "Title"
pTitle.Size = UDim2.new(1, 0, 0, 44)
pTitle.Position = UDim2.new(0, 0, 0, 16)
pTitle.BackgroundTransparency = 1
pTitle.Font = Enum.Font.SpecialElite
pTitle.Text = "PAUSED"
pTitle.TextColor3 = Color3.fromRGB(240, 220, 160)
pTitle.TextSize = 28
pTitle.Parent = pPanel

local resumeBtn = Instance.new("TextButton")
resumeBtn.Name = "ResumeButton"
resumeBtn.Size = UDim2.new(0, 240, 0, 44)
resumeBtn.Position = UDim2.new(0.5, -120, 0, 80)
resumeBtn.BackgroundColor3 = Color3.fromRGB(35, 120, 60)
resumeBtn.Font = Enum.Font.SpecialElite
resumeBtn.Text = "RESUME"
resumeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
resumeBtn.TextSize = 18
makeCorner(resumeBtn, 6)
resumeBtn.Parent = pPanel

local pSettingsBtn = Instance.new("TextButton")
pSettingsBtn.Name = "SettingsButton"
pSettingsBtn.Size = UDim2.new(0, 240, 0, 44)
pSettingsBtn.Position = UDim2.new(0.5, -120, 0, 140)
pSettingsBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
pSettingsBtn.Font = Enum.Font.GothamMedium
pSettingsBtn.Text = "AUDIO SETTINGS"
pSettingsBtn.TextColor3 = Color3.fromRGB(220, 220, 220)
pSettingsBtn.TextSize = 15
makeCorner(pSettingsBtn, 6)
pSettingsBtn.Parent = pPanel

local lobbyBtn = Instance.new("TextButton")
lobbyBtn.Name = "ReturnToLobbyButton"
lobbyBtn.Size = UDim2.new(0, 240, 0, 44)
lobbyBtn.Position = UDim2.new(0.5, -120, 0, 200)
lobbyBtn.BackgroundColor3 = Color3.fromRGB(110, 30, 30)
lobbyBtn.Font = Enum.Font.SpecialElite
lobbyBtn.Text = "QUIT TO LOBBY"
lobbyBtn.TextColor3 = Color3.fromRGB(255, 230, 230)
lobbyBtn.TextSize = 16
makeCorner(lobbyBtn, 6)
lobbyBtn.Parent = pPanel

return "Successfully constructed all 5 Deluxe ScreenGuis in StarterGui!"
