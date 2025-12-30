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

if not Cache then
    error('[Qbox Adapter] Cache not found! Make sure core/cache.lua is loaded before this file.')
end

---@class QboxAdapter : Bridge
QboxAdapter = QboxAdapter or setmetatable({}, Bridge)
local QboxAdapter = QboxAdapter
QboxAdapter.__index = QboxAdapter

QboxAdapter.name = 'Qbox'
QboxAdapter.initialized = false
QboxAdapter.QBCore = nil
QboxAdapter.PlayerData = nil

---Try to get QBCore object with multiple methods
---@return table|nil qbCore QBCore object or nil
local function GetQBCoreObject()
    -- Method 1: Try QBX GetCoreObject export (Qbox)
    local success, qbCore = pcall(function()
        if exports['qbx_core'] then
            if type(exports['qbx_core'].GetCoreObject) == 'function' then
                return exports['qbx_core']:GetCoreObject()
            elseif type(exports['qbx_core']) == 'table' and exports['qbx_core'].GetCoreObject then
                return exports['qbx_core']:GetCoreObject()
            end
        end
        return nil
    end)
    if success and qbCore then
        return qbCore
    end
    
    -- Method 2: Try standard QBCore GetCoreObject export
    success, qbCore = pcall(function()
        if exports['qb-core'] then
            if type(exports['qb-core'].GetCoreObject) == 'function' then
                return exports['qb-core']:GetCoreObject()
            elseif type(exports['qb-core']) == 'table' and exports['qb-core'].GetCoreObject then
                return exports['qb-core']:GetCoreObject()
            end
        end
        return nil
    end)
    if success and qbCore then
        return qbCore
    end
    
    -- Method 3: Try direct export access (for compatibility)
    success, qbCore = pcall(function()
        if exports['qbx_core'] and type(exports['qbx_core']) == 'table' then
            -- Check if it's already the QBCore object (has GetPlayer method)
            if exports['qbx_core'].GetPlayer then
                return exports['qbx_core']
            end
        end
        if exports['qb-core'] and type(exports['qb-core']) == 'table' then
            -- Check if it's already the QBCore object (has GetPlayer method)
            if exports['qb-core'].GetPlayer then
                return exports['qb-core']
            end
        end
        return nil
    end)
    if success and qbCore then
        return qbCore
    end
    
    -- Method 4: Try global QBCore variable (some setups use this)
    success, qbCore = pcall(function()
        if QBCore and type(QBCore) == 'table' and QBCore.GetPlayer then
            return QBCore
        end
        return nil
    end)
    if success and qbCore then
        return qbCore
    end
    
    return nil
end

---Initialize Qbox adapter with retry logic
---@param retries number? Number of retries (default: 10)
---@param delay number? Delay between retries in ms (default: 500)
---@return boolean success
function QboxAdapter:Initialize(retries, delay)
    if self.initialized then
        return true
    end
    
    retries = retries or 10
    delay = delay or 500
    
    -- Qbox uses exports directly, check if exports are available
    for i = 1, retries do
        -- Check if qbx_core export is available
        local success, hasExport = pcall(function()
            return exports['qbx_core'] ~= nil and exports['qbx_core'].GetPlayer ~= nil
        end)
        
        if success and hasExport then
            -- Qbox export is available, we can use it directly
            self.initialized = true
            print('[Daphne Core] Qbox adapter initialized successfully (using exports)')
            return true
        end
        
        -- Check if qb-core export is available (fallback)
        success, hasExport = pcall(function()
            return exports['qb-core'] ~= nil and exports['qb-core'].GetPlayer ~= nil
        end)
        
        if success and hasExport then
            -- QBCore export is available
            self.initialized = true
            print('[Daphne Core] Qbox adapter initialized successfully (using qb-core exports)')
            return true
        end
        
        -- Try to get QBCore object with GetCoreObject (legacy support)
        local qbCore = GetQBCoreObject()
        
        if qbCore then
            -- Verify it's a valid QBCore object
            if type(qbCore) == 'table' and (qbCore.GetPlayer or qbCore.Functions) then
                self.QBCore = qbCore
                self.initialized = true
                print('[Daphne Core] Qbox adapter initialized successfully (using GetCoreObject)')
                return true
            end
        end
        
        -- Wait before retrying (except on last attempt)
        if i < retries then
            Wait(delay)
        end
    end
    
    -- Final attempt with detailed error message
    local resourceState = GetResourceState('qbx_core')
    local qbResourceState = GetResourceState('qb-core')
    
    print('[Daphne Core] Qbox/QBCore not found!')
    print(string.format('[Daphne Core] qbx_core state: %s', resourceState))
    print(string.format('[Daphne Core] qb-core state: %s', qbResourceState))
    print('[Daphne Core] Make sure qbx_core or qb-core is started BEFORE daphne_core in server.cfg')
    print('[Daphne Core] Example: ensure qbx_core (or qb-core)')
    print('[Daphne Core]          ensure daphne_core')
    
    return false
