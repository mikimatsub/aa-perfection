local api = require("api")
local Theme = require("aa-perfection/core/theme")
local Settings = require("aa-perfection/core/settings")
local Mover = require("aa-perfection/core/mover")

local CastBar = {
    window = nil,
    bar = nil,
    spellIcon = nil,
    spellNameLabel = nil,
    timeLabel = nil,
    isCasting = false,
    duration = 0,
    current = 0,
    spellName = ""
}

local WIDTH = 260
local HEIGHT = 22

function CastBar:Init()
    local x, y = Settings:GetPosition("castbar", 650, 560)

    local wnd = api.Interface:CreateEmptyWindow("pui_castbar", "UIParent")
    wnd:SetExtent(WIDTH, HEIGHT)
    wnd:AddAnchor("TOPLEFT", "UIParent", x, y)
    wnd:SetUILayer("hud")

    Theme.ApplyBackdrop(wnd, Theme.Colors.BgDark, Theme.Colors.BorderSubtle)
    Theme.ApplyBorder(wnd, Theme.Colors.BorderActive)

    -- Status Bar Gauge
    local bar = W_BAR.CreateStatusBarOfRaidFrame("pui_cast_gauge", wnd)
    bar:SetExtent(WIDTH - 28, HEIGHT - 4)
    bar:AddAnchor("TOPLEFT", wnd, 26, 2)
    bar:Clickable(false)
    bar.statusBar:SetBarTexture(TEXTURE_PATH.HUD, "background")
    bar.statusBar:SetBarColor(Theme.Colors.CastBarAmber[1], Theme.Colors.CastBarAmber[2], Theme.Colors.CastBarAmber[3], 1)
    bar.statusBar:SetMinMaxValues(0, 100)
    bar.statusBar:SetValue(0)
    self.bar = bar

    -- Spell Icon Button
    local icon = CreateItemIconButton("pui_cast_icon", wnd)
    icon:SetExtent(20, 20)
    icon:AddAnchor("TOPLEFT", wnd, 2, 1)
    icon:Clickable(false)
    F_SLOT.ApplySlotSkin(icon, icon.back, SLOT_STYLE.DEFAULT)
    self.spellIcon = icon

    -- Spell Name Label
    local nameLabel = wnd:CreateChildWidget("label", "spellName", 0, true)
    nameLabel:SetExtent(150, HEIGHT)
    nameLabel:AddAnchor("LEFT", bar, 6, 0)
    Theme.StyleLabel(nameLabel, 11, ALIGN.LEFT, Theme.Colors.TextPrimary, true)
    self.spellNameLabel = nameLabel

    -- Time Label
    local timeLabel = wnd:CreateChildWidget("label", "timeLabel", 0, true)
    timeLabel:SetExtent(70, HEIGHT)
    timeLabel:AddAnchor("RIGHT", bar, -6, 0)
    Theme.StyleLabel(timeLabel, 10, ALIGN.RIGHT, Theme.Colors.TextSecondary, true)
    self.timeLabel = timeLabel

    Mover:RegisterFrame("castbar", wnd, "Cast Bar")
    self.window = wnd
    wnd:Show(false)
end

function CastBar:StartCast(spellName, durationSec, iconPath)
    self.spellName = spellName or "Casting..."
    self.duration = durationSec or 2.0
    self.current = 0
    self.isCasting = true

    self.spellNameLabel:SetText(self.spellName)
    if iconPath and iconPath ~= "" then
        F_SLOT.SetIconBackGround(self.spellIcon, iconPath)
        self.spellIcon:Show(true)
    else
        self.spellIcon:Show(false)
    end

    self.bar.statusBar:SetMinMaxValues(0, self.duration)
    self.bar.statusBar:SetValue(0)
    self.window:Show(true)
end

function CastBar:StopCast(success)
    self.isCasting = false
    if success then
        self.bar.statusBar:SetBarColor(Theme.Colors.CastSuccessGold[1], Theme.Colors.CastSuccessGold[2], Theme.Colors.CastSuccessGold[3], 1)
    end
    self.window:Show(false)
end

function CastBar:Update(dtMs)
    if not self.isCasting then return end
    self.current = self.current + (dtMs / 1000)
    if self.current >= self.duration then
        self:StopCast(true)
    else
        self.bar.statusBar:SetValue(self.current)
        self.timeLabel:SetText(string.format("%.1f / %.1fs", self.current, self.duration))
    end
end

return CastBar
