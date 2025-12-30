---Example: QBCore Script Running on ESX Adapter
---This script demonstrates how a QBCore script can work on an ESX server using daphne-core proxy

-- This script uses QBCore API but will work on ESX adapter
local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('example:giveMoney', function()
    local source = source
    
    -- QBCore API call - will be proxied to ESX adapter
    local Player = QBCore.Functions.GetPlayer(source)
    if Player then
        -- Add money using QBCore API
        Player.Functions.AddMoney('cash', 1000)
        
        -- Get money using QBCore API
        local cash = Player.Functions.GetMoney('cash')
        print(string.format('Player %s now has $%s cash', source, cash))
    end
end)


