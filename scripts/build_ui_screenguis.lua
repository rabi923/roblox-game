--[[
    Hotel Hermes - UI ScreenGui Builder
    File: scripts/build_ui_screenguis.lua
    Constructs the live ScreenGuis in StarterGui using the pre-built layout modules:
    - HermesHUD (Floor badge, stamina fill bar, flashlight power bar, coins badge, inventory, notifications)
    - HermesMainMenu (Title, subtitle, check-in button, settings, credits, price tag)
    - HermesDeathScreen (Dark overlay, 'YOU WERE CAUGHT' label, run summary stats, return to lobby button)
    - HermesElevatorUI (Floor cleared header, Continue button, Check Out button, unsaved loot preview)
    - HermesPauseMenu (Resume button, settings, return to lobby)
    All with ResetOnSpawn = false and ZIndexBehavior = Sibling.
--]]

local StarterGui = game:GetService("StarterGui")

local results = {}

-- 1. Helper to safely instantiate and place ScreenGui
local function buildGui(moduleName, guiName, enabledByDefault)
    local existing = StarterGui:FindFirstChild(guiName)
    if existing and existing:IsA("ScreenGui") then
        existing:Destroy()
    end

    local mod = StarterGui:FindFirstChild(moduleName)
    if not mod or not mod:IsA("ModuleScript") then
        return false, "ModuleScript " .. moduleName .. " not found in StarterGui"
    end

    local success, layoutModule = pcall(require, mod)
    if not success or type(layoutModule) ~= "table" or not layoutModule.Create then
        return false, "Failed to require " .. moduleName .. ": " .. tostring(layoutModule)
    end

    local gui = layoutModule.Create()
    gui.Name = guiName
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.Enabled = (enabledByDefault == true)
    gui.Parent = StarterGui

    return true, gui
end

-- 2. Build HermesHUD (Enabled during gameplay)
local okHUD, hud = buildGui("HUDLayout", "HermesHUD", true)
table.insert(results, okHUD and "✅ Built StarterGui.HermesHUD (Floor counter, stamina, inventory, coins, notifications)" or ("❌ " .. tostring(hud)))

-- 3. Build HermesMainMenu (Enabled by default when player first arrives in Lobby)
local okMenu, menu = buildGui("MainMenuLayout", "HermesMainMenu", true)
table.insert(results, okMenu and "✅ Built StarterGui.HermesMainMenu ('HOTEL HERMES' title, Check In, Settings, Credits)" or ("❌ " .. tostring(menu)))

-- 4. Build HermesDeathScreen (Disabled by default, triggered on catch)
local okDeath, death = buildGui("DeathScreenLayout", "HermesDeathScreen", false)
table.insert(results, okDeath and "✅ Built StarterGui.HermesDeathScreen (Dark overlay, 'YOU WERE CAUGHT', stats, return button)" or ("❌ " .. tostring(death)))

-- 5. Build HermesElevatorUI (Disabled by default, triggered on floor clear)
local okElev, elev = buildGui("ElevatorUILayout", "HermesElevatorUI", false)
table.insert(results, okElev and "✅ Built StarterGui.HermesElevatorUI (Continue ▲, Check Out 🏨, unsaved loot preview)" or ("❌ " .. tostring(elev)))

-- 6. Build HermesPauseMenu (Disabled by default, triggered by ESC/M key)
local okPause, pause = buildGui("PauseMenuLayout", "HermesPauseMenu", false)
table.insert(results, okPause and "✅ Built StarterGui.HermesPauseMenu (Resume, audio sliders, return to lobby)" or ("❌ " .. tostring(pause)))

return table.concat(results, "\n")
