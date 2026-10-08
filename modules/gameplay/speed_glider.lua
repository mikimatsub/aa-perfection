local api = require("api")
local Theme = require("aa-perfection/core/theme")
local Guard = require("aa-perfection/core/api_guard")

local SpeedGlider = {
    window = nil,
    speedLabel = nil,
    lastX = nil,
    lastY = nil,
    lastZ = nil,
    lastTime = nil
}

function SpeedGlider:Init()
    local wnd = api.Interface:CreateEmptyWindow("pui_speedometer", "UIParent")
    wnd:SetExtent(100, 24)
    wnd:AddAnchor("BOTTOM", "UIParent", 0, -210)
    wnd:SetUILayer("hud")

    Theme.ApplyBackdrop(wnd, Theme.Colors.BgDark, Theme.Colors.BorderSubtle)

    local lbl = wnd:CreateChildWidget("label", "speed", 0, true)
    lbl:SetExtent(96, 20)
    lbl:AddAnchor("CENTER", wnd, 0, 0)
    Theme.StyleLabel(lbl, 11, ALIGN.CENTER, Theme.Colors.GildaStarCyan, true)
    self.speedLabel = lbl

    self.window = wnd
    wnd:Show(false)
end

function SpeedGlider:Update(dtMs)
    local x, y, z = Guard.UnitWorldPosition("player")
    if x == nil then return end

    local now = api.Time ~= nil and api.Time:GetUiMsec() or 0
    if self.lastX ~= nil and self.lastTime ~= nil then
        local elapsedSec = (now - self.lastTime) / 1000
        if elapsedSec > 0.05 then
            local dx = x - self.lastX
            local dy = y - self.lastY
            local dz = z - self.lastZ
            local dist = math.sqrt((dx * dx) + (dy * dy) + (dz * dz))
            local speedMs = dist / elapsedSec

            if speedMs > 0.5 then
                self.speedLabel:SetText(string.format("%.1f m/s", speedMs))
                self.window:Show(true)
            else
                self.window:Show(false)
            end

            self.lastX = x
            self.lastY = y
            self.lastZ = z
            self.lastTime = now
        end
    else
        self.lastX = x
        self.lastY = y
        self.lastZ = z
        self.lastTime = now
    end
end

return SpeedGlider