end

---Get QBCore object
---@return table|nil qbCore QBCore object
function QboxAdapter:GetQBCore()
    if not self.initialized then
        local success = self:Initialize()
        if not success then
            -- Initialize failed, QBCore not available
            return nil
        end
    end
    
    -- Double-check that QBCore is still valid
    if not self.QBCore then
        return nil
    end
    
    return self.QBCore
end

---Get player object from source
---@param source number|string Player server ID or identifier (citizenid/userId/phone)
---@return table|nil player Player object or nil if not found
function QboxAdapter:GetPlayer(source)
    -- Check cache first (only for numeric source)
    if type(source) == 'number' then
        local cachedPlayer = Cache.GetPlayer(source)
        if cachedPlayer then
            return cachedPlayer
        end
    end
    
    -- Qbox uses exports directly: exports.qbx_core:GetPlayer(source)
    -- GetPlayer accepts both source (integer) and identifier (string)
    -- Try Qbox export first
    local success, player = pcall(function()
        if exports['qbx_core'] and exports['qbx_core'].GetPlayer then
            return exports['qbx_core']:GetPlayer(source)
        end
        return nil
    end)
    
    if success and player then
        -- Cache the player object (only for numeric source)
        if type(source) == 'number' then
            Cache.SetPlayer(source, player)
        end
        return player
    end
    
    -- Fallback: Try QBCore export (for compatibility)
    success, player = pcall(function()
        if exports['qb-core'] and exports['qb-core'].GetPlayer then
            return exports['qb-core']:GetPlayer(source)
        end
        return nil
    end)
    
    if success and player then
        -- Cache the player object (only for numeric source)
        if type(source) == 'number' then
            Cache.SetPlayer(source, player)
        end
        return player
    end
    
    -- Fallback: Try GetCoreObject method (legacy support)
    local qbCore = self:GetQBCore()
    if qbCore then
        if qbCore.GetPlayer and type(qbCore.GetPlayer) == 'function' then
            success, player = pcall(function()
                return qbCore:GetPlayer(source)
            end)
            
            if success and player then
                -- Cache the player object (only for numeric source)
                if type(source) == 'number' then
                    Cache.SetPlayer(source, player)
                end
                return player
            end
        end
    end
    
    -- All methods failed
    if not success then
        print(string.format('[Daphne Core] ERROR: Failed to get player %s from QBCore/Qbox: %s', tostring(source), tostring(player)))
    end
    
    return nil
end

