local api = require("api")
local Theme = require("aa-perfection/core/theme")
local Guard = require("aa-perfection/core/api_guard")
local Settings = require("aa-perfection/core/settings")
local Mover = require("aa-perfection/core/mover")

local MicroMenu = {
    window = nil,
    buttons = {}
}

local WIDTH = 270
local HEIGHT = 26

local BUTTON_DEFS = {
    { id = "char",   label = "Char",   tip = "Character Sheet (C)", uic = "CHARACTER_INFO", key = "toggle_character_info" },
    { id = "bag",    label = "Bag",    tip = "Inventory (B)",       uic = "BAG",            key = "toggle_inventory" },
    { id = "skills", label = "Skills", tip = "Skill Book (K)",      uic = "SKILL",          key = "toggle_skill_book" },
    { id = "quest",  label = "Quest",  tip = "Quest Journal (L)",   uic = "QUEST_LIST",     key = "toggle_quest_journal" },
    { id = "map",    label = "Map",    tip = "World Map (M)",       uic = "MAP",            key = "toggle_world_map" },
    { id = "opt",    label = "Menu",   tip = "Perfection Settings", custom = "settings" }
}

function MicroMenu:Init()
    local x, y = Settings:GetPosition("micro_menu", 1630, 1040)

    local wnd = api.Interface:CreateEmptyWindow("pui_micro_menu", "UIParent")
    wnd:SetExtent(WIDTH, HEIGHT)
    wnd:AddAnchor("TOPLEFT", "UIParent", x, y)
    wnd:SetUILayer("hud")

    -- Solid Apex Obsidian Backdrop & 1px Hairline Border
    Theme.ApplyBackdrop(wnd, { 0.07, 0.08, 0.11, 0.94 }, Theme.Colors.BorderSubtle)
    Theme.ApplyBorder(wnd, Theme.Colors.BorderActive)

    local btnWidth = 42
    local btnHeight = 20
    local startX = 4

    for i, def in ipairs(BUTTON_DEFS) do
        local btn = wnd:CreateChildWidget("button", "btn_" .. def.id, 0, true)
        btn:SetExtent(btnWidth, btnHeight)
        btn:AddAnchor("LEFT", wnd, startX + ((i - 1) * (btnWidth + 2)), 0)
        btn:SetText(def.label)
        Theme.StyleLabel(btn, 9, ALIGN.CENTER, Theme.Colors.TextPrimary, false)
        api.Interface:ApplyButtonSkin(btn, BUTTON_BASIC.DEFAULT)

        btn:SetHandler("OnClick", function()
            MicroMenu:HandleClick(def)
        end)

        self.buttons[def.id] = btn
    end

    Mover:RegisterFrame("micro_menu", wnd, "Micro Shortcuts Bar")
    self.window = wnd
    wnd:Show(true)

    -- Hide native clunky circular buttons if accessible
    self:SuppressNativeShortcuts()
end

function MicroMenu:HandleClick(def)
    if def.custom == "settings" or def.id == "opt" then
        local SettingsPage = require("aa-perfection/core/settings_page")
        if SettingsPage and SettingsPage.Toggle then
            SettingsPage:Toggle()
        end
        return
    end

    if def.id == "bag" then
        local BagView = require("aa-perfection/modules/inventory/bag_view")
        if BagView and BagView.Toggle then
            BagView:Toggle()
            return
        end
    end

    if def.id == "quest" then
        local QuestTracker = require("aa-perfection/modules/chat_quest/quest_tracker")
        if QuestTracker and QuestTracker.ToggleCollapse then
            QuestTracker:ToggleCollapse()
        end
    end

    -- Try UIC trigger first
    if def.uic and UIC and UIC[def.uic] then
        local uicId = UIC[def.uic]
        local content = Guard.GetStockContent(uicId)
        if content ~= nil then
            local isVis = content:IsVisible()
            Guard.ShowStockContent(uicId, not isVis)
            return
        end
    end

    -- Fallback to key trigger if available
    if api.Input ~= nil and api.Input.DispatchKey ~= nil and def.key then
        pcall(function() api.Input:DispatchKey(def.key) end)
    end
end

function MicroMenu:SuppressNativeShortcuts()
    -- Subtly suppress the dated 2013 circular shortcut icons if accessible
    pcall(function()
        if UIC ~= nil then
            for _, key in ipairs({ "SYSTEM_MENU", "BOTTOM_BAR", "SHORTCUT_BAR", "MENU_BAR", "SYSTEM_CONFIG_FRAME" }) do
                if UIC[key] ~= nil then
                    local content = Guard.GetStockContent(UIC[key])
                    if content ~= nil then
                        content:SetAlpha(0.15)
                    end
                end
            end
        end
    end)
end

return MicroMenu
