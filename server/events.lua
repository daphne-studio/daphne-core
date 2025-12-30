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

    -- Clear hooked player tracking
    hookedPlayers[source] = nil

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

---QBCore/Qbox Money Change Detection
---Since QBCore/Qbox doesn't have direct money change events,
---we need to hook into Player.Functions.AddMoney/RemoveMoney calls

-- Hook into QBCore/Qbox Player object creation
-- When a Player object is created, wrap its Functions.AddMoney/RemoveMoney
-- to trigger state bag updates

local hookedPlayers = {} -- Track hooked players to avoid double-hooking

local function HookPlayerMoneyFunctions(source)
    if hookedPlayers[source] then return end -- Already hooked

    local player = QboxAdapter:GetPlayer(source)
    if not player or not player.Functions then return end

    -- Store original functions
    local originalAddMoney = player.Functions.AddMoney
    local originalRemoveMoney = player.Functions.RemoveMoney

    -- Wrap AddMoney
    player.Functions.AddMoney = function(type, amount)
        local result = originalAddMoney(type, amount)
        if result then
            -- Update state bag after money change
            Wait(100) -- Small delay to ensure QBCore/Qbox has updated
            local updatedPlayer = QboxAdapter:GetPlayer(source)
            if updatedPlayer and updatedPlayer.PlayerData and updatedPlayer.PlayerData.money then
                StateBag.SetStateBag('player', source, 'money', updatedPlayer.PlayerData.money, false)
            end
        end
        return result
    end

    -- Wrap RemoveMoney
    player.Functions.RemoveMoney = function(type, amount)
        local result = originalRemoveMoney(type, amount)
        if result then
            -- Update state bag after money change
            Wait(100) -- Small delay to ensure QBCore/Qbox has updated
            local updatedPlayer = QboxAdapter:GetPlayer(source)
            if updatedPlayer and updatedPlayer.PlayerData and updatedPlayer.PlayerData.money then
                StateBag.SetStateBag('player', source, 'money', updatedPlayer.PlayerData.money, false)
            end
        end
        return result
    end

    hookedPlayers[source] = true
    print(string.format('[Daphne Core] Hooked money functions for player %s', source))
end

-- Hook into player loaded event
RegisterNetEvent('QBCore:Server:OnPlayerLoaded', function()
    local source = source
    Wait(1000) -- Wait for player to fully load
    HookPlayerMoneyFunctions(source)

    -- Original logic continues...
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

---QBCore/Qbox reactive updates
---Listen for QBCore/Qbox money change event
AddEventHandler('QBCore:Server:OnMoneyChange', function(source, moneyType, amount, operation, reason)
    -- Invalidate cache to force refresh
    if Cache then
        Cache.InvalidatePlayer(source)
    end
    
    -- Update money state bag
    if StateBag and Bridge then
        local playerData = Bridge:GetPlayerData(source)
        if playerData and playerData.money then
            StateBag.SetStateBag('player', source, 'money', playerData.money, false)
            print(string.format('[Daphne Core] Money changed for player %s: %s %s %s (reason: %s)', source, operation, amount, moneyType, reason or 'N/A'))
        end
    end
end)

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

---ND Core Event Handlers
---Listen for ND Core money change event
---Event parameters: source, account, amount, action, reason
AddEventHandler('ND:moneyChange', function(source, account, amount, action, reason)
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

---Listen for ND Core character loaded event
---Event parameters: character (includes player data and player functions)
AddEventHandler('ND:characterLoaded', function(character)
    local source = character.source
    
    -- Invalidate cache to force refresh
    if Cache then
        Cache.InvalidatePlayer(source)
    end
    
    -- Bridge is loaded via server_scripts, so it's available as global
    if Bridge then
        -- Sync player data to state bag when character loads
        local playerData = Bridge:GetPlayerData(source)
        if playerData then
            -- Update state bags reactively
            if StateBag then
                StateBag.SetStateBag('player', source, 'data', {
                    citizenid = playerData.citizenid,
                    name = playerData.name,
                    money = playerData.money or {},
                    job = playerData.job or {},
                    metadata = playerData.metadata or {}
                }, false)
                
                if playerData.money then
                    StateBag.SetStateBag('player', source, 'money', playerData.money, false)
                end
                
                if playerData.job then
                    StateBag.SetStateBag('player', source, 'job', playerData.job, false)
                end
            end
            print(string.format('[Daphne Core] ND Core Character %s loaded, data synced to state bag', source))
        end
    end
end)

---Listen for ND Core character unloaded event
---Event parameters: source, character (includes player data and player functions)
AddEventHandler('ND:characterUnloaded', function(source, character)
    -- Clear player cache when character unloads
    if Cache then
        Cache.InvalidatePlayer(source)
    end
    
    -- Clear state bag cache
    if StateBag then
        StateBag.ClearCache('player', source)
        print(string.format('[Daphne Core] ND Core Character %s unloaded, cache cleared', source))
    end
end)

---Listen for ND Core character update event
---Event parameters: character (contains player data)
AddEventHandler('ND:updateCharacter', function(character)
    local source = character.source
    
    -- Invalidate cache to force refresh
    if Cache then
        Cache.InvalidatePlayer(source)
    end
    
    -- Update state bag with new character data
    if StateBag and Bridge then
        local playerData = Bridge:GetPlayerData(source)
        if playerData then
            StateBag.SetStateBag('player', source, 'data', {
                citizenid = playerData.citizenid,
                name = playerData.name,
                money = playerData.money or {},
                job = playerData.job or {},
                metadata = playerData.metadata or {}
            }, false)
            
            if playerData.money then
                StateBag.SetStateBag('player', source, 'money', playerData.money, false)
            end
            
            if playerData.job then
                StateBag.SetStateBag('player', source, 'job', playerData.job, false)
            end
        end
    end
end)