---Get player by citizenid
---@param citizenid string Citizen ID
---@return table|nil player Player object or nil if not found
function QboxAdapter:GetPlayerByCitizenId(citizenid)
    -- Qbox uses exports directly: exports.qbx_core:GetPlayerByCitizenId(citizenid)
    local success, player = pcall(function()
        if exports['qbx_core'] and exports['qbx_core'].GetPlayerByCitizenId then
            return exports['qbx_core']:GetPlayerByCitizenId(citizenid)
        end
        return nil
    end)
    
    if success and player then
        return player
    end
    
    -- Fallback: Try QBCore export
    success, player = pcall(function()
        if exports['qb-core'] and exports['qb-core'].GetPlayerByCitizenId then
            return exports['qb-core']:GetPlayerByCitizenId(citizenid)
        end
        return nil
    end)
    
    if success and player then
        return player
    end
    
    -- Fallback: Use GetPlayer with citizenid (if it supports string identifiers)
    return self:GetPlayer(citizenid)
end

---Get player by phone number
---@param phone string Phone number
---@return table|nil player Player object or nil if not found
function QboxAdapter:GetPlayerByPhone(phone)
    -- Qbox uses exports directly: exports.qbx_core:GetPlayerByPhone(number)
    local success, player = pcall(function()
        if exports['qbx_core'] and exports['qbx_core'].GetPlayerByPhone then
            return exports['qbx_core']:GetPlayerByPhone(phone)
        end
        return nil
    end)
    
    if success and player then
        return player
    end
    
    -- Fallback: Try QBCore export
    success, player = pcall(function()
        if exports['qb-core'] and exports['qb-core'].GetPlayerByPhone then
            return exports['qb-core']:GetPlayerByPhone(phone)
        end
        return nil
    end)
    
    if success and player then
        return player
    end
    
    return nil
end

---Get player data from source
---@param source number Player server ID
---@return PlayerData|nil data Player data or nil if not found
function QboxAdapter:GetPlayerData(source)
    -- GetPlayer already uses exports, so we can use it directly
    -- GetPlayer returns Player object which contains PlayerData
    local player = self:GetPlayer(source)
    if not player then return nil end
    
    -- Player object from Qbox export contains PlayerData property
    local playerData = player.PlayerData
    
    -- Note: State bag updates are handled by framework events, not read operations
    -- This improves performance by avoiding unnecessary updates on every read
    
    return playerData
end

---Get player money
---@param source number Player server ID
---@param type string Money type (cash, bank, crypto, etc.)
---@return number|nil amount Money amount or nil if not found
function QboxAdapter:GetMoney(source, type)
    -- Qbox uses exports directly: exports.qbx_core:GetMoney(identifier, moneyType)
    -- Try Qbox export first
    local success, amount = pcall(function()
        if exports['qbx_core'] and exports['qbx_core'].GetMoney then
            return exports['qbx_core']:GetMoney(source, type)
        end
        return nil
    end)
    
    if success and amount ~= nil and amount ~= false then
        return amount
    end
    
    -- Fallback: Try QBCore export
    success, amount = pcall(function()
        if exports['qb-core'] and exports['qb-core'].GetMoney then
            return exports['qb-core']:GetMoney(source, type)
        end
        return nil
    end)
    
    if success and amount ~= nil and amount ~= false then
        return amount
    end
    
    -- Fallback: Use player object (legacy support)
    local player = self:GetPlayer(source)
    if player and player.PlayerData and player.PlayerData.money then
        return player.PlayerData.money[type]
    end
    
    return nil
end

