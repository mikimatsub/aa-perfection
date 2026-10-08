local api = require("api")

-- Core modules
local Settings = require("aa-perfection/core/settings")
local Theme = require("aa-perfection/core/theme")
local Events = require("aa-perfection/core/events")
local Mover = require("aa-perfection/core/mover")
local Logger = require("aa-perfection/core/logger")
local SettingsPage = require("aa-perfection/core/settings_page")

-- Feature modules
local BagView = require("aa-perfection/modules/inventory/bag_view")
local SwapBar = require("aa-perfection/modules/actionbars/swap_bar")
local BarSkinner = require("aa-perfection/modules/actionbars/bar_skinner")
local CastBar = require("aa-perfection/modules/combat_hud/castbar")
local CCTracker = require("aa-perfection/modules/combat_hud/cc_tracker")
local ComboHUD = require("aa-perfection/modules/combat_hud/combo_hud")
local PlayerFrame = require("aa-perfection/modules/unitframes/player_frame")
local TargetFrame = require("aa-perfection/modules/unitframes/target_frame")
local SecondaryFrames = require("aa-perfection/modules/unitframes/secondary")
local RaidFrames = require("aa-perfection/modules/unitframes/raid_frames")
local PartyFrames = require("aa-perfection/modules/unitframes/party_frames")
local Auras = require("aa-perfection/modules/unitframes/auras")
local LaborHUD = require("aa-perfection/modules/gameplay/labor_hud")
local SpeedGlider = require("aa-perfection/modules/gameplay/speed_glider")
local TradeAssist = require("aa-perfection/modules/gameplay/trade_assist")
local QuestTracker = require("aa-perfection/modules/chat_quest/quest_tracker")
local ChatStyler = require("aa-perfection/modules/chat_quest/chat_styler")

local PerfectionAddon = {
    name = "Perfection UI",
    author = "mikimatsub",
    version = "1.0.0",
    desc = "Definitive UI Overhaul for ArcheAge Classic"
}

local function handleSlashCommand(message)
    local msg = tostring(message or ""):lower():gsub("^%s+", ""):gsub("%s+$", "")
    if not msg:find("^!pui") and not msg:find("^/pui") then
        return false
    end

    local args = {}
    for word in msg:gmatch("%S+") do
        table.insert(args, word)
    end

    local cmd = args[2] or ""

    if cmd == "edit" or cmd == "move" or cmd == "unlock" then
        Mover:ToggleEditMode()
        return true
    elseif cmd == "settings" or cmd == "config" or cmd == "menu" then
        SettingsPage:Toggle()
        return true
    elseif cmd == "bag" or cmd == "inv" then
        BagView:Toggle()
        return true
    elseif cmd == "quest" or cmd == "objectives" then
        QuestTracker:ToggleCollapse()
        return true
    elseif cmd == "swap" then
        SwapBar:Refresh()
        Logger:Info("Quick Swap bar refreshed.")
        return true
    else
        Logger:Info("Perfection UI v1.0.0 commands:")
        Logger:Info("  /pui settings - Open in-game configuration GUI")
        Logger:Info("  /pui edit     - Unlock/Lock all UI frames for moving")
        Logger:Info("  /pui bag      - Toggle Next-Gen Smart Inventory")
        Logger:Info("  /pui quest    - Collapse or expand quest tracker")
        Logger:Info("  /pui swap     - Refresh Quick Swap equipment bar")
        return true
    end
end

