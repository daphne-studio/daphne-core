---Server-Side Basic Usage Examples
---This file demonstrates basic server-side usage of Daphne Core bridge

-- Example 1: Get player data when player joins
RegisterNetEvent('playerConnecting', function()
    local source = source
    
    -- Wait a bit for player to fully load
    SetTimeout(2000, function()
        local playerData = exports['daphne_core']:GetPlayerData(source)
        
        if playerData then
            print(string.format('[Example] Player %s (%s) connected', playerData.name, playerData.citizenid))
        end
    end)
end)

-- Example 2: Give money to player via command
RegisterCommand('givemoney', function(source, args)
    if not args[1] or not args[2] or not args[3] then
        TriggerClientEvent('chat:addMessage', source, {
            color = {255, 0, 0},
            multiline = true,
            args = {"System", "Usage: /givemoney [id] [type] [amount]"}
        })
        return
    end
    
    local targetId = tonumber(args[1])
    local moneyType = args[2] -- 'cash' or 'bank'
    local amount = tonumber(args[3])
    
    if exports['daphne_core']:AddMoney(targetId, moneyType, amount) then
        TriggerClientEvent('chat:addMessage', source, {
            color = {0, 255, 0},
            multiline = true,
            args = {"System", string.format("Gave $%d (%s) to player %d", amount, moneyType, targetId)}
        })
    else
        TriggerClientEvent('chat:addMessage', source, {
            color = {255, 0, 0},
            multiline = true,
            args = {"System", "Failed to give money"}
        })
    end
end, false)

-- Example 3: Check player money before purchase
RegisterNetEvent('example:purchaseItem', function(itemName, price)
    local source = source
    local playerMoney = exports['daphne_core']:GetMoney(source, 'cash')
    
    if playerMoney and playerMoney >= price then
        if exports['daphne_core']:RemoveMoney(source, 'cash', price) then
            -- Give item to player (your inventory system)
            TriggerClientEvent('chat:addMessage', source, {
                color = {0, 255, 0},
                multiline = true,
                args = {"Shop", string.format("Purchased %s for $%d", itemName, price)}
            })
        end
    else
        TriggerClientEvent('chat:addMessage', source, {
            color = {255, 0, 0},
            multiline = true,
            args = {"Shop", "Not enough money!"}
        })
    end
end)

-- Example 4: Get player job and check permissions
RegisterNetEvent('example:checkJob', function()
    local source = source
    local job = exports['daphne_core']:GetJob(source)
    
    if job then
        print(string.format('[Example] Player %d has job: %s (Grade: %d)', source, job.name, job.grade.level))
        
        -- Check if player is a police officer
        if job.name == 'police' and job.grade.level >= 2 then
            -- Allow access to police features
            TriggerClientEvent('example:policeAccess', source, true)
        end
    end
end)

-- Example 5: Get all player money types
RegisterCommand('checkmoney', function(source, args)
    local targetId = source
    if args[1] then
        targetId = tonumber(args[1])
    end
    
    local cash = exports['daphne_core']:GetMoney(targetId, 'cash') or 0
    local bank = exports['daphne_core']:GetMoney(targetId, 'bank') or 0
    
    TriggerClientEvent('chat:addMessage', source, {
        color = {255, 255, 0},
        multiline = true,
        args = {"Money", string.format("Cash: $%d | Bank: $%d", cash, bank)}
    })
end, false)

-- Example 6: Get vehicle information
RegisterNetEvent('example:getVehicleInfo', function(vehicle)
    local source = source
    local vehicleData = exports['daphne_core']:GetVehicle(vehicle)
    
    if vehicleData then
        TriggerClientEvent('chat:addMessage', source, {
            color = {0, 255, 255},
            multiline = true,
            args = {"Vehicle", string.format("Plate: %s | Model: %s", vehicleData.plate, vehicleData.model)}
        })
    end
end)