---Add money to player
---@param source number Player server ID
---@param type string Money type (cash, bank, crypto, etc.)
---@param amount number Amount to add
---@return boolean success True if successful
function QboxAdapter:AddMoney(source, type, amount)
    -- Qbox uses exports directly: exports.qbx_core:AddMoney(identifier, moneyType, amount, reason?)
    -- Try Qbox export first
    local success, result = pcall(function()
        if exports['qbx_core'] and exports['qbx_core'].AddMoney then
            return exports['qbx_core']:AddMoney(source, type, amount)
        end
        return false
    end)
    
    if success and result then
        -- Invalidate cache to ensure fresh data
        Cache.InvalidatePlayer(source)
        -- Sync updated money to state bag (reactive update)
        local player = self:GetPlayer(source)
        if player and player.PlayerData and player.PlayerData.money then
            StateBag.SetStateBag('player', source, 'money', player.PlayerData.money, false)
        end
        return true
    end
    
    -- Fallback: Try QBCore export
    success, result = pcall(function()
        if exports['qb-core'] and exports['qb-core'].AddMoney then
            return exports['qb-core']:AddMoney(source, type, amount)
        end
        return false
    end)
    
    if success and result then
        -- Invalidate cache to ensure fresh data
        Cache.InvalidatePlayer(source)
        -- Sync updated money to state bag (reactive update)
        local player = self:GetPlayer(source)
        if player and player.PlayerData and player.PlayerData.money then
            StateBag.SetStateBag('player', source, 'money', player.PlayerData.money, false)
        end
        return true
    end
    
    -- Fallback: Use player object (legacy support)
    local player = self:GetPlayer(source)
    if player and player.Functions and player.Functions.AddMoney then
        success = player.Functions.AddMoney(type, amount)
        if success then
            Cache.InvalidatePlayer(source)
            if player.PlayerData and player.PlayerData.money then
                StateBag.SetStateBag('player', source, 'money', player.PlayerData.money, false)
            end
        end
        return success
    end
    
    return false
end

---Remove money from player
---@param source number Player server ID
---@param type string Money type (cash, bank, crypto, etc.)
---@param amount number Amount to remove
---@return boolean success True if successful
function QboxAdapter:RemoveMoney(source, type, amount)
    -- Qbox uses exports directly: exports.qbx_core:RemoveMoney(identifier, moneyType, amount, reason?)
    -- Try Qbox export first
    local success, result = pcall(function()
        if exports['qbx_core'] and exports['qbx_core'].RemoveMoney then
            return exports['qbx_core']:RemoveMoney(source, type, amount)
        end
        return false
    end)
    
    if success and result then
        -- Invalidate cache to ensure fresh data
        Cache.InvalidatePlayer(source)
        -- Sync updated money to state bag (reactive update)
        local player = self:GetPlayer(source)
        if player and player.PlayerData and player.PlayerData.money then
            StateBag.SetStateBag('player', source, 'money', player.PlayerData.money, false)
        end
        return true
    end
    
    -- Fallback: Try QBCore export
    success, result = pcall(function()
        if exports['qb-core'] and exports['qb-core'].RemoveMoney then
            return exports['qb-core']:RemoveMoney(source, type, amount)
        end
        return false
    end)
    
    if success and result then
        -- Invalidate cache to ensure fresh data
        Cache.InvalidatePlayer(source)
        -- Sync updated money to state bag (reactive update)
        local player = self:GetPlayer(source)
        if player and player.PlayerData and player.PlayerData.money then
            StateBag.SetStateBag('player', source, 'money', player.PlayerData.money, false)
        end
        return true
    end
    
    -- Fallback: Use player object (legacy support)
    local player = self:GetPlayer(source)
    if player and player.Functions and player.Functions.RemoveMoney then
        success = player.Functions.RemoveMoney(type, amount)
        if success then
            Cache.InvalidatePlayer(source)
            if player.PlayerData and player.PlayerData.money then
                StateBag.SetStateBag('player', source, 'money', player.PlayerData.money, false)
            end
        end
        return success
    end
    
    return false
end

