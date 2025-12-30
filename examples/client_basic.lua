---Client-Side Basic Usage Examples
---This file demonstrates basic client-side usage of Daphne Core bridge

-- Example 1: Get local player data on spawn
Citizen.CreateThread(function()
    while true do
        Wait(1000)
        
        local playerData = exports['daphne_core']:GetPlayerData()
        if playerData then
            print(string.format('[Example] My name: %s', playerData.name))
            break
        end
    end
end)

-- Example 2: Display money in HUD (simplified example)
Citizen.CreateThread(function()
    while true do
        Wait(1000)
        
        local cash = exports['daphne_core']:GetMoney('cash') or 0
        local bank = exports['daphne_core']:GetMoney('bank') or 0
        
        -- Draw text on screen (you would use your HUD system here)
        -- DrawText(0.02, 0.02, string.format("Cash: $%d | Bank: $%d", cash, bank), 255, 255, 255, 255)
    end
end)

-- Example 3: Watch for money changes
exports['daphne_core']:WatchPlayerStateBag('money', function(value, oldValue)
    if value and oldValue then
        if value.cash ~= oldValue.cash then
            local difference = value.cash - oldValue.cash
            if difference > 0 then
                -- Show notification for money gained
                -- exports['ox_lib']:notify({type = 'success', description = string.format('Gained $%d', difference)})
                print(string.format('[Example] Gained $%d (New total: $%d)', difference, value.cash))
            elseif difference < 0 then
                -- Show notification for money lost
                -- exports['ox_lib']:notify({type = 'error', description = string.format('Lost $%d', math.abs(difference))})
                print(string.format('[Example] Lost $%d (New total: $%d)', math.abs(difference), value.cash))
            end
        end
        
        if value.bank ~= oldValue.bank then
            local difference = value.bank - oldValue.bank
            print(string.format('[Example] Bank changed by $%d (New total: $%d)', difference, value.bank))
        end
    end
end)

-- Example 4: Watch for job changes
exports['daphne_core']:WatchPlayerStateBag('job', function(value, oldValue)
    if value and oldValue and value.name ~= oldValue.name then
        print(string.format('[Example] Job changed from %s to %s', oldValue.name, value.name))
        -- Update UI, permissions, etc.
    end
end)

-- Example 5: Get state bag value directly
RegisterCommand('checkmystate', function()
    local moneyData = exports['daphne_core']:GetPlayerStateBag('money')
    if moneyData then
        print(string.format('[Example] My money from state bag - Cash: $%d, Bank: $%d', 
            moneyData.cash or 0, moneyData.bank or 0))
    end
end, false)

-- Example 6: Check if player has enough money before action
function HasEnoughMoney(amount, moneyType)
    moneyType = moneyType or 'cash'
    local currentMoney = exports['daphne_core']:GetMoney(moneyType)
    return currentMoney and currentMoney >= amount
end

-- Usage example:
RegisterCommand('buyitem', function()
    local price = 100
    if HasEnoughMoney(price, 'cash') then
        -- Trigger server event to purchase
        TriggerServerEvent('example:purchaseItem', 'example_item', price)
    else
        print('[Example] Not enough money!')
    end
end, false)

