local api = require("api")
local Theme = require("aa-perfection/core/theme")
local Guard = require("aa-perfection/core/api_guard")
local Settings = require("aa-perfection/core/settings")

local TargetNameplate = {
    window = nil,
    nameLabel = nil,
    distLabel = nil,
    hpBar = nil
}

local WIDTH = 120
local HEIGHT = 24

function TargetNameplate:Init()
    local wnd = api.Interface:CreateEmptyWindow("pui_target_nameplate", "UIParent")
    wnd:SetExtent(WIDTH, HEIGHT)
    wnd:SetUILayer("hud")

    -- Solid sleek obsidian pill with gold/subtle border
    Theme.ApplyBackdrop(wnd, { 0.08, 0.09, 0.12, 0.88 }, Theme.Colors.BorderSubtle)
    Theme.ApplyBorder(wnd, Theme.Colors.BorderActive)

    -- Target Name (Left)
    local nameLbl = wnd:CreateChildWidget("label", "plateName", 0, true)
    nameLbl:SetExtent(72, 14)
    nameLbl:AddAnchor("TOPLEFT", wnd, 6, 2)
    Theme.StyleLabel(nameLbl, 9, ALIGN.LEFT, Theme.Colors.TextPrimary, true)
    nameLbl:SetAutoResize(false)
    self.nameLabel = nameLbl

    -- Distance Badge (Right)
    local distLbl = wnd:CreateChildWidget("label", "plateDist", 0, true)
    distLbl:SetExtent(40, 14)
    distLbl:AddAnchor("TOPRIGHT", wnd, -6, 2)
    Theme.StyleLabel(distLbl, 9, ALIGN.RIGHT, Theme.Colors.TextGold, true)
    self.distLabel = distLbl

    -- Health mini-bar (Slim 3px bar at bottom)
    local hp = W_BAR.CreateStatusBarOfRaidFrame("pui_plate_hp", wnd)
    hp:SetExtent(WIDTH - 12, 3)
    hp:AddAnchor("BOTTOMLEFT", wnd, 6, -3)
    hp:Clickable(false)
    hp.statusBar:SetBarTexture("Textures/Defaults/White.dds", "background")
    hp.statusBar:SetBarColor(Theme.Colors.HealthHostile[1], Theme.Colors.HealthHostile[2], Theme.Colors.HealthHostile[3], 1)
    hp.statusBar:SetMinMaxValues(0, 100)
    hp.statusBar:SetValue(100)
    self.hpBar = hp

    self.window = wnd
    wnd:Show(false)
end

function TargetNameplate:Update()
    if self.window == nil then return end

    if not Settings:IsModuleEnabled("combat_hud") then
        self.window:Show(false)
        return
    end

    local tid = Guard.GetUnitId("target")
    if tid == nil then
        self.window:Show(false)
        return
    end

    local tagX, tagY, tagZ = Guard.UnitScreenNameTagOffset("target")
    local sX, sY, sZ = Guard.UnitScreenPosition("target")

    local posX, posY
    if tagX ~= nil and tagY ~= nil and (tagZ == nil or (tagZ >= 0 and tagZ <= 120)) then
        posX = tagX
        posY = tagY - 26 -- Cleanly above native yellow nametag
    elseif sX ~= nil and sY ~= nil and sZ ~= nil and sZ >= 0 and sZ <= 120 then
        posX = sX
        posY = sY - 68 -- Elevated above head/tag when offset API unavailable
    else
        self.window:Show(false)
        return
    end

    local curHp = Guard.UnitHealth("target")
    local maxHp = Guard.UnitMaxHealth("target")
    if maxHp < 1 then maxHp = 1 end

    local name = Guard.UnitName("target")
    local dist = Guard.UnitDistance("target")
    local isHostile = Guard.UnitIsForceAttack("target")

    self.window:RemoveAllAnchors()
    self.window:AddAnchor("BOTTOM", "UIParent", "TOPLEFT", posX, posY)

    self.nameLabel:SetText(name)

    if dist and dist >= 0 then
        self.distLabel:SetText(string.format("%.1fm", dist))
    else
        self.distLabel:SetText("")
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
