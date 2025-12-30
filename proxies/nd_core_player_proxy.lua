---ND_Core Player Object Proxy
---Proxies ND_Core player object methods to daphne-core
NDCorePlayerProxy = NDCorePlayerProxy or {}
local NDCorePlayerProxy = NDCorePlayerProxy
NDCorePlayerProxy.__index = NDCorePlayerProxy

---Create a new ND_Core Player proxy
---@param source number Player server ID
---@param daphneData PlayerData? Optional normalized player data
---@return table playerProxy ND_Core Player proxy object
function NDCorePlayerProxy.new(source, daphneData)
    local proxy = setmetatable({}, NDCorePlayerProxy)
    proxy._source = source
    proxy._daphneData = daphneData
    proxy._isProxy = true
    
    -- Get fresh data if not provided
    if not daphneData then
        proxy._daphneData = exports['daphne_core']:GetPlayerData(source)
    end
    
    -- Set ND_Core player properties
    proxy.source = source
    proxy.id = tonumber(proxy._daphneData and proxy._daphneData.citizenid) or (proxy._daphneData and proxy._daphneData.citizenid) or ''
    proxy.fullname = proxy._daphneData and proxy._daphneData.name or ''
    
    -- Parse firstname and lastname
    if proxy.fullname then
        local parts = {}
        for part in proxy.fullname:gmatch("%S+") do
            table.insert(parts, part)
        end
        proxy.firstname = parts[1] or ''
        proxy.lastname = parts[2] or ''
    else
        proxy.firstname = ''
        proxy.lastname = ''
    end
    
    proxy.cash = proxy._daphneData and proxy._daphneData.money and proxy._daphneData.money.cash or 0
    proxy.bank = proxy._daphneData and proxy._daphneData.money and proxy._daphneData.money.bank or 0
    proxy.metadata = proxy._daphneData and proxy._daphneData.metadata or {}
    
    return proxy
end

---Add money to player
---@param type string Money type (cash, bank)
---@param amount number Amount to add
---@param reason string? Reason (optional, ignored)
---@return boolean success
function NDCorePlayerProxy:addMoney(type, amount, reason)
    return exports['daphne_core']:AddMoney(self._source, type, amount)
end

---Remove money from player
---@param type string Money type (cash, bank)
---@param amount number Amount to remove
---@param reason string? Reason (optional, ignored)
---@return boolean success
function NDCorePlayerProxy:removeMoney(type, amount, reason)
    return exports['daphne_core']:RemoveMoney(self._source, type, amount)
end

---Deduct money from player (alias for removeMoney)
---@param type string Money type (cash, bank)
---@param amount number Amount to deduct
---@param reason string? Reason (optional, ignored)
---@return boolean success
function NDCorePlayerProxy:deductMoney(type, amount, reason)
    return self:removeMoney(type, amount, reason)
end

---Get money from player
---@param type string Money type (cash, bank)
---@return number? amount Money amount
function NDCorePlayerProxy:getMoney(type)
    return exports['daphne_core']:GetMoney(self._source, type)
end

---Get data from player
---@param key string Data key
---@return any value Data value
function NDCorePlayerProxy:getData(key)
    if key == 'cash' then
        return self.cash
    elseif key == 'bank' then
        return self.bank
    else
        return exports['daphne_core']:GetMetadata(self._source, key)
    end
end

---Get player job
---@return string jobName Job name
---@return table jobInfo Job info table
function NDCorePlayerProxy:getJob()
    local job = exports['daphne_core']:GetJob(self._source)
    if not job then
        return 'unemployed', {
            label = 'Unemployed',
            rank = 0,
            rankName = 'unemployed'
        }
    end
    
    local jobName = job.name or 'unemployed'
    local jobInfo = {
        label = job.label or 'Unemployed',
        rank = job.grade and job.grade.level or 0,
        rankName = job.grade and job.grade.name or 'unemployed'
    }
    
    return jobName, jobInfo
end

---Add item to player inventory
---@param item string Item name
---@param amount number Amount to add
---@return boolean success
function NDCorePlayerProxy:addItem(item, amount)
    return exports['daphne_core']:AddItem(self._source, item, amount)
end

---Remove item from player inventory
---@param item string Item name
---@param amount number Amount to remove
---@return boolean success
function NDCorePlayerProxy:removeItem(item, amount)
    return exports['daphne_core']:RemoveItem(self._source, item, amount)
end

---Check if player has item
---@param item string Item name
---@param amount number? Amount to check (optional, defaults to 1)
---@return boolean hasItem
function NDCorePlayerProxy:hasItem(item, amount)
    return exports['daphne_core']:HasItem(self._source, item, amount)
end

---Get player metadata
---@param key string? Metadata key (optional, returns all if nil)
---@return any|nil metadata Metadata value
function NDCorePlayerProxy:getMetadata(key)
    return exports['daphne_core']:GetMetadata(self._source, key)
end

---Set player metadata
---@param key string Metadata key
---@param value any Metadata value
---@return boolean success
function NDCorePlayerProxy:setMetadata(key, value)
    return exports['daphne_core']:SetMetadata(self._source, key, value)
end

---Update player data from daphne-core
function NDCorePlayerProxy:RefreshData()
    self._daphneData = exports['daphne_core']:GetPlayerData(self._source)
    if self._daphneData then
        self.id = tonumber(self._daphneData.citizenid) or self._daphneData.citizenid
        self.fullname = self._daphneData.name or ''
        
        -- Parse firstname and lastname
        if self.fullname then
            local parts = {}
            for part in self.fullname:gmatch("%S+") do
                table.insert(parts, part)
            end
            self.firstname = parts[1] or ''
            self.lastname = parts[2] or ''
        end
        
        self.cash = self._daphneData.money and self._daphneData.money.cash or 0
        self.bank = self._daphneData.money and self._daphneData.money.bank or 0
        self.metadata = self._daphneData.metadata or {}
    end
end

-- Export NDCorePlayerProxy as global
NDCorePlayerProxy = NDCorePlayerProxy

return NDCorePlayerProxy


