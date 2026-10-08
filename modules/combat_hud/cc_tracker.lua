local api = require("api")
local Theme = require("aa-perfection/core/theme")
local Guard = require("aa-perfection/core/api_guard")

local CCTracker = {
    window = nil,
    label = nil,
    activeCC = nil
}

-- Known ArcheAge crowd control keywords
local CC_KEYWORDS = {
    "stun", "trip", "sleep", "fear", "petrify", "bubble", "silence", "leech", "telekinesis", "shackle", "snare", "paralyze"
}

function CCTracker:Init()
    local wnd = api.Interface:CreateEmptyWindow("pui_cc_tracker", "UIParent")
    wnd:SetExtent(200, 32)
    wnd:AddAnchor("CENTER", "UIParent", 0, -120)
    wnd:SetUILayer("hud")

    Theme.ApplyBackdrop(wnd, Theme.Colors.CCWarning, Theme.Colors.BorderActive)
    Theme.ApplyBorder(wnd, Theme.Colors.TextGold)

    local lbl = wnd:CreateChildWidget("label", "ccText", 0, true)
    lbl:SetExtent(190, 28)
    lbl:AddAnchor("CENTER", wnd, 0, 0)
    Theme.StyleLabel(lbl, 13, ALIGN.CENTER, Theme.Colors.TextPrimary, true)
    self.label = lbl

    self.window = wnd
    wnd:Show(false)
end

function CCTracker:Update()
    local count = Guard.UnitDeBuffCount("player")
    local foundCC = nil

    if count > 0 then
        for i = 1, count do
            local debuff = Guard.UnitDeBuff("player", i)
            if debuff ~= nil then
                local name = tostring(debuff.name or ""):lower()
                for _, kw in ipairs(CC_KEYWORDS) do
                    if name:find(kw) then
                        foundCC = debuff.name or kw:upper()
                        break
                    end
                end
            end
            if foundCC then break end
        end
    end

    if foundCC then
        self.label:SetText(string.format("! %s !", foundCC:upper()))
        self.window:Show(true)
    else
        self.window:Show(false)
    end
end

return CCTracker
