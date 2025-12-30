# ESX Legacy Adapter Documentation

Complete documentation for using Daphne Core with ESX Legacy framework.

## Overview

The ESX adapter provides full compatibility with ESX Legacy framework, allowing you to use Daphne Core's unified API regardless of your framework choice. The adapter automatically detects your inventory system and handles ESX-specific features seamlessly.

## Features

- ✅ Full ESX Legacy support
- ✅ Automatic inventory system detection (`esx_inventory` or `ox_inventory`)
- ✅ ESX job system integration
- ✅ ESX account system (cash, bank, and custom accounts)
- ✅ Player metadata support
- ✅ State bag synchronization
- ✅ Performance optimized (0.00ms policy)

## Installation

1. Ensure `es_extended` is installed and configured
2. Ensure `daphne_core` is started after `es_extended` in your `server.cfg`
3. If using `ox_inventory`, ensure it's started before `daphne_core`
4. Restart your server

### server.cfg Example

```cfg
ensure es_extended
ensure esx_inventory  # or ox_inventory
ensure daphne_core
```

## Inventory System Support

The ESX adapter automatically detects and supports both inventory systems:

### esx_inventory (Standard ESX Inventory)

- Uses ESX's built-in `xPlayer.getInventory()` method
- Full item management support
- Compatible with standard ESX inventory items

### ox_inventory

- Automatically detected when `ox_inventory` resource is running
- Uses `exports.ox_inventory` API
- Supports metadata and advanced item features
- Note: `GetInventory()` returns empty table for ox_inventory (works item-by-item)

## API Usage

### Server-Side

#### Get Player Data

```lua
local playerData = exports['daphne_core']:GetPlayerData(source)
if playerData then
    print("Player: " .. playerData.name)
    print("Identifier: " .. playerData.citizenid)
    print("Cash: $" .. playerData.money.cash)
    print("Bank: $" .. playerData.money.bank)
    print("Job: " .. playerData.job.name .. " - " .. playerData.job.label)
end
```

#### Money Operations

```lua
-- Get money
local cash = exports['daphne_core']:GetMoney(source, 'cash')
local bank = exports['daphne_core']:GetMoney(source, 'bank')

-- Add money
exports['daphne_core']:AddMoney(source, 'cash', 1000)
exports['daphne_core']:AddMoney(source, 'bank', 5000)

-- Remove money
exports['daphne_core']:RemoveMoney(source, 'cash', 500)
exports['daphne_core']:RemoveMoney(source, 'bank', 1000)
```

#### Job Operations

```lua
-- Get player job
local job = exports['daphne_core']:GetJob(source)
if job then
    print("Job: " .. job.name)
    print("Grade: " .. job.grade.level)
    print("Salary: $" .. job.grade.payment)
end

-- Note: Job setting requires direct ESX access
-- Use ESXAdapter for advanced job operations
```

#### Inventory Operations

```lua
-- Get inventory (works with both esx_inventory and ox_inventory)
local inventory = exports['daphne_core']:GetInventory(source)

-- For esx_inventory: Returns full inventory table
-- For ox_inventory: Returns empty table (use item-specific methods)

-- Check if player has item (works with both systems)
local hasItem = exports['daphne_core']:HasItem(source, 'bread', 1)
```

### Client-Side

```lua
-- Get local player data
local playerData = exports['daphne_core']:GetPlayerData()
if playerData then
    print("My Name: " .. playerData.name)
end

-- Get local player money
local cash = exports['daphne_core']:GetMoney('cash')
local bank = exports['daphne_core']:GetMoney('bank')

-- Watch money changes
exports['daphne_core']:WatchPlayerStateBag('money', function(value, oldValue)
    if value and oldValue then
        if value.cash ~= oldValue.cash then
            print("Cash changed from $" .. oldValue.cash .. " to $" .. value.cash)
        end
    end
end)
```

## Data Structure Mapping

### Player Data

ESX xPlayer → Bridge PlayerData:

