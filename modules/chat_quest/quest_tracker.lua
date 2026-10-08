local api = require("api")
local Theme = require("aa-perfection/core/theme")
local Guard = require("aa-perfection/core/api_guard")
local Settings = require("aa-perfection/core/settings")
local Mover = require("aa-perfection/core/mover")

local QuestTracker = {
    window = nil,
    questRows = {},
    maxQuests = 8,
    isCollapsed = false,
    activeQuests = {},
    lastCount = 0
}

local WIDTH = 260
local ROW_HEIGHT = 44
local PADDING = 10

-- Known major event / rift quest ID catalog for instant detection
local NOTABLE_QUESTS = {
    { id = 2941, cat = "Crimson Rift",  name = "Crimson Omens 1" },
    { id = 2942, cat = "Crimson Rift",  name = "Crimson Omens 2" },
    { id = 2943, cat = "Crimson Rift",  name = "Crimson Omens 3" },
    { id = 5886, cat = "Crimson Rift",  name = "Defeat Hounds of Kyrios" },
    { id = 5885, cat = "Crimson Rift",  name = "Defeat Anthalon" },
    { id = 5142, cat = "Grimghast",      name = "Grimghast Construction" },
    { id = 5143, cat = "Grimghast",      name = "Halting Crimson Tide 1" },
    { id = 5144, cat = "Grimghast",      name = "Halting Crimson Tide 2" },
    { id = 7648, cat = "Grimghast",      name = "Defeat Nightmare 1" },
    { id = 7649, cat = "Grimghast",      name = "Defeat Nightmare 2" },
    { id = 8602, cat = "Whalesong",      name = "Whalesong Harbor: Wave 1" },
    { id = 8603, cat = "Whalesong",      name = "Whalesong Harbor: Wave 2" },
    { id = 8604, cat = "Whalesong",      name = "Whalesong Harbor: Wave 3" },
    { id = 8623, cat = "Aegis Island",   name = "Aegis Defense: Wave 1" },
    { id = 8624, cat = "Aegis Island",   name = "Aegis Defense: Wave 2" },
    { id = 8625, cat = "Aegis Island",   name = "Aegis Defense: Wave 3" },
    { id = 9000008, cat = "Daily",       name = "Guild Daily Task" },
    { id = 9000009, cat = "Daily",       name = "ArchePass Mission" },
    { id = 9000011, cat = "Daily",       name = "Honor Daily Challenge" }
}

