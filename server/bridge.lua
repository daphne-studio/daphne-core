---Server Bridge Exports
---Main bridge interface for server-side usage

-- These modules are loaded via shared_scripts, so they're available as globals
-- Config, QboxAdapter, and ESXAdapter are loaded before this file in fxmanifest.lua
if not Config then
    error('[Server Bridge] Config not found! Make sure shared/config.lua is loaded.')
end

---Current active adapter
local ActiveAdapter = nil

---Initialize bridge system
local function InitializeBridge()
    Config.Initialize()
    
    local framework = Config.GetFramework()
    
    if framework == Config.Frameworks.QBOX or framework == Config.Frameworks.QBCORE then
        if not QboxAdapter then
            error('[Server Bridge] QboxAdapter not found! Make sure adapters/qbox/adapter.lua is loaded.')
        end
        ActiveAdapter = QboxAdapter
        -- Initialize with retry logic (10 retries, 500ms delay)
        if ActiveAdapter:Initialize(10, 500) then
            print('[Daphne Core] Bridge initialized with Qbox adapter')
            return true
        end
    elseif framework == Config.Frameworks.ESX then
        if not ESXAdapter then
            error('[Server Bridge] ESXAdapter not found! Make sure adapters/esx/adapter.lua is loaded.')
        end
        ActiveAdapter = ESXAdapter
        if ActiveAdapter:Initialize() then
            print('[Daphne Core] Bridge initialized with ESX adapter')
            return true
        end
    elseif framework == Config.Frameworks.ND_CORE then
        if not NDCoreAdapter then
            error('[Server Bridge] NDCoreAdapter not found! Make sure adapters/nd_core/adapter.lua is loaded.')
        end
        ActiveAdapter = NDCoreAdapter
        -- Initialize with retry logic (10 retries, 500ms delay)
        if ActiveAdapter:Initialize(10, 500) then
            print('[Daphne Core] Bridge initialized with ND Core adapter')
            return true
        end
    end
    
    print('[Daphne Core] ERROR: Failed to initialize bridge!')
    return false
end

---Get active adapter
---@return table|nil adapter Active adapter or nil
local function GetAdapter()
    if not ActiveAdapter then
        InitializeBridge()
    end
    return ActiveAdapter
end

---Bridge exports
-- Create new Bridge table to override core/bridge.lua abstract Bridge
Bridge = {}

---Get player object
---@param source number Player server ID
---@return table|nil player Player object
function Bridge:GetPlayer(source)
    local adapter = GetAdapter()
    if not adapter then return nil end
    return adapter:GetPlayer(source)
end

---Get player data
---@param source number Player server ID
---@return table|nil data Player data
function Bridge:GetPlayerData(source)
    local adapter = GetAdapter()
    if not adapter then return nil end
    return adapter:GetPlayerData(source)
end

---Get player money
---@param source number Player server ID
---@param type string Money type
---@return number|nil amount Money amount
function Bridge:GetMoney(source, type)
    local adapter = GetAdapter()
    if not adapter then return nil end
    return adapter:GetMoney(source, type)
end

---Add money to player
---@param source number Player server ID
---@param type string Money type
---@param amount number Amount to add
---@return boolean success True if successful
function Bridge:AddMoney(source, type, amount)
    local adapter = GetAdapter()
    if not adapter then return false end
    return adapter:AddMoney(source, type, amount)
end

---Remove money from player
---@param source number Player server ID
---@param type string Money type
---@param amount number Amount to remove
---@return boolean success True if successful
function Bridge:RemoveMoney(source, type, amount)
    local adapter = GetAdapter()
    if not adapter then return false end
    return adapter:RemoveMoney(source, type, amount)
end

---Get player inventory
---@param source number Player server ID
---@return table|nil inventory Inventory data
function Bridge:GetInventory(source)
    local adapter = GetAdapter()
    if not adapter then return nil end
    return adapter:GetInventory(source)
end

---Get item from player inventory
---@param source number Player server ID
---@param item string Item name
---@return table|nil itemData Item data or nil
function Bridge:GetItem(source, item)
    local framework = Config.GetFramework()
    if framework == Config.Frameworks.QBOX or framework == Config.Frameworks.QBCORE then
        if QboxInventory then
            return QboxInventory:GetItem(source, item)
        end
    elseif framework == Config.Frameworks.ESX then
        if ESXInventory then
            return ESXInventory:GetItem(source, item)
        end
    elseif framework == Config.Frameworks.ND_CORE then
        if NDCoreInventory then
            return NDCoreInventory:GetItem(source, item)
        end
    end
    return nil
end

---Add item to player inventory
---@param source number Player server ID
---@param item string Item name
---@param amount number Amount to add
---@param slot number? Slot number (optional)
---@param info table? Item info/metadata (optional)
---@return boolean success True if successful
function Bridge:AddItem(source, item, amount, slot, info)
    local framework = Config.GetFramework()
    if framework == Config.Frameworks.QBOX or framework == Config.Frameworks.QBCORE then
        if QboxInventory then
            return QboxInventory:AddItem(source, item, amount, slot, info)
        end
    elseif framework == Config.Frameworks.ESX then
        if ESXInventory then
            return ESXInventory:AddItem(source, item, amount, slot, info)
        end
    elseif framework == Config.Frameworks.ND_CORE then
        if NDCoreInventory then
            return NDCoreInventory:AddItem(source, item, amount, slot, info)
        end
    end
    return false
