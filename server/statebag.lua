---Server State Bag Manager
---Server-side state bag operations

-- StateBag is loaded via shared_scripts, so it's available as global
if not StateBag then
    error('[Server StateBag] StateBag not found! Make sure core/statebag.lua is loaded.')
end

---Server-specific state bag functions
ServerStateBag = ServerStateBag or {}
local ServerStateBag = ServerStateBag

---Set player state bag (server-side)
---@param source number Player server ID
---@param key string State bag key
---@param value any Value to set
---@param immediate boolean? Immediate update flag
function ServerStateBag.SetPlayerStateBag(source, key, value, immediate)
    StateBag.SetStateBag('player', source, key, value, immediate)
end

---Set vehicle state bag (server-side)
---@param vehicle number Vehicle entity
---@param key string State bag key
---@param value any Value to set
---@param immediate boolean? Immediate update flag
function ServerStateBag.SetVehicleStateBag(vehicle, key, value, immediate)
    StateBag.SetStateBag('vehicle', vehicle, key, value, immediate)
end

---Watch player state bag changes
---@param source number Player server ID
---@param key string State bag key
---@param callback fun(value: any, oldValue: any) Callback function
---@return function unwatch Unwatch function
function ServerStateBag.WatchPlayerStateBag(source, key, callback)
    return StateBag.WatchStateBag('player', source, key, callback)
end

---Watch vehicle state bag changes
---@param vehicle number Vehicle entity
---@param key string State bag key
---@param callback fun(value: any, oldValue: any) Callback function
---@return function unwatch Unwatch function
function ServerStateBag.WatchVehicleStateBag(vehicle, key, callback)
    return StateBag.WatchStateBag('vehicle', vehicle, key, callback)
end

-- Export ServerStateBag as global for use in other server scripts
ServerStateBag = ServerStateBag

return ServerStateBag

