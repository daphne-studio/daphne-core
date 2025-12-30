---QBCore Integration Examples
---This file demonstrates QBCore-specific usage patterns with Daphne Core bridge

-- Example 1: QBCore Job-Based Access Control
RegisterNetEvent('example:checkJobAccess', function()
    local source = source
    local job = exports['daphne_core']:GetJob(source)
    
    if not job then
        TriggerClientEvent('notification', source, 'Unable to verify job')
        return
    end
    
    -- Check if player is police with grade 2 or higher
    if job.name == 'police' and job.grade.level >= 2 then
        TriggerClientEvent('notification', source, 'Access granted')
        -- Grant access to restricted area
    else
        TriggerClientEvent('notification', source, 'Access denied: Insufficient rank')
    end
end)

-- Example 2: QBCore Gang-Based Access Control
RegisterNetEvent('example:checkGangAccess', function()
    local source = source
    local gang = exports['daphne_core']:GetGang(source)
    
    if not gang then
        TriggerClientEvent('notification', source, 'You are not in a gang')
        return
    end
    
    -- Check if player is in Ballas gang with grade 2 or higher
    if gang.name == 'ballas' and gang.grade.level >= 2 then
        TriggerClientEvent('notification', source, 'Gang access granted')
        -- Grant access to gang territory
    else
        TriggerClientEvent('notification', source, 'Access denied: Insufficient gang rank')
    end
end)

-- Example 3: QBCore Money Transfer Between Players
RegisterNetEvent('example:transferMoney', function(targetId, amount, moneyType)
    local source = source
    moneyType = moneyType or 'cash'
    
    -- Validate amount
    if amount <= 0 then
        TriggerClientEvent('notification', source, 'Invalid amount')
        return
    end
    
    -- Check if source has enough money
    local sourceMoney = exports['daphne_core']:GetMoney(source, moneyType)
    if sourceMoney < amount then
        TriggerClientEvent('notification', source, 'Insufficient funds')
        return
    end
    
    -- Get target player data
    local targetData = exports['daphne_core']:GetPlayerData(targetId)
    if not targetData then
        TriggerClientEvent('notification', source, 'Target player not found')
        return
    end
    
    -- Remove money from source
    if not exports['daphne_core']:RemoveMoney(source, moneyType, amount) then
        TriggerClientEvent('notification', source, 'Failed to remove money')
        return
    end
    
    -- Add money to target
    if not exports['daphne_core']:AddMoney(targetId, moneyType, amount) then
        -- Refund if failed
        exports['daphne_core']:AddMoney(source, moneyType, amount)
        TriggerClientEvent('notification', source, 'Transfer failed')
        return
    end
    
    -- Success notifications
    TriggerClientEvent('notification', source, string.format('Sent $%d (%s) to %s', amount, moneyType, targetData.name))
    TriggerClientEvent('notification', targetId, string.format('Received $%d (%s) from %s', amount, moneyType, exports['daphne_core']:GetPlayerData(source).name))
end)

-- Example 4: QBCore Shop System with Inventory Check
RegisterNetEvent('example:shopPurchase', function(itemName, price, itemAmount)
    local source = source
    itemAmount = itemAmount or 1
    
    -- Check if player has enough cash
    local cash = exports['daphne_core']:GetMoney(source, 'cash')
    if cash < price then
        TriggerClientEvent('notification', source, 'Insufficient cash')
        return
    end
    
    -- Remove money
    if not exports['daphne_core']:RemoveMoney(source, 'cash', price) then
        TriggerClientEvent('notification', source, 'Failed to process payment')
        return
    end
    
    -- Add item (works with both qb-inventory and ox_inventory)
    if exports['daphne_core']:AddItem(source, itemName, itemAmount) then
        TriggerClientEvent('notification', source, string.format('Purchased %dx %s for $%d', itemAmount, itemName, price))
    else
        -- Refund if item add failed
        exports['daphne_core']:AddMoney(source, 'cash', price)
        TriggerClientEvent('notification', source, 'Failed to add item to inventory')
    end
end)

