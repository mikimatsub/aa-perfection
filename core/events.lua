local api = require("api")

local Events = {
    tickers = {},
    listeners = {}
}

-- Normalizes dt from engine (handles seconds vs milliseconds variations)
function Events.NormalizeDt(dt)
    local n = tonumber(dt) or 0
    if n < 0 then return 0 end
    if n > 0 and n < 5 then
        n = n * 1000
    end
    return math.floor(n + 0.5)
end

-- Registers a periodic function (e.g. intervalMs = 50 for 20 FPS updates, 16 for 60 FPS)
function Events:RegisterTicker(id, intervalMs, callback)
    self.tickers[id] = {
        interval = intervalMs or 50,
        accum = 0,
        cb = callback
    }
end

function Events:UnregisterTicker(id)
    self.tickers[id] = nil
end

-- Dispatches tickers on UPDATE event
function Events:OnUpdate(rawDt)
    local dt = Events.NormalizeDt(rawDt)
    for id, ticker in pairs(self.tickers) do
        ticker.accum = ticker.accum + dt
        if ticker.accum >= ticker.interval then
            local elapsed = ticker.accum
            ticker.accum = 0
            local ok, err = pcall(ticker.cb, elapsed)
            if not ok then
                if not ticker.hasErrored then
                    ticker.hasErrored = true
                    if api.Log ~= nil and api.Log.Err ~= nil then
                        api.Log:Err("[Perfection UI] Ticker error in '" .. tostring(id) .. "': " .. tostring(err))
                    end
                end
            else
                ticker.hasErrored = false
            end
        end
    end
end

-- Safely subscribes to engine global events
function Events:Subscribe(eventName, callback)
    if api.On == nil then return end
    local wrapped = function(...)
        local ok, err = pcall(callback, ...)
        if not ok and api.Log ~= nil and api.Log.Err ~= nil then
            api.Log:Err("[Perfection UI] Event error in '" .. tostring(eventName) .. "': " .. tostring(err))
        end
    end
    api.On(eventName, wrapped)
    table.insert(self.listeners, { event = eventName, cb = wrapped })
end

function Events:ClearAll()
    self.tickers = {}
    self.listeners = {}
end

return Events
