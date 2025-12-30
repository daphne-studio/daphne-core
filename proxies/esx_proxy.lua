---ESX Universal Proxy
---Proxies ESX API calls to daphne-core bridge

-- Load dependencies
if not BaseProxy then
    error('[ESX Proxy] BaseProxy not found!')
end

if not Config then
    error('[ESX Proxy] Config not found!')
end

if not ESXPlayerProxy then
    error('[ESX Proxy] ESXPlayerProxy not found!')
end

-- Initialize ESX proxy instance (will be set after functions are defined)
local ESXProxyInstance = BaseProxy:new('esx', APIMapper.ESXMappings)

---Store original ESX export (if exists)
local originalESXExport = nil

---ESX global variable proxy
local ESXGlobalProxy = {}
ESXGlobalProxy.__index = function(t, k)
    if k == "GetPlayerFromId" then
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
            
            -- If ESX adapter is active, return original player object
            if activeFramework == Config.Frameworks.ESX then
                return daphnePlayer
            end
            
            -- Convert to ESX format using proxy
            return ESXPlayerProxy.new(source, daphneData)
        end
    elseif k == "GetPlayers" then
        return function()
            -- Get active adapter and use its GetPlayers method
            local activeFramework = Config.GetFramework()
            local players = {}
            
            if activeFramework == Config.Frameworks.ESX then
                -- Use ESX adapter's GetPlayers
                if ESXPlayer and ESXPlayer.GetPlayers then
                    return ESXPlayer:GetPlayers()
                end
            elseif activeFramework == Config.Frameworks.QBOX or activeFramework == Config.Frameworks.QBCORE then
                -- Use QBCore adapter's GetPlayers and convert to ESX format
                if QboxPlayer and QboxPlayer.GetPlayers then
                    local qbPlayers = QboxPlayer:GetPlayers()
                    for _, qbPlayer in pairs(qbPlayers) do
                        if qbPlayer and qbPlayer.PlayerData then
                            local source = qbPlayer.PlayerData.source
                            local daphneData = exports['daphne_core']:GetPlayerData(source)
                            if daphneData then
                                table.insert(players, ESXPlayerProxy.new(source, daphneData))
                            end
                        end
                    end
                end
            elseif activeFramework == Config.Frameworks.ND_CORE then
                -- Use ND_Core adapter's GetPlayers and convert to ESX format
                if NDCorePlayer and NDCorePlayer.GetPlayers then
                    local ndPlayers = NDCorePlayer:GetPlayers(nil, nil, true)
                    for _, ndPlayer in pairs(ndPlayers) do
                        if ndPlayer and ndPlayer.source then
                            local daphneData = exports['daphne_core']:GetPlayerData(ndPlayer.source)
                            if daphneData then
                                table.insert(players, ESXPlayerProxy.new(ndPlayer.source, daphneData))
                            end
                        end
                    end
                end
            end
            
            return players
        end
    elseif k == "GetPlayerFromIdentifier" then
        return function(identifier)
            -- This requires custom implementation
            -- For now, return nil
            -- TODO: Implement GetPlayerFromIdentifier functionality
            return nil
        end
    end
    
    -- Fallback to original if available
    if originalESXExport and originalESXExport[k] then
        return originalESXExport[k]
    end
    
    return nil
end

---Override ESX global variable
local function OverrideESXGlobal()
    if Config.Proxy and Config.Proxy.OverrideGlobals then
        -- Store original if exists
        if _G.ESX then
            originalESXExport = _G.ESX
        end
        
        -- Override global
        _G.ESX = ESXGlobalProxy
        print('[ESX Proxy] Overrode ESX global variable')
    end
end

---Override ESX exports
---Note: FiveM exports table is read-only, so we can't override exports directly
---Instead, we rely on global variable override and getSharedObject pattern
local function OverrideESXExports()
    if Config.Proxy and Config.Proxy.OverrideExports then
        -- Store original export for reference
        if exports['es_extended'] then
            originalESXExport = exports['es_extended']
        end
        
        -- Note: We cannot override exports['es_extended'] directly
        -- because FiveM's exports table is read-only. Scripts should use:
        -- local ESX = exports['es_extended']:getSharedObject() or ESX (global)
        -- The global ESX variable is already overridden above
        
        print('[ESX Proxy] Export override attempted (exports table is read-only in FiveM)')
        print('[ESX Proxy] Scripts should use: local ESX = exports["es_extended"]:getSharedObject() or ESX')
        print('[ESX Proxy] The global ESX variable is already proxied')
    end
end

---Initialize ESX proxy
-- Add Initialize method directly to instance table
ESXProxyInstance['Initialize'] = function(self)
    OverrideESXGlobal()
    OverrideESXExports()
    print('[ESX Proxy] Initialized')
    return true
end

-- Set ESXProxy global to instance (after Initialize is defined)
ESXProxy = ESXProxyInstance

-- Debug: Check if Initialize exists
if ESXProxy.Initialize then
    print('[ESX Proxy] Initialize method successfully added')
else
    print('[ESX Proxy] ERROR: Initialize method not found!')
end

return ESXProxy

