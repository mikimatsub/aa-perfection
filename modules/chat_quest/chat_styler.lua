local api = require("api")
local Theme = require("aa-perfection/core/theme")
local Settings = require("aa-perfection/core/settings")

local ChatStyler = {
    skinnedWindows = {},
    skinnedTabs = {},
    skinnedEditBoxes = {}
}

function ChatStyler:Init()
    self:ScanAndSkin()
end

function ChatStyler:ScanAndSkin()
    if not Settings:IsModuleEnabled("chat") then return end

    -- chatTabWindow is the global engine table containing active chat tab windows
    if type(chatTabWindow) ~= "table" then return end

    for index, wnd in pairs(chatTabWindow) do
        if type(wnd) == "table" then
            self:SkinChatWindow(wnd)
        end
    end
end

function ChatStyler:SkinChatWindow(wnd)
    if wnd == nil or self.skinnedWindows[wnd] then return end
    self.skinnedWindows[wnd] = true

    pcall(function()
        -- 1. Apply Obsidian Backing & Hairline Border
        if wnd.bg ~= nil and wnd.bg.SetColor ~= nil then
            wnd.bg:SetColor(0.06, 0.07, 0.10, 0.85)
        elseif wnd.CreateColorDrawable ~= nil then
            Theme.ApplyBackdrop(wnd, { 0.06, 0.07, 0.10, 0.85 }, Theme.Colors.BorderSubtle)
            Theme.ApplyBorder(wnd, Theme.Colors.BorderSubtle)
        end

        -- 2. Skin Chat Tabs
        self:SkinTabs(wnd)

        -- 3. Skin Edit Box
        self:SkinEditBox(wnd)

        -- 4. Skin Scroll Controls
        self:SkinScrollControls(wnd)
    end)
end

function ChatStyler:SkinTabs(wnd)
    local tabCandidates = { wnd.tab, wnd.tabList, wnd.tabs }
    for _, list in ipairs(tabCandidates) do
        if type(list) == "table" then
            for idx, tabBtn in pairs(list) do
                if type(tabBtn) == "table" and not self.skinnedTabs[tabBtn] then
                    self.skinnedTabs[tabBtn] = true
                    pcall(function()
                        if tabBtn.style ~= nil and tabBtn.style.SetColor ~= nil then
                            tabBtn.style:SetColor(0.85, 0.88, 0.95, 1.0)
                            if tabBtn.style.SetFontSize ~= nil then
                                tabBtn.style:SetFontSize(10)
                            end
                        end
                        if tabBtn.bg ~= nil and tabBtn.bg.SetColor ~= nil then
                            tabBtn.bg:SetColor(0.09, 0.11, 0.16, 0.80)
                        end
                    end)
                end
            end
        end
    end
end

function ChatStyler:SkinEditBox(wnd)
    local edit = wnd.editBox or wnd.chatEditBox
    if edit == nil or self.skinnedEditBoxes[edit] then return end
    self.skinnedEditBoxes[edit] = true

    pcall(function()
        if edit.CreateColorDrawable ~= nil and edit.bg == nil then
            local ebg = edit:CreateColorDrawable(0.08, 0.09, 0.13, 0.95, "background")
            ebg:AddAnchor("TOPLEFT", edit, -2, -2)
            ebg:AddAnchor("BOTTOMRIGHT", edit, 2, 2)
            edit.bg = ebg
        end

        if edit.style ~= nil and edit.style.SetColor ~= nil then
            edit.style:SetColor(0.95, 0.96, 0.98, 1.0)
            if edit.style.SetFontSize ~= nil then
                edit.style:SetFontSize(11)
            end
        end

        if edit.SetCursorColor ~= nil then
            edit:SetCursorColor(0.88, 0.70, 0.25, 1.0) -- Gold cursor
        end

        if edit.SetInset ~= nil then
            edit:SetInset(6, 4, 6, 4)
        end
    end)
end

function ChatStyler:SkinScrollControls(wnd)
    pcall(function()
        local scroll = wnd.scroll or wnd.scrollBar
        if scroll ~= nil and type(scroll) == "table" then
            if scroll.bg ~= nil and scroll.bg.SetColor ~= nil then
                scroll.bg:SetColor(0.05, 0.06, 0.08, 0.60)
            end
        end

        -- Declutter option buttons
        local optBtn = wnd.optionButton or wnd.configButton
        if optBtn ~= nil and type(optBtn) == "table" then
            if optBtn.SetAlpha ~= nil then
                optBtn:SetAlpha(0.6)
            end
        end
    end)
end

function ChatStyler:Update()
    -- Periodic scan for newly created or detached chat tabs
    self:ScanAndSkin()
end

return ChatStyler
