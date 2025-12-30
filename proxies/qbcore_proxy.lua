---QBCore Universal Proxy
---Proxies QBCore API calls to daphne-core bridge

-- Load dependencies
if not BaseProxy then
    error('[QBCore Proxy] BaseProxy not found!')
end

if not Config then
    error('[QBCore Proxy] Config not found!')
end

if not QBCorePlayerProxy then
    error('[QBCore Proxy] QBCorePlayerProxy not found!')
end

-- Initialize QBCore proxy instance (will be set after functions are defined)
local QBCoreProxyInstance = BaseProxy:new('qbcore', APIMapper.QBCoreMappings)

---Store original QBCore exports (if they exist)
local originalQBCoreExport = nil
local originalQBXCoreExport = nil

---QBCore Functions proxy
QBCoreFunctionsProxy = QBCoreFunctionsProxy or {}
local QBCoreFunctionsProxy = QBCoreFunctionsProxy

---Get player object
---@param source number|string Player server ID or identifier
---@return table|nil player QBCore Player object (proxy)
function QBCoreFunctionsProxy.GetPlayer(source)
    -- Call daphne-core to get player
    local daphnePlayer = exports['daphne_core']:GetPlayer(source)
    if not daphnePlayer then
        return nil
    end
    
    -- Get normalized player data
    local daphneData = exports['daphne_core']:GetPlayerData(source)
    if not daphneData then
        return nil
    end
    
    -- Check active adapter
    local activeFramework = Config.GetFramework()
    
    -- If QBCore adapter is active, return original player object
    if activeFramework == Config.Frameworks.QBOX or activeFramework == Config.Frameworks.QBCORE then
        return daphnePlayer
    end
    
    -- Convert to QBCore format using proxy
    return QBCorePlayerProxy.new(source, daphneData)
end

---Get all players
---@return table players Table of player objects
function QBCoreFunctionsProxy.GetPlayers()
    -- Get active adapter and use its GetPlayers method
    local activeFramework = Config.GetFramework()
    local players = {}
    
    if activeFramework == Config.Frameworks.QBOX or activeFramework == Config.Frameworks.QBCORE then
        -- Use QBCore adapter's GetPlayers
        if QboxPlayer and QboxPlayer.GetPlayers then
            local qbPlayers = QboxPlayer:GetPlayers()
            -- Convert to QBCore player proxy objects
            for _, qbPlayer in pairs(qbPlayers) do
                if qbPlayer and qbPlayer.PlayerData then
                    local source = qbPlayer.PlayerData.source
                    local daphneData = exports['daphne_core']:GetPlayerData(source)
                    if daphneData then
                        table.insert(players, QBCorePlayerProxy.new(source, daphneData))
                    end
                end
            end
        end
    elseif activeFramework == Config.Frameworks.ESX then
        -- Use ESX adapter's GetPlayers and convert to QBCore format
        if ESXPlayer and ESXPlayer.GetPlayers then
            local esxPlayers = ESXPlayer:GetPlayers()
            for _, xPlayer in pairs(esxPlayers) do
                if xPlayer and xPlayer.source then
                    local daphneData = exports['daphne_core']:GetPlayerData(xPlayer.source)
                    if daphneData then
                        table.insert(players, QBCorePlayerProxy.new(xPlayer.source, daphneData))
                    end
                end
            end
        end
    elseif activeFramework == Config.Frameworks.ND_CORE then
        -- Use ND_Core adapter's GetPlayers and convert to QBCore format
        if NDCorePlayer and NDCorePlayer.GetPlayers then
            local ndPlayers = NDCorePlayer:GetPlayers(nil, nil, true)
            for _, ndPlayer in pairs(ndPlayers) do
                if ndPlayer and ndPlayer.source then
                    local daphneData = exports['daphne_core']:GetPlayerData(ndPlayer.source)
                    if daphneData then
                        table.insert(players, QBCorePlayerProxy.new(ndPlayer.source, daphneData))
                    end
                end
            end
        end
    end
    
    return players
end

---Get player by citizen ID
---@param citizenid string Citizen ID
---@return table|nil player QBCore Player object (proxy)
function QBCoreFunctionsProxy.GetPlayerByCitizenId(citizenid)
    -- Try to get player by identifier
    local player = QBCoreFunctionsProxy.GetPlayer(citizenid)
    return player
end

---Get player by phone number
---@param phone string Phone number
---@return table|nil player QBCore Player object (proxy)
function QBCoreFunctionsProxy.GetPlayerByPhone(phone)
    -- This requires custom implementation
    -- For now, return nil
    -- TODO: Implement GetPlayerByPhone functionality
    return nil
end

---QBCore global variable proxy
local QBCoreGlobalProxy = {}
QBCoreGlobalProxy.__index = function(t, k)
    if k == "Functions" then
        return QBCoreFunctionsProxy
    end
    -- Fallback to original if available
    if originalQBCoreExport and originalQBCoreExport[k] then
        return originalQBCoreExport[k]
    end
    return nil
end

---Override QBCore global variable
local function OverrideQBCoreGlobal()
    if Config.Proxy and Config.Proxy.OverrideGlobals then
        -- Store original if exists
        if _G.QBCore then
            originalQBCoreExport = _G.QBCore
        end
        
        -- Override global
        _G.QBCore = QBCoreGlobalProxy
        print('[QBCore Proxy] Overrode QBCore global variable')
    end
end

---Override QBCore exports
---Note: FiveM exports table is read-only, so we can't override exports directly
---Instead, we rely on global variable override and GetCoreObject pattern
local function OverrideQBCoreExports()
    if Config.Proxy and Config.Proxy.OverrideExports then
        -- Store original exports for reference
        if exports['qb-core'] then
            originalQBCoreExport = exports['qb-core']
        end
        if exports['qbx_core'] then
            originalQBXCoreExport = exports['qbx_core']
        end
        
        -- Note: We cannot override exports['qb-core'] or exports['qbx_core'] directly
        -- because FiveM's exports table is read-only. Scripts should use:
        -- local QBCore = exports['qb-core']:GetCoreObject() or QBCore (global)
        -- The global QBCore variable is already overridden above
        
        print('[QBCore Proxy] Export override attempted (exports table is read-only in FiveM)')
        print('[QBCore Proxy] Scripts should use: local QBCore = exports["qb-core"]:GetCoreObject() or QBCore')
        print('[QBCore Proxy] The global QBCore variable is already proxied')
    end
end

---Initialize QBCore proxy
-- Add Initialize method directly to instance table
QBCoreProxyInstance['Initialize'] = function(self)
    OverrideQBCoreGlobal()
    OverrideQBCoreExports()
    print('[QBCore Proxy] Initialized')
    return true
end

-- Set QBCoreProxy global to instance
QBCoreProxy = QBCoreProxyInstance

-- Debug: Check if Initialize exists
if QBCoreProxy.Initialize then
    print('[QBCore Proxy] Initialize method successfully added')
else
    print('[QBCore Proxy] ERROR: Initialize method not found!')
end

return QBCoreProxy

