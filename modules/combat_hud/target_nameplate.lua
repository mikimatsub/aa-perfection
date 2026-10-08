local api = require("api")
local Theme = require("aa-perfection/core/theme")
local Guard = require("aa-perfection/core/api_guard")
local Settings = require("aa-perfection/core/settings")

local TargetNameplate = {
    window = nil,
    nameLabel = nil,
    distLabel = nil,
    gsLabel = nil,
    hpBar = nil
}

local WIDTH = 140
local HEIGHT = 32

function TargetNameplate:Init()
    local wnd = api.Interface:CreateEmptyWindow("pui_target_nameplate", "UIParent")
    wnd:SetExtent(WIDTH, HEIGHT)
    wnd:SetUILayer("hud")

    -- Solid obsidian backdrop with sleek border
    Theme.ApplyBackdrop(wnd, { 0.08, 0.09, 0.12, 0.88 }, Theme.Colors.BorderSubtle)
    Theme.ApplyBorder(wnd, Theme.Colors.BorderActive)

    -- Target Name
    local nameLbl = wnd:CreateChildWidget("label", "plateName", 0, true)
    nameLbl:SetExtent(WIDTH - 12, 14)
    nameLbl:AddAnchor("TOPLEFT", wnd, 6, 2)
    Theme.StyleLabel(nameLbl, 10, ALIGN.LEFT, Theme.Colors.TextPrimary, true)
    self.nameLabel = nameLbl

    -- Distance Badge (Top Right)
    local distLbl = wnd:CreateChildWidget("label", "plateDist", 0, true)
    distLbl:SetExtent(50, 14)
    distLbl:AddAnchor("TOPRIGHT", wnd, -6, 2)
    Theme.StyleLabel(distLbl, 10, ALIGN.RIGHT, Theme.Colors.TextGold, true)
    self.distLabel = distLbl

    -- Health mini-bar
    local hp = W_BAR.CreateStatusBarOfRaidFrame("pui_plate_hp", wnd)
    hp:SetExtent(WIDTH - 12, 6)
    hp:AddAnchor("BOTTOMLEFT", wnd, 6, -4)
    hp:Clickable(false)
    hp.statusBar:SetBarTexture("Textures/Defaults/White.dds", "background")
    hp.statusBar:SetBarColor(Theme.Colors.HealthHostile[1], Theme.Colors.HealthHostile[2], Theme.Colors.HealthHostile[3], 1)
    hp.statusBar:SetMinMaxValues(0, 100)
    hp.statusBar:SetValue(100)
    self.hpBar = hp

    -- GearScore Badge (Centered right above health bar)
    local gsLbl = wnd:CreateChildWidget("label", "plateGS", 0, true)
    gsLbl:SetExtent(WIDTH - 12, 10)
    gsLbl:AddAnchor("BOTTOMLEFT", hp, "TOPLEFT", 0, -1)
    Theme.StyleLabel(gsLbl, 8, ALIGN.RIGHT, Theme.Colors.TextSecondary, false)
    self.gsLabel = gsLbl

    self.window = wnd
    wnd:Show(false)
end

function TargetNameplate:Update()
    if self.window == nil then return end

    if not Settings:IsModuleEnabled("combat") then
        self.window:Show(false)
        return
    end

    local tid = Guard.GetUnitId("target")
    if tid == nil then
        self.window:Show(false)
        return
    end

    local sX, sY, sZ = Guard.UnitScreenPosition("target")
    if sX == nil or sY == nil or sZ == nil or sZ < 0 or sZ > 120 then
        self.window:Show(false)
        return
    end

    local curHp = Guard.UnitHealth("target")
    local maxHp = Guard.UnitMaxHealth("target")
    if maxHp < 1 then maxHp = 1 end

    local name = Guard.UnitName("target")
    local dist = Guard.UnitDistance("target")
    local gs = Guard.UnitGearScore("target")
    local isHostile = Guard.UnitIsForceAttack("target")

    -- Anchor directly above target's 3D head position
    self.window:RemoveAllAnchors()
    self.window:AddAnchor("BOTTOM", "UIParent", "TOPLEFT", sX, sY - 42)

    -- Update visuals
    self.nameLabel:SetText(name)

    if dist and dist >= 0 then
        self.distLabel:SetText(string.format("%.1fm", dist))
    else
        self.distLabel:SetText("")
    end

    if gs and gs > 0 then
        self.gsLabel:SetText(string.format("%dgs", gs))
        self.gsLabel:Show(true)
    else
        self.gsLabel:Show(false)
    end

    if isHostile then
        self.hpBar.statusBar:SetBarColor(Theme.Colors.HealthHostile[1], Theme.Colors.HealthHostile[2], Theme.Colors.HealthHostile[3], 1)
    else
        self.hpBar.statusBar:SetBarColor(Theme.Colors.HealthFriendly[1], Theme.Colors.HealthFriendly[2], Theme.Colors.HealthFriendly[3], 1)
    end

    self.hpBar.statusBar:SetMinMaxValues(0, maxHp)
    self.hpBar.statusBar:SetValue(curHp)

    self.window:Show(true)
end

return TargetNameplate
