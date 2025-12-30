---ESX xPlayer Object Proxy
---Proxies ESX xPlayer object methods to daphne-core
ESXPlayerProxy = ESXPlayerProxy or {}
local ESXPlayerProxy = ESXPlayerProxy
ESXPlayerProxy.__index = ESXPlayerProxy

---Create a new ESX xPlayer proxy
---@param source number Player server ID
---@param daphneData PlayerData? Optional normalized player data
---@return table xPlayerProxy ESX xPlayer proxy object
function ESXPlayerProxy.new(source, daphneData)
    local proxy = setmetatable({}, ESXPlayerProxy)
    proxy._source = source
    proxy._daphneData = daphneData
    proxy._isProxy = true
    
    -- Get fresh data if not provided
    if not daphneData then
        proxy._daphneData = exports['daphne_core']:GetPlayerData(source)
    end
    
    -- Set ESX xPlayer properties
    proxy.source = source
    proxy.identifier = proxy._daphneData and proxy._daphneData.citizenid or ''
    
    -- Set job property
    local job = proxy._daphneData and proxy._daphneData.job or {}
    proxy.job = {
        name = job.name or 'unemployed',
        label = job.label or 'Unemployed',
        grade = job.grade and job.grade.level or 0,
        grade_name = job.grade and job.grade.name or 'unemployed',
        grade_label = job.grade and job.grade.label or 'Unemployed',
        grade_salary = job.grade and job.grade.payment or 0,
        onduty = job.onduty or false
    }
    
    return proxy
end

---Get player name
---@return string name Player name
function ESXPlayerProxy:getName()
    return self._daphneData and self._daphneData.name or ''
end

---Add money to player (cash)
---@param amount number Amount to add
---@return boolean success
function ESXPlayerProxy:addMoney(amount)
    return exports['daphne_core']:AddMoney(self._source, 'cash', amount)
end

---Remove money from player (cash)
---@param amount number Amount to remove
---@return boolean success
function ESXPlayerProxy:removeMoney(amount)
    return exports['daphne_core']:RemoveMoney(self._source, 'cash', amount)
end

---Get player money (cash)
---@return number money Cash amount
function ESXPlayerProxy:getMoney()
    return exports['daphne_core']:GetMoney(self._source, 'cash') or 0
end

---Add account money
---@param account string Account name
---@param amount number Amount to add
---@return boolean success
function ESXPlayerProxy:addAccountMoney(account, amount)
    return exports['daphne_core']:AddMoney(self._source, account, amount)
end

---Remove account money
---@param account string Account name
---@param amount number Amount to remove
---@return boolean success
function ESXPlayerProxy:removeAccountMoney(account, amount)
    return exports['daphne_core']:RemoveMoney(self._source, account, amount)
end

---Get account
---@param account string Account name
---@return table|nil accountData Account data
function ESXPlayerProxy:getAccount(account)
    local amount = exports['daphne_core']:GetMoney(self._source, account)
    if amount then
        return {
            money = amount
        }
    end
    return nil
end

---Add item to player inventory
---@param item string Item name
---@param count number Item count
---@param metadata table? Item metadata (optional)
---@return boolean success
function ESXPlayerProxy:addItem(item, count, metadata)
    return exports['daphne_core']:AddItem(self._source, item, count, nil, metadata)
end

---Remove item from player inventory
---@param item string Item name
---@param count number Item count
---@return boolean success
function ESXPlayerProxy:removeItem(item, count)
    return exports['daphne_core']:RemoveItem(self._source, item, count)
end

---Check if player has item
---@param item string Item name
---@param count number? Item count (optional, defaults to 1)
---@return boolean hasItem
function ESXPlayerProxy:hasItem(item, count)
    return exports['daphne_core']:HasItem(self._source, item, count)
end

---Get player inventory
---@return table inventory Inventory data
function ESXPlayerProxy:getInventory()
    return exports['daphne_core']:GetInventory(self._source) or {}
end

---Set player job
---@param job string Job name
---@param grade number? Grade level (optional)
---@return boolean success
function ESXPlayerProxy:setJob(job, grade)
    -- Job setting is framework-specific, handled by adapter
    -- This is a placeholder - actual implementation depends on adapter
    return false
end

---Get player metadata
---@return table metadata Player metadata
function ESXPlayerProxy:getMetadata()
    return exports['daphne_core']:GetMetadata(self._source) or {}
end

---Set player metadata
---@param key string Metadata key
---@param value any Metadata value
---@return boolean success
function ESXPlayerProxy:setMetadata(key, value)
    return exports['daphne_core']:SetMetadata(self._source, key, value)
end

---Update xPlayer data from daphne-core
function ESXPlayerProxy:RefreshData()
    self._daphneData = exports['daphne_core']:GetPlayerData(self._source)
    if self._daphneData then
        self.identifier = self._daphneData.citizenid
        
        local job = self._daphneData.job or {}
        self.job = {
            name = job.name or 'unemployed',
            label = job.label or 'Unemployed',
            grade = job.grade and job.grade.level or 0,
            grade_name = job.grade and job.grade.name or 'unemployed',
            grade_label = job.grade and job.grade.label or 'Unemployed',
            grade_salary = job.grade and job.grade.payment or 0,
            onduty = job.onduty or false
        }
    end
end

-- Export ESXPlayerProxy as global
ESXPlayerProxy = ESXPlayerProxy

return ESXPlayerProxy