```lua
{
    source = source,
    citizenid = xPlayer.identifier,  -- ESX identifier
    name = xPlayer.getName(),         -- Full name
    money = {
        cash = xPlayer.getMoney(),
        bank = xPlayer.getAccount('bank').money
    },
    job = {
        name = "police",
        label = "Police",
        grade = {
            level = 2,
            name = "officer",
            label = "Officer",
            payment = 500
        },
        onduty = false
    },
    metadata = {}  -- ESX metadata if available
}
```

### Job Data

ESX job → Bridge JobData:

```lua
{
    name = "police",           -- Job name
    label = "Police",          -- Job label
    grade = {
        level = 2,            -- Grade level (number)
        name = "officer",      -- Grade name
        label = "Officer",     -- Grade label
        payment = 500          -- Grade salary
    },
    onduty = false             -- On duty status
}
```

## ESX-Specific Features

### Custom Accounts

ESX supports custom accounts beyond cash and bank. The adapter can handle these:

```lua
-- Get custom account money
local dirtyMoney = exports['daphne_core']:GetMoney(source, 'dirty_money')

-- Add to custom account
exports['daphne_core']:AddMoney(source, 'dirty_money', 1000)

-- Remove from custom account
exports['daphne_core']:RemoveMoney(source, 'dirty_money', 500)
```

### Direct ESX Access

For advanced ESX features, you can access the ESX object directly:

```lua
-- Get ESX adapter
local ESXAdapter = exports['daphne_core']:GetAdapter()  -- If exposed
-- Or access ESX directly in your code
local ESX = exports['es_extended']:getSharedObject()
```

## Inventory System Details

### esx_inventory

When using `esx_inventory`, the adapter uses ESX's standard inventory methods:

```lua
-- Get full inventory
local inventory = exports['daphne_core']:GetInventory(source)
-- Returns: { {name = "bread", count = 5}, {name = "water", count = 2}, ... }

-- Add item
exports['daphne_core']:AddItem(source, 'bread', 1)

-- Remove item
exports['daphne_core']:RemoveItem(source, 'bread', 1)

-- Check item
local hasBread = exports['daphne_core']:HasItem(source, 'bread', 1)
```

### ox_inventory

When using `ox_inventory`, the adapter uses ox_inventory's export API:

```lua
-- Note: GetInventory() returns empty table for ox_inventory
-- Use item-specific methods instead

-- Get item
local item = exports['daphne_core']:GetItem(source, 'bread')
-- Returns: {name = "bread", count = 5, ...}

-- Add item (with metadata support)
exports['daphne_core']:AddItem(source, 'bread', 1, nil, {quality = 100})

-- Remove item
exports['daphne_core']:RemoveItem(source, 'bread', 1)

-- Check item
local hasBread = exports['daphne_core']:HasItem(source, 'bread', 1)
```

## State Bag Synchronization

The ESX adapter automatically syncs player data to state bags:

- **Money**: `daphne:player:[source]:money` - Updated when money changes
- **Job**: `daphne:player:[source]:job` - Updated when job changes
- **Player Data**: `daphne:player:[source]:data` - Updated when player data changes

### Watching State Bags

```lua
-- Client-side: Watch money changes
exports['daphne_core']:WatchPlayerStateBag('money', function(value, oldValue)
    if value and oldValue then
        local cashDiff = value.cash - oldValue.cash
        local bankDiff = value.bank - oldValue.bank
        
        if cashDiff ~= 0 then
            print("Cash changed by: $" .. cashDiff)
        end
        
        if bankDiff ~= 0 then
            print("Bank changed by: $" .. bankDiff)
        end
    end
end)

-- Watch job changes
exports['daphne_core']:WatchPlayerStateBag('job', function(value, oldValue)
    if value and oldValue and value.name ~= oldValue.name then
        print("Job changed from " .. oldValue.name .. " to " .. value.name)
    end
end)
```

## Common Use Cases

### Job-Based Access Control

```lua
-- Server-side: Check if player has specific job
local job = exports['daphne_core']:GetJob(source)
if job and job.name == 'police' and job.grade.level >= 2 then
    -- Allow access
else
    -- Deny access
end
```

