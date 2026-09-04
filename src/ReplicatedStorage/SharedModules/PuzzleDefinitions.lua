--[[
    Hotel Hermes - Procedural Puzzle Definitions & Rules
    File: ReplicatedStorage/SharedModules/PuzzleDefinitions.lua
    Description: Defines the 4 primary procedural horror puzzle mechanics,
                 their validation criteria, spawn configs, and difficulty scalers.
--]]

local PuzzleDefinitions = {}

PuzzleDefinitions.Types = {
    KeycardHunt = "KEYCARD_HUNT",
    SafeCode = "SAFE_CODE",
    ElectricalRepair = "ELECTRICAL_REPAIR",
    RitualCandles = "RITUAL_CANDLES",
}

--[[
    Template: Keycard Hunt (Floors 1-10)
    Find 2 to 3 color-coded keycards hidden in bedside drawers and desks.
--]]
PuzzleDefinitions[PuzzleDefinitions.Types.KeycardHunt] = {
    DisplayName = "Master Keycard Protocol",
    Colors = { "Red", "Blue", "Gold" },
    Generate = function(difficulty: string)
        local count = (difficulty == "HARD") and 3 or 2
        local requiredKeys = {}
        for i = 1, count do
            table.insert(requiredKeys, PuzzleDefinitions[PuzzleDefinitions.Types.KeycardHunt].Colors[i])
        end
        return {
            RequiredKeys = requiredKeys,
            InsertedKeys = {},
        }
    end,
    CheckSolved = function(puzzleState: table): boolean
        local req = puzzleState.RequiredKeys
        local ins = puzzleState.InsertedKeys
        if #ins < #req then return false end

        for _, key in ipairs(req) do
            local found = false
            for _, insKey in ipairs(ins) do
                if insKey == key then
                    found = true
                    break
                end
            end
            if not found then return false end
        end
        return true
    end
}

--[[
    Template: Safe Code (Floors 4-20)
    Find four separate digits written on hotel memos scattered across the floor.
--]]
PuzzleDefinitions[PuzzleDefinitions.Types.SafeCode] = {
    DisplayName = "Guest Vault Combination",
    Generate = function(difficulty: string)
        -- Generate randomized 4-digit code (e.g. "4829")
        local digits = {}
        for _ = 1, 4 do
            table.insert(digits, tostring(math.random(0, 9)))
        end
        local codeString = table.concat(digits, "")
        return {
            SolutionCode = codeString,
            EnteredCode = "",
            Clues = {
                { Digit = digits[1], Order = 1, Hint = "Scratched into the nightstand" },
                { Digit = digits[2], Order = 2, Hint = "Written behind the bathroom mirror" },
                { Digit = digits[3], Order = 3, Hint = "Typed on the vintage typewriter" },
                { Digit = digits[4], Order = 4, Hint = "Under the bloody floor rug" },
            }
        }
    end,
    CheckSolved = function(puzzleState: table): boolean
        return puzzleState.EnteredCode == puzzleState.SolutionCode
    end
}

--[[
    Template: Electrical Repair (Floors 11-35)
    Flip breaker switches in correct sequence without tripping the master fuse.
--]]
PuzzleDefinitions[PuzzleDefinitions.Types.ElectricalRepair] = {
    DisplayName = "Emergency Breaker Alignment",
    Generate = function(difficulty: string)
        local switchCount = (difficulty == "HARD") and 5 or 4
        local sequence = {}
        for i = 1, switchCount do
            table.insert(sequence, i)
        end
        -- Fisher-Yates shuffle sequence
        for i = switchCount, 2, -1 do
            local j = math.random(1, i)
            sequence[i], sequence[j] = sequence[j], sequence[i]
        end
        return {
            Sequence = sequence,
            CurrentStep = 1,
            TotalSwitches = switchCount,
        }
    end,
    CheckSolved = function(puzzleState: table): boolean
        return puzzleState.CurrentStep > puzzleState.TotalSwitches
    end
}

--[[
    Picks an appropriate puzzle type based on the current floor number.
--]]
function PuzzleDefinitions.SelectPuzzleForFloor(floorNumber: number): string
    if floorNumber <= 3 then
        return PuzzleDefinitions.Types.KeycardHunt -- Tutorial floors use intuitive key hunt
    elseif floorNumber <= 10 then
        return (math.random() > 0.5) and PuzzleDefinitions.Types.KeycardHunt or PuzzleDefinitions.Types.SafeCode
    elseif floorNumber <= 20 then
        return (math.random() > 0.5) and PuzzleDefinitions.Types.SafeCode or PuzzleDefinitions.Types.ElectricalRepair
    else
        return PuzzleDefinitions.Types.ElectricalRepair
    end
end

return PuzzleDefinitions
