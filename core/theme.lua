local api = require("api")

local Theme = {}

-- Hex to RGBA float conversion helper
local function HexToRGBA(hex, alpha)
    local cleanHex = tostring(hex or "FFFFFF"):gsub("#", "")
    local r = tonumber(cleanHex:sub(1, 2), 16) or 255
    local g = tonumber(cleanHex:sub(3, 4), 16) or 255
    local b = tonumber(cleanHex:sub(5, 6), 16) or 255
    local a = alpha ~= nil and alpha or 1.0
    return r / 255, g / 255, b / 255, a
end

Theme.Colors = {
    -- Backgrounds & Surfaces
    BgDark          = { HexToRGBA("0D0F14", 0.90) },
    BgCard          = { HexToRGBA("141721", 0.95) },
    BgElevated      = { HexToRGBA("1E2333", 0.98) },
    BorderSubtle    = { HexToRGBA("252A38", 1.00) },
    BorderActive    = { HexToRGBA("3D445C", 1.00) },
    BorderAccent    = { HexToRGBA("E2B342", 1.00) },

    -- Status & Combat Gauges
    HealthPlayer    = { HexToRGBA("10B981", 1.00) }, -- Emerald
    HealthHostile   = { HexToRGBA("EF4444", 1.00) }, -- Crimson Red
    HealthFriendly  = { HexToRGBA("06B6D4", 1.00) }, -- Cyan
    ManaPower       = { HexToRGBA("3B82F6", 1.00) }, -- Vibrant Blue
    CastBarAmber    = { HexToRGBA("F59E0B", 1.00) }, -- Amber
    CastSuccessGold = { HexToRGBA("EAB308", 1.00) }, -- Gold
    CCWarning       = { HexToRGBA("DC2626", 1.00) }, -- Deep Red

    -- ArcheAge Specifics
    LaborOrange     = { HexToRGBA("F97316", 1.00) }, -- Labor Power
    GoldCurrency    = { HexToRGBA("E2B342", 1.00) }, -- Gold / Apex
    GildaStarCyan   = { HexToRGBA("38BDF8", 1.00) }, -- Gilda
    HonorPurple     = { HexToRGBA("A855F7", 1.00) }, -- Honor
    VocationMint    = { HexToRGBA("34D399", 1.00) }, -- Vocation

    -- Roles
    RoleAttacker    = { HexToRGBA("EF4444", 1.00) },
    RoleDefender    = { HexToRGBA("EAB308", 1.00) },
    RoleHealer      = { HexToRGBA("EC4899", 1.00) },
    RoleUndecided   = { HexToRGBA("60A5FA", 1.00) },

    -- Typography
    TextPrimary     = { HexToRGBA("F8FAFC", 1.00) },
    TextSecondary   = { HexToRGBA("94A3B8", 1.00) },
    TextMuted       = { HexToRGBA("64748B", 1.00) },
    TextGold        = { HexToRGBA("FCD34D", 1.00) },
}

Theme.HexToRGBA = HexToRGBA

-- Creates an Obsidian sleek panel backdrop on any window/widget
function Theme.ApplyBackdrop(widget, bgColor, borderColor)
    if widget == nil then return nil end
    local bg = widget:CreateNinePartDrawable(TEXTURE_PATH.HUD, "background")
    bg:SetCoords(301, 120, 150, 19)
    bg:SetInset(6, 6, 6, 6)
    
    local c = bgColor or Theme.Colors.BgDark
    bg:SetColor(c[1], c[2], c[3], c[4])
    bg:AddAnchor("TOPLEFT", widget, 0, 0)
    bg:AddAnchor("BOTTOMRIGHT", widget, 0, 0)
    widget.__pui_bg = bg
    return bg
end

-- Creates an edge border overlay
function Theme.ApplyBorder(widget, borderColor)
    if widget == nil then return nil end
    local border = widget:CreateNinePartDrawable(TEXTURE_PATH.HUD, "overlay")
    border:SetCoords(79, 203, 18, 23)
    border:SetInset(4, 4, 4, 4)
    local bc = borderColor or Theme.Colors.BorderSubtle
    border:SetColor(bc[1], bc[2], bc[3], bc[4])
    border:AddAnchor("TOPLEFT", widget, -1, -1)
    border:AddAnchor("BOTTOMRIGHT", widget, 1, 1)
    widget.__pui_border = border
    return border
end

-- Sets font formatting cleanly
function Theme.StyleLabel(label, fontSize, align, color, shadow)
    if label == nil or label.style == nil then return end
    if fontSize then
        label.style:SetFontSize(fontSize)
    end
    if align ~= nil then
        label.style:SetAlign(align)
    end
    if color then
        label.style:SetColor(color[1], color[2], color[3], color[4] or 1)
    end
    if shadow ~= nil then
        label.style:SetShadow(shadow)
    end
end

-- Formats a gold amount into G / S / C string
function Theme.FormatMoney(amount)
    local copper = math.floor(tonumber(amount) or 0)
    if copper <= 0 then return "0|cFFFFD700g|r" end
    local g = math.floor(copper / 10000)
    local s = math.floor((copper % 10000) / 100)
    local c = copper % 100

    local parts = {}
    if g > 0 then table.insert(parts, string.format("%d|cFFFFD700g|r", g)) end
    if s > 0 or g > 0 then table.insert(parts, string.format("%02d|cFFC0C0C0s|r", s)) end
    table.insert(parts, string.format("%02d|cFFB87333c|r", c))
    return table.concat(parts, " ")
end

return Theme
