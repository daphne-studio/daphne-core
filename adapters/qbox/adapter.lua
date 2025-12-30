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

---@class QboxAdapter : Bridge
QboxAdapter = QboxAdapter or setmetatable({}, Bridge)
local QboxAdapter = QboxAdapter
QboxAdapter.__index = QboxAdapter

QboxAdapter.name = 'Qbox'
QboxAdapter.initialized = false
QboxAdapter.QBCore = nil
QboxAdapter.PlayerData = nil

---Initialize Qbox adapter
---@return boolean success
function QboxAdapter:Initialize()
    if self.initialized then
        return true
    end
    
    -- Try to get QBCore export (works for both Qbox and QBCore)
    local success, qbCore = pcall(function()
        return exports['qbx_core'] or exports['qb-core']
    end)
    
    if not success or not qbCore then
        print('[Daphne Core] Qbox/QBCore not found!')
        return false
    end
    
    self.QBCore = qbCore
    self.initialized = true
    
    print('[Daphne Core] Qbox adapter initialized successfully')
    return true
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
    local qbCore = self:GetQBCore()
    if not qbCore then return nil end
    
    return qbCore:GetPlayer(source)
end

---Get player data from source
---@param source number Player server ID
---@return PlayerData|nil data Player data or nil if not found
function QboxAdapter:GetPlayerData(source)
    local player = self:GetPlayer(source)
    if not player then return nil end
    
    local playerData = player.PlayerData
    
    -- Sync to state bag
    if playerData then
        StateBag.SetStateBag('player', source, 'data', {
            citizenid = playerData.citizenid,
            name = playerData.charinfo and (playerData.charinfo.firstname .. ' ' .. playerData.charinfo.lastname) or '',
            money = playerData.money or {},
            job = playerData.job or {},
            gang = playerData.gang or {},
            metadata = playerData.metadata or {}
        })
    end
    
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
    
    -- Sync to state bag
    if money then
        StateBag.SetStateBag('player', source, 'money', player.PlayerData.money)
    end
    
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
        -- Sync updated money to state bag
        StateBag.SetStateBag('player', source, 'money', player.PlayerData.money)
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
        -- Sync updated money to state bag
        StateBag.SetStateBag('player', source, 'money', player.PlayerData.money)
    end
    
    return success
end

---Get player inventory
---@param source number Player server ID
---@return table|nil inventory Inventory data or nil if not found
function QboxAdapter:GetInventory(source)
    local player = self:GetPlayer(source)
    if not player then return nil end
    
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
    
    if job then
        -- Sync to state bag
        StateBag.SetStateBag('player', source, 'job', job)
    end
    
    return job
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
    local success, vehicleData = pcall(function()
        return exports['qbx_core']:GetVehicleByPlate(plate) or exports['qb-core']:GetVehicleByPlate(plate)
    end)
    
    local data = {
        plate = plate,
        model = modelName,
        props = {},
        metadata = {}
    }
    
    if success and vehicleData then
        data.props = vehicleData.mods or {}
        data.metadata = vehicleData.metadata or {}
    end
    
    -- Sync to state bag
    StateBag.SetStateBag('vehicle', vehicle, 'data', data)
    
    return data
end

-- Export QboxAdapter as global for use in other scripts
QboxAdapter = QboxAdapter

return QboxAdapter

