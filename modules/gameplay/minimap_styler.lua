local api = require("api")
local Theme = require("aa-perfection/core/theme")
local Guard = require("aa-perfection/core/api_guard")
local Settings = require("aa-perfection/core/settings")
local Mover = require("aa-perfection/core/mover")

local MinimapStyler = {
    window = nil,
    zoneLabel = nil,
    statusLabel = nil,
    coordsLabel = nil,
    compassLabel = nil,
    lastZone = "",
    lastCoords = ""
}

local WIDTH = 200
local HEIGHT = 58
local PADDING = 6

function MinimapStyler:Init()
    local x, y = Settings:GetPosition("minimap_hud", 1700, 20)

    local wnd = api.Interface:CreateEmptyWindow("pui_minimap_hud", "UIParent")
    wnd:SetExtent(WIDTH, HEIGHT)
    wnd:AddAnchor("TOPLEFT", "UIParent", x, y)
    wnd:SetUILayer("hud")

    -- Solid Apex Obsidian Backdrop with 1px Hairline Border
    Theme.ApplyBackdrop(wnd, { 0.07, 0.08, 0.11, 0.94 }, Theme.Colors.BorderSubtle)
    Theme.ApplyBorder(wnd, Theme.Colors.BorderActive)

    -- Top Accent Line (Gold)
    local accent = wnd:CreateColorDrawable(Theme.Colors.BorderAccent[1], Theme.Colors.BorderAccent[2], Theme.Colors.BorderAccent[3], 1, "artwork")
    accent:SetExtent(WIDTH, 2)
    accent:AddAnchor("TOPLEFT", wnd, 0, 0)

    -- Zone Name Label (Top Left)
    local zoneLbl = wnd:CreateChildWidget("label", "zoneLabel", 0, true)
    zoneLbl:SetExtent(130, 16)
    zoneLbl:AddAnchor("TOPLEFT", wnd, PADDING, PADDING + 1)
    zoneLbl:SetText("UNKNOWN ZONE")
    Theme.StyleLabel(zoneLbl, 10, ALIGN.LEFT, Theme.Colors.TextPrimary, true)
    zoneLbl:SetAutoResize(false)
    self.zoneLabel = zoneLbl

    -- Zone Peace / War Status Badge (Top Right)
    local statusLbl = wnd:CreateChildWidget("label", "statusLabel", 0, true)
    statusLbl:SetExtent(54, 14)
    statusLbl:AddAnchor("TOPRIGHT", wnd, -PADDING, PADDING + 2)
    statusLbl:SetText("[ PEACE ]")
    Theme.StyleLabel(statusLbl, 8, ALIGN.RIGHT, Theme.Colors.HealthPlayer, true)
    self.statusLabel = statusLbl

    -- Live Coordinates (Bottom Left)
    local coordsLbl = wnd:CreateChildWidget("label", "coordsLabel", 0, true)
    coordsLbl:SetExtent(140, 14)
    coordsLbl:AddAnchor("BOTTOMLEFT", wnd, PADDING, -PADDING)
    coordsLbl:SetText("00.0, 00.0")
    Theme.StyleLabel(coordsLbl, 9, ALIGN.LEFT, Theme.Colors.TextGold, true)
    self.coordsLabel = coordsLbl

    -- World Map Pill Button (Bottom Right)
    local mapBtn = wnd:CreateChildWidget("button", "mapBtn", 0, true)
    mapBtn:SetExtent(36, 18)
    mapBtn:AddAnchor("BOTTOMRIGHT", wnd, -PADDING, -PADDING + 1)
    mapBtn:SetText("MAP")
    Theme.StyleLabel(mapBtn, 8, ALIGN.CENTER, Theme.Colors.TextPrimary, true)
    api.Interface:ApplyButtonSkin(mapBtn, BUTTON_BASIC.DEFAULT)

    mapBtn:SetHandler("OnClick", function()
        if UIC ~= nil and UIC.MAP ~= nil then
            local uicId = UIC.MAP
            local content = Guard.GetStockContent(uicId)
            if content ~= nil then
                Guard.ShowStockContent(uicId, not content:IsVisible())
                return
            end
        end
        if api.Input ~= nil and api.Input.DispatchKey ~= nil then
            pcall(function() api.Input:DispatchKey("toggle_world_map") end)
        end
    end)

    Mover:RegisterFrame("minimap_hud", wnd, "Minimap HUD Banner")
    self.window = wnd
    wnd:Show(true)

    self:Update()
