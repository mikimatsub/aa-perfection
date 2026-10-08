local api = require("api")
local Theme = require("aa-perfection/core/theme")
local Guard = require("aa-perfection/core/api_guard")
local Settings = require("aa-perfection/core/settings")
local Mover = require("aa-perfection/core/mover")

local SecondaryFrames = {
    tot = {
        window = nil,
        hpBar = nil,
        nameLabel = nil,
        hpLabel = nil
    },
    focus = {
        window = nil,
        hpBar = nil,
        nameLabel = nil,
        infoLabel = nil,
        distLabel = nil
    }
}

-- ============================================================================
-- Target of Target Frame
-- ============================================================================

local function initToT()
    local x, y = Settings:GetPosition("tot_frame", 1080, 620)
    local width, height = 130, 36

    local wnd = api.Interface:CreateEmptyWindow("pui_tot_frame", "UIParent")
    wnd:SetExtent(width, height)
    wnd:AddAnchor("TOPLEFT", "UIParent", x, y)
    wnd:SetUILayer("game")

    Theme.ApplyBackdrop(wnd, Theme.Colors.BgDark, Theme.Colors.BorderSubtle)
    Theme.ApplyBorder(wnd, Theme.Colors.BorderActive)

    local name = wnd:CreateChildWidget("label", "name", 0, true)
    name:SetExtent(width - 12, 14)
    name:AddAnchor("TOPLEFT", wnd, 6, 3)
    Theme.StyleLabel(name, 10, ALIGN.LEFT, Theme.Colors.TextPrimary, true)
    SecondaryFrames.tot.nameLabel = name

    local hp = W_BAR.CreateStatusBarOfRaidFrame("pui_tot_hp", wnd)
    hp:SetExtent(width - 12, 12)
    hp:AddAnchor("TOPLEFT", wnd, 6, 18)
    hp:Clickable(false)
    hp.statusBar:SetBarTexture(TEXTURE_PATH.HUD, "background")
    hp.statusBar:SetBarColor(Theme.Colors.HealthHostile[1], Theme.Colors.HealthHostile[2], Theme.Colors.HealthHostile[3], 1)
    hp.statusBar:SetMinMaxValues(0, 100)
    hp.statusBar:SetValue(100)
    SecondaryFrames.tot.hpBar = hp

    local hpText = hp:CreateChildWidget("label", "hpText", 0, true)
    hpText:SetExtent(width - 16, 12)
    hpText:AddAnchor("CENTER", hp, 0, 0)
    Theme.StyleLabel(hpText, 9, ALIGN.CENTER, Theme.Colors.TextPrimary, true)
    SecondaryFrames.tot.hpLabel = hpText

    Mover:RegisterFrame("tot_frame", wnd, "Target of Target")
    SecondaryFrames.tot.window = wnd
    wnd:Show(false)
end

-- ============================================================================
-- Focus / Watch Target Frame
-- ============================================================================

local function initFocus()
    local x, y = Settings:GetPosition("focus_frame", 850, 540)
    local width, height = 180, 42

    local wnd = api.Interface:CreateEmptyWindow("pui_focus_frame", "UIParent")
    wnd:SetExtent(width, height)
    wnd:AddAnchor("TOPLEFT", "UIParent", x, y)
    wnd:SetUILayer("game")

    Theme.ApplyBackdrop(wnd, Theme.Colors.BgDark, Theme.Colors.BorderSubtle)
    Theme.ApplyBorder(wnd, Theme.Colors.BorderActive)

    local name = wnd:CreateChildWidget("label", "name", 0, true)
    name:SetExtent(110, 14)
    name:AddAnchor("TOPLEFT", wnd, 6, 4)
    Theme.StyleLabel(name, 11, ALIGN.LEFT, Theme.Colors.TextPrimary, true)
    SecondaryFrames.focus.nameLabel = name

    local dist = wnd:CreateChildWidget("label", "dist", 0, true)
    dist:SetExtent(50, 14)
    dist:AddAnchor("TOPRIGHT", wnd, -6, 4)
    Theme.StyleLabel(dist, 9, ALIGN.RIGHT, Theme.Colors.TextGold, true)
    SecondaryFrames.focus.distLabel = dist

    local hp = W_BAR.CreateStatusBarOfRaidFrame("pui_focus_hp", wnd)
    hp:SetExtent(width - 12, 16)
    hp:AddAnchor("TOPLEFT", wnd, 6, 20)
    hp:Clickable(false)
    hp.statusBar:SetBarTexture(TEXTURE_PATH.HUD, "background")
    hp.statusBar:SetBarColor(Theme.Colors.HealthHostile[1], Theme.Colors.HealthHostile[2], Theme.Colors.HealthHostile[3], 1)
    hp.statusBar:SetMinMaxValues(0, 100)
    hp.statusBar:SetValue(100)
    SecondaryFrames.focus.hpBar = hp

    local hpText = hp:CreateChildWidget("label", "hpText", 0, true)
    hpText:SetExtent(width - 16, 14)
    hpText:AddAnchor("CENTER", hp, 0, 0)
    Theme.StyleLabel(hpText, 9, ALIGN.CENTER, Theme.Colors.TextPrimary, true)
    SecondaryFrames.focus.hpLabel = hpText

    Mover:RegisterFrame("focus_frame", wnd, "Focus / Watch Target")
    SecondaryFrames.focus.window = wnd
    wnd:Show(false)
