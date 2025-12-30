---ND_Core Universal Proxy
---Proxies ND_Core API calls to daphne-core bridge

-- Load dependencies
if not BaseProxy then
    error('[ND_Core Proxy] BaseProxy not found!')
end

if not Config then
    error('[ND_Core Proxy] Config not found!')
end

if not NDCorePlayerProxy then
    error('[ND_Core Proxy] NDCorePlayerProxy not found!')
end

-- Initialize ND_Core proxy instance (will be set after functions are defined)
local NDCoreProxyInstance = BaseProxy:new('nd_core', APIMapper.NDCoreMappings)

---Store original ND_Core export (if exists)
local originalNDCoreExport = nil

---ND_Core export proxy
local NDCoreExportProxy = {}
NDCoreExportProxy.__index = function(t, k)
    if k == "getPlayer" then
        return function(source)
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
            
            -- If ND_Core adapter is active, return original player object
            if activeFramework == Config.Frameworks.ND_CORE then
                return daphnePlayer
            end
            
            -- Convert to ND_Core format using proxy
            return NDCorePlayerProxy.new(source, daphneData)
        end
    elseif k == "getPlayers" then
        return function(key, value, returnArray)
            -- Get active adapter and use its GetPlayers method
            local activeFramework = Config.GetFramework()
            local players = {}
            
            if activeFramework == Config.Frameworks.ND_CORE then
                -- Use ND_Core adapter's GetPlayers
                if NDCorePlayer and NDCorePlayer.GetPlayers then
                    return NDCorePlayer:GetPlayers(key, value, returnArray)
                end
            elseif activeFramework == Config.Frameworks.QBOX or activeFramework == Config.Frameworks.QBCORE then
                -- Use QBCore adapter's GetPlayers and convert to ND_Core format
                if QboxPlayer and QboxPlayer.GetPlayers then
                    local qbPlayers = QboxPlayer:GetPlayers()
                    for _, qbPlayer in pairs(qbPlayers) do
                        if qbPlayer and qbPlayer.PlayerData then
                            local source = qbPlayer.PlayerData.source
                            local daphneData = exports['daphne_core']:GetPlayerData(source)
                            if daphneData then
                                table.insert(players, NDCorePlayerProxy.new(source, daphneData))
                            end
                        end
                    end
                end
            elseif activeFramework == Config.Frameworks.ESX then
                -- Use ESX adapter's GetPlayers and convert to ND_Core format
                if ESXPlayer and ESXPlayer.GetPlayers then
                    local esxPlayers = ESXPlayer:GetPlayers()
                    for _, xPlayer in pairs(esxPlayers) do
                        if xPlayer and xPlayer.source then
                            local daphneData = exports['daphne_core']:GetPlayerData(xPlayer.source)
                            if daphneData then
                                table.insert(players, NDCorePlayerProxy.new(xPlayer.source, daphneData))
                            end
                        end
                    end
                end
            end
            
            return returnArray and players or players
        end
    end
    
    -- Fallback to original if available
    if originalNDCoreExport and originalNDCoreExport[k] then
        return originalNDCoreExport[k]
    end
    
    return nil
end

---Override ND_Core global variable (if exists)
local function OverrideNDCoreGlobal()
    if Config.Proxy and Config.Proxy.OverrideGlobals then
        -- Store original if exists
        if _G.NDCore then
            originalNDCoreExport = _G.NDCore
        end
        
        -- Override global
        _G.NDCore = NDCoreExportProxy
        print('[ND_Core Proxy] Overrode NDCore global variable')
    end
end

---Override ND_Core exports
---Note: FiveM exports table is read-only, so we can't override exports directly
---Instead, we rely on global variable override
local function OverrideNDCoreExports()
    if Config.Proxy and Config.Proxy.OverrideExports then
        -- Store original export for reference
        if exports['ND_Core'] then
            originalNDCoreExport = exports['ND_Core']
        end
        
        -- Note: We cannot override exports['ND_Core'] directly
        -- because FiveM's exports table is read-only. Scripts should use:
        -- local player = exports['ND_Core']:getPlayer(source)
        -- The export will work if the original ND_Core is available, otherwise
        -- scripts should check for the global NDCore variable (if overridden)
        
        print('[ND_Core Proxy] Export override attempted (exports table is read-only in FiveM)')
        print('[ND_Core Proxy] Scripts should use: exports["ND_Core"]:getPlayer(source)')
        print('[ND_Core Proxy] The export will be proxied through the original ND_Core if available')
    end
end

---Initialize ND_Core proxy
-- Add Initialize method directly to instance table
NDCoreProxyInstance['Initialize'] = function(self)
    OverrideNDCoreGlobal()
    OverrideNDCoreExports()
    print('[ND_Core Proxy] Initialized')
    return true
end

-- Set NDCoreProxy global to instance (after Initialize is defined)
NDCoreProxy = NDCoreProxyInstance

-- Debug: Check if Initialize exists
if NDCoreProxy.Initialize then
    print('[ND_Core Proxy] Initialize method successfully added')
else
    print('[ND_Core Proxy] ERROR: Initialize method not found!')
end

return NDCoreProxy

