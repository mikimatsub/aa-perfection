local api = require("api")
local Guard = require("aa-perfection/core/api_guard")
local Categories = require("aa-perfection/modules/inventory/categories")

local Scanner = {}

local function stripLinkFormatting(text)
    local s = tostring(text or "")
    s = s:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", "")
    s = s:gsub("%s+", " ")
    return s:gsub("^%s+", ""):gsub("%s+$", "")
end

function Scanner:ScanBag()
    local capacity = Guard.BagCapacity()
    if capacity <= 0 then return {}, 0, 0 end

    local items = {}
    local usedCount = 0

    for slot = 1, capacity do
        local info = Guard.GetBagItemInfo(1, slot)
        if type(info) == "table" then
            local rawName = info.name or info.itemName or info.linkText or ""
            local cleanName = stripLinkFormatting(rawName)
            
            if cleanName ~= "" then
                usedCount = usedCount + 1
                local itemType = tonumber(info.itemType or info.item_type or info.typeId or info.id)
                local grade = tonumber(info.itemGrade or info.grade or 0) or 0
                local count = tonumber(info.stack or info.stackCount or info.itemCount or info.amount or 1) or 1
                local icon = info.iconPath or info.icon or info.path or ""

                -- If icon or category missing, query Item API
                if (icon == "" or info.category == nil) and itemType ~= nil then
                    local extra = Guard.GetItemInfoByType(itemType)
                    if type(extra) == "table" then
                        if icon == "" then icon = extra.iconPath or extra.icon or "" end
                        info.category = extra.category or info.category
                    end
                end

                local entry = {
                    slot        = slot,
                    name        = cleanName,
                    itemType    = itemType,
                    grade       = grade,
                    count       = count,
                    icon        = icon,
                    category    = Categories.ClassifyItem(info),
                    rawInfo     = info
                }
                table.insert(items, entry)
            end
        end
    end

    return items, usedCount, capacity
end

return Scanner
