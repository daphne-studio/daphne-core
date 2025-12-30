---Example: QBCore Script Running on ND_Core Adapter
---This script demonstrates how a QBCore script can work on an ND_Core server using daphne-core proxy

-- This script uses QBCore API but will work on ND_Core adapter
local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('example:giveMoney', function()
    local source = source
    
    -- QBCore API call - will be proxied to ND_Core adapter
    local Player = QBCore.Functions.GetPlayer(source)
    if Player then
        -- Add money using QBCore API
        Player.Functions.AddMoney('cash', 1000)
        
        -- Get money using QBCore API
        local cash = Player.Functions.GetMoney('cash')
        print(string.format('Player %s now has $%s cash', source, cash))
    end
end)

