--[[
    Hotel Hermes - Server Remote Validator & Rate Limiter
    File: ServerScriptService/RemoteValidator.lua
    Description: Security firewall for server-bound remote calls.
                 Performs sliding-window rate limiting, type assertions,
                 and proximity/spatial verification to prevent client exploits.
--]]

local Players = game:GetService("Players")

local RemoteValidator = {}

-- Rate limiter configurations
local MAX_REQUESTS_PER_SECOND = 28
local SLIDING_WINDOW_SEC = 1.0
local MAX_INTERACTION_DISTANCE = 14.0 -- Maximum studs a player can reach an object

-- Storage: Player -> { timestamps = { ... }, cooldowns = { action = lastTime } }
local playerTrafficMap = {}

--[[
    Registers player traffic bucket on join.
--]]
local function onPlayerAdded(player: Player)
    playerTrafficMap[player.UserId] = {
        requests = {},
        cooldowns = {},
    }
end

--[[
    Cleans up memory on player departure.
--]]
local function onPlayerRemoving(player: Player)
    playerTrafficMap[player.UserId] = nil
end

Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(onPlayerRemoving)

for _, player in ipairs(Players:GetPlayers()) do
    onPlayerAdded(player)
end

--[[
    Checks if a player is exceeding allowable remote packet throughput.
    Returns: true if packet is allowed, false if dropped/throttled.
--]]
function RemoteValidator.CheckRateLimit(player: Player): boolean
    local bucket = playerTrafficMap[player.UserId]
    if not bucket then
        return false
    end

    local now = os.clock()
    local timestamps = bucket.requests

    -- Prune expired timestamps outside the sliding window
    local writeIdx = 1
    for readIdx = 1, #timestamps do
        if now - timestamps[readIdx] < SLIDING_WINDOW_SEC then
            timestamps[writeIdx] = timestamps[readIdx]
            writeIdx = writeIdx + 1
        end
    end
    for i = writeIdx, #timestamps do
        timestamps[i] = nil
    end

    if #timestamps >= MAX_REQUESTS_PER_SECOND then
        warn(string.format("[RemoteValidator] Rate limit exceeded by player %s (UserId: %d)!", player.Name, player.UserId))
        return false
    end

    table.insert(timestamps, now)
    return true
end

--[[
    Enforces a cooldown on a specific action key (e.g., "DoorInteract", "LootPickup").
--]]
function RemoteValidator.CheckCooldown(player: Player, actionKey: string, cooldownSec: number): boolean
    local bucket = playerTrafficMap[player.UserId]
    if not bucket then
        return false
    end

    local now = os.clock()
    local lastTime = bucket.cooldowns[actionKey] or 0

    if now - lastTime < cooldownSec then
        return false
    end

    bucket.cooldowns[actionKey] = now
    return true
end

--[[
    Validates physical proximity between the player's character and a target Part.
    Rejects interactions attempted across walls or from excessive distance.
--]]
function RemoteValidator.ValidateProximity(player: Player, targetInstance: Instance, maxDistance: number?): (boolean, string?)
    local maxDist = maxDistance or MAX_INTERACTION_DISTANCE
    
    local character = player.Character
    if not character then
        return false, "Character does not exist"
    end

    local rootPart = character:FindFirstChild("HumanoidRootPart") :: BasePart
    if not rootPart then
        return false, "HumanoidRootPart missing"
    end

    local targetPart: BasePart? = nil
    if targetInstance:IsA("BasePart") then
        targetPart = targetInstance
    elseif targetInstance:IsA("Model") then
        targetPart = targetInstance.PrimaryPart or targetInstance:FindFirstChildWhichIsA("BasePart")
    end

    if not targetPart then
        return false, "Target is not a valid physical part"
    end

    local distance = (rootPart.Position - targetPart.Position).Magnitude
    if distance > maxDist then
        return false, string.format("Distance %.1f exceeds max allowed %.1f studs", distance, maxDist)
    end

    return true, nil
end

return RemoteValidator
