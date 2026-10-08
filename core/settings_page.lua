local api = require("api")
local Theme = require("aa-perfection/core/theme")
local Settings = require("aa-perfection/core/settings")
local Mover = require("aa-perfection/core/mover")

local SettingsPage = {
    window = nil,
    isOpen = false,
    moduleRows = {}
}

local WIDTH = 440
local HEIGHT = 520
local PADDING = 16

function SettingsPage:Init()
    local wnd = api.Interface:CreateEmptyWindow("pui_settings_window", "UIParent")
    wnd:SetExtent(WIDTH, HEIGHT)
    wnd:AddAnchor("CENTER", "UIParent", 0, -30)
    wnd:SetUILayer("dialog")

    -- Solid dark obsidian backdrop with gold border
    Theme.ApplyBackdrop(wnd, { 0.07, 0.08, 0.11, 0.98 })
    Theme.ApplyBorder(wnd, Theme.Colors.BorderAccent)

    -- Header Title
    local title = wnd:CreateChildWidget("label", "title", 0, true)
    title:SetExtent(WIDTH - 80, 20)
    title:SetText("PERFECTION UI - SETTINGS")
    Theme.StyleLabel(title, 13, ALIGN.LEFT, Theme.Colors.TextGold, true)
    title:AddAnchor("TOPLEFT", wnd, PADDING, PADDING)

    local subTitle = wnd:CreateChildWidget("label", "subTitle", 0, true)
    subTitle:SetExtent(WIDTH - 80, 14)
    subTitle:SetText("MODULE CONFIGURATION & CONTROLS")
    Theme.StyleLabel(subTitle, 9, ALIGN.LEFT, Theme.Colors.TextSecondary, true)
    subTitle:AddAnchor("TOPLEFT", title, "BOTTOMLEFT", 0, 4)

    -- Close Button
    local closeBtn = wnd:CreateChildWidget("button", "close", 0, true)
    closeBtn:SetExtent(24, 24)
    closeBtn:AddAnchor("TOPRIGHT", wnd, -PADDING, PADDING)
    closeBtn:SetText("X")
    Theme.StyleLabel(closeBtn, 12, ALIGN.CENTER, Theme.Colors.TextGold, true)
    api.Interface:ApplyButtonSkin(closeBtn, BUTTON_BASIC.DEFAULT)
    closeBtn:SetHandler("OnClick", function()
        SettingsPage:Toggle()
    end)

    -- Modules List
    local modules = {
        { id = "inventory",   label = "Obsidian Bag Styling",           desc = "Dark obsidian theme on native bags" },
        { id = "unitframes",  label = "Obsidian Unit Frames",           desc = "Player & Target frames with health/mana" },
        { id = "combat_hud",  label = "Combat HUD & 3D Target Plate",   desc = "Cast bar, CC alerts, & 3D overhead plate" },
        { id = "actionbars",  label = "Quick Swap & Micro Bar",         desc = "Floating weapon swap & modern shortcuts" },
        { id = "gameplay",    label = "Labor HUD & Radar HUD",          desc = "Labor power, speedometer & minimap coords" },
        { id = "chat",        label = "Chat Tab Enhancements",          desc = "Obsidian styling for chat windows" },
        { id = "quest",       label = "Objectives Tracker",             desc = "Obsidian quest tracker with rift counters" }
    }

    local startY = PADDING + 20 + 4 + 14 + 12
    local rowWidth = WIDTH - (PADDING * 2)

    for idx, mod in ipairs(modules) do
        local posY = startY + ((idx - 1) * 36)
        local row = wnd:CreateChildWidget("emptywidget", "row_" .. mod.id, 0, true)
        row:SetExtent(rowWidth, 32)
        row:AddAnchor("TOPLEFT", wnd, PADDING, posY)
        Theme.ApplyBackdrop(row, { 0.11, 0.13, 0.18, 0.90 })
        Theme.ApplyBorder(row, { 0.18, 0.22, 0.30, 0.80 })

        local label = row:CreateChildWidget("label", "lbl", 0, true)
        label:SetExtent(rowWidth - 90, 16)
        label:AddAnchor("TOPLEFT", row, 8, 4)
        label:SetText(mod.label)
        Theme.StyleLabel(label, 10, ALIGN.LEFT, Theme.Colors.TextPrimary, true)

        local descLbl = row:CreateChildWidget("label", "desc", 0, true)
        descLbl:SetExtent(rowWidth - 90, 12)
        descLbl:AddAnchor("TOPLEFT", label, "BOTTOMLEFT", 0, 1)
        descLbl:SetText(mod.desc)
        Theme.StyleLabel(descLbl, 8, ALIGN.LEFT, Theme.Colors.TextMuted, false)

        -- High-visibility ON / OFF Toggle Pill
        local toggleBtn = row:CreateChildWidget("button", "toggle", 0, true)
        toggleBtn:SetExtent(74, 22)
        toggleBtn:AddAnchor("RIGHT", row, -6, 0)
        api.Interface:ApplyButtonSkin(toggleBtn, BUTTON_BASIC.DEFAULT)

        local function updateToggleVisual(enabled)
            if enabled then
                toggleBtn:SetText("ON")
                Theme.StyleLabel(toggleBtn, 10, ALIGN.CENTER, Theme.Colors.HealthPlayer, true)
            else
                toggleBtn:SetText("OFF")
                Theme.StyleLabel(toggleBtn, 10, ALIGN.CENTER, Theme.Colors.TextMuted, false)
            end
        end

        local isEnabled = Settings:IsModuleEnabled(mod.id)
        updateToggleVisual(isEnabled)

        toggleBtn:SetHandler("OnClick", function()
            local newState = not Settings:IsModuleEnabled(mod.id)
            Settings:SetModuleEnabled(mod.id, newState)
            updateToggleVisual(newState)
        end)

        self.moduleRows[mod.id] = {
            row = row,
            toggleBtn = toggleBtn,
            update = updateToggleVisual
        }
    end

    -- Presets Section
    local presetY = startY + (#modules * 36) + 12
    local presetLabel = wnd:CreateChildWidget("label", "presetLabel", 0, true)
    presetLabel:SetExtent(rowWidth, 14)
    presetLabel:SetText("PERFORMANCE PRESETS")
    Theme.StyleLabel(presetLabel, 9, ALIGN.LEFT, Theme.Colors.TextSecondary, true)
    presetLabel:AddAnchor("TOPLEFT", wnd, PADDING, presetY)

    local btnY = presetY + 18
    local zergBtn = wnd:CreateChildWidget("button", "zergPreset", 0, true)
    zergBtn:SetExtent(120, 24)
    zergBtn:AddAnchor("TOPLEFT", wnd, PADDING, btnY)
    zergBtn:SetText("Zerg Mode")
    Theme.StyleLabel(zergBtn, 10, ALIGN.CENTER, Theme.Colors.TextPrimary, false)
    api.Interface:ApplyButtonSkin(zergBtn, BUTTON_BASIC.DEFAULT)

    zergBtn:SetHandler("OnClick", function()
        Settings:SetModuleEnabled("gameplay", false)
        Settings:SetModuleEnabled("chat", false)
        SettingsPage:RefreshCheckboxes()
        if api.Log ~= nil and api.Log.Info ~= nil then
            api.Log:Info("[Perfection UI] Activated 'Zerg Mode' (combat FPS priority).")
        end
    end)

    local defaultBtn = wnd:CreateChildWidget("button", "defaultPreset", 0, true)
    defaultBtn:SetExtent(120, 24)
    defaultBtn:AddAnchor("LEFT", zergBtn, "RIGHT", 10, 0)
    defaultBtn:SetText("Balanced Mode")
    Theme.StyleLabel(defaultBtn, 10, ALIGN.CENTER, Theme.Colors.TextPrimary, false)
    api.Interface:ApplyButtonSkin(defaultBtn, BUTTON_BASIC.DEFAULT)

    defaultBtn:SetHandler("OnClick", function()
        for _, mod in ipairs(modules) do
            Settings:SetModuleEnabled(mod.id, true)
        end
        SettingsPage:RefreshCheckboxes()
        if api.Log ~= nil and api.Log.Info ~= nil then
            api.Log:Info("[Perfection UI] Activated 'Balanced Mode' (all modules active).")
        end
    end)

    -- Bottom Actions: Edit Mode & Reset Layout
    local editBtn = wnd:CreateChildWidget("button", "editModeBtn", 0, true)
    editBtn:SetExtent(190, 28)
    editBtn:AddAnchor("BOTTOMLEFT", wnd, PADDING, -PADDING)
    editBtn:SetText("Move / Unlock Frames")
    Theme.StyleLabel(editBtn, 10, ALIGN.CENTER, Theme.Colors.TextGold, true)
    api.Interface:ApplyButtonSkin(editBtn, BUTTON_BASIC.DEFAULT)

    editBtn:SetHandler("OnClick", function()
        Mover:ToggleEditMode()
        if Mover.isUnlocked then
            editBtn:SetText("Lock Frames (Done)")
        else
            editBtn:SetText("Move / Unlock Frames")
        end
    end)

    local resetBtn = wnd:CreateChildWidget("button", "resetBtn", 0, true)
    resetBtn:SetExtent(190, 28)
    resetBtn:AddAnchor("BOTTOMRIGHT", wnd, -PADDING, -PADDING)
    resetBtn:SetText("Reset Layout")
    Theme.StyleLabel(resetBtn, 10, ALIGN.CENTER, Theme.Colors.TextMuted, false)
    api.Interface:ApplyButtonSkin(resetBtn, BUTTON_BASIC.DEFAULT)

    resetBtn:SetHandler("OnClick", function()
        Settings.data.positions = nil
        Settings:Save()
        if api.Log ~= nil and api.Log.Info ~= nil then
            api.Log:Info("[Perfection UI] Layout coordinates reset to default.")
        end
    end)

    self.window = wnd
    wnd:Show(false)
end

function SettingsPage:RefreshCheckboxes()
    for modId, data in pairs(self.moduleRows) do
        if data.update then
            data.update(Settings:IsModuleEnabled(modId))
        end
    end
end

function SettingsPage:Toggle()
    self.isOpen = not self.isOpen
    if self.window ~= nil then
        self.window:Show(self.isOpen)
        if self.isOpen then
            self:RefreshCheckboxes()
        end
    end
end

return SettingsPage
