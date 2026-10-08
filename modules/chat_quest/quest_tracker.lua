local api = require("api")
local Theme = require("aa-perfection/core/theme")
local Guard = require("aa-perfection/core/api_guard")
local Settings = require("aa-perfection/core/settings")
local Mover = require("aa-perfection/core/mover")

local QuestTracker = {
    window = nil,
    questRows = {},
    maxQuests = 6,
    isCollapsed = false
}

local WIDTH = 240
local ROW_HEIGHT = 36
local PADDING = 8

function QuestTracker:Init()
    local x, y = Settings:GetPosition("quest_tracker", 1640, 200)

    local wnd = api.Interface:CreateEmptyWindow("pui_quest_tracker", "UIParent")
    wnd:SetExtent(WIDTH, 260)
    wnd:AddAnchor("TOPLEFT", "UIParent", x, y)
    wnd:SetUILayer("game")

    Theme.ApplyBackdrop(wnd, Theme.Colors.BgDark, Theme.Colors.BorderSubtle)

    -- Header Title
    local title = wnd:CreateChildWidget("label", "title", 0, true)
    title:SetText("OBJECTIVES")
    Theme.StyleLabel(title, 11, ALIGN.LEFT, Theme.Colors.TextGold, true)
    title:AddAnchor("TOPLEFT", wnd, PADDING, PADDING)

    -- Collapse Button
    local toggleBtn = wnd:CreateChildWidget("button", "toggleBtn", 0, true)
    toggleBtn:SetExtent(16, 16)
    toggleBtn:AddAnchor("TOPRIGHT", wnd, -PADDING, PADDING - 2)
    toggleBtn:SetText("-")
    Theme.StyleLabel(toggleBtn, 12, ALIGN.CENTER, Theme.Colors.TextMuted, false)

    toggleBtn:SetHandler("OnClick", function()
        QuestTracker:ToggleCollapse()
    end)
    wnd.toggleBtn = toggleBtn

    -- Rows container
    local rowsContainer = wnd:CreateChildWidget("emptywidget", "rows", 0, true)
    rowsContainer:SetExtent(WIDTH - (PADDING * 2), ROW_HEIGHT * self.maxQuests)
    rowsContainer:AddAnchor("TOPLEFT", title, "BOTTOMLEFT", 0, 6)
    wnd.rowsContainer = rowsContainer

    for i = 1, self.maxQuests do
        local row = rowsContainer:CreateChildWidget("emptywidget", "qrow_" .. i, 0, true)
        row:SetExtent(WIDTH - (PADDING * 2), ROW_HEIGHT)
        row:AddAnchor("TOPLEFT", rowsContainer, 0, (i - 1) * ROW_HEIGHT)

        local qTitle = row:CreateChildWidget("label", "qTitle", 0, true)
        qTitle:SetExtent(WIDTH - (PADDING * 2), 14)
        qTitle:AddAnchor("TOPLEFT", row, 0, 0)
        Theme.StyleLabel(qTitle, 10, ALIGN.LEFT, Theme.Colors.TextPrimary, true)

        local qBody = row:CreateChildWidget("label", "qBody", 0, true)
        qBody:SetExtent(WIDTH - (PADDING * 2), 16)
        qBody:AddAnchor("TOPLEFT", qTitle, "BOTTOMLEFT", 0, 2)
        Theme.StyleLabel(qBody, 9, ALIGN.LEFT, Theme.Colors.TextSecondary, false)

        self.questRows[i] = {
            widget = row,
            title = qTitle,
            body = qBody
        }
        row:Show(false)
    end

    Mover:RegisterFrame("quest_tracker", wnd, "Quest Tracker")
    self.window = wnd
    wnd:Show(true)
    self:Refresh()
end

function QuestTracker:ToggleCollapse()
    self.isCollapsed = not self.isCollapsed
    if self.isCollapsed then
        self.window.rowsContainer:Show(false)
        self.window:SetExtent(WIDTH, 32)
        self.window.toggleBtn:SetText("+")
    else
        self.window.rowsContainer:Show(true)
        self.window:SetExtent(WIDTH, 260)
        self.window.toggleBtn:SetText("-")
    end
end

function QuestTracker:Refresh()
    if self.isCollapsed or self.window == nil then return end

    local rowIndex = 1
    -- Query active quest IDs if Quest API is present
    if api.Quest ~= nil and api.Quest.GetActiveQuestTitle ~= nil then
        for qId = 1, 200 do
            if rowIndex > self.maxQuests then break end
            local qTitle = Guard.SafePcall(function() return api.Quest:GetActiveQuestTitle(qId) end, nil)
            if qTitle and qTitle ~= "" then
                local row = self.questRows[rowIndex]
                row.title:SetText(qTitle)

                local qBody = ""
                if api.Quest.GetQuestContextBody ~= nil then
                    qBody = Guard.SafePcall(function() return api.Quest:GetQuestContextBody(qId) end, "")
                end
                row.body:SetText(qBody ~= "" and qBody or "In Progress")
                row.widget:Show(true)
                rowIndex = rowIndex + 1
            end
        end
    end

    -- Hide unused rows
    for i = rowIndex, self.maxQuests do
        self.questRows[i].widget:Show(false)
    end
end

return QuestTracker
