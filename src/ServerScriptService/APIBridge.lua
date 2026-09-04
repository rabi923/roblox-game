--[[
    Hotel Hermes - External Backend HTTP Bridge
    File: ServerScriptService/APIBridge.lua
    Description: Asynchronous HttpService client communicating with server.py.
                 Features graceful offline fallback, retry queue, and auth token validation.
--]]

local HttpService = game:GetService("HttpService")

local APIBridge = {}

-- Backend URL (Default localhost:5000 in dev, or deployed URL)
local BASE_URL = "http://127.0.0.1:5000"
local API_SECRET = "HERMES_HOTEL_SECRET_TOKEN_2026"

local isHttpEnabled = false
pcall(function()
    -- Check if HttpService is enabled in Studio Game Settings
    HttpService:GetAsync("http://httpbin.org/get")
    isHttpEnabled = true
end)

-- Retry queue for offline resilience
local outboundQueue = {}

--[[
    Internal helper to send non-blocking HTTP requests.
--]]
local function sendRequest(endpoint: string, method: string, payload: table?): (boolean, table?)
    if not isHttpEnabled then
        return false, { error = "HttpService is disabled in Game Settings" }
    end

    local url = BASE_URL .. endpoint
    local headers = {
        ["Content-Type"] = "application/json",
        ["Authorization"] = "Bearer " .. API_SECRET,
    }

    local body = payload and HttpService:JSONEncode(payload) or nil

    local success, response = pcall(function()
        return HttpService:RequestAsync({
            Url = url,
            Method = method,
            Headers = headers,
            Body = body,
        })
    end)

    if success and response.Success then
        local decodeSuccess, decoded = pcall(function()
            return HttpService:JSONDecode(response.Body)
        end)
        return true, decodeSuccess and decoded or response.Body
    else
        -- Queue for retry if it's an analytics or logging payload
        if payload and method == "POST" then
            table.insert(outboundQueue, {
                endpoint = endpoint,
                method = method,
                payload = payload,
                timestamp = os.time(),
            })
        end
        return false, { error = tostring(response) }
    end
end

--[[
    Logs player check-in to external backend.
--]]
function APIBridge.LogCheckIn(userId: number, username: string, isPaid: boolean)
    task.spawn(function()
        sendRequest("/api/player/checkin", "POST", {
            roblox_user_id = userId,
            username = username,
            is_paid = isPaid,
            timestamp = os.time(),
        })
    end)
end

--[[
    Logs run session metrics (floor reached, outcome, loot).
--]]
function APIBridge.LogSession(userId: number, floorReached: number, outcome: string, lootCoins: number, durationSeconds: number)
    task.spawn(function()
        sendRequest("/api/analytics/session", "POST", {
            roblox_user_id = userId,
            floor_reached = floorReached,
            outcome = outcome, -- "CHECKED_OUT" or "ELIMINATED"
            coins_earned = lootCoins,
            duration_seconds = durationSeconds,
        })
    end)
end

--[[
    Background flusher for offline retry queue.
--]]
task.spawn(function()
    while true do
        task.wait(20)
        if #outboundQueue > 0 and isHttpEnabled then
            local item = table.remove(outboundQueue, 1)
            if item and os.time() - item.timestamp < 3600 then
                sendRequest(item.endpoint, item.method, item.payload)
            end
        end
    end
end)

return APIBridge
