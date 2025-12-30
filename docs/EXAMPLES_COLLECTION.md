# Examples Collection

Detailed explanations of all example files with code walkthroughs, use cases, and best practices.

## Table of Contents

- [server_basic.lua](#server_basiclua)
- [client_basic.lua](#client_basiclua)
- [statebag_advanced.lua](#statebag_advancedlua)
- [resource_integration.lua](#resource_integrationlua)
- [qbcore_integration.lua](#qbcore_integrationlua)
- [esx_integration.lua](#esx_integrationlua)

## server_basic.lua

**Purpose:** Basic server-side usage examples

**Key Concepts:**
- Getting player data
- Money operations
- Job checking
- Vehicle information
- Command examples

**Code Walkthrough:**

```lua
-- Example: Get player data when player joins
RegisterNetEvent('playerConnecting', function()
    local source = source
    
    -- Wait for player to fully load
    SetTimeout(2000, function()
        local playerData = exports['daphne_core']:GetPlayerData(source)
        
        if playerData then
            print(string.format('[Example] Player %s (%s) connected', 
                playerData.name, playerData.citizenid))
        end
    end)
end)
```

**Use Cases:**
- Player join logging
- Welcome messages
- Initial data setup

**Best Practices:**
- Always check return values
- Use SetTimeout for player loading
- Handle nil cases

## client_basic.lua

**Purpose:** Basic client-side usage examples

**Key Concepts:**
- Getting local player data
- Displaying money in HUD
- Watching state bag changes
- Money validation functions

**Code Walkthrough:**

```lua
-- Example: Watch for money changes
exports['daphne_core']:WatchPlayerStateBag('money', function(value, oldValue)
    if value and oldValue then
        if value.cash ~= oldValue.cash then
            local difference = value.cash - oldValue.cash
            if difference > 0 then
                print(string.format('[Example] Gained $%d', difference))
            elseif difference < 0 then
                print(string.format('[Example] Lost $%d', math.abs(difference)))
            end
        end
    end
end)
```

**Use Cases:**
- HUD updates
- Money change notifications
- Real-time UI updates

**Best Practices:**
- Use watchers instead of polling
- Check for nil values
- Handle first callback (oldValue may be nil)

## statebag_advanced.lua

**Purpose:** Advanced state bag usage patterns

**Key Concepts:**
- Debounced watchers
- Multiple key watchers
- State bag caching with TTL
- Change aggregation
- State bag validation

**Code Walkthrough:**

```lua
-- Example: Custom state bag watcher with debouncing
local function CreateDebouncedWatcher(key, callback, delay)
    delay = delay or 500
    local lastCall = 0
    local lastValue = nil
    
    return exports['daphne_core']:WatchPlayerStateBag(key, function(value, oldValue)
        local now = GetGameTimer()
        
        -- Debounce: only call callback if enough time has passed
        if now - lastCall >= delay then
            callback(value, oldValue, lastValue)
            lastValue = value
            lastCall = now
        end
    end)
end
```

**Use Cases:**
- Reducing callback frequency
- Aggregating changes
- Validating state bag data

**Best Practices:**
- Use debouncing for frequent updates
- Aggregate changes when possible
- Validate state bag data

## resource_integration.lua

**Purpose:** Complete resource integration examples

**Key Concepts:**
- Shop system implementation
- Job-based access control
- Money transfer system
- HUD integration
- Real-world usage patterns

**Code Walkthrough:**

```lua
-- Example: Shop system using Daphne Core
local ShopItems = {
    {name = 'water', price = 5, moneyType = 'cash'},
    {name = 'bread', price = 3, moneyType = 'cash'},
    {name = 'phone', price = 500, moneyType = 'bank'},
}

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
        -- Give item
        exports['daphne_core']:AddItem(source, item.name, 1)
        TriggerClientEvent('shop:notification', source, 'success', 
            string.format('Purchased %s for $%d', item.name, item.price))
    else
        TriggerClientEvent('shop:notification', source, 'error', 'Purchase failed')
    end
end)
```

**Use Cases:**
- Shop systems
- Vending machines
- NPC vendors

**Best Practices:**
- Validate inputs
- Check money before purchase
- Refund on item add failure
- Provide user feedback

## qbcore_integration.lua

**Purpose:** QBCore-specific integration examples

**Key Concepts:**
- QBCore job-based access control
- QBCore gang-based access control
- Money transfer between players
- Shop system with inventory checks
- Job salary system
- Metadata management
- Vehicle ownership checks
- Gang territory system
- ox_inventory specific usage

**Code Walkthrough:**

```lua
-- Example: QBCore Gang-Based Access Control
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
```

**Use Cases:**
- Gang territory systems
- Gang-based permissions
- Gang activities

**Best Practices:**
- Check for nil gang
- Verify gang name and grade
- Provide clear feedback

## esx_integration.lua

**Purpose:** ESX-specific integration examples

**Key Concepts:**
- ESX job-based access control
- Money transfer between players
- Shop system with inventory checks
- Job salary system
- Custom account management (dirty money)
- Inventory item requirements
- State bag watchers for HUD updates
- ESX-specific patterns and best practices

**Code Walkthrough:**

```lua
-- Example: ESX Job Salary System
local SalaryTimer = {}
CreateThread(function()
    while true do
        Wait(60000 * 10) -- Every 10 minutes
        
        -- Get all players
        local players = GetPlayers()
        
        for _, playerId in ipairs(players) do
            local source = tonumber(playerId)
            local job = exports['daphne_core']:GetJob(source)
            
            if job and job.onduty and job.grade.payment > 0 then
                -- Pay salary
                exports['daphne_core']:AddMoney(source, 'bank', job.grade.payment)
                TriggerClientEvent('notification', source, 
                    string.format('Received salary: $%d', job.grade.payment))
            end
        end
    end
end)
```

**Use Cases:**
- Job salary systems
- Payroll systems
- Duty-based payments

**Best Practices:**
- Check job and onduty status
- Verify payment amount
- Use appropriate money type
- Provide user feedback

## Related Documentation

- [API Reference](API_REFERENCE.md) - Export function documentation
- [Integration Guide](INTEGRATION_GUIDE.md) - Integration patterns
- [Quick Start](QUICK_START.md) - Getting started guide

