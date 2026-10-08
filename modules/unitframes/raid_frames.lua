local api = require("api")
local Theme = require("aa-perfection/core/theme")
local Guard = require("aa-perfection/core/api_guard")
local Settings = require("aa-perfection/core/settings")
local Mover = require("aa-perfection/core/mover")

local RaidFrames = {
    window = nil,
    cells = {},
    maxMembers = 50,
    columns = 5,
    rowsPerCol = 10,
    isActive = false
}

local CELL_WIDTH = 84
local CELL_HEIGHT = 26
local CELL_GAP_X = 4
local CELL_GAP_Y = 3
local PADDING = 6

-- Priority debuff watchlist for raid frames
local WATCH_DEBUFF_IDS = {
    [18352] = true, -- Abyssal Petrify
    [3783]  = true, -- Petrify
    [2869]  = true, -- Enervate
    [101]   = true, -- Enervate
    [7188]  = true, -- Telekinesis
    [6184]  = true, -- Leech
    [771]   = true, -- Charm
    [467]   = true  -- Curse
}

function RaidFrames:Init()
    local x, y = Settings:GetPosition("raid_frames", 30, 200)
    local totalW = (self.columns * (CELL_WIDTH + CELL_GAP_X)) + (PADDING * 2) - CELL_GAP_X
    local totalH = (self.rowsPerCol * (CELL_HEIGHT + CELL_GAP_Y)) + (PADDING * 2) - CELL_GAP_Y

    local wnd = api.Interface:CreateEmptyWindow("pui_raid_frames", "UIParent")
    wnd:SetExtent(totalW, totalH)
    wnd:AddAnchor("TOPLEFT", "UIParent", x, y)
    wnd:SetUILayer("game")

    Theme.ApplyBackdrop(wnd, Theme.Colors.BgDark, Theme.Colors.BorderSubtle)

    -- Build 50 Cells
    for i = 1, self.maxMembers do
        local col = math.floor((i - 1) / self.rowsPerCol)
        local row = (i - 1) % self.rowsPerCol

        local posX = PADDING + (col * (CELL_WIDTH + CELL_GAP_X))
        local posY = PADDING + (row * (CELL_HEIGHT + CELL_GAP_Y))

        local cell = wnd:CreateChildWidget("emptywidget", "cell_" .. i, 0, true)
        cell:SetExtent(CELL_WIDTH, CELL_HEIGHT)
        cell:AddAnchor("TOPLEFT", wnd, posX, posY)

        local hpBar = W_BAR.CreateStatusBarOfRaidFrame("pui_raid_hp_" .. i, cell)
        hpBar:SetExtent(CELL_WIDTH, CELL_HEIGHT)
        hpBar:AddAnchor("TOPLEFT", cell, 0, 0)
        hpBar:Clickable(false)
        hpBar.statusBar:SetBarTexture("Textures/Defaults/White.dds", "background")
        hpBar.statusBar:SetBarColor(Theme.Colors.RoleUndecided[1], Theme.Colors.RoleUndecided[2], Theme.Colors.RoleUndecided[3], 1)
        hpBar.statusBar:SetMinMaxValues(0, 100)
        hpBar.statusBar:SetValue(100)

        local name = cell:CreateChildWidget("label", "name", 0, true)
        name:SetExtent(CELL_WIDTH - 6, 12)
        name:AddAnchor("TOPLEFT", cell, 3, 2)
        Theme.StyleLabel(name, 9, ALIGN.LEFT, Theme.Colors.TextPrimary, true)

        local statusText = cell:CreateChildWidget("label", "statusText", 0, true)
        statusText:SetExtent(CELL_WIDTH - 6, 10)
        statusText:AddAnchor("BOTTOMRIGHT", cell, -3, -2)
        Theme.StyleLabel(statusText, 8, ALIGN.RIGHT, Theme.Colors.TextSecondary, true)

        local debuffIcon = cell:CreateChildWidget("emptywidget", "debuffIcon", 0, true)
        debuffIcon:SetExtent(12, 12)
        debuffIcon:AddAnchor("TOPRIGHT", cell, -2, 2)
        debuffIcon:Show(false)

        self.cells[i] = {
            widget = cell,
            hpBar = hpBar,
            name = name,
            statusText = statusText,
            debuffIcon = debuffIcon
        }
        cell:Show(false)
    end

    Mover:RegisterFrame("raid_frames", wnd, "Raid Frames (50-Man)")
    self.window = wnd
    wnd:Show(false)
end

function RaidFrames:Update()
    local isRaid = false
    if api.Team ~= nil and api.Team.IsPartyRaid ~= nil then
        isRaid = Guard.SafePcall(function() return api.Team:IsPartyRaid() end, false)
    end

    if not isRaid then
        if self.isActive then
            self.window:Show(false)
            self.isActive = false
        end
        return
    end

    self.isActive = true
    self.window:Show(true)

    for i = 1, self.maxMembers do
        local unit = "team" .. i
        local unitId = Guard.GetUnitId(unit)
        local cell = self.cells[i]

        if unitId ~= nil then
            cell.widget:Show(true)
            local name = Guard.UnitName(unit)
            local curHp = Guard.UnitHealth(unit)
            local maxHp = Guard.UnitMaxHealth(unit)
            local isOffline = false
            if api.Unit ~= nil and api.Unit.UnitIsOffline ~= nil then
                isOffline = Guard.SafePcall(function() return api.Unit:UnitIsOffline(unit) end, false)
            end

            -- Query role from Team API
            local roleColor = Theme.Colors.RoleUndecided
            if api.Team ~= nil and api.Team.GetRole ~= nil then
                local roleId = Guard.SafePcall(function() return api.Team:GetRole(i) end, 0)
                if roleId == 1 then
                    roleColor = Theme.Colors.RoleAttacker
                elseif roleId == 0 then
                    roleColor = Theme.Colors.RoleDefender
                elseif roleId == 2 then
                    roleColor = Theme.Colors.RoleHealer
                end
            end

            cell.hpBar.statusBar:SetBarColor(roleColor[1], roleColor[2], roleColor[3], 1)
            cell.hpBar.statusBar:SetMinMaxValues(0, maxHp)
            cell.hpBar.statusBar:SetValue(curHp)

            cell.name:SetText(name ~= "" and name or ("M " .. i))

            if isOffline then
                cell.statusText:SetText("|cFF64748BOffline|r")
                cell.hpBar.statusBar:SetBarColor(0.2, 0.2, 0.2, 0.5)
            elseif curHp <= 0 then
                cell.statusText:SetText("|cFFEF4444Dead|r")
            else
                local missing = maxHp - curHp
                if missing > 0 then
                    cell.statusText:SetText(string.format("-%d", missing))
                else
                    cell.statusText:SetText("")
                end
            end

            -- Priority debuff scan
            local debuffCount = Guard.UnitDeBuffCount(unit)
            local foundDebuff = false
            if debuffCount > 0 then
                for d = 1, debuffCount do
                    local debuff = Guard.UnitDeBuff(unit, d)
                    if debuff and WATCH_DEBUFF_IDS[debuff.buff_id] then
                        foundDebuff = true
                        break
                    end
                end
            end
            cell.debuffIcon:Show(foundDebuff)
        else
            cell.widget:Show(false)
        end
    end
end

return RaidFrames
