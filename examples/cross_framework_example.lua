---Example: Cross-Framework Script
---This script demonstrates cross-framework compatibility using daphne-core proxy

-- This script can work with any framework
RegisterNetEvent('example:crossFramework', function()
    local source = source
    
    -- Try QBCore API
    local success, qbCore = pcall(function()
        return exports['qb-core']:GetCoreObject()
    end)
    
    if success and qbCore then
        local Player = qbCore.Functions.GetPlayer(source)
        if Player then
            Player.Functions.AddMoney('cash', 500)
            print('[Cross-Framework] Used QBCore API')
        end
    end
    
    -- Try ESX API
    local success2, esx = pcall(function()
        return exports['es_extended']:getSharedObject()
    end)
    
    if success2 and esx then
        local xPlayer = esx.GetPlayerFromId(source)
        if xPlayer then
            xPlayer.addMoney(500)
            print('[Cross-Framework] Used ESX API')
        end
    end
    
    -- Try ND_Core API
    local success3, ndPlayer = pcall(function()
        if exports['ND_Core'] and exports['ND_Core'].getPlayer then
            return exports['ND_Core']:getPlayer(source)
        end
        return nil
    end)
    
    if success3 and ndPlayer then
        ndPlayer.addMoney('cash', 500, 'Cross-Framework')
        print('[Cross-Framework] Used ND_Core API')
    end
    
    -- All three API calls will work regardless of which adapter is active
    -- They will all be proxied to the active adapter through daphne-core
end)

