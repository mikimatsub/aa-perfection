local api = require("api")
local Theme = require("aa-perfection/core/theme")
local Guard = require("aa-perfection/core/api_guard")
local Settings = require("aa-perfection/core/settings")

local BagView = {
    skinned = false
}

function BagView:Init()
    -- Skin the native ArcheAge bag window
    if UIC ~= nil and UIC.BAG ~= nil then
        local bagWnd = Guard.GetStockContent(UIC.BAG)
        if bagWnd ~= nil then
            self:SkinNativeBag(bagWnd)
        end
    end
end

function BagView:SkinNativeBag(bagWnd)
    if bagWnd == nil or self.skinned then return end

    pcall(function()
        -- Apply solid Obsidian background and crisp 1px border
        Theme.ApplyBackdrop(bagWnd, Theme.Colors.BgDark, Theme.Colors.BorderSubtle)
        Theme.ApplyBorder(bagWnd, Theme.Colors.BorderActive)

        -- Clean up default decorative frame ornaments if present
        if bagWnd.frameBg ~= nil and bagWnd.frameBg.Show ~= nil then bagWnd.frameBg:Show(false) end
        if bagWnd.leftBg ~= nil and bagWnd.leftBg.Show ~= nil then bagWnd.leftBg:Show(false) end
        if bagWnd.rightBg ~= nil and bagWnd.rightBg.Show ~= nil then bagWnd.rightBg:Show(false) end

        -- Style title if present
        if bagWnd.title ~= nil and bagWnd.title.style ~= nil then
            Theme.StyleLabel(bagWnd.title, 13, ALIGN.LEFT, Theme.Colors.TextGold, true)
        end

        self.skinned = true
    end)
end

function BagView:Toggle()
    if UIC ~= nil and UIC.BAG ~= nil then
        local bagWnd = Guard.GetStockContent(UIC.BAG)
        if bagWnd ~= nil then
            local isVisible = bagWnd:IsVisible()
            Guard.ShowStockContent(UIC.BAG, not isVisible)
        end
    end
end

return BagView
