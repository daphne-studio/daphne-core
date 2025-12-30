---Qbox Framework Adapter
---Implements Bridge interface for Qbox/QBCore framework

-- Load dependencies (these are loaded via shared_scripts, so they're available as globals)
-- Bridge, Config, and StateBag are loaded before this file in fxmanifest.lua
if not Bridge then
    error('[Qbox Adapter] Bridge not found! Make sure core/bridge.lua is loaded before this file.')
end

if not Config then
    error('[Qbox Adapter] Config not found! Make sure shared/config.lua is loaded before this file.')
end

if not StateBag then
    error('[Qbox Adapter] StateBag not found! Make sure core/statebag.lua is loaded before this file.')
end

if not Cache then
    error('[Qbox Adapter] Cache not found! Make sure core/cache.lua is loaded before this file.')
end

---@class QboxAdapter : Bridge
QboxAdapter = QboxAdapter or setmetatable({}, Bridge)
local QboxAdapter = QboxAdapter
QboxAdapter.__index = QboxAdapter

QboxAdapter.name = 'Qbox'
QboxAdapter.initialized = false
QboxAdapter.QBCore = nil
QboxAdapter.PlayerData = nil

---Try to get QBCore object with multiple methods
---@return table|nil qbCore QBCore object or nil
local function GetQBCoreObject()
    -- Method 1: Try QBX GetCoreObject export (Qbox)
    local success, qbCore = pcall(function()
        if exports['qbx_core'] then
            if type(exports['qbx_core'].GetCoreObject) == 'function' then
                return exports['qbx_core']:GetCoreObject()
            elseif type(exports['qbx_core']) == 'table' and exports['qbx_core'].GetCoreObject then
                return exports['qbx_core']:GetCoreObject()
            end
        end
        return nil
    end)
    if success and qbCore then
        return qbCore
    end
    
    -- Method 2: Try standard QBCore GetCoreObject export
    success, qbCore = pcall(function()
        if exports['qb-core'] then
            if type(exports['qb-core'].GetCoreObject) == 'function' then
                return exports['qb-core']:GetCoreObject()
            elseif type(exports['qb-core']) == 'table' and exports['qb-core'].GetCoreObject then
                return exports['qb-core']:GetCoreObject()
            end
        end
        return nil
    end)
    if success and qbCore then
        return qbCore
    end
    
    -- Method 3: Try direct export access (for compatibility)
    success, qbCore = pcall(function()
        if exports['qbx_core'] and type(exports['qbx_core']) == 'table' then
            -- Check if it's already the QBCore object (has GetPlayer method)
            if exports['qbx_core'].GetPlayer then
                return exports['qbx_core']
            end
        end
        if exports['qb-core'] and type(exports['qb-core']) == 'table' then
            -- Check if it's already the QBCore object (has GetPlayer method)
            if exports['qb-core'].GetPlayer then
                return exports['qb-core']
            end
        end
        return nil
    end)
    if success and qbCore then
        return qbCore
    end
    
    -- Method 4: Try global QBCore variable (some setups use this)
    success, qbCore = pcall(function()
        if QBCore and type(QBCore) == 'table' and QBCore.GetPlayer then
            return QBCore
        end
        return nil
    end)
    if success and qbCore then
        return qbCore
    end
    
    return nil
end

---Initialize Qbox adapter with retry logic
---@param retries number? Number of retries (default: 10)
---@param delay number? Delay between retries in ms (default: 500)
---@return boolean success
function QboxAdapter:Initialize(retries, delay)
    if self.initialized then
        return true
    end
    
    retries = retries or 10
    delay = delay or 500
    
    -- Try to get QBCore object with retries
    local qbCore = nil
    for i = 1, retries do
        qbCore = GetQBCoreObject()
        
        if qbCore then
            -- Verify it's a valid QBCore object
            if type(qbCore) == 'table' and (qbCore.GetPlayer or qbCore.Functions) then
                self.QBCore = qbCore
                self.initialized = true
                print('[Daphne Core] Qbox adapter initialized successfully')
                return true
            end
        end
        
        -- Wait before retrying (except on last attempt)
        if i < retries then
            Wait(delay)
        end
    end
    
    -- Final attempt with detailed error message
    local resourceState = GetResourceState('qbx_core')
    local qbResourceState = GetResourceState('qb-core')
    
    print('[Daphne Core] Qbox/QBCore not found!')
    print(string.format('[Daphne Core] qbx_core state: %s', resourceState))
    print(string.format('[Daphne Core] qb-core state: %s', qbResourceState))
    print('[Daphne Core] Make sure qbx_core or qb-core is started BEFORE daphne_core in server.cfg')
    print('[Daphne Core] Example: ensure qbx_core (or qb-core)')
    print('[Daphne Core]          ensure daphne_core')
    
    return false
end

---Get QBCore object
---@return table|nil qbCore QBCore object
function QboxAdapter:GetQBCore()
    if not self.initialized then
        self:Initialize()
    end
    return self.QBCore
end

---Get player object from source
---@param source number Player server ID
---@return table|nil player Player object or nil if not found
function QboxAdapter:GetPlayer(source)
    -- Check cache first
    local cachedPlayer = Cache.GetPlayer(source)
    if cachedPlayer then
        return cachedPlayer
    end
    
    -- Get from framework
    local qbCore = self:GetQBCore()
    if not qbCore then return nil end
    
    local player = qbCore:GetPlayer(source)
    if player then
        -- Cache the player object
        Cache.SetPlayer(source, player)
    end
    
    return player
end

---Get player data from source
---@param source number Player server ID
---@return PlayerData|nil data Player data or nil if not found
function QboxAdapter:GetPlayerData(source)
    local player = self:GetPlayer(source)
    if not player then return nil end
    
    local playerData = player.PlayerData
    
    -- Note: State bag updates are handled by framework events, not read operations
    -- This improves performance by avoiding unnecessary updates on every read
    
    return playerData
end

---Get player money
---@param source number Player server ID
---@param type string Money type (cash, bank, crypto, etc.)
---@return number|nil amount Money amount or nil if not found
function QboxAdapter:GetMoney(source, type)
    local player = self:GetPlayer(source)
    if not player then return nil end
    
    local money = player.PlayerData.money[type]
    
    -- Note: State bag updates are handled by framework events, not read operations
    -- This improves performance by avoiding unnecessary updates on every read
    
    return money
end

---Add money to player
---@param source number Player server ID
---@param type string Money type (cash, bank, crypto, etc.)
---@param amount number Amount to add
---@return boolean success True if successful
function QboxAdapter:AddMoney(source, type, amount)
    local player = self:GetPlayer(source)
    if not player then return false end
    
    local success = player.Functions.AddMoney(type, amount)
    
    if success then
        -- Invalidate cache to ensure fresh data
        Cache.InvalidatePlayer(source)
        -- Sync updated money to state bag (reactive update)
        StateBag.SetStateBag('player', source, 'money', player.PlayerData.money, false)
    end
    
    return success
end

---Remove money from player
---@param source number Player server ID
---@param type string Money type (cash, bank, crypto, etc.)
---@param amount number Amount to remove
---@return boolean success True if successful
function QboxAdapter:RemoveMoney(source, type, amount)
    local player = self:GetPlayer(source)
    if not player then return false end
    
    local success = player.Functions.RemoveMoney(type, amount)
    
    if success then
        -- Invalidate cache to ensure fresh data
        Cache.InvalidatePlayer(source)
        -- Sync updated money to state bag (reactive update)
        StateBag.SetStateBag('player', source, 'money', player.PlayerData.money, false)
    end
    
    return success
end

---Get player inventory
---@param source number Player server ID
---@return table|nil inventory Inventory data or nil if not found
function QboxAdapter:GetInventory(source)
    local player = self:GetPlayer(source)
    if not player then return nil end
    
    -- Check if using ox_inventory
    local usingOxInventory = false
    local success, _ = pcall(function()
        return exports.ox_inventory
    end)
    if success then
        usingOxInventory = true
    end
    
    -- If using ox_inventory, return empty table (ox_inventory works item-by-item)
    if usingOxInventory then
        return {}
    end
    
    -- Try to get inventory from exports
    local success, inventory = pcall(function()
        return exports['qbx_core']:GetInventory(source) or exports['qb-core']:GetInventory(source)
    end)
    
    if success and inventory then
        return inventory
    end
    
    -- Fallback to player data
    return player.PlayerData.items or {}
end

---Get player job
---@param source number Player server ID
---@return JobData|nil job Job data or nil if not found
function QboxAdapter:GetJob(source)
    local player = self:GetPlayer(source)
    if not player then return nil end
    
    local job = player.PlayerData.job
    
    -- Note: State bag updates are handled by framework events, not read operations
    -- This improves performance by avoiding unnecessary updates on every read
    
    return job
end

---Get player gang
---@param source number Player server ID
---@return GangData|nil gang Gang data or nil if not found
function QboxAdapter:GetGang(source)
    local player = self:GetPlayer(source)
    if not player then return nil end
    
    local gang = player.PlayerData.gang
    
    -- Note: State bag updates are handled by framework events, not read operations
    -- This improves performance by avoiding unnecessary updates on every read
    
    return gang
end

---Get player metadata
---@param source number Player server ID
---@param key string? Metadata key (optional, returns all metadata if nil)
---@return any|nil metadata Metadata value or all metadata if key is nil
function QboxAdapter:GetMetadata(source, key)
    local player = self:GetPlayer(source)
    if not player then return nil end
    
    local metadata = player.PlayerData.metadata or {}
    
    if key then
        return metadata[key]
    end
    
    return metadata
end

---Set player metadata
---@param source number Player server ID
---@param key string Metadata key
---@param value any Metadata value
---@return boolean success True if successful
function QboxAdapter:SetMetadata(source, key, value)
    local player = self:GetPlayer(source)
    if not player then return false end
    
    if not player.PlayerData.metadata then
        player.PlayerData.metadata = {}
    end
    
    player.PlayerData.metadata[key] = value
    
    -- Invalidate cache to ensure fresh data
    Cache.InvalidatePlayer(source)
    
    -- Sync to state bag (reactive update)
    StateBag.SetStateBag('player', source, 'data', {
        citizenid = player.PlayerData.citizenid,
        name = player.PlayerData.charinfo and (player.PlayerData.charinfo.firstname .. ' ' .. player.PlayerData.charinfo.lastname) or '',
        money = player.PlayerData.money or {},
        job = player.PlayerData.job or {},
        gang = player.PlayerData.gang or {},
        metadata = player.PlayerData.metadata or {}
    }, false)
    
    return true
end

---Get vehicle data
---@param vehicle number Vehicle entity
---@return VehicleData|nil data Vehicle data or nil if not found
function QboxAdapter:GetVehicle(vehicle)
    if not DoesEntityExist(vehicle) then
        return nil
    end
    
    local plate = GetVehicleNumberPlateText(vehicle)
    local model = GetEntityModel(vehicle)
    local modelName = GetDisplayNameFromVehicleModel(model)
    
    -- Try to get vehicle data from database/exports
    local qbCore = self:GetQBCore()
    local vehicleData = nil
    
    if qbCore then
        local success, data = pcall(function()
            -- Try QBX export first
            if exports['qbx_core'] and exports['qbx_core'].GetVehicleByPlate then
                return exports['qbx_core']:GetVehicleByPlate(plate)
            end
            -- Try QBCore export
            if exports['qb-core'] and exports['qb-core'].GetVehicleByPlate then
                return exports['qb-core']:GetVehicleByPlate(plate)
            end
            return nil
        end)
        
        if success and data then
            vehicleData = data
        end
    end
    
    local data = {
        plate = plate,
        model = modelName,
        props = {},
        metadata = {},
        citizenid = nil,
        engine = nil,
        body = nil,
        fuel = nil
    }
    
    if vehicleData then
        data.props = vehicleData.mods or vehicleData.props or {}
        data.metadata = vehicleData.metadata or {}
        data.citizenid = vehicleData.citizenid
        data.engine = vehicleData.engine
        data.body = vehicleData.body
        data.fuel = vehicleData.fuel
    end
    
    -- Note: State bag updates are handled by framework events, not read operations
    -- This improves performance by avoiding unnecessary updates on every read
    
    return data
end

-- Export QboxAdapter as global for use in other scripts
QboxAdapter = QboxAdapter

return QboxAdapter

