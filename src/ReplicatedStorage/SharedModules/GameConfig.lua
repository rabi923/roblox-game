--[[
    Hotel Hermes - Runtime Configuration & Scaler
    File: ReplicatedStorage/SharedModules/GameConfig.lua
    Description: Dynamic balance config, floor difficulty scaling formulas,
                 and runtime environmental overrides.
--]]

local Constants = require(script.Parent.Constants)

local GameConfig = {}

-- Server limits
GameConfig.MaxPlayersPerServer = 12
GameConfig.ReservedServerCoopMax = 4

-- Game balance toggles
GameConfig.AllowSprintInCrouch = false
GameConfig.EnableDynamicFlashlightFlicker = true
GameConfig.StrictAntiExploit = true
GameConfig.EnableAnalyticsLogging = true

-- Free play access limit
GameConfig.FreeFloorCeiling = Constants.Architecture.FreeFloorCeiling

--[[
    Computes floor difficulty parameters based on floor number:
    Returns:
      - RoomCount (integer)
      - EntityChaseSpeedMultiplier (number)
      - EntityHearingMultiplier (number)
      - PuzzleComplexity (string)
      - SecretRoomChance (number 0..1)
--]]
function GameConfig.GetFloorDifficulty(floorNumber: number)
    local floor = math.max(1, floorNumber or 1)
    
    -- Room count scales gradually from 4 to 9
    local roomCount = math.clamp(
        Constants.Architecture.MinRoomsPerFloor + math.floor(floor / 6),
        Constants.Architecture.MinRoomsPerFloor,
        Constants.Architecture.MaxRoomsPerFloor
    )
    
    -- Speed scales from 1.0x up to 1.35x
    local speedMult = math.clamp(1.0 + (floor * 0.007), 1.0, 1.35)
    
    -- Entity hearing sensitivity multiplier
    local hearingMult = math.clamp(1.0 + (floor * 0.015), 1.0, 1.6)
    
    -- Puzzle step complexity
    local puzzleComplexity = "EASY"
    if floor > 20 then
        puzzleComplexity = "HARD"
    elseif floor > 7 then
        puzzleComplexity = "MEDIUM"
    end
    
    -- Secret room appearance chance
    local secretRoomChance = math.clamp(0.20 + (floor * 0.01), 0.20, 0.50)
    
    return {
        RoomCount = roomCount,
        SpeedMultiplier = speedMult,
        HearingMultiplier = hearingMult,
        PuzzleComplexity = puzzleComplexity,
        SecretRoomChance = secretRoomChance,
    }
end

--[[
    Finds the active theme configuration for a given floor.
--]]
function GameConfig.GetThemeForFloor(floorNumber: number)
    local floor = math.max(1, floorNumber or 1)
    
    for _, theme in ipairs(Constants.FloorThemes) do
        local minFloor = theme.Floors[1]
        local maxFloor = theme.Floors[2]
        if floor >= minFloor and floor <= maxFloor then
            return theme
        end
    end
    
    -- Fallback to the highest floor theme (The Penthouse Void) for prestige floors > 50
    return Constants.FloorThemes[#Constants.FloorThemes]
end

return GameConfig