end

function MinimapStyler:Update()
    if self.window == nil then return end

    if not Settings:IsModuleEnabled("gameplay") then
        self.window:Show(false)
        return
    end
    self.window:Show(true)

    -- 1. Query Coordinates (Sextant or World XY)
    local coordStr = nil
    if api.Map ~= nil and api.Map.GetPlayerSextants ~= nil then
        local sextant = Guard.SafePcall(function() return api.Map:GetPlayerSextants() end, nil)
        if type(sextant) == "table" and sextant.deg_long ~= nil and sextant.deg_lat ~= nil then
            coordStr = string.format("%s %d°%02d'  %s %d°%02d'",
                sextant.longitude or "W", sextant.deg_long or 0, sextant.min_long or 0,
                sextant.latitude or "S", sextant.deg_lat or 0, sextant.min_lat or 0)
        elseif type(sextant) == "table" and sextant.longitudeDeg ~= nil then
            coordStr = string.format("%s %d°%02d'  %s %d°%02d'",
                sextant.longitudeDir or "W", sextant.longitudeDeg or 0, sextant.longitudeMin or 0,
                sextant.latitudeDir or "S", sextant.latitudeDeg or 0, sextant.latitudeMin or 0)
        end
    end

    if coordStr == nil then
        local wx, wy, _ = Guard.UnitWorldPosition("player")
        if wx ~= nil and wy ~= nil then
            coordStr = string.format("X: %.0f  Y: %.0f", wx, wy)
        else
            coordStr = "LOC: --, --"
        end
    end

    if coordStr ~= self.lastCoords then
        self.coordsLabel:SetText(coordStr)
        self.lastCoords = coordStr
    end

    -- 2. Query Zone Name
    local zoneName = nil
    if api.Zone ~= nil and api.Zone.GetZoneName ~= nil then
        zoneName = Guard.SafePcall(function() return api.Zone:GetZoneName() end, nil)
    end
    if (not zoneName or zoneName == "") and api.Zone ~= nil and api.Zone.GetCurrentZoneName ~= nil then
        zoneName = Guard.SafePcall(function() return api.Zone:GetCurrentZoneName() end, nil)
    end
    if (not zoneName or zoneName == "") and api.Map ~= nil and api.Map.GetZoneInfo ~= nil then
        zoneName = Guard.SafePcall(function() return api.Map:GetZoneInfo() end, nil)
    end

    if zoneName and zoneName ~= "" and zoneName ~= self.lastZone then
        self.zoneLabel:SetText(zoneName)
        self.lastZone = zoneName
    end

    -- 3. Query Zone Conflict State
    local conflictState = nil
    if api.Zone ~= nil and api.Zone.GetZoneState ~= nil then
        conflictState = Guard.SafePcall(function() return api.Zone:GetZoneState() end, nil)
    end

    if conflictState == "war" or conflictState == 1 then
        self.statusLabel:SetText("[ WAR ]")
        Theme.StyleLabel(self.statusLabel, 8, ALIGN.RIGHT, Theme.Colors.HealthHostile, true)
    elseif conflictState == "conflict" or conflictState == 2 then
        self.statusLabel:SetText("[ CONFLICT ]")
        Theme.StyleLabel(self.statusLabel, 8, ALIGN.RIGHT, { 0.95, 0.70, 0.15, 1.0 }, true)
    else
        self.statusLabel:SetText("[ PEACE ]")
        Theme.StyleLabel(self.statusLabel, 8, ALIGN.RIGHT, Theme.Colors.HealthPlayer, true)
    end
end

return MinimapStyler