-- Example 5: QBCore Job Salary System
local SalaryTimer = {}
CreateThread(function()
    while true do
        Wait(60000 * 10) -- Every 10 minutes
        
        -- Get all players
        for _, playerId in ipairs(GetPlayers()) do
            local source = tonumber(playerId)
            local job = exports['daphne_core']:GetJob(source)
            
            if job and job.grade.payment > 0 and job.onduty then
                -- Add salary to bank account
                exports['daphne_core']:AddMoney(source, 'bank', job.grade.payment)
                
                TriggerClientEvent('notification', source, string.format('Salary: $%d added to bank', job.grade.payment))
            end
        end
    end
end)

-- Example 6: QBCore Metadata Management (Hunger/Thirst System)
RegisterNetEvent('example:updateHunger', function(amount)
    local source = source
    
    local currentHunger = exports['daphne_core']:GetMetadata(source, 'hunger') or 100
    local newHunger = math.max(0, math.min(100, currentHunger + amount))
    
    exports['daphne_core']:SetMetadata(source, 'hunger', newHunger)
    
    if newHunger <= 0 then
        TriggerClientEvent('notification', source, 'You are starving!')
    elseif newHunger <= 20 then
        TriggerClientEvent('notification', source, 'You are very hungry')
    end
end)

RegisterNetEvent('example:updateThirst', function(amount)
    local source = source
    
    local currentThirst = exports['daphne_core']:GetMetadata(source, 'thirst') or 100
    local newThirst = math.max(0, math.min(100, currentThirst + amount))
    
    exports['daphne_core']:SetMetadata(source, 'thirst', newThirst)
    
    if newThirst <= 0 then
        TriggerClientEvent('notification', source, 'You are dehydrated!')
    elseif newThirst <= 20 then
        TriggerClientEvent('notification', source, 'You are very thirsty')
    end
end)

-- Example 7: QBCore Inventory Check for Item Requirements
RegisterNetEvent('example:useItem', function(itemName, requiredAmount)
    local source = source
    requiredAmount = requiredAmount or 1
    
    -- Check if player has required item
    if exports['daphne_core']:HasItem(source, itemName, requiredAmount) then
        -- Remove item
        if exports['daphne_core']:RemoveItem(source, itemName, requiredAmount) then
            TriggerClientEvent('notification', source, string.format('Used %dx %s', requiredAmount, itemName))
            -- Do something with the item
        end
    else
        TriggerClientEvent('notification', source, string.format('You need %dx %s', requiredAmount, itemName))
    end
end)

-- Example 8: QBCore Player Data Display Command
RegisterCommand('mystats', function(source, args)
    local playerData = exports['daphne_core']:GetPlayerData(source)
    
    if not playerData then
        TriggerClientEvent('chat:addMessage', source, {
            color = {255, 0, 0},
            args = {"System", "Unable to load player data"}
        })
        return
    end
    
    local job = playerData.job
    local gang = playerData.gang
    local metadata = playerData.metadata or {}
    
    local message = string.format(
        "Name: %s | Cash: $%d | Bank: $%d | Job: %s (Grade %d)",
        playerData.name,
        playerData.money.cash,
        playerData.money.bank,
        job.label,
        job.grade.level
    )
    
    if gang then
        message = message .. string.format(" | Gang: %s (Grade %d)", gang.label, gang.grade.level)
    end
    
    if metadata.hunger then
        message = message .. string.format(" | Hunger: %d%%", metadata.hunger)
    end
    
    if metadata.thirst then
        message = message .. string.format(" | Thirst: %d%%", metadata.thirst)
    end
    
    TriggerClientEvent('chat:addMessage', source, {
        color = {0, 255, 255},
        args = {"Stats", message}
    })
end, false)

-- Example 9: QBCore Admin Command - Set Player Job
RegisterCommand('setjob', function(source, args)
    -- This would require admin check in production
    if not args[1] or not args[2] then
        TriggerClientEvent('chat:addMessage', source, {
            color = {255, 0, 0},
            args = {"System", "Usage: /setjob [id] [jobname] [grade]"}
        })
        return
    end
    
    local targetId = tonumber(args[1])
    local jobName = args[2]
    local grade = tonumber(args[3]) or 0
    
    local job = exports['daphne_core']:GetJob(targetId)
    if job then
        -- Note: Job setting requires direct QBCore access or custom export
        -- This is a placeholder showing the concept
        TriggerClientEvent('chat:addMessage', source, {
            color = {0, 255, 0},
            args = {"System", string.format("Job set to %s (Grade %d)", jobName, grade)}
        })
    end
end, false)