---Set money for player
---@param source number Player server ID
---@param type string Money type (cash, bank, crypto, etc.)
---@param amount number Amount to set
---@return boolean success True if successful
function QboxAdapter:SetMoney(source, type, amount)
    -- Qbox uses exports directly: exports.qbx_core:SetMoney(identifier, moneyType, amount, reason?)
    -- Try Qbox export first
    local success, result = pcall(function()
        if exports['qbx_core'] and exports['qbx_core'].SetMoney then
            return exports['qbx_core']:SetMoney(source, type, amount)
        end
        return false
    end)
    
    if success and result then
        -- Invalidate cache to ensure fresh data
        Cache.InvalidatePlayer(source)
        -- Sync updated money to state bag (reactive update)
        local player = self:GetPlayer(source)
        if player and player.PlayerData and player.PlayerData.money then
            StateBag.SetStateBag('player', source, 'money', player.PlayerData.money, false)
        end
        return true
    end
    
    -- Fallback: Try QBCore export
    success, result = pcall(function()
        if exports['qb-core'] and exports['qb-core'].SetMoney then
            return exports['qb-core']:SetMoney(source, type, amount)
        end
        return false
    end)
    
    if success and result then
        -- Invalidate cache to ensure fresh data
        Cache.InvalidatePlayer(source)
        -- Sync updated money to state bag (reactive update)
        local player = self:GetPlayer(source)
        if player and player.PlayerData and player.PlayerData.money then
            StateBag.SetStateBag('player', source, 'money', player.PlayerData.money, false)
        end
        return true
    end
    
    -- Fallback: Use player object (legacy support)
    local player = self:GetPlayer(source)
    if player and player.PlayerData and player.PlayerData.money then
        player.PlayerData.money[type] = amount
        -- Trigger update if method exists
        if player.Functions and player.Functions.SetMoney then
            success = player.Functions.SetMoney(type, amount)
        else
            success = true
        end
        if success then
            Cache.InvalidatePlayer(source)
            StateBag.SetStateBag('player', source, 'money', player.PlayerData.money, false)
        end
        return success
    end
    
    return false
end

---Get player inventory
---@param source number Player server ID
---@return table|nil inventory Inventory data or nil if not found
function QboxAdapter:GetInventory(source)
    local player = self:GetPlayer(source)
    if not player then return nil end
    
    -- Check if using ox_inventory
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
    
    -- Note: State bag updates are handled by framework events, not read operations
    -- This improves performance by avoiding unnecessary updates on every read
    
    return job
end

---Get player gang
---@param source number Player server ID
---@return GangData|nil gang Gang data or nil if not found
function QboxAdapter:GetGang(source)
    local player = self:GetPlayer(source)
    if not player then return nil end
    
    local gang = player.PlayerData.gang
    
    -- Note: State bag updates are handled by framework events, not read operations
    -- This improves performance by avoiding unnecessary updates on every read
    
    return gang
end

---Get player metadata
---@param source number Player server ID
---@param key string? Metadata key (optional, returns all metadata if nil)
---@return any|nil metadata Metadata value or all metadata if key is nil
function QboxAdapter:GetMetadata(source, key)
    -- Qbox uses exports directly: exports.qbx_core:GetMetadata(identifier, metadata)
    -- If key is provided, use export; if nil, get all metadata from player
    if key then
        -- Try Qbox export first
        local success, value = pcall(function()
            if exports['qbx_core'] and exports['qbx_core'].GetMetadata then
                return exports['qbx_core']:GetMetadata(source, key)
            end
            return nil
        end)
        
        if success and value ~= nil then
            return value
        end
        
        -- Fallback: Try QBCore export
        success, value = pcall(function()
            if exports['qb-core'] and exports['qb-core'].GetMetadata then
                return exports['qb-core']:GetMetadata(source, key)
            end
            return nil
        end)
        
        if success and value ~= nil then
            return value
        end
    end
    
    -- Fallback: Use player object (for getting all metadata or if export fails)
    local player = self:GetPlayer(source)
    if not player then return nil end
    
    local metadata = player.PlayerData.metadata or {}
    
    if key then
        return metadata[key]
    end
    
    return metadata
end

