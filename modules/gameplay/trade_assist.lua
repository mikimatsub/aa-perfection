local api = require("api")
local Theme = require("aa-perfection/core/theme")
local Guard = require("aa-perfection/core/api_guard")

local TradeAssist = {
    window = nil,
    label = nil
}

function TradeAssist:Init()
    local wnd = api.Interface:CreateEmptyWindow("pui_trade_assist", "UIParent")
    wnd:SetExtent(180, 26)
    wnd:AddAnchor("TOP", "UIParent", 0, 50)
    wnd:SetUILayer("hud")

    Theme.ApplyBackdrop(wnd, Theme.Colors.BgDark, Theme.Colors.BorderSubtle)
    Theme.ApplyBorder(wnd, Theme.Colors.BorderActive)

    local lbl = wnd:CreateChildWidget("label", "text", 0, true)
    lbl:SetExtent(170, 20)
    lbl:AddAnchor("CENTER", wnd, 0, 0)
    Theme.StyleLabel(lbl, 10, ALIGN.CENTER, Theme.Colors.TextGold, true)
    self.label = lbl

    self.window = wnd
    wnd:Show(false)
end

function TradeAssist:Update()
    if self.window == nil then return end

    -- Check if back slot has an ACTUAL trade pack (not glider, not cloak)
    local hasPack = false
    if api.Equipment ~= nil and EQUIP_SLOT ~= nil and EQUIP_SLOT.BACKPACK ~= nil then
        local tip = Guard.SafePcall(function() return api.Equipment:GetEquippedItemTooltipInfo(EQUIP_SLOT.BACKPACK) end)
        if type(tip) == "table" then
            local name = tostring(tip.name or tip.linkText or ""):lower()
            local cat = tostring(tip.category or ""):lower()
            if name:find("pack") or name:find("specialty") or name:find("cargo") or cat:find("trade") or cat:find("specialty") then
                hasPack = true
            end
        end
    end

    if hasPack then
        local shareRatio = 80
        if api.Store ~= nil and api.Store.GetSellerShareRatio ~= nil then
            shareRatio = Guard.SafePcall(function() return api.Store:GetSellerShareRatio() end, 80)
        end
        self.label:SetText(string.format("TRADE PACK: %d%% PAYOUT", shareRatio))
        self.window:Show(true)
    else
        self.window:Show(false)
    end
end

return TradeAssist
