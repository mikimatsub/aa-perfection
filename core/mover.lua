local api = require("api")
local Settings = require("aa-perfection/core/settings")
local Theme = require("aa-perfection/core/theme")

local Mover = {
    isUnlocked = false,
    registeredFrames = {},
    overlayWidgets = {}
}

function Mover:RegisterFrame(id, frame, displayName)
    if frame == nil then return end
    self.registeredFrames[id] = {
        frame = frame,
        name = displayName or id
    }

    frame:EnableDrag(true)

    frame:SetHandler("OnDragStart", function(selfWidget)
        if Mover.isUnlocked then
            selfWidget:StartMoving()
            if api.Cursor ~= nil and api.Cursor.SetCursorImage ~= nil then
                api.Cursor:SetCursorImage(CURSOR_PATH.MOVE, 0, 0)
            end
        end
    end)

    frame:SetHandler("OnDragStop", function(selfWidget)
        if Mover.isUnlocked then
            selfWidget:StopMovingOrSizing()
            if api.Cursor ~= nil and api.Cursor.ClearCursor ~= nil then
                api.Cursor:ClearCursor()
            end
            local x, y = selfWidget:GetOffset()
            Settings:SetPosition(id, x, y)
        end
    end)
end

function Mover:ToggleEditMode()
    self.isUnlocked = not self.isUnlocked
    if self.isUnlocked then
        self:ShowOverlays()
        if api.Log ~= nil and api.Log.Info ~= nil then
            api.Log:Info("[Perfection UI] Edit Mode: UNLOCKED. Drag frames to position them. Run '/pui edit' again to lock.")
        end
    else
        self:HideOverlays()
        if api.Log ~= nil and api.Log.Info ~= nil then
            api.Log:Info("[Perfection UI] Edit Mode: LOCKED and saved.")
        end
    end
end

function Mover:ShowOverlays()
    for id, entry in pairs(self.registeredFrames) do
        local frame = entry.frame
        if frame ~= nil then
            if self.overlayWidgets[id] == nil then
                local overlay = frame:CreateChildWidget("emptywidget", "pui_mover_" .. id, 0, true)
                overlay:AddAnchor("TOPLEFT", frame, 0, 0)
                overlay:AddAnchor("BOTTOMRIGHT", frame, 0, 0)
                
                local border = overlay:CreateNinePartDrawable(TEXTURE_PATH.HUD, "overlay")
                border:SetCoords(79, 203, 18, 23)
                border:SetInset(4, 4, 4, 4)
                border:SetColor(0.9, 0.7, 0.2, 0.9) -- Amber gold outline
                border:AddAnchor("TOPLEFT", overlay, -2, -2)
                border:AddAnchor("BOTTOMRIGHT", overlay, 2, 2)

                local label = overlay:CreateChildWidget("label", "label", 0, true)
                label:SetText(entry.name)
                Theme.StyleLabel(label, 12, ALIGN.CENTER, Theme.Colors.TextGold, true)
                label:AddAnchor("CENTER", overlay, 0, 0)

                self.overlayWidgets[id] = overlay
            end
            self.overlayWidgets[id]:Show(true)
        end
    end
end

function Mover:HideOverlays()
    for _, overlay in pairs(self.overlayWidgets) do
        if overlay ~= nil then
            overlay:Show(false)
        end
    end
end

return Mover
