local api = require("api")
local Theme = require("aa-perfection/core/theme")
local Guard = require("aa-perfection/core/api_guard")
local Settings = require("aa-perfection/core/settings")
local Mover = require("aa-perfection/core/mover")

local PlayerFrame = {
    window = nil,
    hpBar = nil,
    mpBar = nil,
    nameLabel = nil,
    hpLabel = nil,
    mpLabel = nil,
    levelLabel = nil
}

local WIDTH = 220
local HEIGHT = 54

function PlayerFrame:Init()
    -- Suppress stock player frame
    local stockPlayer = Guard.GetStockContent(UIC.PLAYER_UNITFRAME)
    if stockPlayer ~= nil then
        pcall(function() stockPlayer:Show(false) end)
    end

    local x, y = Settings:GetPosition("player_frame", 450, 620)

    local wnd = api.Interface:CreateEmptyWindow("pui_player_frame", "UIParent")
    wnd:SetExtent(WIDTH, HEIGHT)
    wnd:AddAnchor("TOPLEFT", "UIParent", x, y)
    wnd:SetUILayer("game")

    Theme.ApplyBackdrop(wnd, Theme.Colors.BgDark, Theme.Colors.BorderSubtle)
    Theme.ApplyBorder(wnd, Theme.Colors.BorderActive)

    -- Level & Name
    local lvl = wnd:CreateChildWidget("label", "level", 0, true)
    lvl:SetExtent(28, 16)
    lvl:AddAnchor("TOPLEFT", wnd, 6, 4)
    Theme.StyleLabel(lvl, 11, ALIGN.LEFT, Theme.Colors.TextGold, true)
    self.levelLabel = lvl

    local name = wnd:CreateChildWidget("label", "name", 0, true)
    name:SetExtent(160, 16)
    name:AddAnchor("LEFT", lvl, "RIGHT", 4, 0)
    Theme.StyleLabel(name, 12, ALIGN.LEFT, Theme.Colors.TextPrimary, true)
    self.nameLabel = name

    -- Health Bar
    local hp = W_BAR.CreateStatusBarOfRaidFrame("pui_player_hp", wnd)
    hp:SetExtent(WIDTH - 12, 18)
    hp:AddAnchor("TOPLEFT", wnd, 6, 22)
    hp:Clickable(false)
    hp.statusBar:SetBarTexture(TEXTURE_PATH.HUD, "background")
    hp.statusBar:SetBarColor(Theme.Colors.HealthPlayer[1], Theme.Colors.HealthPlayer[2], Theme.Colors.HealthPlayer[3], 1)
    hp.statusBar:SetMinMaxValues(0, 100)
    hp.statusBar:SetValue(100)
    self.hpBar = hp

    local hpText = hp:CreateChildWidget("label", "hpText", 0, true)
    hpText:SetExtent(WIDTH - 20, 16)
    hpText:AddAnchor("CENTER", hp, 0, 0)
    Theme.StyleLabel(hpText, 10, ALIGN.CENTER, Theme.Colors.TextPrimary, true)
    self.hpLabel = hpText

    -- Mana Bar
    local mp = W_BAR.CreateStatusBarOfRaidFrame("pui_player_mp", wnd)
    mp:SetExtent(WIDTH - 12, 6)
    mp:AddAnchor("TOPLEFT", hp, "BOTTOMLEFT", 0, 2)
    mp:Clickable(false)
    mp.statusBar:SetBarTexture(TEXTURE_PATH.HUD, "background")
    mp.statusBar:SetBarColor(Theme.Colors.ManaPower[1], Theme.Colors.ManaPower[2], Theme.Colors.ManaPower[3], 1)
    mp.statusBar:SetMinMaxValues(0, 100)
    mp.statusBar:SetValue(100)
    self.mpBar = mp

    Mover:RegisterFrame("player_frame", wnd, "Player Frame")
    self.window = wnd
    wnd:Show(true)
end

function PlayerFrame:Update()
    local curHp = Guard.UnitHealth("player")
    local maxHp = Guard.UnitMaxHealth("player")
    local curMp = Guard.UnitMana("player")
    local maxMp = Guard.UnitMaxMana("player")
    local playerName = Guard.UnitName("player")

    self.hpBar.statusBar:SetMinMaxValues(0, maxHp)
    self.hpBar.statusBar:SetValue(curHp)

    self.mpBar.statusBar:SetMinMaxValues(0, maxMp)
    self.mpBar.statusBar:SetValue(curMp)

    local pct = math.floor((curHp / maxHp) * 100)
    self.hpLabel:SetText(string.format("%d / %d (%d%%)", curHp, maxHp, pct))
    self.nameLabel:SetText(playerName)
end

return PlayerFrame
