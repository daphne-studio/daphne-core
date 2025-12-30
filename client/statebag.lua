---Client State Bag Manager
---Client-side state bag operations

-- StateBag is loaded via shared_scripts, so it's available as global
if not StateBag then
    error('[Client StateBag] StateBag not found! Make sure core/statebag.lua is loaded.')
end

---Client-specific state bag functions
ClientStateBag = ClientStateBag or {}
local ClientStateBag = ClientStateBag

---Get player state bag value (client-side)
---@param key string State bag key
---@return any|nil value State bag value or nil
function ClientStateBag.GetPlayerStateBag(key)
    local playerPed = PlayerPedId()
    local serverId = GetPlayerServerId(PlayerId())
    local stateBag = StateBag.GetStateBag('player', serverId, key)
    
    if stateBag then
        local stateBagName = StateBag.GetStateBagName('player', serverId, key)
        return stateBag[stateBagName]
    end
    
    return nil
end

---Get vehicle state bag value (client-side)
---@param vehicle number Vehicle entity
---@param key string State bag key
---@return any|nil value State bag value or nil
function ClientStateBag.GetVehicleStateBag(vehicle, key)
    local stateBag = StateBag.GetStateBag('vehicle', vehicle, key)
    
    if stateBag then
        local stateBagName = StateBag.GetStateBagName('vehicle', vehicle, key)
        return stateBag[stateBagName]
    end
    
    return nil
end

---Watch player state bag changes (client-side)
---@param key string State bag key
---@param callback fun(value: any, oldValue: any) Callback function
---@return function unwatch Unwatch function
function ClientStateBag.WatchPlayerStateBag(key, callback)
    local serverId = GetPlayerServerId(PlayerId())
    return StateBag.WatchStateBag('player', serverId, key, callback)
end

---Watch vehicle state bag changes (client-side)
---@param vehicle number Vehicle entity
---@param key string State bag key
---@param callback fun(value: any, oldValue: any) Callback function
---@return function unwatch Unwatch function
function ClientStateBag.WatchVehicleStateBag(vehicle, key, callback)
    return StateBag.WatchStateBag('vehicle', vehicle, key, callback)
end

-- Export ClientStateBag as global for use in other client scripts
ClientStateBag = ClientStateBag

return ClientStateBag

