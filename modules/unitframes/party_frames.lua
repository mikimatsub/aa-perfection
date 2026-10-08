local api = require("api")
local Theme = require("aa-perfection/core/theme")
local Guard = require("aa-perfection/core/api_guard")
local Settings = require("aa-perfection/core/settings")
local Mover = require("aa-perfection/core/mover")

local PartyFrames = {
    window = nil,
    members = {},
    maxMembers = 5,
    petFrame = nil
}

local FRAME_WIDTH = 160
local FRAME_HEIGHT = 38
local GAP_Y = 6
local PADDING = 6

function PartyFrames:Init()
    local x, y = Settings:GetPosition("party_frames", 30, 240)
    local totalH = (self.maxMembers * (FRAME_HEIGHT + GAP_Y)) + (PADDING * 2) - GAP_Y

    local wnd = api.Interface:CreateEmptyWindow("pui_party_frames", "UIParent")
    wnd:SetExtent(FRAME_WIDTH + (PADDING * 2), totalH)
    wnd:AddAnchor("TOPLEFT", "UIParent", x, y)
    wnd:SetUILayer("game")

    Theme.ApplyBackdrop(wnd, Theme.Colors.BgDark, Theme.Colors.BorderSubtle)

    for i = 1, self.maxMembers do
        local posY = PADDING + ((i - 1) * (FRAME_HEIGHT + GAP_Y))
        local row = wnd:CreateChildWidget("emptywidget", "party_member_" .. i, 0, true)
        row:SetExtent(FRAME_WIDTH, FRAME_HEIGHT)
        row:AddAnchor("TOPLEFT", wnd, PADDING, posY)

        local name = row:CreateChildWidget("label", "name", 0, true)
        name:SetExtent(FRAME_WIDTH - 40, 14)
        name:AddAnchor("TOPLEFT", row, 2, 2)
        Theme.StyleLabel(name, 10, ALIGN.LEFT, Theme.Colors.TextPrimary, true)

        local dist = row:CreateChildWidget("label", "dist", 0, true)
        dist:SetExtent(36, 14)
        dist:AddAnchor("TOPRIGHT", row, -2, 2)
        Theme.StyleLabel(dist, 9, ALIGN.RIGHT, Theme.Colors.TextGold, true)

        local hp = W_BAR.CreateStatusBarOfRaidFrame("pui_party_hp_" .. i, row)
        hp:SetExtent(FRAME_WIDTH, 14)
        hp:AddAnchor("TOPLEFT", row, 0, 16)
        hp:Clickable(false)
        hp.statusBar:SetBarTexture("Textures/Defaults/White.dds", "background")
        hp.statusBar:SetBarColor(Theme.Colors.HealthFriendly[1], Theme.Colors.HealthFriendly[2], Theme.Colors.HealthFriendly[3], 1)
        hp.statusBar:SetMinMaxValues(0, 100)
        hp.statusBar:SetValue(100)

        local mp = W_BAR.CreateStatusBarOfRaidFrame("pui_party_mp_" .. i, row)
        mp:SetExtent(FRAME_WIDTH, 4)
        mp:AddAnchor("TOPLEFT", hp, "BOTTOMLEFT", 0, 2)
        mp:Clickable(false)
        mp.statusBar:SetBarTexture("Textures/Defaults/White.dds", "background")
        mp.statusBar:SetBarColor(Theme.Colors.ManaPower[1], Theme.Colors.ManaPower[2], Theme.Colors.ManaPower[3], 1)
        mp.statusBar:SetMinMaxValues(0, 100)
        mp.statusBar:SetValue(100)

        self.members[i] = {
            widget = row,
            name = name,
            dist = dist,
            hpBar = hp,
            mpBar = mp
        }
        row:Show(false)
    end

    Mover:RegisterFrame("party_frames", wnd, "Party Frames (5-Man)")
    self.window = wnd
    wnd:Show(false)
end

function PartyFrames:Update()
    local isParty = false
    local isRaid = false
    if api.Team ~= nil then
        if api.Team.IsPartyTeam ~= nil then isParty = Guard.SafePcall(function() return api.Team:IsPartyTeam() end, false) end
        if api.Team.IsPartyRaid ~= nil then isRaid = Guard.SafePcall(function() return api.Team:IsPartyRaid() end, false) end
    end

    -- If in a raid, raid frames take precedence
    if not isParty or isRaid then
        self.window:Show(false)
        return
    end

    self.window:Show(true)
    for i = 1, self.maxMembers do
        local unit = "team" .. i
        local unitId = Guard.GetUnitId(unit)
        local member = self.members[i]

        if unitId ~= nil then
            member.widget:Show(true)
            local name = Guard.UnitName(unit)
            local curHp = Guard.UnitHealth(unit)
            local maxHp = Guard.UnitMaxHealth(unit)
            local curMp = Guard.UnitMana(unit)
            local maxMp = Guard.UnitMaxMana(unit)
            local dist = Guard.UnitDistance(unit)

            member.hpBar.statusBar:SetMinMaxValues(0, maxHp)
            member.hpBar.statusBar:SetValue(curHp)

            member.mpBar.statusBar:SetMinMaxValues(0, maxMp)
            member.mpBar.statusBar:SetValue(curMp)

            member.name:SetText(name ~= "" and name or ("Party " .. i))
            if dist then
                member.dist:SetText(string.format("%.0fm", dist))
            else
                member.dist:SetText("")
            end
        else
            member.widget:Show(false)
        end
    end
end

return PartyFrames
