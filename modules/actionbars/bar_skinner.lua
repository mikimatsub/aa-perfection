local api = require("api")
local Theme = require("aa-perfection/core/theme")
local Guard = require("aa-perfection/core/api_guard")

local BarSkinner = {}

function BarSkinner:Init()
    -- Look for Bubble Action Bar if available in stock UIC
    if UIC ~= nil and UIC.BUBBLE_ACTION_BAR ~= nil then
        local bubbleBar = Guard.GetStockContent(UIC.BUBBLE_ACTION_BAR)
        if bubbleBar ~= nil then
            self:SkinFrame(bubbleBar)
        end
    end
end

function BarSkinner:SkinFrame(frame)
    if frame == nil then return end
    pcall(function()
        if frame.bg ~= nil then
            frame.bg:SetColor(0.05, 0.06, 0.08, 0.85)
        else
            Theme.ApplyBackdrop(frame, Theme.Colors.BgDark, Theme.Colors.BorderSubtle)
        end
    end)
end

return BarSkinner