function QuestTracker:Init()
    local x, y = Settings:GetPosition("quest_tracker", 1630, 180)

    local wnd = api.Interface:CreateEmptyWindow("pui_quest_tracker", "UIParent")
    wnd:SetExtent(WIDTH, 380)
    wnd:AddAnchor("TOPLEFT", "UIParent", x, y)
    wnd:SetUILayer("game")

    -- Solid Apex Obsidian Backdrop with 1px Hairline Border
    Theme.ApplyBackdrop(wnd, { 0.07, 0.08, 0.11, 0.94 }, Theme.Colors.BorderSubtle)
    Theme.ApplyBorder(wnd, Theme.Colors.BorderActive)

    -- Top Accent Line (Gold)
    local accent = wnd:CreateColorDrawable(Theme.Colors.BorderAccent[1], Theme.Colors.BorderAccent[2], Theme.Colors.BorderAccent[3], 1, "artwork")
    accent:SetExtent(WIDTH, 2)
    accent:AddAnchor("TOPLEFT", wnd, 0, 0)
    wnd.accent = accent

    -- Header Title
    local title = wnd:CreateChildWidget("label", "title", 0, true)
    title:SetText("OBJECTIVES")
    Theme.StyleLabel(title, 11, ALIGN.LEFT, Theme.Colors.TextGold, true)
    title:AddAnchor("TOPLEFT", wnd, PADDING, PADDING + 2)
    wnd.title = title

    -- Quest Count Pill / Badge
    local countBadge = wnd:CreateChildWidget("label", "countBadge", 0, true)
    countBadge:SetExtent(60, 14)
    countBadge:AddAnchor("LEFT", title, "RIGHT", 8, 0)
    countBadge:SetText("[ 0 / 25 ]")
    Theme.StyleLabel(countBadge, 9, ALIGN.LEFT, Theme.Colors.TextMuted, false)
    wnd.countBadge = countBadge

    -- Collapse / Expand Pill Button
    local toggleBtn = wnd:CreateChildWidget("button", "toggleBtn", 0, true)
    toggleBtn:SetExtent(20, 18)
    toggleBtn:AddAnchor("TOPRIGHT", wnd, -PADDING, PADDING)
    toggleBtn:SetText("-")
    Theme.StyleLabel(toggleBtn, 11, ALIGN.CENTER, Theme.Colors.TextGold, true)
    api.Interface:ApplyButtonSkin(toggleBtn, BUTTON_BASIC.DEFAULT)

    toggleBtn:SetHandler("OnClick", function()
        QuestTracker:ToggleCollapse()
    end)
    wnd.toggleBtn = toggleBtn

    -- Rows container
    local rowsContainer = wnd:CreateChildWidget("emptywidget", "rows", 0, true)
    rowsContainer:SetExtent(WIDTH - (PADDING * 2), ROW_HEIGHT * self.maxQuests)
    rowsContainer:AddAnchor("TOPLEFT", title, "BOTTOMLEFT", 0, 8)
    wnd.rowsContainer = rowsContainer

    for i = 1, self.maxQuests do
        local row = rowsContainer:CreateChildWidget("button", "qrow_" .. i, 0, true)
        row:SetExtent(WIDTH - (PADDING * 2), ROW_HEIGHT)
        row:AddAnchor("TOPLEFT", rowsContainer, 0, (i - 1) * ROW_HEIGHT)

        -- Subtle row separator hairline
        local sep = row:CreateColorDrawable(0.15, 0.18, 0.24, 0.40, "background")
        sep:SetExtent(WIDTH - (PADDING * 2), 1)
        sep:AddAnchor("BOTTOMLEFT", row, 0, 0)

        -- Category Tag / Category Label
        local qCat = row:CreateChildWidget("label", "qCat", 0, true)
        qCat:SetExtent(WIDTH - (PADDING * 2), 11)
        qCat:AddAnchor("TOPLEFT", row, 2, 2)
        Theme.StyleLabel(qCat, 8, ALIGN.LEFT, { 0.30, 0.65, 0.95, 1.0 }, true)

        -- Quest Title
        local qTitle = row:CreateChildWidget("label", "qTitle", 0, true)
        qTitle:SetExtent(WIDTH - (PADDING * 2) - 40, 14)
        qTitle:AddAnchor("TOPLEFT", qCat, "BOTTOMLEFT", 0, 1)
        Theme.StyleLabel(qTitle, 9, ALIGN.LEFT, Theme.Colors.TextPrimary, true)
        qTitle:SetAutoResize(false)

        -- Status badge (e.g. COMPLETE / Progress)
        local qStatus = row:CreateChildWidget("label", "qStatus", 0, true)
        qStatus:SetExtent(40, 14)
        qStatus:AddAnchor("TOPRIGHT", row, -2, 12)
        Theme.StyleLabel(qStatus, 8, ALIGN.RIGHT, Theme.Colors.TextGold, true)

        -- Objectives / Body Description
        local qBody = row:CreateChildWidget("label", "qBody", 0, true)
        qBody:SetExtent(WIDTH - (PADDING * 2), 13)
        qBody:AddAnchor("TOPLEFT", qTitle, "BOTTOMLEFT", 0, 1)
        Theme.StyleLabel(qBody, 8, ALIGN.LEFT, Theme.Colors.TextSecondary, false)
        qBody:SetAutoResize(false)

        row:SetHandler("OnClick", function()
            -- Click opens Quest Journal
            if UIC ~= nil and UIC.QUEST_LIST ~= nil then
                local uicId = UIC.QUEST_LIST
                local content = Guard.GetStockContent(uicId)
                if content ~= nil then
                    Guard.ShowStockContent(uicId, not content:IsVisible())
                end
            end
        end)

        self.questRows[i] = {
            widget = row,
            cat = qCat,
            title = qTitle,
            status = qStatus,
            body = qBody
        }
        row:Show(false)
    end

    Mover:RegisterFrame("quest_tracker", wnd, "Objectives Tracker")
    self.window = wnd
    wnd:Show(true)

    -- Also skin stock Quest Watch if present
    self:SkinStockQuestWatch()

    self:Refresh()
end

function QuestTracker:SkinStockQuestWatch()
    pcall(function()
        if UIC ~= nil and UIC.QUEST_WATCH ~= nil then
            local stockWatch = Guard.GetStockContent(UIC.QUEST_WATCH)
            if stockWatch ~= nil then
                if stockWatch.bg ~= nil and stockWatch.bg.SetColor ~= nil then
                    stockWatch.bg:SetColor(0.06, 0.07, 0.10, 0.85)
                end
            end
        end
    end)
