---ESX Framework Adapter
---Implements Bridge interface for ESX Legacy framework

-- Load dependencies (these are loaded via shared_scripts, so they're available as globals)
-- Bridge, Config, and StateBag are loaded before this file in fxmanifest.lua
if not Bridge then
    error('[ESX Adapter] Bridge not found! Make sure core/bridge.lua is loaded before this file.')
end

if not Config then
    error('[ESX Adapter] Config not found! Make sure shared/config.lua is loaded before this file.')
end

if not StateBag then
    error('[ESX Adapter] StateBag not found! Make sure core/statebag.lua is loaded before this file.')
end

if not Cache then
    error('[ESX Adapter] Cache not found! Make sure core/cache.lua is loaded before this file.')
end

---@class ESXAdapter : Bridge
ESXAdapter = ESXAdapter or setmetatable({}, Bridge)
local ESXAdapter = ESXAdapter
ESXAdapter.__index = ESXAdapter

ESXAdapter.name = 'ESX'
ESXAdapter.initialized = false
ESXAdapter.ESX = nil

---Initialize ESX adapter
---@return boolean success
function ESXAdapter:Initialize()
    if self.initialized then
        return true
    end
    
    -- Try to get ESX export (ESX Legacy method)
    local success, esx = pcall(function()
        -- Try export method first
        if exports['es_extended'] then
            return exports['es_extended']:getSharedObject()
        end
        -- Fallback: check if ESX is already loaded globally
        if ESX then
            return ESX
        end
        return nil
    end)
    
    if not success or not esx then
        print('[Daphne Core] ESX not found! Make sure es_extended resource is started.')
        return false
    end
    
    self.ESX = esx
    self.initialized = true
    
    print('[Daphne Core] ESX adapter initialized successfully')
    return true
end

---Get ESX object
---@return table|nil esx ESX object
function ESXAdapter:GetESX()
    if not self.initialized then
        self:Initialize()
    end
    return self.ESX
end

---Get player object from source
---@param source number Player server ID
---@return table|nil player Player object or nil if not found
function ESXAdapter:GetPlayer(source)
    -- Check cache first
    local cachedPlayer = Cache.GetPlayer(source)
    if cachedPlayer then
        return cachedPlayer
    end
    
    -- Get from framework
    local esx = self:GetESX()
    if not esx then return nil end
    
    local player = esx.GetPlayerFromId(source)
    if player then
        -- Cache the player object
        Cache.SetPlayer(source, player)
    end
    
    return player
end

---Get player data from source
---@param source number Player server ID
---@return PlayerData|nil data Player data or nil if not found
function ESXAdapter:GetPlayerData(source)
    local xPlayer = self:GetPlayer(source)
    if not xPlayer then return nil end
    
    -- Map ESX player data to Bridge PlayerData format
    local job = xPlayer.job or {}
    local bankAccount = xPlayer.getAccount('bank') or {money = 0}
    
    local playerData = {
        source = source,
        citizenid = xPlayer.identifier,
        name = xPlayer.getName(),
        money = {
            cash = xPlayer.getMoney() or 0,
            bank = bankAccount.money or 0
        },
        job = {
            name = job.name or 'unemployed',
            label = job.label or 'Unemployed',
            grade = {
                level = job.grade or 0,
                name = job.grade_name or 'unemployed',
                label = job.grade_label or 'Unemployed',
                payment = job.grade_salary or 0
            },
            onduty = job.onduty or false
        },
        metadata = {}
    }
    
    -- Try to get metadata if method exists
    local success, metadata = pcall(function()
        return xPlayer.getMetadata()
    end)
    if success and metadata then
        playerData.metadata = metadata
    end
    
    -- Note: State bag updates are handled by framework events, not read operations
    -- This improves performance by avoiding unnecessary updates on every read
    
    return playerData
end

---Get player money
---@param source number Player server ID
---@param type string Money type (cash, bank, etc.)
---@return number|nil amount Money amount or nil if not found
function ESXAdapter:GetMoney(source, type)
    local xPlayer = self:GetPlayer(source)
    if not xPlayer then return nil end
    
    local amount = nil
    if type == 'cash' then
        amount = xPlayer.getMoney()
    elseif type == 'bank' then
        amount = xPlayer.getAccount('bank').money
    else
        -- Try to get account by type
        local account = xPlayer.getAccount(type)
        if account then
            amount = account.money
        end
    end
    
    -- Note: State bag updates are handled by framework events, not read operations
    -- This improves performance by avoiding unnecessary updates on every read
    
    return amount
end

---Add money to player
---@param source number Player server ID
---@param type string Money type (cash, bank, etc.)
---@param amount number Amount to add
---@return boolean success True if successful
function ESXAdapter:AddMoney(source, type, amount)
    local xPlayer = self:GetPlayer(source)
    if not xPlayer then return false end
    
    local success = false
    if type == 'cash' then
        xPlayer.addMoney(amount)
        success = true
    elseif type == 'bank' then
        xPlayer.addAccountMoney('bank', amount)
        success = true
    else
        -- Try to add to account by type
        local account = xPlayer.getAccount(type)
        if account then
            xPlayer.addAccountMoney(type, amount)
            success = true
        end
    end
    
    if success then
        -- Invalidate cache to ensure fresh data
        Cache.InvalidatePlayer(source)
        -- Sync updated money to state bag (reactive update)
        StateBag.SetStateBag('player', source, 'money', {
            cash = xPlayer.getMoney(),
            bank = xPlayer.getAccount('bank').money
        }, false)
    end
    
    return success
end

---Remove money from player
---@param source number Player server ID
---@param type string Money type (cash, bank, etc.)
---@param amount number Amount to remove
---@return boolean success True if successful
function ESXAdapter:RemoveMoney(source, type, amount)
    local xPlayer = self:GetPlayer(source)
    if not xPlayer then return false end
    
    local success = false
    if type == 'cash' then
        if xPlayer.getMoney() >= amount then
            xPlayer.removeMoney(amount)
            success = true
        end
    elseif type == 'bank' then
        if xPlayer.getAccount('bank').money >= amount then
            xPlayer.removeAccountMoney('bank', amount)
            success = true
        end
    else
        -- Try to remove from account by type
        local account = xPlayer.getAccount(type)
        if account and account.money >= amount then
            xPlayer.removeAccountMoney(type, amount)
            success = true
        end
    end
    
    if success then
        -- Invalidate cache to ensure fresh data
        Cache.InvalidatePlayer(source)
        -- Sync updated money to state bag (reactive update)
        StateBag.SetStateBag('player', source, 'money', {
            cash = xPlayer.getMoney(),
            bank = xPlayer.getAccount('bank').money
        }, false)
    end
    
    return success
end

---Get player inventory
---@param source number Player server ID
---@return table|nil inventory Inventory data or nil if not found
function ESXAdapter:GetInventory(source)
    local xPlayer = self:GetPlayer(source)
    if not xPlayer then return nil end
    
    -- Check if using ox_inventory (ox_inventory doesn't provide full inventory via standard API)
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
    
    -- Try esx_inventory (standard ESX inventory)
    local esxInventory = xPlayer.getInventory()
    if esxInventory then
        return esxInventory
    end
    
    -- Fallback: return empty table
    return {}
end

---Get player job
---@param source number Player server ID
---@return JobData|nil job Job data or nil if not found
function ESXAdapter:GetJob(source)
    local xPlayer = self:GetPlayer(source)
    if not xPlayer then return nil end
    
    local job = {
        name = xPlayer.job.name,
        label = xPlayer.job.label,
        grade = {
            level = xPlayer.job.grade,
            name = xPlayer.job.grade_name,
            label = xPlayer.job.grade_label,
            payment = xPlayer.job.grade_salary
        },
        onduty = xPlayer.job.onduty or false
    }
    
    -- Note: State bag updates are handled by framework events, not read operations
    -- This improves performance by avoiding unnecessary updates on every read
    
    return job
end

---Get vehicle data
---@param vehicle number Vehicle entity
---@return VehicleData|nil data Vehicle data or nil if not found
function ESXAdapter:GetVehicle(vehicle)
    if not DoesEntityExist(vehicle) then
        return nil
    end
    
    local plate = GetVehicleNumberPlateText(vehicle)
    local model = GetEntityModel(vehicle)
    local modelName = GetDisplayNameFromVehicleModel(model)
    
    -- Try to get vehicle data from ESX database
    local success, vehicleData = pcall(function()
        local esx = self:GetESX()
        if not esx then return nil end
        
        -- ESX doesn't have a direct GetVehicleByPlate export, so we'll use basic data
        return nil
    end)
    
    local data = {
        plate = plate,
        model = modelName,
        props = {},
        metadata = {}
    }
    
    if success and vehicleData then
        data.props = vehicleData.props or {}
        data.metadata = vehicleData.metadata or {}
    end
    
    -- Note: State bag updates are handled by framework events, not read operations
    -- This improves performance by avoiding unnecessary updates on every read
    
    return data
end

-- Export ESXAdapter as global for use in other scripts
ESXAdapter = ESXAdapter

return ESXAdapter

