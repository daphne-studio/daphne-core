---Example: ND_Core Script Running on ESX Adapter
---This script demonstrates how an ND_Core script can work on an ESX server using daphne-core proxy

-- This script uses ND_Core API but will work on ESX adapter
RegisterNetEvent('example:giveMoney', function()
    local source = source
    
    -- ND_Core API call - will be proxied to ESX adapter
    local player = exports['ND_Core']:getPlayer(source)
    if player then
        -- Add money using ND_Core API
        player.addMoney('cash', 1000, 'Example')
        
        -- Get money using ND_Core API
        local cash = player.cash
        print(string.format('Player %s now has $%s cash', source, cash))
        
        -- Get job using ND_Core API
        local jobName, jobInfo = player.getJob()
        print(string.format('Player %s job: %s (Rank: %s)', source, jobName, jobInfo.rankName))
    end
end)