---Set player metadata
---@param source number Player server ID
---@param key string Metadata key
---@param value any Metadata value
---@return boolean success True if successful
function QboxAdapter:SetMetadata(source, key, value)
    -- Qbox uses exports directly: exports.qbx_core:SetMetadata(identifier, metadata, value)
    -- Try Qbox export first
    local success = pcall(function()
        if exports['qbx_core'] and exports['qbx_core'].SetMetadata then
            exports['qbx_core']:SetMetadata(source, key, value)
            return true
        end
        return false
    end)
    
    if success then
        -- Invalidate cache to ensure fresh data
        Cache.InvalidatePlayer(source)
        
        -- Sync to state bag (reactive update)
        local player = self:GetPlayer(source)
        if player and player.PlayerData then
            StateBag.SetStateBag('player', source, 'data', {
                citizenid = player.PlayerData.citizenid,
                name = player.PlayerData.charinfo and (player.PlayerData.charinfo.firstname .. ' ' .. player.PlayerData.charinfo.lastname) or '',
                money = player.PlayerData.money or {},
                job = player.PlayerData.job or {},
                gang = player.PlayerData.gang or {},
                metadata = player.PlayerData.metadata or {}
            }, false)
        end
        return true
    end
    
    -- Fallback: Try QBCore export
    success = pcall(function()
        if exports['qb-core'] and exports['qb-core'].SetMetadata then
            exports['qb-core']:SetMetadata(source, key, value)
            return true
        end
        return false
    end)
    
    if success then
        -- Invalidate cache to ensure fresh data
        Cache.InvalidatePlayer(source)
        
        -- Sync to state bag (reactive update)
        local player = self:GetPlayer(source)
        if player and player.PlayerData then
            StateBag.SetStateBag('player', source, 'data', {
                citizenid = player.PlayerData.citizenid,
                name = player.PlayerData.charinfo and (player.PlayerData.charinfo.firstname .. ' ' .. player.PlayerData.charinfo.lastname) or '',
                money = player.PlayerData.money or {},
                job = player.PlayerData.job or {},
                gang = player.PlayerData.gang or {},
                metadata = player.PlayerData.metadata or {}
            }, false)
        end
        return true
    end
    
    -- Fallback: Use player object (legacy support)
    local player = self:GetPlayer(source)
    if not player then return false end
    
    if not player.PlayerData.metadata then
        player.PlayerData.metadata = {}
    end
    
    player.PlayerData.metadata[key] = value
    
    -- Invalidate cache to ensure fresh data
    Cache.InvalidatePlayer(source)
    
    -- Sync to state bag (reactive update)
    StateBag.SetStateBag('player', source, 'data', {
        citizenid = player.PlayerData.citizenid,
        name = player.PlayerData.charinfo and (player.PlayerData.charinfo.firstname .. ' ' .. player.PlayerData.charinfo.lastname) or '',
        money = player.PlayerData.money or {},
        job = player.PlayerData.job or {},
        gang = player.PlayerData.gang or {},
        metadata = player.PlayerData.metadata or {}
    }, false)
    
    return true
end

---Set player data
---@param source number|string Player server ID or citizenid
---@param key string PlayerData key to set
---@param value any Value to set
---@return boolean success True if successful
function QboxAdapter:SetPlayerData(source, key, value)
    -- Qbox uses exports directly: exports.qbx_core:SetPlayerData(identifier, key, value)
    local success = pcall(function()
        if exports['qbx_core'] and exports['qbx_core'].SetPlayerData then
            exports['qbx_core']:SetPlayerData(source, key, value)
            return true
        end
        return false
    end)
    
    if success then
        -- Invalidate cache to ensure fresh data
        if type(source) == 'number' then
            Cache.InvalidatePlayer(source)
        end
        return true
    end
    
    -- Fallback: Try QBCore export
    success = pcall(function()
        if exports['qb-core'] and exports['qb-core'].SetPlayerData then
            exports['qb-core']:SetPlayerData(source, key, value)
            return true
        end
        return false
    end)
    
    if success then
        -- Invalidate cache to ensure fresh data
        if type(source) == 'number' then
            Cache.InvalidatePlayer(source)
        end
        return true
    end
    
    -- Fallback: Use player object (legacy support)
    if type(source) == 'number' then
        local player = self:GetPlayer(source)
        if player and player.PlayerData then
            player.PlayerData[key] = value
            Cache.InvalidatePlayer(source)
            return true
        end
    end
    
    return false
