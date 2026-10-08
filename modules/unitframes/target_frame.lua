local api = require("api")
local Theme = require("aa-perfection/core/theme")
local Guard = require("aa-perfection/core/api_guard")
local Settings = require("aa-perfection/core/settings")
local Mover = require("aa-perfection/core/mover")

local TargetFrame = {
    window = nil,
    hpBar = nil,
    mpBar = nil,
    nameLabel = nil,
    infoLabel = nil,
    hpLabel = nil,
    distLabel = nil
}

local WIDTH = 220
local HEIGHT = 54

function TargetFrame:Init()
    -- Suppress stock target frame
    local stockTarget = Guard.GetStockContent(UIC.TARGET_UNITFRAME)
    if stockTarget ~= nil then
        pcall(function() stockTarget:Show(false) end)
    end

    local x, y = Settings:GetPosition("target_frame", 850, 620)

    local wnd = api.Interface:CreateEmptyWindow("pui_target_frame", "UIParent")
    wnd:SetExtent(WIDTH, HEIGHT)
    wnd:AddAnchor("TOPLEFT", "UIParent", x, y)
    wnd:SetUILayer("game")

    Theme.ApplyBackdrop(wnd, Theme.Colors.BgDark, Theme.Colors.BorderSubtle)
    Theme.ApplyBorder(wnd, Theme.Colors.BorderActive)

    -- Name
    local name = wnd:CreateChildWidget("label", "name", 0, true)
    name:SetExtent(130, 16)
    name:AddAnchor("TOPLEFT", wnd, 6, 4)
    Theme.StyleLabel(name, 12, ALIGN.LEFT, Theme.Colors.TextPrimary, true)
    self.nameLabel = name

    -- Distance & Class / GS
    local dist = wnd:CreateChildWidget("label", "dist", 0, true)
    dist:SetExtent(70, 16)
    dist:AddAnchor("TOPRIGHT", wnd, -6, 4)
    Theme.StyleLabel(dist, 10, ALIGN.RIGHT, Theme.Colors.TextGold, true)
    self.distLabel = dist

    -- Health Bar
    local hp = W_BAR.CreateStatusBarOfRaidFrame("pui_target_hp", wnd)
    hp:SetExtent(WIDTH - 12, 18)
    hp:AddAnchor("TOPLEFT", wnd, 6, 22)
    hp:Clickable(false)
    hp.statusBar:SetBarTexture(TEXTURE_PATH.HUD, "background")
    hp.statusBar:SetBarColor(Theme.Colors.HealthHostile[1], Theme.Colors.HealthHostile[2], Theme.Colors.HealthHostile[3], 1)
    hp.statusBar:SetMinMaxValues(0, 100)
    hp.statusBar:SetValue(100)
    self.hpBar = hp

    local hpText = hp:CreateChildWidget("label", "hpText", 0, true)
    hpText:SetExtent(WIDTH - 20, 16)
    hpText:AddAnchor("CENTER", hp, 0, 0)
    Theme.StyleLabel(hpText, 10, ALIGN.CENTER, Theme.Colors.TextPrimary, true)
    self.hpLabel = hpText

    -- Class & GS Subtitle below HP
    local info = wnd:CreateChildWidget("label", "info", 0, true)
    info:SetExtent(WIDTH - 12, 12)
    info:AddAnchor("TOPLEFT", hp, "BOTTOMLEFT", 0, 2)
    Theme.StyleLabel(info, 9, ALIGN.LEFT, Theme.Colors.TextSecondary, true)
    self.infoLabel = info

    Mover:RegisterFrame("target_frame", wnd, "Target Frame")
    self.window = wnd
    wnd:Show(false)
end

function TargetFrame:Update()
    local targetId = Guard.GetUnitId("target")
    if targetId == nil then
        self.window:Show(false)
        return
    end

    self.window:Show(true)
    local curHp = Guard.UnitHealth("target")
    local maxHp = Guard.UnitMaxHealth("target")
    local name = Guard.UnitName("target")
    local className = Guard.UnitClass("target")
    local gs = Guard.UnitGearScore("target")
    local dist = Guard.UnitDistance("target")
    local isHostile = Guard.UnitIsForceAttack("target")

    -- Reactive Color: Red for Hostile, Cyan for Friendly
    if isHostile then
        self.hpBar.statusBar:SetBarColor(Theme.Colors.HealthHostile[1], Theme.Colors.HealthHostile[2], Theme.Colors.HealthHostile[3], 1)
    else
        self.hpBar.statusBar:SetBarColor(Theme.Colors.HealthFriendly[1], Theme.Colors.HealthFriendly[2], Theme.Colors.HealthFriendly[3], 1)
    end

    self.hpBar.statusBar:SetMinMaxValues(0, maxHp)
    self.hpBar.statusBar:SetValue(curHp)

    local pct = math.floor((curHp / maxHp) * 100)
    self.hpLabel:SetText(string.format("%d / %d (%d%%)", curHp, maxHp, pct))
    self.nameLabel:SetText(name)

    if dist then
        self.distLabel:SetText(string.format("%.1fm", dist))
    else
        self.distLabel:SetText("")
    end

    local gsStr = gs > 0 and (tostring(gs) .. " GS") or ""
    local classStr = className ~= "" and className or "Target"
    self.infoLabel:SetText(classStr .. (gsStr ~= "" and (" | " .. gsStr) or ""))
end

return TargetFrame