-- Example 10: QBCore Admin Command - Set Player Gang
RegisterCommand('setgang', function(source, args)
    -- This would require admin check in production
    if not args[1] or not args[2] then
        TriggerClientEvent('chat:addMessage', source, {
            color = {255, 0, 0},
            args = {"System", "Usage: /setgang [id] [gangname] [grade]"}
        })
        return
    end
    
    local targetId = tonumber(args[1])
    local gangName = args[2]
    local grade = tonumber(args[3]) or 0
    
    local gang = exports['daphne_core']:GetGang(targetId)
    if gang then
        -- Note: Gang setting requires direct QBCore access or custom export
        -- This is a placeholder showing the concept
        TriggerClientEvent('chat:addMessage', source, {
            color = {0, 255, 0},
            args = {"System", string.format("Gang set to %s (Grade %d)", gangName, grade)}
        })
    end
end, false)

-- Example 11: QBCore State Bag Watcher (Client-Side)
-- This would be in a client script
--[[
exports['daphne_core']:WatchPlayerStateBag('money', function(value, oldValue)
    if value and oldValue then
        local cashDiff = value.cash - (oldValue.cash or 0)
        local bankDiff = value.bank - (oldValue.bank or 0)
        
        if cashDiff ~= 0 then
            -- Update HUD cash display
            SendNUIMessage({
                type = 'updateCash',
                amount = value.cash,
                change = cashDiff
            })
        end
        
        if bankDiff ~= 0 then
            -- Update HUD bank display
            SendNUIMessage({
                type = 'updateBank',
                amount = value.bank,
                change = bankDiff
            })
        end
    end
end)

exports['daphne_core']:WatchPlayerStateBag('job', function(value, oldValue)
    if value and oldValue and value.name ~= oldValue.name then
        -- Job changed
        SendNUIMessage({
            type = 'updateJob',
            job = value.label,
            grade = value.grade.label
        })
    end
end)

exports['daphne_core']:WatchPlayerStateBag('gang', function(value, oldValue)
    if value and oldValue and value.name ~= oldValue.name then
        -- Gang changed
        SendNUIMessage({
            type = 'updateGang',
            gang = value.label,
            grade = value.grade.label
        })
    end
end)
--]]

-- Example 12: QBCore Vehicle Ownership Check
RegisterNetEvent('example:checkVehicleOwnership', function(vehicle)
    local source = source
    local vehicleData = exports['daphne_core']:GetVehicle(vehicle)
    
    if not vehicleData then
        TriggerClientEvent('notification', source, 'Invalid vehicle')
        return
    end
    
    local playerData = exports['daphne_core']:GetPlayerData(source)
    
    -- Check if player owns the vehicle
    if vehicleData.citizenid and vehicleData.citizenid == playerData.citizenid then
        TriggerClientEvent('notification', source, 'You own this vehicle')
        -- Grant access to vehicle
    else
        TriggerClientEvent('notification', source, 'You do not own this vehicle')
    end
end)

-- Example 13: QBCore Gang Territory System
RegisterNetEvent('example:enterGangTerritory', function(territoryGang)
    local source = source
    local gang = exports['daphne_core']:GetGang(source)
    
    if not gang then
        TriggerClientEvent('notification', source, 'You are not in a gang')
        return
    end
    
    if gang.name == territoryGang then
        TriggerClientEvent('notification', source, 'Welcome to your gang territory')
        -- Grant benefits
    else
        TriggerClientEvent('notification', source, 'You are in enemy territory!')
        -- Apply penalties or restrictions
    end
end)

-- Example 14: QBCore ox_inventory Specific Usage
RegisterNetEvent('example:oxInventoryUsage', function()
    local source = source
    
    -- ox_inventory supports metadata in items
    local item = exports['daphne_core']:GetItem(source, 'weapon_pistol')
    if item and item.metadata then
        -- Access item metadata
        local serial = item.metadata.serial
        local quality = item.metadata.quality
        
        TriggerClientEvent('notification', source, string.format('Weapon Serial: %s, Quality: %d%%', serial or 'N/A', quality or 100))
    end
    
    -- Add item with metadata (ox_inventory)
    exports['daphne_core']:AddItem(source, 'weapon_pistol', 1, nil, {
        serial = 'ABC123',
        quality = 100,
        ammo = 50
    })
end)

