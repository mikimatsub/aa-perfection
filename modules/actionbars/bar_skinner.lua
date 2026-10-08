local api = require("api")
local Theme = require("aa-perfection/core/theme")
local Guard = require("aa-perfection/core/api_guard")

local BarSkinner = {
    skinnedBars = {},
    skinnedButtons = {}
}

function BarSkinner:Init()
    self:ScanAndSkin()
end

function BarSkinner:ScanAndSkin()
    -- 1. Bubble Action Bar
    if UIC ~= nil and UIC.BUBBLE_ACTION_BAR ~= nil then
        local bubbleBar = Guard.GetStockContent(UIC.BUBBLE_ACTION_BAR)
        if bubbleBar ~= nil then
            self:SkinFrame(bubbleBar)
        end
    end

    -- 2. Inspect common action bar globals
    local barGlobals = { "actionBar", "actionBars", "mainActionBar", "subActionBar", "petActionBar" }
    for _, gName in ipairs(barGlobals) do
        local globalVal = _G[gName]
        if type(globalVal) == "table" then
            self:SkinFrame(globalVal)
        end
    end

    -- 3. Also check if ADDON has registered action bar contents
    if ADDON ~= nil and ADDON.GetContent ~= nil and UIC ~= nil then
        for k, v in pairs(UIC) do
            if type(k) == "string" and k:find("ACTION_BAR") then
                local content = Guard.GetStockContent(v)
                if content ~= nil then
                    self:SkinFrame(content)
                end
            end
        end
    end
end

function BarSkinner:SkinFrame(frame)
    if frame == nil or self.skinnedBars[frame] then return end
    self.skinnedBars[frame] = true

    pcall(function()
        -- Apply obsidian backdrop if container widget
        if frame.bg ~= nil and frame.bg.SetColor ~= nil then
            frame.bg:SetColor(0.06, 0.07, 0.10, 0.85)
        elseif frame.CreateColorDrawable ~= nil then
            Theme.ApplyBackdrop(frame, { 0.06, 0.07, 0.10, 0.85 }, Theme.Colors.BorderSubtle)
        end

        -- Skin any child slot buttons
        self:SkinChildren(frame)
    end)
end

function BarSkinner:SkinChildren(parent)
    if parent == nil or type(parent) ~= "table" then return end

    -- Check direct indexed children or slots table
    for k, child in pairs(parent) do
        if type(child) == "table" and child ~= parent then
            -- If it looks like an action slot button
            if (child.back ~= nil or child.hotkey ~= nil or child.icon ~= nil or (type(k) == "number" and child.SetExtent ~= nil)) then
                self:SkinSlotButton(child)
            end
        end
    end
end

function BarSkinner:SkinSlotButton(btn)
    if btn == nil or self.skinnedButtons[btn] then return end
    self.skinnedButtons[btn] = true

    pcall(function()
        -- Style button background / slot back
        if btn.back ~= nil and btn.back.SetColor ~= nil then
            btn.back:SetColor(0.08, 0.09, 0.12, 0.90)
        end

        -- Style hotkey text if accessible
        local hk = btn.hotkey or btn.hotkeyLabel or btn.keyLabel
        if hk ~= nil and hk.style ~= nil and hk.style.SetColor ~= nil then
            hk.style:SetColor(0.95, 0.95, 0.98, 1.0)
            if hk.style.SetFontSize ~= nil then
                hk.style:SetFontSize(9)
            end
        end

        -- Style stack / count label if accessible
        local stack = btn.stack or btn.count or btn.stackLabel
        if stack ~= nil and stack.style ~= nil and stack.style.SetColor ~= nil then
            stack.style:SetColor(Theme.Colors.TextGold[1], Theme.Colors.TextGold[2], Theme.Colors.TextGold[3], 1.0)
            if stack.style.SetFontSize ~= nil then
                stack.style:SetFontSize(9)
            end
        end
    end)
end

return BarSkinner
