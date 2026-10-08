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

-- Creates an Obsidian sleek solid panel backdrop on any window/widget
function Theme.ApplyBackdrop(widget, bgColor, borderColor)
    if widget == nil then return nil end
    local bg = widget:CreateImageDrawable("Textures/Defaults/White.dds", "background")
    local c = bgColor or Theme.Colors.BgDark
    bg:SetColor(c[1], c[2], c[3], c[4] or 0.94)
    bg:AddAnchor("TOPLEFT", widget, 0, 0)
    bg:AddAnchor("BOTTOMRIGHT", widget, 0, 0)
    widget.__pui_bg = bg
    return bg
end

-- Creates a sleek subtle 1px border around a frame
function Theme.ApplyBorder(widget, borderColor)
    if widget == nil then return nil end
    local bc = borderColor or Theme.Colors.BorderSubtle
    -- Top border
    local top = widget:CreateImageDrawable("Textures/Defaults/White.dds", "overlay")
    top:SetColor(bc[1], bc[2], bc[3], bc[4] or 1.0)
    top:AddAnchor("TOPLEFT", widget, 0, 0)
    top:AddAnchor("BOTTOMRIGHT", widget, "TOPRIGHT", 0, 1)

    -- Bottom border
    local bot = widget:CreateImageDrawable("Textures/Defaults/White.dds", "overlay")
    bot:SetColor(bc[1], bc[2], bc[3], bc[4] or 1.0)
    bot:AddAnchor("TOPLEFT", widget, "BOTTOMLEFT", 0, -1)
    bot:AddAnchor("BOTTOMRIGHT", widget, 0, 0)

    -- Left border
    local left = widget:CreateImageDrawable("Textures/Defaults/White.dds", "overlay")
    left:SetColor(bc[1], bc[2], bc[3], bc[4] or 1.0)
    left:AddAnchor("TOPLEFT", widget, 0, 0)
    left:AddAnchor("BOTTOMRIGHT", widget, "BOTTOMLEFT", 1, 0)

    -- Right border
    local right = widget:CreateImageDrawable("Textures/Defaults/White.dds", "overlay")
    right:SetColor(bc[1], bc[2], bc[3], bc[4] or 1.0)
    right:AddAnchor("TOPLEFT", widget, "TOPRIGHT", -1, 0)
    right:AddAnchor("BOTTOMRIGHT", widget, 0, 0)

    widget.__pui_borders = { top, bot, left, right }
    return top
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

-- Formats a copper amount into clean G / S / C string
function Theme.FormatMoney(amount)
    local copper = math.floor(tonumber(amount) or 0)
    if copper <= 0 then return "0g 00s 00c" end
    local g = math.floor(copper / 10000)
    local s = math.floor((copper % 10000) / 100)
    local c = copper % 100

    local parts = {}
    if g > 0 then table.insert(parts, string.format("%dg", g)) end
    if s > 0 or g > 0 then table.insert(parts, string.format("%02ds", s)) end
    table.insert(parts, string.format("%02dc", c))
    return table.concat(parts, " ")
end

return Theme
