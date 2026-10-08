local api = require("api")
local Theme = require("aa-perfection/core/theme")

local ChatStyler = {}

function ChatStyler:Init()
    -- chatTabWindow is the global engine table containing active chat tab windows
    if type(chatTabWindow) ~= "table" then return end

    for index, wnd in pairs(chatTabWindow) do
        if type(wnd) == "table" then
            self:SkinChatWindow(wnd)
        end
    end
end

function ChatStyler:SkinChatWindow(wnd)
    if wnd == nil then return end

    pcall(function()
        if wnd.bg ~= nil and wnd.bg.SetColor ~= nil then
            wnd.bg:SetColor(0.06, 0.07, 0.10, 0.80)
        end
    end)
end

return ChatStyler
