--[[
    Hotel Hermes - Lobby & Front Desk Manager
    File: ServerScriptService/LobbyManager.lua
    Description: Manages the 5 Robux Check-In purchase pipeline (free for 1st time),
                 MarketplaceService ProcessReceipt callback, 24h daily prize wheel,
                 and OrderedDataStore global leaderboard.
--]]

local MarketplaceService = game:GetService("MarketplaceService")
local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local SharedModules = ReplicatedStorage:WaitForChild("SharedModules")
local Constants = require(SharedModules:WaitForChild("Constants"))
local RemoteDeclarations = require(ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("RemoteDeclarations"))

local DataManager = require(script.Parent:WaitForChild("DataManager"))
local GameManager = require(script.Parent:WaitForChild("GameManager"))

local LobbyManager = {}

-- Leaderboard DataStore
local leaderboardDataStore: OrderedDataStore? = nil
pcall(function()
    leaderboardDataStore = DataStoreService:GetOrderedDataStore(Constants.Data.DataStoreKeyPrefix .. "Leaderboard")
end)

local checkInFunction: RemoteFunction
local wheelSpinFunction: RemoteFunction
local getLeaderboardFunction: RemoteFunction
local uiNotificationEvent: RemoteEvent

-- Cooldown tracker for daily wheel: UserId -> os.time()
local wheelLastSpunMap = {}

--[[
    Handles Check-In Request from Front Desk.
    If first time: Granted for Free!
    If returning: Prompts 5 Robux Developer Product.
--]]
local function handleCheckInRequest(player: Player): (boolean, string)
    local profile = DataManager.GetProfile(player)
    if not profile then
        return false, "Player data not yet ready."
    end

    -- First Time Free Check-In
    if not profile.hasUsedFreeCheckIn then
        profile.hasUsedFreeCheckIn = true
        profile.totalCheckIns = profile.totalCheckIns + 1
        DataManager.SaveProfile(player)

        GameManager.StartRun(player)
        return true, "Welcome to Hotel Hermes. Your first stay is complimentary."
    end

    -- Returning Player: Prompt Developer Product (5 Robux)
    if Constants.Monetization.CheckInProductId > 0 then
        MarketplaceService:PromptProductPurchase(player, Constants.Monetization.CheckInProductId)
        return true, "Prompting front desk registration fee..."
    else
        -- Fallback if Product ID not yet created in Studio: allow testing
        profile.totalCheckIns = profile.totalCheckIns + 1
        DataManager.SaveProfile(player)
        GameManager.StartRun(player)
        return true, "Studio Test Mode: Check-In granted."
    end
end

--[[
    MarketplaceService ProcessReceipt callback.
    Guarantees reliable Developer Product purchase fulfillment.
--]]
local function processReceipt(receiptInfo)
    local player = Players:GetPlayerByUserId(receiptInfo.PlayerId)
    if not player then
        return Enum.ProductPurchaseDecision.NotProcessedYet
    end

    if receiptInfo.ProductId == Constants.Monetization.CheckInProductId then
        local profile = DataManager.GetProfile(player)
        if profile then
            profile.totalCheckIns = profile.totalCheckIns + 1
            DataManager.SaveProfile(player)
        end

        GameManager.StartRun(player)
        return Enum.ProductPurchaseDecision.PurchaseGranted
    end

    return Enum.ProductPurchaseDecision.NotProcessedYet
end

--[[
    Rolls the Daily Room Service Wheel with transparent policy-compliant odds.
--]]
local function handleWheelSpin(player: Player): (boolean, table)
    local now = os.time()
    local lastSpin = wheelLastSpunMap[player.UserId] or 0
    local dayInSeconds = 24 * 3600

    if now - lastSpin < dayInSeconds then
        local remainingSec = dayInSeconds - (now - lastSpin)
        local hoursLeft = math.ceil(remainingSec / 3600)
        return false, { Message = string.format("Room Service wheel available in %d hours.", hoursLeft) }
    end

    -- Server-side RNG roll
    local rand = math.random()
    local accumulated = 0
    local chosenReward = nil

    for _, tier in ipairs(Constants.Monetization.RoomServiceWheelOdds) do
        accumulated = accumulated + tier.Weight
        if rand <= accumulated then
            chosenReward = tier
            break
        end
    end
    chosenReward = chosenReward or Constants.Monetization.RoomServiceWheelOdds[1]

    -- Apply reward to profile
    local profile = DataManager.GetProfile(player)
    if profile then
        if chosenReward.ItemType == "Coins" then
            profile.hotelCoins = profile.hotelCoins + chosenReward.Amount
        elseif chosenReward.ItemType == "Cosmetic" then
            table.insert(profile.inventory.skins, chosenReward.ItemId)
        end
        DataManager.SaveProfile(player)
    end

    wheelLastSpunMap[player.UserId] = now
    uiNotificationEvent:FireClient(player, "Room Service Prize!", chosenReward.DisplayName, "Success")
    return true, chosenReward
end

--[[
    Updates player's highest floor on the Global Leaderboard.
--]]
function LobbyManager.UpdateLeaderboard(player: Player, highestFloor: number)
    if leaderboardDataStore and highestFloor > 0 then
        pcall(function()
            leaderboardDataStore:SetAsync(tostring(player.UserId), highestFloor)
        end)
    end
end

--[[
    Fetches top 50 scores from OrderedDataStore.
--]]
local function handleGetLeaderboard(player: Player): table
    local entries = {}
    if not leaderboardDataStore then return entries end

    pcall(function()
        local pages = leaderboardDataStore:GetSortedAsync(false, 50)
        local currentPage = pages:GetCurrentPage()
        for rank, data in ipairs(currentPage) do
            local userId = tonumber(data.key)
            local score = data.value
            local name = "Guest"
            pcall(function()
                name = Players:GetNameFromUserIdAsync(userId)
            end)
            table.insert(entries, { Rank = rank, Name = name, HighestFloor = score })
        end
    end)

    return entries
end

function LobbyManager.Init()
    checkInFunction = RemoteDeclarations.GetFunction("CheckInRequest")
    wheelSpinFunction = RemoteDeclarations.GetFunction("WheelSpinRequest")
    getLeaderboardFunction = RemoteDeclarations.GetFunction("GetLeaderboardData")
    uiNotificationEvent = RemoteDeclarations.GetEvent("UINotification")

    checkInFunction.OnServerInvoke = handleCheckInRequest
    wheelSpinFunction.OnServerInvoke = handleWheelSpin
    getLeaderboardFunction.OnServerInvoke = handleGetLeaderboard

    MarketplaceService.ProcessReceipt = processReceipt
end

LobbyManager.Init()

return LobbyManager
