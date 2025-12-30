---Client Bridge Exports
---Main bridge interface for client-side usage

-- These modules are loaded via shared_scripts, so they're available as globals
-- Config, QboxAdapter, and ESXAdapter are loaded before this file in fxmanifest.lua
if not Config then
    error('[Client Bridge] Config not found! Make sure shared/config.lua is loaded.')
end

-- ClientStateBag is loaded via client_scripts
if not ClientStateBag then
    error('[Client Bridge] ClientStateBag not found! Make sure client/statebag.lua is loaded.')
end

---Current active adapter
local ActiveAdapter = nil

---Initialize bridge system
local function InitializeBridge()
    Config.Initialize()
    
    local framework = Config.GetFramework()
    
    if framework == Config.Frameworks.QBOX or framework == Config.Frameworks.QBCORE then
        if not QboxAdapter then
            error('[Client Bridge] QboxAdapter not found! Make sure adapters/qbox/adapter.lua is loaded.')
        end
        ActiveAdapter = QboxAdapter
        if ActiveAdapter:Initialize() then
            print('[Daphne Core] Client bridge initialized with Qbox adapter')
            return true
        end
    elseif framework == Config.Frameworks.ESX then
        if not ESXAdapter then
            error('[Client Bridge] ESXAdapter not found! Make sure adapters/esx/adapter.lua is loaded.')
        end
        ActiveAdapter = ESXAdapter
        if ActiveAdapter:Initialize() then
            print('[Daphne Core] Client bridge initialized with ESX adapter')
            return true
        end
    end
    
    print('[Daphne Core] ERROR: Failed to initialize client bridge!')
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

---Get local player object
---@return table|nil player Player object
function Bridge:GetPlayer()
    local adapter = GetAdapter()
    if not adapter then return nil end
    
    local source = GetPlayerServerId(PlayerId())
    return adapter:GetPlayer(source)
end

---Get local player data
---@return table|nil data Player data
function Bridge:GetPlayerData()
    local adapter = GetAdapter()
    if not adapter then return nil end
    
    local source = GetPlayerServerId(PlayerId())
    return adapter:GetPlayerData(source)
end

---Get local player money
---@param type string Money type
---@return number|nil amount Money amount
function Bridge:GetMoney(type)
    local adapter = GetAdapter()
    if not adapter then return nil end
    
    local source = GetPlayerServerId(PlayerId())
    return adapter:GetMoney(source, type)
end

---Get player state bag value
---@param key string State bag key
---@return any|nil value State bag value
function Bridge:GetPlayerStateBag(key)
    return ClientStateBag.GetPlayerStateBag(key)
end

---Watch player state bag changes
---@param key string State bag key
---@param callback fun(value: any, oldValue: any) Callback function
---@return function unwatch Unwatch function
function Bridge:WatchPlayerStateBag(key, callback)
    return ClientStateBag.WatchPlayerStateBag(key, callback)
end

---Initialize bridge on resource start
AddEventHandler('onClientResourceStart', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        InitializeBridge()
    end
end)

---Export bridge
exports('GetPlayer', function() return Bridge:GetPlayer() end)
exports('GetPlayerData', function() return Bridge:GetPlayerData() end)
exports('GetMoney', function(type) return Bridge:GetMoney(type) end)
exports('GetPlayerStateBag', function(key) return Bridge:GetPlayerStateBag(key) end)
exports('WatchPlayerStateBag', function(key, callback) return Bridge:WatchPlayerStateBag(key, callback) end)

return Bridge

