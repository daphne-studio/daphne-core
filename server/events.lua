---Server events
---Framework-specific event handlers

---Listen for QBCore/Qbox player loaded event
RegisterNetEvent('QBCore:Server:OnPlayerLoaded', function()
    local source = source
    
    -- Bridge is loaded via server_scripts, so it's available as global
    if Bridge then
        -- Sync player data to state bag when player loads
        local playerData = Bridge:GetPlayerData(source)
        if playerData then
            print(string.format('[Daphne Core] Player %s loaded, data synced to state bag', source))
        end
    end
end)

---Listen for QBCore/Qbox player unloaded event
RegisterNetEvent('QBCore:Server:OnPlayerUnload', function()
    local source = source
    
    -- StateBag is loaded via shared_scripts, so it's available as global
    if StateBag then
        -- Clear player state bag cache when player unloads
        StateBag.ClearCache('player', source)
        print(string.format('[Daphne Core] Player %s unloaded, cache cleared', source))
    end
end)
