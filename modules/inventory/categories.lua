local Categories = {
    KEYS = {
        ALL         = "ALL",
        GEAR        = "GEAR",
        CONSUMABLE  = "CONSUMABLE",
        REGRADE     = "REGRADE",
        MATERIALS   = "MATERIALS",
        TRADE       = "TRADE",
        QUEST       = "QUEST",
        OTHER       = "OTHER"
    }
}

-- Keyword and pattern matcher based on ArcheAge item categorization
function Categories.ClassifyItem(itemInfo)
    if type(itemInfo) ~= "table" then return Categories.KEYS.OTHER end

    local name = tostring(itemInfo.name or itemInfo.itemName or ""):lower()
    local category = tostring(itemInfo.category or itemInfo.itemCategory or ""):lower()
    local equipSlot = tostring(itemInfo.equipSlot or itemInfo.equip_slot or ""):lower()

    -- Quest items
    if category:find("quest") or name:find("quest") then
        return Categories.KEYS.QUEST
    end

    -- Gear & Equipment
    if equipSlot ~= "" or category:find("weapon") or category:find("armor") or category:find("accessory")
        or category:find("shield") or category:find("bow") or category:find("instrument") or category:find("costume") then
        return Categories.KEYS.GEAR
    end

    -- Regrade, Gems, and Enchanting
    if name:find("regrade") or name:find("charm") or name:find("lunagem") or name:find("lunafrost")
        or name:find("temper") or name:find("anchor") or category:find("enchant") or category:find("gem") then
        return Categories.KEYS.REGRADE
    end

    -- Consumables & Buffs
    if category:find("consumable") or category:find("potion") or category:find("food") or category:find("drink")
        or name:find("potion") or name:find("soup") or name:find("bread") or name:find("spellbook") or name:find("grimoire") then
        return Categories.KEYS.CONSUMABLE
    end

    -- Trade, Cargo, and Specialties
    if name:find("pack") or name:find("specialty") or name:find("cargo") or name:find("design:")
        or category:find("trade") or category:find("specialty") then
        return Categories.KEYS.TRADE
    end

    -- Raw Materials & Crafting components
    if category:find("material") or category:find("ore") or category:find("ingot") or category:find("lumber")
        or category:find("log") or category:find("fabric") or category:find("leather") or category:find("archeum")
        or name:find("archeum") or name:find("ingot") or name:find("lumber") or name:find("fabric") or name:find("leather") then
        return Categories.KEYS.MATERIALS
    end

    return Categories.KEYS.OTHER
end

return Categories
