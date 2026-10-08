local api = require("api")
local Theme = require("aa-perfection/core/theme")
local Settings = require("aa-perfection/core/settings")
local Mover = require("aa-perfection/core/mover")

local LaborHUD = {
    window = nil,
    bar = nil,
    laborText = nil,
    regenText = nil
}

local WIDTH = 180
local HEIGHT = 32

function LaborHUD:Init()
    local x, y = Settings:GetPosition("labor_hud", 20, 20)

    local wnd = api.Interface:CreateEmptyWindow("pui_labor_hud", "UIParent")
    wnd:SetExtent(WIDTH, HEIGHT)
    wnd:AddAnchor("TOPLEFT", "UIParent", x, y)
    wnd:SetUILayer("hud")

    Theme.ApplyBackdrop(wnd, Theme.Colors.BgDark, Theme.Colors.BorderSubtle)

    -- Status Bar
    local bar = W_BAR.CreateStatusBarOfRaidFrame("pui_labor_bar", wnd)
    bar:SetExtent(WIDTH - 12, 12)
    bar:AddAnchor("TOPLEFT", wnd, 6, 6)
    bar:Clickable(false)
    bar.statusBar:SetBarTexture(TEXTURE_PATH.HUD, "background")
    bar.statusBar:SetBarColor(Theme.Colors.LaborOrange[1], Theme.Colors.LaborOrange[2], Theme.Colors.LaborOrange[3], 1)
    bar.statusBar:SetMinMaxValues(0, 5000)
    bar.statusBar:SetValue(5000)
    self.bar = bar

    -- Labor Count Text
    local txt = bar:CreateChildWidget("label", "laborText", 0, true)
    txt:SetExtent(WIDTH - 20, 12)
    txt:AddAnchor("CENTER", bar, 0, 0)
    Theme.StyleLabel(txt, 9, ALIGN.CENTER, Theme.Colors.TextPrimary, true)
    self.laborText = txt

    -- Subtitle / Regen timer
    local sub = wnd:CreateChildWidget("label", "regenText", 0, true)
    sub:SetExtent(WIDTH - 12, 10)
    sub:AddAnchor("TOPLEFT", bar, "BOTTOMLEFT", 0, 2)
    Theme.StyleLabel(sub, 8, ALIGN.LEFT, Theme.Colors.TextSecondary, true)
    sub:SetText("LABOR POWER")
    self.regenText = sub

    Mover:RegisterFrame("labor_hud", wnd, "Labor HUD")
    self.window = wnd
    wnd:Show(true)
end

function LaborHUD:Update()
    -- Query player game points or labor
    local labor = 5000
    if api.Player ~= nil and api.Player.GetGamePoints ~= nil then
        local pts = api.Player:GetGamePoints()
        if pts ~= nil then labor = pts end
    end

    self.bar.statusBar:SetValue(labor)
    self.laborText:SetText(string.format("%d / 5000 LP", labor))
end

return LaborHUD
