---Example: ESX Script Running on QBCore Adapter
---This script demonstrates how an ESX script can work on a QBCore server using daphne-core proxy

-- This script uses ESX API but will work on QBCore adapter
local ESX = exports['es_extended']:getSharedObject()

RegisterNetEvent('example:giveMoney', function()
    local source = source
    
    -- ESX API call - will be proxied to QBCore adapter
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer then
        -- Add money using ESX API
        xPlayer.addMoney(1000)
        
        -- Get money using ESX API
        local cash = xPlayer.getMoney()
        print(string.format('Player %s now has $%s cash', source, cash))
    end
end)


