local api = require("api")

local Logger = {
    prefix = "|cFFE2B342[Perfection UI]|r "
}

function Logger:Info(msg)
    if api.Log ~= nil and api.Log.Info ~= nil then
        api.Log:Info(self.prefix .. tostring(msg))
    end
end

function Logger:Err(msg)
    if api.Log ~= nil and api.Log.Err ~= nil then
        api.Log:Err(self.prefix .. "|cFFEF4444ERROR:|r " .. tostring(msg))
    end
end

function Logger:Try(label, fn, ...)
    if type(fn) ~= "function" then return nil end
    local args = { ... }
    local ok, res = pcall(function() return fn(unpack(args)) end)
    if not ok then
        self:Err(tostring(label) .. ": " .. tostring(res))
        return nil
    end
    return res
end

return Logger
