local api = require("api")
local Theme = require("aa-perfection/core/theme")
local Guard = require("aa-perfection/core/api_guard")
local Settings = require("aa-perfection/core/settings")
local Mover = require("aa-perfection/core/mover")

local TargetFrame = {
    window = nil,
    hpBar = nil,
    nameLabel = nil,
    infoLabel = nil,
    hpLabel = nil,
    distLabel = nil,
    levelLabel = nil
}

local WIDTH = 224
local HEIGHT = 56

local function formatThousands(n)
    local num = math.floor(tonumber(n) or 0)
    local formatted = tostring(num)
    local k
    while true do
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
        if k == 0 then break end
    end
    return formatted
end

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

    Theme.ApplyBackdrop(wnd, { 0.08, 0.09, 0.12, 0.94 }, Theme.Colors.BorderSubtle)
    Theme.ApplyBorder(wnd, Theme.Colors.BorderActive)

    -- Level Tag
    local lvl = wnd:CreateChildWidget("label", "level", 0, true)
    lvl:SetExtent(24, 16)
    lvl:AddAnchor("TOPLEFT", wnd, 8, 4)
    Theme.StyleLabel(lvl, 11, ALIGN.LEFT, Theme.Colors.TextGold, true)
    self.levelLabel = lvl

    -- Target Name
    local name = wnd:CreateChildWidget("label", "name", 0, true)
    name:SetExtent(130, 16)
    name:AddAnchor("LEFT", lvl, "RIGHT", 4, 0)
    Theme.StyleLabel(name, 12, ALIGN.LEFT, Theme.Colors.TextPrimary, true)
    self.nameLabel = name

    -- Distance (Top Right)
    local dist = wnd:CreateChildWidget("label", "dist", 0, true)
    dist:SetExtent(56, 16)
    dist:AddAnchor("TOPRIGHT", wnd, -8, 4)
    Theme.StyleLabel(dist, 10, ALIGN.RIGHT, Theme.Colors.TextGold, true)
    self.distLabel = dist

    -- Health Bar (Flat solid texture)
    local hp = W_BAR.CreateStatusBarOfRaidFrame("pui_target_hp", wnd)
    hp:SetExtent(WIDTH - 16, 20)
    hp:AddAnchor("TOPLEFT", wnd, 8, 22)
    hp:Clickable(false)
    hp.statusBar:SetBarTexture("Textures/Defaults/White.dds", "background")
    hp.statusBar:SetBarColor(Theme.Colors.HealthHostile[1], Theme.Colors.HealthHostile[2], Theme.Colors.HealthHostile[3], 1)
    hp.statusBar:SetMinMaxValues(0, 100)
    hp.statusBar:SetValue(100)
    self.hpBar = hp

    local hpText = hp:CreateChildWidget("label", "hpText", 0, true)
    hpText:SetExtent(WIDTH - 24, 18)
    hpText:AddAnchor("CENTER", hp, 0, 0)
    Theme.StyleLabel(hpText, 10, ALIGN.CENTER, Theme.Colors.TextPrimary, true)
    self.hpLabel = hpText

    -- Class & GS Subtitle below HP
    local info = wnd:CreateChildWidget("label", "info", 0, true)
    info:SetExtent(WIDTH - 16, 10)
    info:AddAnchor("TOPLEFT", hp, "BOTTOMLEFT", 0, 2)
    Theme.StyleLabel(info, 9, ALIGN.LEFT, Theme.Colors.TextSecondary, true)
    self.infoLabel = info

    Mover:RegisterFrame("target_frame", wnd, "Target Frame")
    self.window = wnd
    wnd:Show(false)
end

function TargetFrame:Update()
    if self.window == nil then return end

    local targetId = Guard.GetUnitId("target")
    if targetId == nil then
        self.window:Show(false)
        return
    end

    local curHp = Guard.UnitHealth("target") or 0
    local maxHp = Guard.UnitMaxHealth("target") or 1
    if maxHp < 1 then maxHp = 1 end

    local name = Guard.UnitName("target") or ""
    local className = Guard.UnitClass("target") or ""
    local gs = Guard.UnitGearScore("target")
    local dist = Guard.UnitDistance("target")
    local level = Guard.UnitLevel("target")
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
    self.hpLabel:SetText(string.format("%s / %s (%d%%)", formatThousands(curHp), formatThousands(maxHp), pct))
    self.nameLabel:SetText(name)

    if self.levelLabel then
        if level and tonumber(level) then
            self.levelLabel:SetText(tostring(level))
            self.levelLabel:Show(true)
        else
            self.levelLabel:SetText("")
            self.levelLabel:Show(false)
        end
    end

    if dist and dist >= 0 then
        self.distLabel:SetText(string.format("%.1fm", dist))
    else
        self.distLabel:SetText("")
    end

    -- Format Class and GearScore line
    local details = {}
    if className ~= "" then table.insert(details, className) end
    if gs and gs > 0 then table.insert(details, string.format("%d GS", gs)) end
    self.infoLabel:SetText(table.concat(details, "  •  "))

    self.window:Show(true)
end

return TargetFrame
