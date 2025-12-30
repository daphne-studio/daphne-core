---ESX Integration Examples
---This file demonstrates ESX-specific usage patterns with Daphne Core bridge

-- Example 1: ESX Job-Based Access Control
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

-- Example 2: ESX Money Transfer Between Players
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

-- Example 3: ESX Shop System with Inventory Check
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
    
    -- Add item (works with both esx_inventory and ox_inventory)
    if exports['daphne_core']:AddItem(source, itemName, itemAmount) then
        TriggerClientEvent('notification', source, string.format('Purchased %dx %s for $%d', itemAmount, itemName, price))
    else
        -- Refund if item add failed
        exports['daphne_core']:AddMoney(source, 'cash', price)
        TriggerClientEvent('notification', source, 'Failed to add item to inventory')
    end
end)

-- Example 4: ESX Job Salary System
local SalaryTimer = {}
CreateThread(function()
    while true do
        Wait(60000 * 10) -- Every 10 minutes
        
        -- Get all players (would need custom function or iterate through sources)
        -- This is a simplified example
        for _, playerId in ipairs(GetPlayers()) do
            local source = tonumber(playerId)
            local job = exports['daphne_core']:GetJob(source)
            
            if job and job.grade.payment > 0 then
                -- Add salary to bank account
                exports['daphne_core']:AddMoney(source, 'bank', job.grade.payment)
                
                TriggerClientEvent('notification', source, string.format('Salary: $%d added to bank', job.grade.payment))
            end
        end
    end
end)

-- Example 5: ESX Custom Account Management (Dirty Money)
RegisterNetEvent('example:addDirtyMoney', function(amount)
    local source = source
    
    -- Add to custom account (if supported by ESX setup)
    if exports['daphne_core']:AddMoney(source, 'dirty_money', amount) then
        TriggerClientEvent('notification', source, string.format('Added $%d dirty money', amount))
    else
        TriggerClientEvent('notification', source, 'Failed to add dirty money')
    end
end)

-- Example 6: ESX Inventory Check for Item Requirements
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

-- Example 7: ESX Player Data Display Command
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
    local message = string.format(
        "Name: %s | Cash: $%d | Bank: $%d | Job: %s (Grade %d)",
        playerData.name,
        playerData.money.cash,
        playerData.money.bank,
        job.label,
        job.grade.level
    )
    
    TriggerClientEvent('chat:addMessage', source, {
        color = {0, 255, 255},
        args = {"Stats", message}
    })
end, false)

-- Example 8: ESX Admin Command - Set Player Job
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
    
    -- Note: Job setting requires direct ESX access or custom export
    -- This is a placeholder showing the concept
    local job = exports['daphne_core']:GetJob(targetId)
    if job then
        -- Would need ESXAdapter:SetJob() or direct ESX access
        TriggerClientEvent('chat:addMessage', source, {
            color = {0, 255, 0},
            args = {"System", string.format("Job set to %s (Grade %d)", jobName, grade)}
        })
    end
end, false)

-- Example 9: ESX State Bag Watcher (Client-Side)
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
--]]

-- Example 10: ESX Vehicle Ownership Check
RegisterNetEvent('example:checkVehicleOwnership', function(vehicle)
    local source = source
    local vehicleData = exports['daphne_core']:GetVehicle(vehicle)
    
    if not vehicleData then
        TriggerClientEvent('notification', source, 'Invalid vehicle')
        return
    end
    
    local playerData = exports['daphne_core']:GetPlayerData(source)
    
    -- Note: ESX vehicle ownership checking would require custom database queries
    -- This is a conceptual example
    if vehicleData.plate then
        -- Check ownership logic here
        TriggerClientEvent('notification', source, 'Vehicle ownership checked')
    end
end)

