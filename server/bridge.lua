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
        if ActiveAdapter:Initialize() then
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
local Bridge = {}

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

---Initialize bridge on resource start
AddEventHandler('onResourceStart', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        InitializeBridge()
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

-- Export Bridge as global for use in other server scripts
Bridge = Bridge

return Bridge

