local api = require("api")
local Theme = require("aa-perfection/core/theme")
local Guard = require("aa-perfection/core/api_guard")
local Settings = require("aa-perfection/core/settings")
local Mover = require("aa-perfection/core/mover")

local SwapBar = {
    window = nil,
    buttons = {},
    maxButtons = 8
}

local BUTTON_SIZE = 36
local BUTTON_GAP = 4
local PADDING = 6

function SwapBar:Init()
    local x, y = Settings:GetPosition("swap_bar", 650, 780)
    local width = (self.maxButtons * (BUTTON_SIZE + BUTTON_GAP)) + (PADDING * 2) - BUTTON_GAP
    local height = BUTTON_SIZE + (PADDING * 2)

    local wnd = api.Interface:CreateEmptyWindow("pui_swap_bar", "UIParent")
    wnd:SetExtent(width, height)
    wnd:AddAnchor("TOPLEFT", "UIParent", x, y)
    wnd:SetUILayer("game")

    Theme.ApplyBackdrop(wnd, Theme.Colors.BgDark, Theme.Colors.BorderSubtle)

    for i = 1, self.maxButtons do
        local btn = CreateItemIconButton("pui_swap_btn_" .. i, wnd)
        btn:SetExtent(BUTTON_SIZE, BUTTON_SIZE)
        local posX = PADDING + ((i - 1) * (BUTTON_SIZE + BUTTON_GAP))
        btn:AddAnchor("TOPLEFT", wnd, posX, PADDING)
        F_SLOT.ApplySlotSkin(btn, btn.back, SLOT_STYLE.DEFAULT)

        local hotkeyLabel = btn:CreateChildWidget("label", "hotkey", 0, true)
        hotkeyLabel:SetExtent(BUTTON_SIZE, 10)
        hotkeyLabel:AddAnchor("TOPRIGHT", btn, -1, 1)
        hotkeyLabel:SetText(tostring(i))
        Theme.StyleLabel(hotkeyLabel, 9, ALIGN.RIGHT, Theme.Colors.TextGold, true)

        btn:SetHandler("OnClick", function(selfBtn)
            if selfBtn.__slotIndex then
                Guard.EquipBagItem(selfBtn.__slotIndex, false)
            end
        end)

        self.buttons[i] = btn
    end

    Mover:RegisterFrame("swap_bar", wnd, "Quick Swap Bar")
    self.window = wnd
    wnd:Show(false)
    self:Refresh()
end

function SwapBar:Toggle()
    if self.window == nil then return end
    self.window:Show(not self.window:IsVisible())
end

function SwapBar:Refresh()
    -- Scan bag for equip items to populate quick swap bar
    local capacity = Guard.BagCapacity()
    local btnIndex = 1

    for slot = 1, capacity do
        if btnIndex > self.maxButtons then break end
        local info = Guard.GetBagItemInfo(1, slot)
        if type(info) == "table" and (info.equipSlot or info.equip_slot) then
            local btn = self.buttons[btnIndex]
            btn.__slotIndex = slot
            if info.iconPath or info.icon then
                F_SLOT.SetIconBackGround(btn, info.iconPath or info.icon)
            end
            btn:Show(true)
            btnIndex = btnIndex + 1
        end
    end

    -- Hide remaining unused slots
    for i = btnIndex, self.maxButtons do
        self.buttons[i]:Show(false)
    end
end

return SwapBar
