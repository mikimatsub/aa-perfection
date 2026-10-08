local api = require("api")

local Guard = {}

local function sanitizeUnit(unit)
    if unit == nil then return nil end
    local str = tostring(unit):gsub("^%s+", ""):gsub("%s+$", "")
    if str == "" or str == "0" then return nil end
    return str
end

function Guard.SafePcall(fn, fallback)
    local ok, res = pcall(fn)
    if ok then
        return res
    end
    return fallback
end

-- ============================================================================
-- Unit API Guards
-- ============================================================================

function Guard.UnitHealth(unit)
    local u = sanitizeUnit(unit)
    if not u or api.Unit == nil or api.Unit.UnitHealth == nil then return 0 end
    return Guard.SafePcall(function() return tonumber(api.Unit:UnitHealth(u)) or 0 end, 0)
end

function Guard.UnitMaxHealth(unit)
    local u = sanitizeUnit(unit)
    if not u or api.Unit == nil or api.Unit.UnitMaxHealth == nil then return 1 end
    local maxHp = Guard.SafePcall(function() return tonumber(api.Unit:UnitMaxHealth(u)) or 1 end, 1)
    return maxHp > 0 and maxHp or 1
end

function Guard.UnitMana(unit)
    local u = sanitizeUnit(unit)
    if not u or api.Unit == nil or api.Unit.UnitMana == nil then return 0 end
    return Guard.SafePcall(function() return tonumber(api.Unit:UnitMana(u)) or 0 end, 0)
end

function Guard.UnitMaxMana(unit)
    local u = sanitizeUnit(unit)
    if not u or api.Unit == nil or api.Unit.UnitMaxMana == nil then return 1 end
    local maxMp = Guard.SafePcall(function() return tonumber(api.Unit:UnitMaxMana(u)) or 1 end, 1)
    return maxMp > 0 and maxMp or 1
end

function Guard.UnitName(unit)
    local u = sanitizeUnit(unit)
    if not u or api.Unit == nil or api.Unit.UnitName == nil then return "" end
    return Guard.SafePcall(function() return tostring(api.Unit:UnitName(u) or "") end, "")
end

function Guard.GetUnitId(unit)
    local u = sanitizeUnit(unit)
    if not u or api.Unit == nil or api.Unit.GetUnitId == nil then return nil end
    return Guard.SafePcall(function() return api.Unit:GetUnitId(u) end, nil)
end

function Guard.UnitLevel(unit)
    local u = sanitizeUnit(unit)
    if not u or api.Unit == nil then return nil end
    local ok, lvl = pcall(function()
        if api.Unit.UnitLevel ~= nil then
            return api.Unit:UnitLevel(u)
        end
        if api.Unit.GetUnitLevel ~= nil then
            return api.Unit:GetUnitLevel(u)
        end
        local uid = api.Unit:GetUnitId(u)
        if uid ~= nil and api.Unit.GetUnitInfoById ~= nil then
            local info = api.Unit:GetUnitInfoById(uid)
            if info ~= nil and info.level ~= nil then
                return info.level
            end
        end
        if u == "player" and api.Player ~= nil and api.Player.GetLevel ~= nil then
            return api.Player:GetLevel()
        end
        return nil
    end)
    if ok and lvl ~= nil and tonumber(lvl) then
        return tonumber(lvl)
    end
    return nil
end

function Guard.UnitScreenPosition(unit)
    local u = sanitizeUnit(unit)
    if not u or api.Unit == nil or api.Unit.GetUnitScreenPosition == nil then return nil, nil, nil end
    local ok, sx, sy, sz = pcall(function() return api.Unit:GetUnitScreenPosition(u) end)
    if ok and sx ~= nil then return sx, sy, sz end
    return nil, nil, nil
end

function Guard.UnitDistance(unit)
    local u = sanitizeUnit(unit)
    if not u or api.Unit == nil or api.Unit.UnitDistance == nil then return nil end
    return Guard.SafePcall(function() return tonumber(api.Unit:UnitDistance(u)) end, nil)
end

function Guard.UnitWorldPosition(unit)
    local u = sanitizeUnit(unit)
    if not u or api.Unit == nil or api.Unit.UnitWorldPosition == nil then return nil, nil, nil end
    local ok, x, y, z = pcall(function() return api.Unit:UnitWorldPosition(u) end)
    if ok and x ~= nil then return x, y, z end
    return nil, nil, nil
end