local function OnLoad()
    Logger:Try("Settings:Load", function() Settings:Load() end)
    Logger:Try("SettingsPage:Init", function() SettingsPage:Init() end)

    -- Initialize Feature Modules
    Logger:Try("BarSkinner:Init", function() BarSkinner:Init() end)
    Logger:Try("SwapBar:Init", function() SwapBar:Init() end)
    Logger:Try("BagView:Init", function() BagView:Init() end)
    Logger:Try("CastBar:Init", function() CastBar:Init() end)
    Logger:Try("CCTracker:Init", function() CCTracker:Init() end)
    Logger:Try("ComboHUD:Init", function() ComboHUD:Init() end)
    Logger:Try("PlayerFrame:Init", function() PlayerFrame:Init() end)
    Logger:Try("TargetFrame:Init", function() TargetFrame:Init() end)
    Logger:Try("SecondaryFrames:Init", function() SecondaryFrames:Init() end)
    Logger:Try("RaidFrames:Init", function() RaidFrames:Init() end)
    Logger:Try("PartyFrames:Init", function() PartyFrames:Init() end)
    Logger:Try("Auras:Init", function() Auras:Init(PlayerFrame, TargetFrame) end)
    Logger:Try("LaborHUD:Init", function() LaborHUD:Init() end)
    Logger:Try("SpeedGlider:Init", function() SpeedGlider:Init() end)
    Logger:Try("TradeAssist:Init", function() TradeAssist:Init() end)
    Logger:Try("QuestTracker:Init", function() QuestTracker:Init() end)
    Logger:Try("ChatStyler:Init", function() ChatStyler:Init() end)

    -- High-frequency ticker (16ms = ~60 FPS): Castbar & Speedometer
    Events:RegisterTicker("fast_hud", 16, function(dt)
        if Settings:IsModuleEnabled("combat_hud") then CastBar:Update(dt) end
        if Settings:IsModuleEnabled("gameplay") then SpeedGlider:Update(dt) end
    end)

    -- Medium-frequency ticker (50ms = ~20 FPS): Unit frames, combat HUD, and auras
    Events:RegisterTicker("unit_frames", 50, function(dt)
        if Settings:IsModuleEnabled("unitframes") then
            PlayerFrame:Update()
            TargetFrame:Update()
            SecondaryFrames:Update()
            Auras:Update()
        end
        if Settings:IsModuleEnabled("combat_hud") then
            CCTracker:Update()
            ComboHUD:Update()
        end
    end)

    -- Group-frequency ticker (100ms = 10 FPS): 50-man raid & party frames
    Events:RegisterTicker("group_frames", 100, function(dt)
        if Settings:IsModuleEnabled("unitframes") then
            RaidFrames:Update()
            PartyFrames:Update()
        end
    end)

    -- Low-frequency ticker (500ms = 2 FPS): Labor, trade, and quests
    Events:RegisterTicker("slow_gameplay", 500, function(dt)
        if Settings:IsModuleEnabled("gameplay") then
            LaborHUD:Update()
            TradeAssist:Update()
        end
        QuestTracker:Refresh()
    end)

    -- Engine event subscriptions
    Events:Subscribe("UPDATE", function(dt)
        Events:OnUpdate(dt)
    end)

    Events:Subscribe("CHAT_MESSAGE", function(channel, sender, message)
        handleSlashCommand(message)
    end)

    Logger:Info("Loaded successfully. Type |cFFE2B342/pui settings|r for options, or |cFFE2B342/pui edit|r to move frames.")
end

local function OnUnload()
    Events:ClearAll()
    if BagView.window ~= nil then BagView.window:Show(false) end
    if PlayerFrame.window ~= nil then PlayerFrame.window:Show(false) end
    if TargetFrame.window ~= nil then TargetFrame.window:Show(false) end
    if SecondaryFrames.tot.window ~= nil then SecondaryFrames.tot.window:Show(false) end
    if SecondaryFrames.focus.window ~= nil then SecondaryFrames.focus.window:Show(false) end
    if RaidFrames.window ~= nil then RaidFrames.window:Show(false) end
    if PartyFrames.window ~= nil then PartyFrames.window:Show(false) end
    if CastBar.window ~= nil then CastBar.window:Show(false) end
    if CCTracker.window ~= nil then CCTracker.window:Show(false) end
    if ComboHUD.window ~= nil then ComboHUD.window:Show(false) end
    if LaborHUD.window ~= nil then LaborHUD.window:Show(false) end
    if SpeedGlider.window ~= nil then SpeedGlider.window:Show(false) end
    if TradeAssist.window ~= nil then TradeAssist.window:Show(false) end
    if SwapBar.window ~= nil then SwapBar.window:Show(false) end
    if QuestTracker.window ~= nil then QuestTracker.window:Show(false) end
    if SettingsPage.window ~= nil then SettingsPage.window:Show(false) end
    Logger:Info("Unloaded cleanly.")
end

local function OnSettingToggle()
    SettingsPage:Toggle()
end

PerfectionAddon.OnLoad = OnLoad
PerfectionAddon.OnUnload = OnUnload
PerfectionAddon.OnSettingToggle = OnSettingToggle

return PerfectionAddon
