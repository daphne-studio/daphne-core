# Quick Start Guide

Get started with daphne-core in 5 minutes. This guide covers installation, basic usage, and common scenarios.

## Table of Contents

- [Installation](#installation)
- [Verification](#verification)
- [Basic Usage](#basic-usage)
- [Common Scenarios](#common-scenarios)
- [Next Steps](#next-steps)

## Installation

### Prerequisites

- FiveM Server
- One of the supported frameworks:
  - **QBCore** or **Qbox**
  - **ESX Legacy**

### Installation Steps

1. **Download daphne-core** and place it in your `resources` directory

2. **Add to server.cfg:**
   ```cfg
   # Ensure your framework starts first
   ensure qbx_core  # or qb-core for QBCore
   # OR
   ensure es_extended  # for ESX
   
   # Then ensure daphne_core
   ensure daphne_core
   ```

3. **Restart your server**

### Framework-Specific Notes

**For QBCore/Qbox:**
- Ensure `qbx_core` or `qb-core` is started before `daphne_core`
- Supports both `qb-inventory` and `ox_inventory` (auto-detected)

**For ESX Legacy:**
- Ensure `es_extended` is started before `daphne_core`
- Supports both `esx_inventory` and `ox_inventory` (auto-detected)

## Verification

### Check Framework Detection

After starting your server, check the console for:

```
[Daphne Core] Framework detected: qbox
[Daphne Core] Bridge initialized with Qbox adapter
```

Or for ESX:

```
[Daphne Core] Framework detected: es_extended
[Daphne Core] Bridge initialized with ESX adapter
```

If you see an error, ensure your framework is started **before** daphne_core in server.cfg.

## Basic Usage

### Server-Side Example

Create a simple server script to test daphne-core:

```lua
-- server/test_daphne.lua
RegisterCommand('testdaphne', function(source, args)
    local playerData = exports['daphne_core']:GetPlayerData(source)
    
    if playerData then
        print(string.format("Player: %s", playerData.name))
        print(string.format("Cash: $%d", playerData.money.cash))
        print(string.format("Bank: $%d", playerData.money.bank))
        print(string.format("Job: %s", playerData.job.name))
    else
        print("Failed to get player data")
    end
end, false)
```

### Client-Side Example

Create a simple client script:

```lua
-- client/test_daphne.lua
RegisterCommand('mymoney', function()
    local cash = exports['daphne_core']:GetMoney('cash') or 0
    local bank = exports['daphne_core']:GetMoney('bank') or 0
    
    print(string.format("Cash: $%d | Bank: $%d", cash, bank))
end, false)
```

### Watch State Bag Changes

```lua
-- client/watch_money.lua
exports['daphne_core']:WatchPlayerStateBag('money', function(value, oldValue)
    if value and oldValue then
        if value.cash ~= oldValue.cash then
            local difference = value.cash - oldValue.cash
            print(string.format("Cash changed by: $%d", difference))
        end
    end
end)
```

## Common Scenarios

### Scenario 1: Give Money to Player

**Server-side:**
```lua
RegisterCommand('givemoney', function(source, args)
    local targetId = tonumber(args[1])
    local amount = tonumber(args[2])
    
    if not targetId or not amount then
        TriggerClientEvent('chat:addMessage', source, {
            args = {"Usage: /givemoney [id] [amount]"}
        })
        return
    end
    
    local success = exports['daphne_core']:AddMoney(targetId, 'cash', amount)
    
    if success then
        TriggerClientEvent('chat:addMessage', source, {
            args = {string.format("Gave $%d to player %d", amount, targetId)}
        })
    else
        TriggerClientEvent('chat:addMessage', source, {
            args = {"Failed to give money"}
        })
    end
end, false)
```

### Scenario 2: Check if Player Has Item

**Server-side:**
```lua
RegisterNetEvent('example:checkItem', function()
    local source = source
    
    if exports['daphne_core']:HasItem(source, 'bread', 1) then
        print("Player has bread")
        -- Do something
    else
        print("Player doesn't have bread")
    end
end)
```

### Scenario 3: Job-Based Access Control

**Server-side:**
```lua
RegisterNetEvent('example:policeOnly', function()
    local source = source
    local job = exports['daphne_core']:GetJob(source)
    
    if job and job.name == 'police' then
        -- Allow access
        print("Access granted - Police officer")
    else
        -- Deny access
        TriggerClientEvent('chat:addMessage', source, {
            args = {"Access denied - Police only"}
        })
    end
end)
```

### Scenario 4: Money Transfer Between Players

**Server-side:**
```lua
RegisterNetEvent('example:transferMoney', function(targetId, amount)
    local source = source
    
    -- Check if source has enough money
    local sourceMoney = exports['daphne_core']:GetMoney(source, 'bank')
    if not sourceMoney or sourceMoney < amount then
        TriggerClientEvent('chat:addMessage', source, {
            args = {"Insufficient funds"}
        })
        return
    end
    
    -- Remove from source
    local removeSuccess = exports['daphne_core']:RemoveMoney(source, 'bank', amount)
    if not removeSuccess then
        TriggerClientEvent('chat:addMessage', source, {
            args = {"Transfer failed"}
        })
        return
    end
    
    -- Add to target
    local addSuccess = exports['daphne_core']:AddMoney(targetId, 'bank', amount)
    if addSuccess then
        TriggerClientEvent('chat:addMessage', source, {
            args = {string.format("Transferred $%d to player %d", amount, targetId)}
        })
        TriggerClientEvent('chat:addMessage', targetId, {
            args = {string.format("Received $%d from player %d", amount, source)}
        })
    else
        -- Refund if target add failed
        exports['daphne_core']:AddMoney(source, 'bank', amount)
        TriggerClientEvent('chat:addMessage', source, {
            args = {"Transfer failed - refunded"}
        })
    end
end)
```

### Scenario 5: HUD Integration (Client-Side)

**Client-side:**
```lua
-- Update HUD when money changes
exports['daphne_core']:WatchPlayerStateBag('money', function(value, oldValue)
    if value then
        -- Update your HUD system
        -- Example: exports['your_hud']:UpdateMoney(value.cash, value.bank)
        print(string.format("Money updated - Cash: $%d, Bank: $%d", 
            value.cash or 0, value.bank or 0))
    end
end)

-- Update HUD when job changes
exports['daphne_core']:WatchPlayerStateBag('job', function(value, oldValue)
    if value then
        -- Update your HUD system
        -- Example: exports['your_hud']:UpdateJob(value.name, value.label)
        print(string.format("Job updated - %s (%s)", value.label, value.name))
    end
end)
```

### Scenario 6: Shop System

**Server-side:**
```lua
RegisterNetEvent('example:buyItem', function(itemName, price)
    local source = source
    
    -- Check if player has enough money
    local cash = exports['daphne_core']:GetMoney(source, 'cash')
    if not cash or cash < price then
        TriggerClientEvent('chat:addMessage', source, {
            args = {"Not enough cash"}
        })
        return
    end
    
    -- Remove money
    local moneySuccess = exports['daphne_core']:RemoveMoney(source, 'cash', price)
    if not moneySuccess then
        TriggerClientEvent('chat:addMessage', source, {
            args = {"Purchase failed"}
        })
        return
    end
    
    -- Add item
    local itemSuccess = exports['daphne_core']:AddItem(source, itemName, 1)
    if itemSuccess then
        TriggerClientEvent('chat:addMessage', source, {
            args = {string.format("Purchased %s for $%d", itemName, price)}
        })
    else
        -- Refund if item add failed
        exports['daphne_core']:AddMoney(source, 'cash', price)
        TriggerClientEvent('chat:addMessage', source, {
            args = {"Purchase failed - refunded"}
        })
    end
end)
```

## Next Steps

Now that you've completed the quick start:

1. **Read the [API Reference](API_REFERENCE.md)** - Complete export documentation
2. **Check [Data Structures](DATA_STRUCTURES.md)** - Understand data formats
3. **Learn [State Bag System](STATE_BAG_SYSTEM.md)** - Advanced state bag usage
4. **See [Integration Guide](INTEGRATION_GUIDE.md)** - Integration patterns
5. **Review [Examples Collection](EXAMPLES_COLLECTION.md)** - More examples

## Troubleshooting

### Framework Not Detected

**Problem:** Console shows "No supported framework detected"

**Solution:**
1. Ensure your framework is started **before** daphne_core in server.cfg
2. Check framework resource name matches exactly:
   - `qbx_core` or `qb-core` for QBCore
   - `es_extended` for ESX
3. Restart server

### Exports Return Nil

**Problem:** Exports return `nil` or `false`

**Solution:**
1. Check if player is online and loaded
2. Verify framework is initialized (check console logs)
3. Ensure you're using correct export syntax: `exports['daphne_core']:FunctionName()`

### State Bag Not Updating

**Problem:** State bag values not updating on client

**Solution:**
1. State bag updates are batched (50ms) and throttled (100ms per entity)
2. Updates only occur on write operations (AddMoney, RemoveMoney, SetMetadata)
3. Read operations do not trigger updates (performance optimization)

## Related Documentation

- [API Reference](API_REFERENCE.md) - Complete API documentation
- [FAQ](FAQ.md) - Common questions and solutions
- [Integration Guide](INTEGRATION_GUIDE.md) - Integration patterns