end

function QuestTracker:ToggleCollapse()
    self.isCollapsed = not self.isCollapsed
    if self.isCollapsed then
        self.window.rowsContainer:Show(false)
        self.window:SetExtent(WIDTH, 36)
        self.window.toggleBtn:SetText("+")
    else
        self.window.rowsContainer:Show(true)
        local visibleCount = math.max(1, math.min(self.lastCount, self.maxQuests))
        self.window:SetExtent(WIDTH, PADDING + 20 + 8 + (visibleCount * ROW_HEIGHT) + PADDING)
        self.window.toggleBtn:SetText("-")
    end
end

function QuestTracker:Refresh()
    if self.window == nil then return end

    local entries = {}

    -- 1. Scan for active quests via engine Quest API
    if api.Quest ~= nil then
        -- Query using GetActiveQuestTitle or GetQuestContextMainTitle
        for qId = 1, 250 do
            if #entries >= self.maxQuests then break end
            local qTitle = nil
            if api.Quest.GetActiveQuestTitle ~= nil then
                qTitle = Guard.SafePcall(function() return api.Quest:GetActiveQuestTitle(qId) end, nil)
            end
            if (not qTitle or qTitle == "") and api.Quest.GetQuestContextMainTitle ~= nil then
                qTitle = Guard.SafePcall(function() return api.Quest:GetQuestContextMainTitle(qId) end, nil)
            end

            if qTitle and qTitle ~= "" then
                local isDone = false
                if api.Quest.IsCompleted ~= nil then
                    isDone = Guard.SafePcall(function() return api.Quest:IsCompleted(qId) end, false)
                end

                local qBody = ""
                if api.Quest.GetQuestContextBody ~= nil then
                    qBody = Guard.SafePcall(function() return api.Quest:GetQuestContextBody(qId) end, "")
                end

                table.insert(entries, {
                    category = "QUEST",
                    title = "• " .. tostring(qTitle),
                    body = (qBody ~= "" and qBody or (isDone and "Ready to hand in" or "In Progress")),
                    isComplete = isDone
                })
            end
        end

        -- 2. Check notable rift / daily quests
        if #entries < self.maxQuests then
            for _, def in ipairs(NOTABLE_QUESTS) do
                if #entries >= self.maxQuests then break end
                local isDone = false
                if api.Quest.IsCompleted ~= nil then
                    isDone = Guard.SafePcall(function() return api.Quest:IsCompleted(def.id) end, false)
                end
                local mainTitle = nil
                if api.Quest.GetQuestContextMainTitle ~= nil then
                    mainTitle = Guard.SafePcall(function() return api.Quest:GetQuestContextMainTitle(def.id) end, nil)
                end

                if mainTitle and mainTitle ~= "" then
                    table.insert(entries, {
                        category = def.cat:upper(),
                        title = "• " .. mainTitle,
                        body = isDone and "Task Completed" or "In Progress",
                        isComplete = isDone
                    })
                end
            end
        end
    end

    self.lastCount = #entries
    self.window.countBadge:SetText(string.format("[ %d / 25 ]", #entries))

    -- Populate UI rows
    for i = 1, self.maxQuests do
        local row = self.questRows[i]
        local data = entries[i]

        if data ~= nil then
            row.cat:SetText(data.category)
            row.title:SetText(data.title)
            row.body:SetText(data.body)

            if data.isComplete then
                row.status:SetText("DONE")
                Theme.StyleLabel(row.status, 8, ALIGN.RIGHT, Theme.Colors.HealthPlayer, true)
                Theme.StyleLabel(row.title, 9, ALIGN.LEFT, Theme.Colors.TextGold, true)
            else
                row.status:SetText("")
                Theme.StyleLabel(row.title, 9, ALIGN.LEFT, Theme.Colors.TextPrimary, true)
            end

            row.widget:Show(not self.isCollapsed)
        else
            row.widget:Show(false)
        end
    end

    -- Adjust frame height dynamically based on active count if not collapsed
    if not self.isCollapsed then
        local displayRows = math.max(1, #entries)
        local newH = PADDING + 20 + 8 + (displayRows * ROW_HEIGHT) + PADDING
        self.window:SetExtent(WIDTH, newH)
    end
end

return QuestTracker