end

---Remove item from player inventory
---@param source number Player server ID
---@param item string Item name
---@param amount number Amount to remove
---@param slot number? Slot number (optional)
---@return boolean success True if successful
function Bridge:RemoveItem(source, item, amount, slot)
    local framework = Config.GetFramework()
    if framework == Config.Frameworks.QBOX or framework == Config.Frameworks.QBCORE then
        if QboxInventory then
            return QboxInventory:RemoveItem(source, item, amount, slot)
        end
    elseif framework == Config.Frameworks.ESX then
        if ESXInventory then
            return ESXInventory:RemoveItem(source, item, amount, slot)
        end
    elseif framework == Config.Frameworks.ND_CORE then
        if NDCoreInventory then
            return NDCoreInventory:RemoveItem(source, item, amount, slot)
        end
    end
    return false
end

---Check if player has item
---@param source number Player server ID
---@param item string Item name
---@param amount number? Amount to check (optional, defaults to 1)
---@return boolean hasItem True if player has item
function Bridge:HasItem(source, item, amount)
    local framework = Config.GetFramework()
    if framework == Config.Frameworks.QBOX or framework == Config.Frameworks.QBCORE then
        if QboxInventory then
            return QboxInventory:HasItem(source, item, amount)
        end
    elseif framework == Config.Frameworks.ESX then
        if ESXInventory then
            return ESXInventory:HasItem(source, item, amount)
        end
    elseif framework == Config.Frameworks.ND_CORE then
        if NDCoreInventory then
            return NDCoreInventory:HasItem(source, item, amount)
        end
    end
    return false
end

---Get player job
---@param source number Player server ID
---@return table|nil job Job data
function Bridge:GetJob(source)
    local adapter = GetAdapter()
    if not adapter then return nil end
    return adapter:GetJob(source)
end

---Get vehicle data
---@param vehicle number Vehicle entity
---@return table|nil data Vehicle data
function Bridge:GetVehicle(vehicle)
    local adapter = GetAdapter()
    if not adapter then return nil end
    return adapter:GetVehicle(vehicle)
end

---Get player gang (QBCore only)
---@param source number Player server ID
---@return table|nil gang Gang data
function Bridge:GetGang(source)
    local adapter = GetAdapter()
    if not adapter then return nil end
    if adapter.GetGang then
        return adapter:GetGang(source)
    end
    return nil
end

---Get player metadata
---@param source number Player server ID
---@param key string? Metadata key (optional)
---@return any|nil metadata Metadata value or all metadata
function Bridge:GetMetadata(source, key)
    local adapter = GetAdapter()
    if not adapter then return nil end
    if adapter.GetMetadata then
        return adapter:GetMetadata(source, key)
    end
    return nil
end

---Set player metadata
---@param source number Player server ID
---@param key string Metadata key
---@param value any Metadata value
---@return boolean success True if successful
function Bridge:SetMetadata(source, key, value)
    local adapter = GetAdapter()
    if not adapter then return false end
    if adapter.SetMetadata then
        return adapter:SetMetadata(source, key, value)
    end
    return false
end

---Initialize bridge on resource start
AddEventHandler('onResourceStart', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        InitializeBridge()
    -- Retry initialization if framework starts after daphne_core
    elseif resourceName == 'qbx_core' or resourceName == 'qb-core' then
        if not ActiveAdapter or not ActiveAdapter.initialized then
            print(string.format('[Daphne Core] Framework resource %s started, retrying initialization...', resourceName))
            InitializeBridge()
        end
    elseif resourceName == 'nd_core' then
        if not ActiveAdapter or not ActiveAdapter.initialized then
            print(string.format('[Daphne Core] Framework resource %s started, retrying initialization...', resourceName))
            InitializeBridge()
        end
    end
end)

---Export bridge
exports('GetPlayer', function(source) return Bridge:GetPlayer(source) end)
exports('GetPlayerData', function(source) return Bridge:GetPlayerData(source) end)
exports('GetMoney', function(source, type) return Bridge:GetMoney(source, type) end)
exports('AddMoney', function(source, type, amount) return Bridge:AddMoney(source, type, amount) end)
exports('RemoveMoney', function(source, type, amount) return Bridge:RemoveMoney(source, type, amount) end)
exports('GetInventory', function(source) return Bridge:GetInventory(source) end)
exports('GetJob', function(source) return Bridge:GetJob(source) end)
exports('GetVehicle', function(vehicle) return Bridge:GetVehicle(vehicle) end)
exports('GetGang', function(source) return Bridge:GetGang(source) end)
exports('GetMetadata', function(source, key) return Bridge:GetMetadata(source, key) end)
exports('SetMetadata', function(source, key, value) return Bridge:SetMetadata(source, key, value) end)
exports('GetItem', function(source, item) return Bridge:GetItem(source, item) end)
exports('AddItem', function(source, item, amount, slot, info) return Bridge:AddItem(source, item, amount, slot, info) end)
exports('RemoveItem', function(source, item, amount, slot) return Bridge:RemoveItem(source, item, amount, slot) end)
exports('HasItem', function(source, item, amount) return Bridge:HasItem(source, item, amount) end)

-- Bridge is already global, no need to reassign
-- This file overrides the abstract Bridge from core/bridge.lua

return Bridge

