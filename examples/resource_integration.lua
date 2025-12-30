---Example Resource Integration
---This file shows how to integrate Daphne Core into your own resource

-- This is an example resource that uses Daphne Core bridge
-- Place this in your resource's server.lua or client.lua

-- ============================================
-- SERVER-SIDE INTEGRATION EXAMPLE
-- ============================================

if IsDuplicityVersion() then
    -- Example: Shop system using Daphne Core
    
    local ShopItems = {
        {name = 'water', price = 5, moneyType = 'cash'},
        {name = 'bread', price = 3, moneyType = 'cash'},
        {name = 'phone', price = 500, moneyType = 'bank'},
        {name = 'laptop', price = 2000, moneyType = 'bank'},
    }
    
    -- Register shop purchase event
    RegisterNetEvent('shop:purchase', function(itemName)
        local source = source
        
        -- Find item in shop
        local item = nil
        for _, shopItem in ipairs(ShopItems) do
            if shopItem.name == itemName then
                item = shopItem
                break
            end
        end
        
        if not item then
            TriggerClientEvent('shop:notification', source, 'error', 'Item not found')
            return
        end
        
        -- Check if player has enough money
        local playerMoney = exports['daphne_core']:GetMoney(source, item.moneyType)
        
        if not playerMoney or playerMoney < item.price then
            TriggerClientEvent('shop:notification', source, 'error', 'Not enough money!')
            return
        end
        
        -- Remove money
        if exports['daphne_core']:RemoveMoney(source, item.moneyType, item.price) then
            -- Give item to player (use your inventory system)
            -- exports['your_inventory']:AddItem(source, item.name, 1)
            
            TriggerClientEvent('shop:notification', source, 'success', string.format('Purchased %s for $%d', item.name, item.price))
        else
            TriggerClientEvent('shop:notification', source, 'error', 'Purchase failed')
        end
    end)
    
    -- Example: Job-based access control
    RegisterNetEvent('job:checkAccess', function(requiredJob, minGrade)
        local source = source
        local playerJob = exports['daphne_core']:GetJob(source)
        
        if not playerJob then
            TriggerClientEvent('job:accessResult', source, false, 'Job data not found')
            return
        end
        
        if playerJob.name == requiredJob and playerJob.grade.level >= (minGrade or 0) then
            TriggerClientEvent('job:accessResult', source, true, 'Access granted')
        else
            TriggerClientEvent('job:accessResult', source, false, 'Insufficient permissions')
        end
    end)
    
    -- Example: Money transfer between players
    RegisterNetEvent('money:transfer', function(targetId, amount, moneyType)
        local source = source
        moneyType = moneyType or 'bank'
        
        -- Validate amount
        if not amount or amount <= 0 then
            TriggerClientEvent('money:transferResult', source, false, 'Invalid amount')
            return
        end
        
        -- Check if source has enough money
        local sourceMoney = exports['daphne_core']:GetMoney(source, moneyType)
        if not sourceMoney or sourceMoney < amount then
            TriggerClientEvent('money:transferResult', source, false, 'Not enough money')
            return
        end
        
        -- Transfer money
        if exports['daphne_core']:RemoveMoney(source, moneyType, amount) then
            if exports['daphne_core']:AddMoney(targetId, moneyType, amount) then
                TriggerClientEvent('money:transferResult', source, true, string.format('Transferred $%d to player %d', amount, targetId))
                TriggerClientEvent('money:transferResult', targetId, true, string.format('Received $%d from player %d', amount, source))
            else
                -- Refund if target add failed
                exports['daphne_core']:AddMoney(source, moneyType, amount)
                TriggerClientEvent('money:transferResult', source, false, 'Transfer failed')
            end
        else
            TriggerClientEvent('money:transferResult', source, false, 'Transfer failed')
        end
    end)
end

-- ============================================
-- CLIENT-SIDE INTEGRATION EXAMPLE
-- ============================================

if not IsDuplicityVersion() then
    -- Example: HUD integration
    local function UpdateHUD()
        local cash = exports['daphne_core']:GetMoney('cash') or 0
        local bank = exports['daphne_core']:GetMoney('bank') or 0
        
        -- Update your HUD here
        -- exports['your_hud']:UpdateMoney(cash, bank)
        
        return cash, bank
    end
    
    -- Update HUD every second
    Citizen.CreateThread(function()
        while true do
            Wait(1000)
            UpdateHUD()
        end
    end)
    
    -- Watch for money changes and update HUD immediately
    exports['daphne_core']:WatchPlayerStateBag('money', function(value, oldValue)
        if value then
            UpdateHUD()
        end
    end)
    
    -- Example: Job-based UI updates
    exports['daphne_core']:WatchPlayerStateBag('job', function(value, oldValue)
        if value then
            -- Update UI based on job
            -- exports['your_ui']:UpdateJob(value.name, value.grade.level)
            
            -- Show notification on job change
            if oldValue and value.name ~= oldValue.name then
                -- exports['ox_lib']:notify({type = 'info', description = string.format('Job changed to %s', value.name)})
            end
        end
    end)
    
    -- Example: Command to check player info
    RegisterCommand('myinfo', function()
        local playerData = exports['daphne_core']:GetPlayerData()
        if playerData then
            print(string.format('Name: %s', playerData.name))
            print(string.format('CitizenID: %s', playerData.citizenid))
            
            local job = exports['daphne_core']:GetJob()
            if job then
                print(string.format('Job: %s (Grade %d)', job.name, job.grade.level))
            end
            
            local cash = exports['daphne_core']:GetMoney('cash') or 0
            local bank = exports['daphne_core']:GetMoney('bank') or 0
            print(string.format('Money: Cash $%d | Bank $%d', cash, bank))
        end
    end, false)
end

