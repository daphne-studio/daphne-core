---ND Core Framework Adapter
---Implements Bridge interface for ND Core framework

-- Load dependencies (these are loaded via shared_scripts, so they're available as globals)
-- Bridge, Config, and StateBag are loaded before this file in fxmanifest.lua
if not Bridge then
    error('[ND Core Adapter] Bridge not found! Make sure core/bridge.lua is loaded before this file.')
end

if not Config then
    error('[ND Core Adapter] Config not found! Make sure shared/config.lua is loaded before this file.')
end

if not StateBag then
    error('[ND Core Adapter] StateBag not found! Make sure core/statebag.lua is loaded before this file.')
end

if not Cache then
    error('[ND Core Adapter] Cache not found! Make sure core/cache.lua is loaded before this file.')
end

---@class NDCoreAdapter : Bridge
NDCoreAdapter = NDCoreAdapter or setmetatable({}, Bridge)
local NDCoreAdapter = NDCoreAdapter
NDCoreAdapter.__index = NDCoreAdapter

NDCoreAdapter.name = 'ND Core'
NDCoreAdapter.initialized = false
NDCoreAdapter.NDCore = nil

---Try to get ND Core object with multiple methods
---@return table|nil ndCore ND Core object or nil
local function GetNDCoreObject()
    -- Method 1: Try export method (ND_Core is the correct export name)
    local success, ndCore = pcall(function()
        if exports['ND_Core'] and type(exports['ND_Core']) == 'table' then
            -- Check if it has getPlayer method (can be called with : or .)
            if exports['ND_Core'].getPlayer or (type(exports['ND_Core'].getPlayer) == 'function') then
                return exports['ND_Core']
            end
        end
        return nil
    end)
    if success and ndCore then
        return ndCore
    end
    
    -- Method 2: Try global NDCore variable (might be set from exports)
    success, ndCore = pcall(function()
        if NDCore and type(NDCore) == 'table' then
            if NDCore.getPlayer or (type(NDCore.getPlayer) == 'function') then
                return NDCore
            end
        end
        return nil
    end)
    if success and ndCore then
        return ndCore
    end
    
    -- Method 3: Try lowercase export as fallback
    success, ndCore = pcall(function()
        if exports['nd_core'] and type(exports['nd_core']) == 'table' then
            if exports['nd_core'].getPlayer then
                return exports['nd_core']
            end
        end
        return nil
    end)
    if success and ndCore then
        return ndCore
    end
    
    return nil
end

---Initialize ND Core adapter with retry logic
---@param retries number? Number of retries (default: 10)
---@param delay number? Delay between retries in ms (default: 500)
---@return boolean success
function NDCoreAdapter:Initialize(retries, delay)
    if self.initialized then
        return true
    end
    
    retries = retries or 10
    delay = delay or 500
    
    -- Try to get ND Core object
    for i = 1, retries do
        local success, ndCore = pcall(function()
            return GetNDCoreObject()
        end)
        
        if success and ndCore then
            self.NDCore = ndCore
            self.initialized = true
            print('[Daphne Core] ND Core adapter initialized successfully')
            return true
        end
        
        -- Wait before retrying (except on last attempt)
        if i < retries then
            Wait(delay)
        end
    end
    
    -- Final attempt with detailed error message
    local resourceState1 = GetResourceState('ND_Core')
    local resourceState2 = GetResourceState('nd_core')
    
    print('[Daphne Core] ND Core not found!')
    print(string.format('[Daphne Core] ND_Core resource state: %s', resourceState1))
    print(string.format('[Daphne Core] nd_core resource state: %s', resourceState2))
    print('[Daphne Core] Make sure ND_Core is started BEFORE daphne_core in server.cfg')
    print('[Daphne Core] Example: ensure ND_Core')
    print('[Daphne Core]          ensure daphne_core')
    
    -- Check if export exists
    local hasExport = pcall(function() return exports['ND_Core'] ~= nil end)
    print(string.format('[Daphne Core] exports["ND_Core"] available: %s', hasExport and 'yes' or 'no'))
    
    return false
end

---Get ND Core object
---@return table|nil ndCore ND Core object
function NDCoreAdapter:GetNDCore()
    if not self.initialized then
        local success = self:Initialize()
        if not success then
            -- Initialize failed, ND Core not available
            return nil
        end
    end
    
    -- Double-check that ND Core is still valid
    if not self.NDCore then
        return nil
    end
    
    return self.NDCore
end

---Get player object from source
---@param source number Player server ID
---@return table|nil player Player object or nil if not found
function NDCoreAdapter:GetPlayer(source)
    -- Check cache first
    local cachedPlayer = Cache.GetPlayer(source)
    if cachedPlayer then
        return cachedPlayer
    end
    
    -- Get from framework
    local ndCore = self:GetNDCore()
    if not ndCore then 
        return nil 
    end
    
    -- Check if ND Core has getPlayer method
    if not ndCore.getPlayer or type(ndCore.getPlayer) ~= 'function' then
        print('[Daphne Core] ERROR: ND Core object does not have getPlayer method')
        return nil
    end
    
    local success, player = pcall(function()
        -- ND Core uses : syntax for method calls (exports["ND_Core"]:getPlayer(source))
        -- But we can also try . syntax as fallback
        if type(ndCore.getPlayer) == 'function' then
            -- Try : syntax first (method call with self)
            return ndCore:getPlayer(source)
        end
        return nil
    end)
    
    if not success then
        print(string.format('[Daphne Core] ERROR: Failed to get player %s from ND Core: %s', source, tostring(player)))
        return nil
    end
    
    if player then
        -- Cache the player object
        Cache.SetPlayer(source, player)
    end
    
    return player
end

---Get player data from source
---@param source number Player server ID
---@return PlayerData|nil data Player data or nil if not found
function NDCoreAdapter:GetPlayerData(source)
    local player = self:GetPlayer(source)
    if not player then return nil end
    
    -- Map ND Core player data to Bridge PlayerData format
    local jobName, jobInfo = player.getJob()
    local jobInfo = jobInfo or {}
    
    local playerData = {
        source = source,
        citizenid = tostring(player.id),  -- Character ID
        name = player.fullname or (player.firstname .. ' ' .. player.lastname) or '',
        money = {
            cash = player.cash or player.getData('cash') or 0,
            bank = player.bank or player.getData('bank') or 0
        },
        job = {
            name = jobName or 'unemployed',
            label = jobInfo.label or 'Unemployed',
            grade = {
                level = jobInfo.rank or 0,
                name = jobInfo.rankName or 'unemployed',
                label = jobInfo.rankName or 'Unemployed',
                payment = 0  -- ND Core doesn't have payment info
            },
            onduty = nil  -- ND Core doesn't have duty system
        },
        metadata = player.metadata or {}
    }
    
    -- Note: State bag updates are handled by framework events, not read operations
    -- This improves performance by avoiding unnecessary updates on every read
    
    return playerData
end

---Get player money
---@param source number Player server ID
---@param type string Money type (cash, bank)
---@return number|nil amount Money amount or nil if not found
function NDCoreAdapter:GetMoney(source, type)
    local player = self:GetPlayer(source)
    if not player then return nil end
    
    local amount = nil
    if type == 'cash' then
        amount = player.cash or player.getData('cash')
    elseif type == 'bank' then
        amount = player.bank or player.getData('bank')
    end
    
    -- Note: State bag updates are handled by framework events, not read operations
    -- This improves performance by avoiding unnecessary updates on every read
    
    return amount
end

---Add money to player
---@param source number Player server ID
---@param type string Money type (cash, bank)
---@param amount number Amount to add
---@return boolean success True if successful
function NDCoreAdapter:AddMoney(source, type, amount)
    local player = self:GetPlayer(source)
    if not player then return false end
    
    local success = false
    if type == 'cash' or type == 'bank' then
        local success_call, result = pcall(function()
            return player.addMoney(type, amount, 'Daphne Core')
        end)
        
        if success_call and result then
            success = true
        end
    end
    
    if success then
        -- Invalidate cache to ensure fresh data
        Cache.InvalidatePlayer(source)
        -- Sync updated money to state bag (reactive update)
        local playerData = self:GetPlayerData(source)
        if playerData and playerData.money then
            StateBag.SetStateBag('player', source, 'money', playerData.money, false)
        end
    end
    
    return success
end

---Remove money from player
---@param source number Player server ID
---@param type string Money type (cash, bank)
---@param amount number Amount to remove
---@return boolean success True if successful
function NDCoreAdapter:RemoveMoney(source, type, amount)
    local player = self:GetPlayer(source)
    if not player then return false end
    
    -- Check if player has enough money
    local currentAmount = self:GetMoney(source, type)
    if not currentAmount or currentAmount < amount then
        return false
    end
    
    local success = false
    if type == 'cash' or type == 'bank' then
        local success_call, result = pcall(function()
            return player.deductMoney(type, amount, 'Daphne Core')
        end)
        
        if success_call and result then
            success = true
        end
    end
    
    if success then
        -- Invalidate cache to ensure fresh data
        Cache.InvalidatePlayer(source)
        -- Sync updated money to state bag (reactive update)
        local playerData = self:GetPlayerData(source)
        if playerData and playerData.money then
            StateBag.SetStateBag('player', source, 'money', playerData.money, false)
        end
    end
    
    return success
end

---Get player inventory
---@param source number Player server ID
---@return table|nil inventory Inventory data or nil if not found
function NDCoreAdapter:GetInventory(source)
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
    
    -- Try to get inventory from player data
    local inventory = player.inventory or player.getData('inventory')
    if inventory then
        return inventory
    end
    
    -- Fallback: return empty table
    return {}
end

---Get player job
---@param source number Player server ID
---@return JobData|nil job Job data or nil if not found
function NDCoreAdapter:GetJob(source)
    local player = self:GetPlayer(source)
    if not player then return nil end
    
    local jobName, jobInfo = player.getJob()
    local jobInfo = jobInfo or {}
    
    local job = {
        name = jobName or 'unemployed',
        label = jobInfo.label or 'Unemployed',
        grade = {
            level = jobInfo.rank or 0,
            name = jobInfo.rankName or 'unemployed',
            label = jobInfo.rankName or 'Unemployed',
            payment = 0  -- ND Core doesn't have payment info
        },
        onduty = nil  -- ND Core doesn't have duty system
    }
    
    -- Note: State bag updates are handled by framework events, not read operations
    -- This improves performance by avoiding unnecessary updates on every read
    
    return job
end

---Get vehicle data
---@param vehicle number Vehicle entity
---@return VehicleData|nil data Vehicle data or nil if not found
function NDCoreAdapter:GetVehicle(vehicle)
    if not DoesEntityExist(vehicle) then
        return nil
    end
    
    local ndCore = self:GetNDCore()
    if not ndCore then return nil end
    
    local plate = GetVehicleNumberPlateText(vehicle)
    local model = GetEntityModel(vehicle)
    local modelName = GetDisplayNameFromVehicleModel(model)
    
    -- Try to get vehicle data from ND Core
    local vehicleData = nil
    local success, data = pcall(function()
        if ndCore.getVehicle then
            return ndCore.getVehicle(vehicle)
        end
        return nil
    end)
    
    if success and data then
        vehicleData = data
    end
    
    local result = {
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
        result.props = vehicleData.properties or {}
        result.metadata = vehicleData.metadata or {}
        result.citizenid = vehicleData.owner
    end
    
    -- Note: State bag updates are handled by framework events, not read operations
    -- This improves performance by avoiding unnecessary updates on every read
    
    return result
end

---Get player metadata
---@param source number Player server ID
---@param key string? Metadata key (optional, returns all metadata if nil)
---@return any|nil metadata Metadata value or all metadata if key is nil
function NDCoreAdapter:GetMetadata(source, key)
    local player = self:GetPlayer(source)
    if not player then return nil end
    
    local success, metadata = pcall(function()
        if key then
            -- Get specific metadata key
            return player.getMetadata(key)
        else
            -- Get all metadata
            return player.metadata or {}
        end
    end)
    
    if success and metadata ~= nil then
        return metadata
    end
    
    return nil
end

---Set player metadata
---@param source number Player server ID
---@param key string Metadata key
---@param value any Metadata value
---@return boolean success True if successful
function NDCoreAdapter:SetMetadata(source, key, value)
    local player = self:GetPlayer(source)
    if not player then return false end
    
    local success, result = pcall(function()
        return player.setMetadata(key, value)
    end)
    
    if success then
        -- Invalidate cache to ensure fresh data
        Cache.InvalidatePlayer(source)
        
        -- Sync to state bag (reactive update)
        local playerData = self:GetPlayerData(source)
        if playerData then
            StateBag.SetStateBag('player', source, 'data', {
                citizenid = playerData.citizenid,
                name = playerData.name,
                money = playerData.money or {},
                job = playerData.job or {},
                metadata = playerData.metadata or {}
            }, false)
        end
        return true
    end
    
    return false
end

-- Export NDCoreAdapter as global for use in other scripts
NDCoreAdapter = NDCoreAdapter

return NDCoreAdapter

