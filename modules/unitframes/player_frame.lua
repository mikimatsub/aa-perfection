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

function PlayerFrame:Init()
    -- Suppress stock player frame to avoid duplicates
    local stockPlayer = Guard.GetStockContent(UIC.PLAYER_UNITFRAME)
    if stockPlayer ~= nil then
        pcall(function() stockPlayer:Show(false) end)
    end

    local x, y = Settings:GetPosition("player_frame", 450, 620)

    local wnd = api.Interface:CreateEmptyWindow("pui_player_frame", "UIParent")
    wnd:SetExtent(WIDTH, HEIGHT)
    wnd:AddAnchor("TOPLEFT", "UIParent", x, y)
    wnd:SetUILayer("game")

    -- Solid Apex Obsidian Backdrop & 1px Hairline Border
    Theme.ApplyBackdrop(wnd, { 0.08, 0.09, 0.12, 0.94 }, Theme.Colors.BorderSubtle)
    Theme.ApplyBorder(wnd, Theme.Colors.BorderActive)

    -- Level Tag
    local lvl = wnd:CreateChildWidget("label", "level", 0, true)
    lvl:SetExtent(24, 16)
    lvl:AddAnchor("TOPLEFT", wnd, 8, 4)
    Theme.StyleLabel(lvl, 11, ALIGN.LEFT, Theme.Colors.TextGold, true)
    self.levelLabel = lvl

    -- Character Name
    local name = wnd:CreateChildWidget("label", "name", 0, true)
    name:SetExtent(170, 16)
    name:AddAnchor("LEFT", lvl, "RIGHT", 4, 0)
    Theme.StyleLabel(name, 12, ALIGN.LEFT, Theme.Colors.TextPrimary, true)
    self.nameLabel = name

    -- Health Bar (Flat solid texture)
    local hp = W_BAR.CreateStatusBarOfRaidFrame("pui_player_hp", wnd)
    hp:SetExtent(WIDTH - 16, 20)
    hp:AddAnchor("TOPLEFT", wnd, 8, 22)
    hp:Clickable(false)
    hp.statusBar:SetBarTexture("Textures/Defaults/White.dds", "background")
    hp.statusBar:SetBarColor(Theme.Colors.HealthPlayer[1], Theme.Colors.HealthPlayer[2], Theme.Colors.HealthPlayer[3], 1)
    hp.statusBar:SetMinMaxValues(0, 100)
    hp.statusBar:SetValue(100)
    self.hpBar = hp

    local hpText = hp:CreateChildWidget("label", "hpText", 0, true)
    hpText:SetExtent(WIDTH - 24, 18)
    hpText:AddAnchor("CENTER", hp, 0, 0)
    Theme.StyleLabel(hpText, 10, ALIGN.CENTER, Theme.Colors.TextPrimary, true)
    self.hpLabel = hpText

    -- Mana Bar (Flat solid texture)
    local mp = W_BAR.CreateStatusBarOfRaidFrame("pui_player_mp", wnd)
    mp:SetExtent(WIDTH - 16, 7)
    mp:AddAnchor("TOPLEFT", hp, "BOTTOMLEFT", 0, 2)
    mp:Clickable(false)
    mp.statusBar:SetBarTexture("Textures/Defaults/White.dds", "background")
    mp.statusBar:SetBarColor(Theme.Colors.ManaPower[1], Theme.Colors.ManaPower[2], Theme.Colors.ManaPower[3], 1)
    mp.statusBar:SetMinMaxValues(0, 100)
    mp.statusBar:SetValue(100)
    self.mpBar = mp

    Mover:RegisterFrame("player_frame", wnd, "Player Frame")
    self.window = wnd
    wnd:Show(true)
end

function PlayerFrame:Update()
    if self.window == nil then return end

    local curHp = Guard.UnitHealth("player") or 100
    local maxHp = Guard.UnitMaxHealth("player") or 100
    local curMp = Guard.UnitMana("player") or 100
    local maxMp = Guard.UnitMaxMana("player") or 100
    local playerName = Guard.UnitName("player") or "Player"
    local level = Guard.UnitLevel("player")

    if maxHp < 1 then maxHp = 1 end
    if maxMp < 1 then maxMp = 1 end

    self.hpBar.statusBar:SetMinMaxValues(0, maxHp)
    self.hpBar.statusBar:SetValue(curHp)

    self.mpBar.statusBar:SetMinMaxValues(0, maxMp)
    self.mpBar.statusBar:SetValue(curMp)

    local pct = math.floor((curHp / maxHp) * 100)
    self.hpLabel:SetText(string.format("%s / %s (%d%%)", formatThousands(curHp), formatThousands(maxHp), pct))
    self.nameLabel:SetText(playerName)

    if self.levelLabel then
        if level and tonumber(level) then
            self.levelLabel:SetText(tostring(level))
            self.levelLabel:Show(true)
        else
            self.levelLabel:SetText("")
            self.levelLabel:Show(false)
        end
    end
end

return PlayerFrame
