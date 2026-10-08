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
        if wnd.bg ~= nil then
            wnd.bg:SetColor(0.05, 0.06, 0.08, 0.82)
        else
            Theme.ApplyBackdrop(wnd, Theme.Colors.BgDark, Theme.Colors.BorderSubtle)
        end

        -- Clean up default decorative frame ornaments if present
        if wnd.frameBg ~= nil then wnd.frameBg:Show(false) end
        if wnd.leftBg ~= nil then wnd.leftBg:Show(false) end
        if wnd.rightBg ~= nil then wnd.rightBg:Show(false) end
    end)
end

return ChatStyler
