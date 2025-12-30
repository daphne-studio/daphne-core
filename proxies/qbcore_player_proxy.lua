---QBCore Player Object Proxy
---Proxies QBCore Player object methods to daphne-core
QBCorePlayerProxy = QBCorePlayerProxy or {}
local QBCorePlayerProxy = QBCorePlayerProxy
QBCorePlayerProxy.__index = QBCorePlayerProxy

---Create a new QBCore Player proxy
---@param source number Player server ID
---@param daphneData PlayerData? Optional normalized player data
---@return table playerProxy QBCore Player proxy object
function QBCorePlayerProxy.new(source, daphneData)
    local proxy = setmetatable({}, QBCorePlayerProxy)
    proxy._source = source
    proxy._daphneData = daphneData
    proxy._isProxy = true
    
    -- Get fresh data if not provided
    if not daphneData then
        proxy._daphneData = exports['daphne_core']:GetPlayerData(source)
    end
    
    -- Create PlayerData property
    proxy.PlayerData = {
        citizenid = proxy._daphneData and proxy._daphneData.citizenid or '',
        name = proxy._daphneData and proxy._daphneData.name or '',
        money = proxy._daphneData and proxy._daphneData.money or {},
        job = proxy._daphneData and proxy._daphneData.job or {},
        gang = proxy._daphneData and proxy._daphneData.gang,
        metadata = proxy._daphneData and proxy._daphneData.metadata or {}
    }
    
    return proxy
end

---Add money to player
---@param type string Money type
---@param amount number Amount to add
---@return boolean success
function QBCorePlayerProxy:AddMoney(type, amount)
    return exports['daphne_core']:AddMoney(self._source, type, amount)
end

---Remove money from player
---@param type string Money type
---@param amount number Amount to remove
---@return boolean success
function QBCorePlayerProxy:RemoveMoney(type, amount)
    return exports['daphne_core']:RemoveMoney(self._source, type, amount)
end

---Get money from player
---@param type string Money type
---@return number? amount Money amount
function QBCorePlayerProxy:GetMoney(type)
    return exports['daphne_core']:GetMoney(self._source, type)
end

---Add item to player inventory
---@param item string Item name
---@param amount number Amount to add
---@param slot number? Slot number (optional)
---@param info table? Item info/metadata (optional)
---@return boolean success
function QBCorePlayerProxy:AddItem(item, amount, slot, info)
    return exports['daphne_core']:AddItem(self._source, item, amount, slot, info)
end

---Remove item from player inventory
---@param item string Item name
---@param amount number Amount to remove
---@param slot number? Slot number (optional)
---@return boolean success
function QBCorePlayerProxy:RemoveItem(item, amount, slot)
    return exports['daphne_core']:RemoveItem(self._source, item, amount, slot)
end

---Check if player has item
---@param item string Item name
---@param amount number? Amount to check (optional, defaults to 1)
---@return boolean hasItem
function QBCorePlayerProxy:HasItem(item, amount)
    return exports['daphne_core']:HasItem(self._source, item, amount)
end

---Get item from player inventory
---@param item string Item name
---@return table|nil itemData Item data
function QBCorePlayerProxy:GetItem(item)
    return exports['daphne_core']:GetItem(self._source, item)
end

---Set player job
---@param job string Job name
---@param grade number? Grade level (optional)
---@return boolean success
function QBCorePlayerProxy:SetJob(job, grade)
    -- Job setting is framework-specific, handled by adapter
    -- This is a placeholder - actual implementation depends on adapter
    return false
end

---Set player gang
---@param gang string Gang name
---@param grade number? Grade level (optional)
---@return boolean success
function QBCorePlayerProxy:SetGang(gang, grade)
    -- Gang setting is QBCore-specific
    -- This is a placeholder - actual implementation depends on adapter
    return false
end

---Get player metadata
---@param key string? Metadata key (optional, returns all if nil)
---@return any|nil metadata Metadata value
function QBCorePlayerProxy:GetMetadata(key)
    return exports['daphne_core']:GetMetadata(self._source, key)
end

---Set player metadata
---@param key string Metadata key
---@param value any Metadata value
---@return boolean success
function QBCorePlayerProxy:SetMetadata(key, value)
    return exports['daphne_core']:SetMetadata(self._source, key, value)
end

---Update PlayerData from daphne-core
function QBCorePlayerProxy:RefreshData()
    self._daphneData = exports['daphne_core']:GetPlayerData(self._source)
    if self._daphneData then
        self.PlayerData = {
            citizenid = self._daphneData.citizenid,
            name = self._daphneData.name,
            money = self._daphneData.money or {},
            job = self._daphneData.job or {},
            gang = self._daphneData.gang,
            metadata = self._daphneData.metadata or {}
        }
    end
end

-- Create Functions table for QBCore compatibility
local QBCoreFunctionsTable = {}
QBCoreFunctionsTable.__index = function(t, k)
    -- This will be set per-instance in the proxy
    return nil
end

function QBCorePlayerProxy:__index(k)
    if k == "Functions" then
        -- Create Functions table bound to this instance
        local functions = setmetatable({}, {
            __index = function(t, funcName)
                if funcName == "AddMoney" then
                    return function(type, amount) return self:AddMoney(type, amount) end
                elseif funcName == "RemoveMoney" then
                    return function(type, amount) return self:RemoveMoney(type, amount) end
                elseif funcName == "GetMoney" then
                    return function(type) return self:GetMoney(type) end
                elseif funcName == "AddItem" then
                    return function(item, amount, slot, info) return self:AddItem(item, amount, slot, info) end
                elseif funcName == "RemoveItem" then
                    return function(item, amount, slot) return self:RemoveItem(item, amount, slot) end
                elseif funcName == "HasItem" then
                    return function(item, amount) return self:HasItem(item, amount) end
                elseif funcName == "GetItem" then
                    return function(item) return self:GetItem(item) end
                elseif funcName == "SetJob" then
                    return function(job, grade) return self:SetJob(job, grade) end
                elseif funcName == "SetGang" then
                    return function(gang, grade) return self:SetGang(gang, grade) end
                elseif funcName == "GetMetadata" then
                    return function(key) return self:GetMetadata(key) end
                elseif funcName == "SetMetadata" then
                    return function(key, value) return self:SetMetadata(key, value) end
                end
                return nil
            end
        })
        return functions
    end
    return QBCorePlayerProxy[k]
end

-- Export QBCorePlayerProxy as global
QBCorePlayerProxy = QBCorePlayerProxy

return QBCorePlayerProxy