### Money Transfer System

```lua
-- Server-side: Transfer money between players
function TransferMoney(source, target, amount, type)
    type = type or 'cash'
    
    -- Check if source has enough money
    local sourceMoney = exports['daphne_core']:GetMoney(source, type)
    if sourceMoney < amount then
        return false, "Insufficient funds"
    end
    
    -- Remove from source
    if not exports['daphne_core']:RemoveMoney(source, type, amount) then
        return false, "Failed to remove money"
    end
    
    -- Add to target
    if not exports['daphne_core']:AddMoney(target, type, amount) then
        -- Refund if failed
        exports['daphne_core']:AddMoney(source, type, amount)
        return false, "Failed to add money"
    end
    
    return true, "Transfer successful"
end
```

### Shop System Integration

```lua
-- Server-side: Purchase item
RegisterServerEvent('shop:purchase')
AddEventHandler('shop:purchase', function(item, price)
    local source = source
    
    -- Check if player has enough money
    local cash = exports['daphne_core']:GetMoney(source, 'cash')
    if cash < price then
        TriggerClientEvent('notification', source, 'Insufficient funds')
        return
    end
    
    -- Remove money
    if exports['daphne_core']:RemoveMoney(source, 'cash', price) then
        -- Add item
        if exports['daphne_core']:AddItem(source, item, 1) then
            TriggerClientEvent('notification', source, 'Purchase successful')
        else
            -- Refund if item add failed
            exports['daphne_core']:AddMoney(source, 'cash', price)
            TriggerClientEvent('notification', source, 'Failed to add item')
        end
    end
end)
```

## Troubleshooting

### ESX Not Detected

**Problem**: `[Daphne Core] ESX not found!`

**Solutions**:
1. Ensure `es_extended` is started before `daphne_core` in `server.cfg`
2. Check that `es_extended` resource exists and is properly configured
3. Verify ESX is using the standard export method: `exports['es_extended']:getSharedObject()`

### Inventory Not Working

**Problem**: Inventory operations fail or return empty

**Solutions**:
1. For `esx_inventory`: Ensure `esx_inventory` resource is started
2. For `ox_inventory`: Ensure `ox_inventory` resource is started and properly configured
3. Check server console for error messages
4. Verify inventory system is compatible with ESX Legacy

### Money Operations Not Syncing

**Problem**: Money changes but state bag doesn't update

**Solutions**:
1. Check that state bag system is working (check server console)
2. Verify player source ID is correct
3. Check for errors in server console
4. Ensure state bag updates aren't being throttled (normal behavior)

## Performance Notes

- The ESX adapter follows the 0.00ms policy
- State bag updates are batched (50ms interval)
- Throttling prevents excessive updates (100ms per entity)
- Change detection minimizes unnecessary syncs
- Lazy loading for on-demand data access

## Migration from Direct ESX Usage

If you're migrating from direct ESX usage to Daphne Core:

### Before (Direct ESX)

```lua
local ESX = exports['es_extended']:getSharedObject()
local xPlayer = ESX.GetPlayerFromId(source)
local money = xPlayer.getMoney()
xPlayer.addMoney(1000)
```

### After (Daphne Core)

```lua
local money = exports['daphne_core']:GetMoney(source, 'cash')
exports['daphne_core']:AddMoney(source, 'cash', 1000)
```

**Benefits**:
- Framework-agnostic code
- Unified API across frameworks
- Automatic state bag synchronization
- Better performance optimizations

## Additional Resources

- [Main Documentation](../README.md)
- [Examples Directory](../examples/README.md)
- [ESX Legacy Documentation](https://docs.esx-framework.org/)

## Support

For ESX-specific issues or questions:
- Check the [Troubleshooting](#troubleshooting) section
- Visit [Daphne Studio's Discord Server](https://discord.gg/qEwgy9B5br)
- Review ESX Legacy documentation

---

**Note**: This adapter is designed for ESX Legacy. For newer ESX versions, compatibility may vary. Test thoroughly before deploying to production.

