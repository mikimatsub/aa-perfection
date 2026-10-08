local api = require("api")
local Theme = require("aa-perfection/core/theme")
local Settings = require("aa-perfection/core/settings")
local Mover = require("aa-perfection/core/mover")

local SettingsPage = {
    window = nil,
    isOpen = false,
    moduleCheckboxes = {}
}

local WIDTH = 340
local HEIGHT = 380
local PADDING = 14

function SettingsPage:Init()
    local wnd = api.Interface:CreateEmptyWindow("pui_settings_window", "UIParent")
    wnd:SetExtent(WIDTH, HEIGHT)
    wnd:AddAnchor("CENTER", "UIParent", 0, 0)
    wnd:SetUILayer("dialog")

    Theme.ApplyBackdrop(wnd, Theme.Colors.BgDark, Theme.Colors.BorderSubtle)
    Theme.ApplyBorder(wnd, Theme.Colors.BorderActive)

    -- Header
    local title = wnd:CreateChildWidget("label", "title", 0, true)
    title:SetText("PERFECTION UI - SETTINGS")
    Theme.StyleLabel(title, 13, ALIGN.LEFT, Theme.Colors.TextGold, true)
    title:AddAnchor("TOPLEFT", wnd, PADDING, PADDING)

    local closeBtn = wnd:CreateChildWidget("button", "close", 0, true)
    closeBtn:SetExtent(18, 18)
    closeBtn:AddAnchor("TOPRIGHT", wnd, -PADDING, PADDING)
    closeBtn:SetText("X")
    Theme.StyleLabel(closeBtn, 12, ALIGN.CENTER, Theme.Colors.TextMuted, false)
    closeBtn:SetHandler("OnClick", function()
        SettingsPage:Toggle()
    end)

    -- Module Toggles Section
    local subTitle = wnd:CreateChildWidget("label", "subTitle", 0, true)
    subTitle:SetText("MODULE CONFIGURATION")
    Theme.StyleLabel(subTitle, 10, ALIGN.LEFT, Theme.Colors.TextSecondary, true)
    subTitle:AddAnchor("TOPLEFT", title, "BOTTOMLEFT", 0, 10)

    local modules = {
        { id = "inventory",   label = "Next-Gen Inventory (Bag)" },
        { id = "unitframes",  label = "Obsidian Unit Frames (Player/Target)" },
        { id = "combat_hud",  label = "Combat HUD (Castbar & CC Alert)" },
        { id = "actionbars",  label = "Quick Swap Bar & Action Skin" },
        { id = "gameplay",    label = "Labor HUD & Speedometer" },
        { id = "chat",        label = "Obsidian Chat Enhancements" }
    }

    local startY = PADDING + 16 + 10 + 14 + 8
    for idx, mod in ipairs(modules) do
        local posY = startY + ((idx - 1) * 28)
        local chk = api.Interface:CreateWidget("checkbutton", "chk_" .. mod.id, wnd)
        chk:AddAnchor("TOPLEFT", wnd, PADDING, posY)
        chk:SetText(mod.label)
        Theme.StyleLabel(chk.textButton, 10, ALIGN.LEFT, Theme.Colors.TextPrimary, false)

        local isEnabled = Settings:IsModuleEnabled(mod.id)
        chk:SetChecked(isEnabled)

        chk:SetHandler("OnCheckChanged", function(selfChk)
            local checked = selfChk:IsChecked()
            Settings:SetModuleEnabled(mod.id, checked)
        end)

        self.moduleCheckboxes[mod.id] = chk
    end

    -- Presets Section
    local presetLabel = wnd:CreateChildWidget("label", "presetLabel", 0, true)
    presetLabel:SetText("PERFORMANCE PRESETS")
    Theme.StyleLabel(presetLabel, 10, ALIGN.LEFT, Theme.Colors.TextSecondary, true)
    presetLabel:AddAnchor("TOPLEFT", wnd, PADDING, startY + (#modules * 28) + 10)

    local presetY = startY + (#modules * 28) + 26
    local zergBtn = wnd:CreateChildWidget("button", "zergPreset", 0, true)
    zergBtn:SetExtent(96, 24)
    zergBtn:AddAnchor("TOPLEFT", wnd, PADDING, presetY)
    zergBtn:SetText("Zerg / Raid")
    Theme.StyleLabel(zergBtn, 10, ALIGN.CENTER, Theme.Colors.TextPrimary, false)
    api.Interface:ApplyButtonSkin(zergBtn, BUTTON_BASIC.DEFAULT)

    zergBtn:SetHandler("OnClick", function()
        Settings:SetModuleEnabled("gameplay", false)
        Settings:SetModuleEnabled("chat", false)
        SettingsPage:RefreshCheckboxes()
        if api.Log ~= nil and api.Log.Info ~= nil then
            api.Log:Info("[Perfection UI] Activated 'Zerg Mode' preset (max combat FPS).")
        end
    end)

    local defaultBtn = wnd:CreateChildWidget("button", "defaultPreset", 0, true)
    defaultBtn:SetExtent(96, 24)
    defaultBtn:AddAnchor("LEFT", zergBtn, "RIGHT", 8, 0)
    defaultBtn:SetText("Balanced")
    Theme.StyleLabel(defaultBtn, 10, ALIGN.CENTER, Theme.Colors.TextPrimary, false)
    api.Interface:ApplyButtonSkin(defaultBtn, BUTTON_BASIC.DEFAULT)

    defaultBtn:SetHandler("OnClick", function()
        for _, mod in ipairs(modules) do
            Settings:SetModuleEnabled(mod.id, true)
        end
        SettingsPage:RefreshCheckboxes()
        if api.Log ~= nil and api.Log.Info ~= nil then
            api.Log:Info("[Perfection UI] Activated 'Balanced' preset (all features enabled).")
        end
    end)

    -- Bottom Actions: Edit Mode & Reset
    local editBtn = wnd:CreateChildWidget("button", "editModeBtn", 0, true)
    editBtn:SetExtent(144, 28)
    editBtn:AddAnchor("BOTTOMLEFT", wnd, PADDING, -PADDING)
    editBtn:SetText("Unlock Positions")
    Theme.StyleLabel(editBtn, 10, ALIGN.CENTER, Theme.Colors.TextGold, false)
    api.Interface:ApplyButtonSkin(editBtn, BUTTON_BASIC.DEFAULT)

    editBtn:SetHandler("OnClick", function()
        Mover:ToggleEditMode()
        if Mover.isUnlocked then
            editBtn:SetText("Lock Positions")
        else
            editBtn:SetText("Unlock Positions")
        end
    end)

    local resetBtn = wnd:CreateChildWidget("button", "resetBtn", 0, true)
    resetBtn:SetExtent(144, 28)
    resetBtn:AddAnchor("BOTTOMRIGHT", wnd, -PADDING, -PADDING)
    resetBtn:SetText("Reset Layout")
    Theme.StyleLabel(resetBtn, 10, ALIGN.CENTER, Theme.Colors.TextMuted, false)
    api.Interface:ApplyButtonSkin(resetBtn, BUTTON_BASIC.DEFAULT)

    resetBtn:SetHandler("OnClick", function()
        Settings.data.positions = nil
        Settings:Save()
        if api.Log ~= nil and api.Log.Info ~= nil then
            api.Log:Info("[Perfection UI] Layout coordinates reset to factory defaults.")
        end
    end)

    self.window = wnd
    wnd:Show(false)
end

function SettingsPage:RefreshCheckboxes()
    for modId, chk in pairs(self.moduleCheckboxes) do
        chk:SetChecked(Settings:IsModuleEnabled(modId))
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
