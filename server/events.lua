---Server events
---Framework-specific event handlers

---Listen for QBCore/Qbox player loaded event
RegisterNetEvent('QBCore:Server:OnPlayerLoaded', function()
    local source = source
    
    -- Invalidate cache to force refresh
    if Cache then
        Cache.InvalidatePlayer(source)
    end
    
    -- Bridge is loaded via server_scripts, so it's available as global
    if Bridge then
        -- Sync player data to state bag when player loads
        local playerData = Bridge:GetPlayerData(source)
        if playerData then
            -- Update state bags reactively
            if StateBag then
                StateBag.SetStateBag('player', source, 'data', {
                    citizenid = playerData.citizenid,
                    name = playerData.charinfo and (playerData.charinfo.firstname .. ' ' .. playerData.charinfo.lastname) or '',
                    money = playerData.money or {},
                    job = playerData.job or {},
                    gang = playerData.gang or {},
                    metadata = playerData.metadata or {}
                }, false)
                
                if playerData.money then
                    StateBag.SetStateBag('player', source, 'money', playerData.money, false)
                end
                
                if playerData.job then
                    StateBag.SetStateBag('player', source, 'job', playerData.job, false)
                end
                
                if playerData.gang then
                    StateBag.SetStateBag('player', source, 'gang', playerData.gang, false)
                end
            end
            print(string.format('[Daphne Core] Player %s loaded, data synced to state bag', source))
        end
    end
end)

---Listen for QBCore/Qbox player unloaded event
RegisterNetEvent('QBCore:Server:OnPlayerUnload', function()
    local source = source
    
    -- Clear player cache when player unloads
    if Cache then
        Cache.InvalidatePlayer(source)
    end
    
    -- StateBag is loaded via shared_scripts, so it's available as global
    if StateBag then
        -- Clear player state bag cache when player unloads
        StateBag.ClearCache('player', source)
        print(string.format('[Daphne Core] Player %s unloaded, cache cleared', source))
    end
end)

---QBCore/Qbox reactive updates
---Note: QBCore doesn't have specific events for job/money changes
---State bag updates are handled in adapter write operations (AddMoney, RemoveMoney, SetMetadata)
---Cache invalidation ensures fresh data on next read

---Listen for player disconnect (universal event)
AddEventHandler('playerDropped', function(reason)
    local source = source
    
    -- Clear player cache on disconnect
    if Cache then
        Cache.InvalidatePlayer(source)
    end
    
    -- Clear state bag cache
    if StateBag then
        StateBag.ClearCache('player', source)
    end
end)

---ESX Event Handlers
---Listen for ESX player loaded event
RegisterNetEvent('esx:playerLoaded', function(playerId, xPlayer)
    local source = playerId or source
    
    -- Invalidate cache to force refresh
    if Cache then
        Cache.InvalidatePlayer(source)
    end
    
    -- Bridge is loaded via server_scripts, so it's available as global
    if Bridge then
        -- Sync player data to state bag when player loads
        local playerData = Bridge:GetPlayerData(source)
        if playerData then
            print(string.format('[Daphne Core] ESX Player %s loaded, data synced to state bag', source))
        end
    end
end)

---Listen for ESX player dropped event
RegisterNetEvent('esx:playerDropped', function(playerId)
    local source = playerId or source
    
    -- Clear player cache when player unloads
    if Cache then
        Cache.InvalidatePlayer(source)
    end
    
    -- Clear state bag cache
    if StateBag then
        StateBag.ClearCache('player', source)
        print(string.format('[Daphne Core] ESX Player %s unloaded, cache cleared', source))
    end
end)

---Listen for ESX job change event
RegisterNetEvent('esx:setJob', function(playerId, job)
    local source = playerId or source
    
    -- Invalidate cache to force refresh
    if Cache then
        Cache.InvalidatePlayer(source)
    end
    
    -- Update job state bag
    if StateBag and Bridge then
        local jobData = Bridge:GetJob(source)
        if jobData then
            StateBag.SetStateBag('player', source, 'job', jobData, false)
        end
    end
end)

---Listen for ESX account money change event
RegisterNetEvent('esx:setAccountMoney', function(playerId, account)
    local source = playerId or source
    
    -- Invalidate cache to force refresh
    if Cache then
        Cache.InvalidatePlayer(source)
    end
    
    -- Update money state bag
    if StateBag and Bridge then
        local playerData = Bridge:GetPlayerData(source)
        if playerData and playerData.money then
            StateBag.SetStateBag('player', source, 'money', playerData.money, false)
        end
    end
end)