end

---Update player data
---@param source number|string Player server ID or citizenid
---@return boolean success True if successful
function QboxAdapter:UpdatePlayerData(source)
    -- Qbox uses exports directly: exports.qbx_core:UpdatePlayerData(identifier)
    local success = pcall(function()
        if exports['qbx_core'] and exports['qbx_core'].UpdatePlayerData then
            exports['qbx_core']:UpdatePlayerData(source)
            return true
        end
        return false
    end)
    
    if success then
        -- Invalidate cache to ensure fresh data
        if type(source) == 'number' then
            Cache.InvalidatePlayer(source)
        end
        return true
    end
    
    -- Fallback: Try QBCore export
    success = pcall(function()
        if exports['qb-core'] and exports['qb-core'].UpdatePlayerData then
            exports['qb-core']:UpdatePlayerData(source)
            return true
        end
        return false
    end)
    
    if success then
        -- Invalidate cache to ensure fresh data
        if type(source) == 'number' then
            Cache.InvalidatePlayer(source)
        end
        return true
    end
    
    return false
end

---Set character info
---@param source number|string Player server ID or citizenid
---@param charInfo string Character info key
---@param value any Value to set
---@return boolean success True if successful
function QboxAdapter:SetCharInfo(source, charInfo, value)
    -- Qbox uses exports directly: exports.qbx_core:SetCharInfo(identifier, charInfo, value)
    local success = pcall(function()
        if exports['qbx_core'] and exports['qbx_core'].SetCharInfo then
            exports['qbx_core']:SetCharInfo(source, charInfo, value)
            return true
        end
        return false
    end)
    
    if success then
        -- Invalidate cache to ensure fresh data
        if type(source) == 'number' then
            Cache.InvalidatePlayer(source)
        end
        return true
    end
    
    -- Fallback: Try QBCore export
    success = pcall(function()
        if exports['qb-core'] and exports['qb-core'].SetCharInfo then
            exports['qb-core']:SetCharInfo(source, charInfo, value)
            return true
        end
        return false
    end)
    
    if success then
        -- Invalidate cache to ensure fresh data
        if type(source) == 'number' then
            Cache.InvalidatePlayer(source)
        end
        return true
    end
    
    -- Fallback: Use player object (legacy support)
    if type(source) == 'number' then
        local player = self:GetPlayer(source)
        if player and player.PlayerData and player.PlayerData.charinfo then
            player.PlayerData.charinfo[charInfo] = value
            Cache.InvalidatePlayer(source)
            return true
        end
    end
    
    return false
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
    local qbCore = self:GetQBCore()
    local vehicleData = nil
    
    if qbCore then
        local success, data = pcall(function()
            -- Try QBX export first
            if exports['qbx_core'] and exports['qbx_core'].GetVehicleByPlate then
                return exports['qbx_core']:GetVehicleByPlate(plate)
            end
            -- Try QBCore export
            if exports['qb-core'] and exports['qb-core'].GetVehicleByPlate then
                return exports['qb-core']:GetVehicleByPlate(plate)
            end
            return nil
        end)
        
        if success and data then
            vehicleData = data
        end
    end
    
    local data = {
        plate = plate,
        model = modelName,
        props = {},
        metadata = {},
        citizenid = nil,
        engine = nil,
        body = nil,
        fuel = nil
    }
    
    if vehicleData then
        data.props = vehicleData.mods or vehicleData.props or {}
        data.metadata = vehicleData.metadata or {}
        data.citizenid = vehicleData.citizenid
        data.engine = vehicleData.engine
        data.body = vehicleData.body
        data.fuel = vehicleData.fuel
    end
    
    -- Note: State bag updates are handled by framework events, not read operations
    -- This improves performance by avoiding unnecessary updates on every read
    
    return data
end

-- Export QboxAdapter as global for use in other scripts
QboxAdapter = QboxAdapter

return QboxAdapter

