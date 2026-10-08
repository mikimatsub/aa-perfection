local api = require("api")

local Settings = {
    data = nil,
    filePath = "aa-perfection/settings.txt"
}

local defaults = {
    version = "1.0.0",
    modules = {
        inventory   = true,
        combat_hud  = true,
        unitframes  = true,
        actionbars  = true,
        gameplay    = true,
        chat        = true,
        quest       = true
    },
    positions = {
        player_frame  = { x = 450, y = 620 },
        target_frame  = { x = 850, y = 620 },
        castbar       = { x = 650, y = 560 },
        combo_hud     = { x = 650, y = 500 },
        inventory     = { x = 700, y = 200 },
        labor_hud     = { x = 20, y = 20 },
        swap_bar      = { x = 650, y = 780 },
        micro_menu    = { x = 1630, y = 1040 },
        quest_tracker = { x = 1630, y = 180 },
        minimap_hud   = { x = 1700, y = 20 }
    },
    ui = {
        scale = 1.0,
        darkBackdropAlpha = 0.92,
        showTargetGearScore = true,
        showTargetGuild = true,
        showDebuffTimers = true,
        enableSpeedometer = true,
        enableLaborEngine = true,
        bagColumns = 10
    }
}

local function deepCopy(t)
    if type(t) ~= "table" then return t end
    local copy = {}
    for k, v in pairs(t) do
        copy[k] = deepCopy(v)
    end
    return copy
end

local function applyDefaults(target, source)
    for k, v in pairs(source) do
        if type(v) == "table" then
            if type(target[k]) ~= "table" then
                target[k] = {}
            end
            applyDefaults(target[k], v)
        elseif target[k] == nil then
            target[k] = v
        end
    end
end

function Settings:Load()
    local saved = nil
    if api.File ~= nil and api.File.Read ~= nil then
        local ok, res = pcall(function() return api.File:Read(self.filePath) end)
        if ok and type(res) == "table" then
            saved = res
        end
    end

    if saved == nil and api.GetSettings ~= nil then
        local ok, res = pcall(function() return api.GetSettings("aa-perfection") end)
        if ok and type(res) == "table" then
            saved = res
        end
    end

    self.data = deepCopy(defaults)
    if saved ~= nil then
        applyDefaults(self.data, saved)
    end
    return self.data
end

function Settings:Save()
    if self.data == nil then return end
    
    if api.File ~= nil and api.File.Write ~= nil then
        pcall(function() api.File:Write(self.filePath, self.data) end)
    end

    if api.SaveSettings ~= nil then
        pcall(function() api.SaveSettings() end)
    end
end

function Settings:GetPosition(key, defaultX, defaultY)
    if self.data == nil or self.data.positions == nil then
        return defaultX, defaultY
    end
    local pos = self.data.positions[key]
    if pos ~= nil and pos.x ~= nil and pos.y ~= nil then
        return pos.x, pos.y
    end
    return defaultX, defaultY
end

function Settings:SetPosition(key, x, y)
    if self.data == nil then self:Load() end
    if self.data.positions == nil then self.data.positions = {} end
    self.data.positions[key] = { x = math.floor(x), y = math.floor(y) }
    self:Save()
end

function Settings:IsModuleEnabled(moduleName)
    if self.data == nil then self:Load() end
    if self.data.modules == nil or self.data.modules[moduleName] == nil then
        return true
    end
    return self.data.modules[moduleName] == true
end

function Settings:SetModuleEnabled(moduleName, enabled)
    if self.data == nil then self:Load() end
    if self.data.modules == nil then self.data.modules = {} end
    self.data.modules[moduleName] = enabled and true or false
    self:Save()
end

return Settings
