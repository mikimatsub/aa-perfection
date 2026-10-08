local api = require("api")
local Theme = require("aa-perfection/core/theme")
local Guard = require("aa-perfection/core/api_guard")
local Settings = require("aa-perfection/core/settings")
local Mover = require("aa-perfection/core/mover")

local ComboHUD = {
    window = nil,
    charges = {}
}

function ComboHUD:Init()
    local x, y = Settings:GetPosition("combo_hud", 650, 500)

    local wnd = api.Interface:CreateEmptyWindow("pui_combo_hud", "UIParent")
    wnd:SetExtent(120, 24)
    wnd:AddAnchor("TOPLEFT", "UIParent", x, y)
    wnd:SetUILayer("hud")

    -- 4 Abyssal Charge Orbs
    for i = 1, 4 do
        local orb = wnd:CreateChildWidget("emptywidget", "orb_" .. i, 0, true)
        orb:SetExtent(20, 16)
        orb:AddAnchor("LEFT", wnd, (i - 1) * 28 + 6, 0)
        
        local bg = orb:CreateNinePartDrawable(TEXTURE_PATH.HUD, "background")
        bg:SetCoords(301, 120, 150, 19)
        bg:SetColor(0.2, 0.2, 0.3, 0.6)
        bg:AddAnchor("TOPLEFT", orb, 0, 0)
        bg:AddAnchor("BOTTOMRIGHT", orb, 0, 0)
        orb.bg = bg

        self.charges[i] = orb
    end

    Mover:RegisterFrame("combo_hud", wnd, "Abyssal / Combo HUD")
    self.window = wnd
    wnd:Show(false)
end

function ComboHUD:Update()
    local rsc = Guard.GetHighAbilityRscInfo()
    local curCharges = 0
    if type(rsc) == "table" then
        curCharges = tonumber(rsc.charge or rsc.current or rsc.count or 0) or 0
    end

    if curCharges <= 0 then
        if self.window:IsVisible() then
            self.window:Show(false)
        end
        return
    end

    self.window:Show(true)
    for i = 1, 4 do
        local orb = self.charges[i]
        if i <= curCharges then
            orb.bg:SetColor(Theme.Colors.HonorPurple[1], Theme.Colors.HonorPurple[2], Theme.Colors.HonorPurple[3], 1.0)
        else
            orb.bg:SetColor(0.15, 0.17, 0.22, 0.6)
        end
    end
end

return ComboHUD
