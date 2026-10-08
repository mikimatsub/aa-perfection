local api = require("api")
local Theme = require("aa-perfection/core/theme")
local Guard = require("aa-perfection/core/api_guard")

local Auras = {
    playerBuffs = {},
    targetDebuffs = {},
    maxPlayerBuffs = 16,
    maxTargetDebuffs = 12
}

local ICON_SIZE = 24
local GAP = 3

local function formatDuration(sec)
    local s = tonumber(sec) or 0
    if s <= 0 then return "" end
    if s < 60 then
        return string.format("%ds", math.floor(s))
    elseif s < 3600 then
        return string.format("%dm", math.floor(s / 60))
    else
        return string.format("%dh", math.floor(s / 3600))
    end
end

function Auras:Init(playerFrame, targetFrame)
    if playerFrame ~= nil and playerFrame.window ~= nil then
        local pContainer = playerFrame.window:CreateChildWidget("emptywidget", "pui_player_auras", 0, true)
        pContainer:SetExtent(playerFrame.window:GetWidth(), ICON_SIZE)
        pContainer:AddAnchor("BOTTOMLEFT", playerFrame.window, "TOPLEFT", 0, -4)

        for i = 1, self.maxPlayerBuffs do
            local btn = CreateItemIconButton("pui_pbuff_" .. i, pContainer)
            btn:SetExtent(ICON_SIZE, ICON_SIZE)
            btn:AddAnchor("TOPLEFT", pContainer, (i - 1) * (ICON_SIZE + GAP), 0)
            F_SLOT.ApplySlotSkin(btn, btn.back, SLOT_STYLE.BUFF)
            btn:Clickable(false)

            local timeLbl = btn:CreateChildWidget("label", "dur", 0, true)
            timeLbl:SetExtent(ICON_SIZE, 10)
            timeLbl:AddAnchor("BOTTOM", btn, 0, 1)
            Theme.StyleLabel(timeLbl, 8, ALIGN.CENTER, Theme.Colors.TextGold, true)
            btn.timeLabel = timeLbl

            self.playerBuffs[i] = btn
            btn:Show(false)
        end
    end

    if targetFrame ~= nil and targetFrame.window ~= nil then
        local tContainer = targetFrame.window:CreateChildWidget("emptywidget", "pui_target_auras", 0, true)
        tContainer:SetExtent(targetFrame.window:GetWidth(), ICON_SIZE)
        tContainer:AddAnchor("TOPLEFT", targetFrame.window, "BOTTOMLEFT", 0, 6)

        for i = 1, self.maxTargetDebuffs do
            local btn = CreateItemIconButton("pui_tdebuff_" .. i, tContainer)
            btn:SetExtent(ICON_SIZE, ICON_SIZE)
            btn:AddAnchor("TOPLEFT", tContainer, (i - 1) * (ICON_SIZE + GAP), 0)
            F_SLOT.ApplySlotSkin(btn, btn.back, SLOT_STYLE.BUFF)
            btn:Clickable(false)

            -- Red border for target debuffs
            if btn.back ~= nil then
                btn.back:SetColor(1, 0.2, 0.2, 1)
            end

            local timeLbl = btn:CreateChildWidget("label", "dur", 0, true)
            timeLbl:SetExtent(ICON_SIZE, 10)
            timeLbl:AddAnchor("BOTTOM", btn, 0, 1)
            Theme.StyleLabel(timeLbl, 8, ALIGN.CENTER, Theme.Colors.TextPrimary, true)
            btn.timeLabel = timeLbl

            self.targetDebuffs[i] = btn
            btn:Show(false)
        end
    end
end

function Auras:Update()
    -- Update Player Buffs
    local pCount = Guard.UnitBuffCount("player")
    for i = 1, self.maxPlayerBuffs do
        local btn = self.playerBuffs[i]
        if btn ~= nil then
            if i <= pCount then
                local buff = Guard.UnitBuff("player", i)
                if buff ~= nil then
                    if buff.path then F_SLOT.SetIconBackGround(btn, buff.path) end
                    if buff.timeLeft then
                        btn.timeLabel:SetText(formatDuration(buff.timeLeft))
                    else
                        btn.timeLabel:SetText("")
                    end
                    btn:Show(true)
                else
                    btn:Show(false)
                end
            else
                btn:Show(false)
            end
        end
    end

    -- Update Target Debuffs
    local targetId = Guard.GetUnitId("target")
    if targetId == nil then
        for i = 1, self.maxTargetDebuffs do
            if self.targetDebuffs[i] ~= nil then self.targetDebuffs[i]:Show(false) end
        end
        return
    end

    local tCount = Guard.UnitDeBuffCount("target")
    for i = 1, self.maxTargetDebuffs do
        local btn = self.targetDebuffs[i]
        if btn ~= nil then
            if i <= tCount then
                local debuff = Guard.UnitDeBuff("target", i)
                if debuff ~= nil then
                    if debuff.path then F_SLOT.SetIconBackGround(btn, debuff.path) end
                    if debuff.timeLeft then
                        btn.timeLabel:SetText(formatDuration(debuff.timeLeft))
                    else
                        btn.timeLabel:SetText("")
                    end
                    btn:Show(true)
                else
                    btn:Show(false)
                end
            else
                btn:Show(false)
            end
        end
    end
end

return Auras