end

function SecondaryFrames:Init()
    -- Suppress stock secondary frames
    local stockTot = Guard.GetStockContent(UIC.TARGET_OF_TARGET_FRAME)
    if stockTot ~= nil then pcall(function() stockTot:Show(false) end) end

    local stockWatch = Guard.GetStockContent(UIC.WATCH_TARGET_FRAME)
    if stockWatch ~= nil then pcall(function() stockWatch:Show(false) end) end

    initToT()
    initFocus()
end

function SecondaryFrames:Update()
    -- Update Target of Target
    local totId = Guard.GetUnitId("targettarget")
    if totId ~= nil then
        self.tot.window:Show(true)
        local curHp = Guard.UnitHealth("targettarget")
        local maxHp = Guard.UnitMaxHealth("targettarget")
        local name = Guard.UnitName("targettarget")
        local isHostile = Guard.UnitIsForceAttack("targettarget")

        if isHostile then
            self.tot.hpBar.statusBar:SetBarColor(Theme.Colors.HealthHostile[1], Theme.Colors.HealthHostile[2], Theme.Colors.HealthHostile[3], 1)
        else
            self.tot.hpBar.statusBar:SetBarColor(Theme.Colors.HealthFriendly[1], Theme.Colors.HealthFriendly[2], Theme.Colors.HealthFriendly[3], 1)
        end

        self.tot.hpBar.statusBar:SetMinMaxValues(0, maxHp)
        self.tot.hpBar.statusBar:SetValue(curHp)

        local pct = math.floor((curHp / maxHp) * 100)
        self.tot.nameLabel:SetText(name ~= "" and name or "Target's Target")
        self.tot.hpLabel:SetText(string.format("%d%%", pct))
    else
        self.tot.window:Show(false)
    end

    -- Update Watch / Focus Target
    local focusId = Guard.GetUnitId("watchtarget")
    if focusId ~= nil then
        self.focus.window:Show(true)
        local curHp = Guard.UnitHealth("watchtarget")
        local maxHp = Guard.UnitMaxHealth("watchtarget")
        local name = Guard.UnitName("watchtarget")
        local dist = Guard.UnitDistance("watchtarget")
        local isHostile = Guard.UnitIsForceAttack("watchtarget")

        if isHostile then
            self.focus.hpBar.statusBar:SetBarColor(Theme.Colors.HealthHostile[1], Theme.Colors.HealthHostile[2], Theme.Colors.HealthHostile[3], 1)
        else
            self.focus.hpBar.statusBar:SetBarColor(Theme.Colors.HealthFriendly[1], Theme.Colors.HealthFriendly[2], Theme.Colors.HealthFriendly[3], 1)
        end

        self.focus.hpBar.statusBar:SetMinMaxValues(0, maxHp)
        self.focus.hpBar.statusBar:SetValue(curHp)

        local pct = math.floor((curHp / maxHp) * 100)
        self.focus.nameLabel:SetText(name ~= "" and name or "Focus Target")
        self.focus.hpLabel:SetText(string.format("%d / %d (%d%%)", curHp, maxHp, pct))

        if dist then
            self.focus.distLabel:SetText(string.format("%.1fm", dist))
        else
            self.focus.distLabel:SetText("")
        end
    else
        self.focus.window:Show(false)
    end
end

return SecondaryFrames