function Guard.UnitClass(unit)
    local u = sanitizeUnit(unit)
    if not u or api.Unit == nil or api.Unit.UnitClass == nil then return "" end
    return Guard.SafePcall(function() return tostring(api.Unit:UnitClass(u) or "") end, "")
end

function Guard.UnitGearScore(unit)
    local u = sanitizeUnit(unit)
    if not u or api.Unit == nil or api.Unit.UnitGearScore == nil then return 0 end
    return Guard.SafePcall(function() return tonumber(api.Unit:UnitGearScore(u)) or 0 end, 0)
end

function Guard.UnitBuffCount(unit)
    local u = sanitizeUnit(unit)
    if not u or api.Unit == nil or api.Unit.UnitBuffCount == nil then return 0 end
    return Guard.SafePcall(function() return tonumber(api.Unit:UnitBuffCount(u)) or 0 end, 0)
end

function Guard.UnitBuff(unit, index)
    local u = sanitizeUnit(unit)
    if not u or not index or api.Unit == nil or api.Unit.UnitBuff == nil then return nil end
    return Guard.SafePcall(function() return api.Unit:UnitBuff(u, index) end, nil)
end

function Guard.UnitDeBuffCount(unit)
    local u = sanitizeUnit(unit)
    if not u or api.Unit == nil or api.Unit.UnitDeBuffCount == nil then return 0 end
    return Guard.SafePcall(function() return tonumber(api.Unit:UnitDeBuffCount(u)) or 0 end, 0)
end

function Guard.UnitDeBuff(unit, index)
    local u = sanitizeUnit(unit)
    if not u or not index or api.Unit == nil or api.Unit.UnitDeBuff == nil then return nil end
    return Guard.SafePcall(function() return api.Unit:UnitDeBuff(u, index) end, nil)
end

function Guard.UnitIsForceAttack(unit)
    local u = sanitizeUnit(unit)
    if not u or api.Unit == nil or api.Unit.UnitIsForceAttack == nil then return false end
    return Guard.SafePcall(function() return api.Unit:UnitIsForceAttack(u) == true end, false)
end

function Guard.GetHighAbilityRscInfo()
    if api.Unit == nil or api.Unit.GetHighAbilityRscInfo == nil then return nil end
    return Guard.SafePcall(function() return api.Unit:GetHighAbilityRscInfo() end, nil)
end

-- ============================================================================
-- Bag & Inventory API Guards
-- ============================================================================

function Guard.BagCapacity()
    if api.Bag == nil or api.Bag.Capacity == nil then return 0 end
    return Guard.SafePcall(function() return tonumber(api.Bag:Capacity()) or 0 end, 0)
end

function Guard.GetBagItemInfo(bagType, slot)
    if not slot or api.Bag == nil or api.Bag.GetBagItemInfo == nil then return nil end
    return Guard.SafePcall(function() return api.Bag:GetBagItemInfo(bagType or 1, slot) end, nil)
end

function Guard.GetCurrency()
    if api.Bag == nil or api.Bag.GetCurrency == nil then return 0 end
    return Guard.SafePcall(function() return tonumber(api.Bag:GetCurrency()) or 0 end, 0)
end

function Guard.EquipBagItem(slot, isAux)
    if not slot or api.Bag == nil or api.Bag.EquipBagItem == nil then return false end
    return Guard.SafePcall(function()
        api.Bag:EquipBagItem(slot, isAux and true or false)
        return true
    end, false)
end

function Guard.GetItemInfoByType(itemType)
    if not itemType or api.Item == nil or api.Item.GetItemInfoByType == nil then return nil end
    return Guard.SafePcall(function() return api.Item:GetItemInfoByType(itemType) end, nil)
end

-- ============================================================================
-- Stock UI Interception Guards
-- ============================================================================

function Guard.GetStockContent(uicId)
    if uicId == nil or ADDON == nil or ADDON.GetContent == nil then return nil end
    return Guard.SafePcall(function() return ADDON:GetContent(uicId) end, nil)
end

function Guard.ShowStockContent(uicId, show)
    if uicId == nil or ADDON == nil or ADDON.ShowContent == nil then return false end
    return Guard.SafePcall(function()
        ADDON:ShowContent(uicId, show and true or false)
        return true
    end, false)
end

function Guard.RegisterContentTriggerFunc(uicId, callback)
    if uicId == nil or callback == nil or ADDON == nil or ADDON.RegisterContentTriggerFunc == nil then return false end
    return Guard.SafePcall(function()
        ADDON:RegisterContentTriggerFunc(uicId, callback)
        return true
    end, false)
end

return Guard
