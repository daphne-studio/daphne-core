# QBCore/Qbox Adapter Documentation

Complete documentation for using Daphne Core with QBCore/Qbox framework.

## Overview

The QBCore/Qbox adapter provides full compatibility with QBCore and Qbox frameworks, allowing you to use Daphne Core's unified API regardless of your framework choice. The adapter automatically detects your inventory system and handles QBCore-specific features seamlessly.

## Features

- ✅ Full QBCore/Qbox support
- ✅ Automatic inventory system detection (`qb-inventory` or `ox_inventory`)
- ✅ QBCore job system integration
- ✅ QBCore gang system integration (QBCore exclusive feature)
- ✅ Player metadata support
- ✅ Vehicle ownership system
- ✅ State bag synchronization
- ✅ Performance optimized (0.00ms policy)

## Installation

1. Ensure `qb-core` or `qbx_core` is installed and configured
2. Ensure `daphne_core` is started after your framework in your `server.cfg`
3. If using `ox_inventory`, ensure it's started before `daphne_core`
4. Restart your server

### server.cfg Example

```cfg
ensure qb-core  # or qbx_core
ensure qb-inventory  # or ox_inventory
ensure daphne_core
```

## Inventory System Support

The QBCore adapter automatically detects and supports both inventory systems:

### qb-inventory (Standard QBCore Inventory)

- Uses QBCore's built-in player inventory methods
- Full item management support
- Compatible with standard QBCore inventory items

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
    print("CitizenID: " .. playerData.citizenid)
    print("Cash: $" .. playerData.money.cash)
    print("Bank: $" .. playerData.money.bank)
    print("Job: " .. playerData.job.name .. " - " .. playerData.job.label)
    print("Gang: " .. (playerData.gang.name or "None"))
end
```

#### Money Operations

```lua
-- Get money
local cash = exports['daphne_core']:GetMoney(source, 'cash')
local bank = exports['daphne_core']:GetMoney(source, 'bank')
local crypto = exports['daphne_core']:GetMoney(source, 'crypto')

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

-- Set player job (requires direct adapter access)
-- Use QboxAdapter:SetJob() or Job:SetJob() for advanced operations
```

#### Gang Operations (QBCore Exclusive)

```lua
-- Get player gang
local gang = exports['daphne_core']:GetGang(source)
if gang then
    print("Gang: " .. gang.name)
    print("Grade: " .. gang.grade.level)
end

-- Set player gang (requires direct adapter access)
-- Use Job:SetGang() for gang operations
```

#### Metadata Operations

```lua
-- Get all metadata
local metadata = exports['daphne_core']:GetMetadata(source)
if metadata then
    print("Hunger: " .. (metadata.hunger or 100))
    print("Thirst: " .. (metadata.thirst or 100))
end

-- Get specific metadata key
local hunger = exports['daphne_core']:GetMetadata(source, 'hunger')

-- Set metadata
exports['daphne_core']:SetMetadata(source, 'hunger', 50)
exports['daphne_core']:SetMetadata(source, 'thirst', 75)
```

#### Inventory Operations

```lua
-- Get inventory (works with both qb-inventory and ox_inventory)
local inventory = exports['daphne_core']:GetInventory(source)

-- For qb-inventory: Returns full inventory table
-- For ox_inventory: Returns empty table (use item-specific methods)

-- Get item
local item = exports['daphne_core']:GetItem(source, 'bread')
if item then
    print("Item: " .. item.name .. " - Amount: " .. item.amount)
end

-- Add item
exports['daphne_core']:AddItem(source, 'bread', 1, nil, {quality = 100})

-- Remove item
exports['daphne_core']:RemoveItem(source, 'bread', 1)

-- Check if player has item
local hasBread = exports['daphne_core']:HasItem(source, 'bread', 1)
```

#### Vehicle Operations

```lua
-- Get vehicle data
local vehicleData = exports['daphne_core']:GetVehicle(vehicle)
if vehicleData then
    print("Plate: " .. vehicleData.plate)
    print("Model: " .. vehicleData.model)
    print("Owner: " .. (vehicleData.citizenid or "Unknown"))
end
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

-- Watch gang changes
exports['daphne_core']:WatchPlayerStateBag('gang', function(value, oldValue)
    if value and oldValue and value.name ~= oldValue.name then
        print("Gang changed from " .. oldValue.name .. " to " .. value.name)
    end
end)
```

## Data Structure Mapping

### Player Data

QBCore PlayerData → Bridge PlayerData:

```lua
{
    citizenid = "ABC12345",
    name = "John Doe",
    money = {
        cash = 5000,
        bank = 10000,
        crypto = 0
    },
    job = {
        name = "police",
        label = "Police",
        payment = 500,
        onduty = true,
        isboss = false,
        grade = {
            name = "officer",
            level = 2,
            payment = 500
        }
    },
    gang = {
        name = "ballas",
        label = "Ballas",
        isboss = false,
        grade = {
            name = "member",
            level = 1,
            payment = 0
        }
    },
    metadata = {
        hunger = 100,
        thirst = 100,
        stress = 0,
        -- ... other metadata
    }
}
```

### Job Data

QBCore job → Bridge JobData:

```lua
{
    name = "police",           -- Job name
    label = "Police",          -- Job label
    payment = 500,              -- Base payment
    onduty = true,              -- On duty status
    isboss = false,             -- Is boss
    grade = {
        name = "officer",       -- Grade name
        level = 2,              -- Grade level (number)
        payment = 500           -- Grade payment
    }
}
```

### Gang Data

QBCore gang → Bridge GangData:

```lua
{
    name = "ballas",           -- Gang name
    label = "Ballas",          -- Gang label
    isboss = false,             -- Is boss
    grade = {
        name = "member",        -- Grade name
        level = 1,              -- Grade level (number)
        payment = 0             -- Grade payment
    }
}
```

## QBCore-Specific Features

### Gang System

QBCore has a built-in gang system that ESX doesn't have. The adapter fully supports it:

```lua
-- Get gang
local gang = exports['daphne_core']:GetGang(source)

-- Set gang (via Job module)
-- Note: This requires direct access to Job module
local Job = require('adapters.qbox.job')
Job:SetGang(source, 'ballas', 1)

-- Get players with specific gang
local gangMembers = Job:GetPlayersWithGang('ballas')
```

### Metadata System

QBCore uses a metadata system for storing custom player data:

```lua
-- Common metadata keys:
-- hunger, thirst, stress, armor, phone, etc.

-- Get metadata
local metadata = exports['daphne_core']:GetMetadata(source)
local hunger = exports['daphne_core']:GetMetadata(source, 'hunger')

-- Set metadata
exports['daphne_core']:SetMetadata(source, 'hunger', 50)
exports['daphne_core']:SetMetadata(source, 'stress', 25)
```

### Direct QBCore Access

For advanced QBCore features, you can access the QBCore object directly:

```lua
-- Get QBCore adapter
local QboxAdapter = exports['daphne_core']:GetAdapter()  -- If exposed
-- Or access QBCore directly
local QBCore = exports['qb-core']:GetCoreObject()
```

## Inventory System Details

### qb-inventory

When using `qb-inventory`, the adapter uses QBCore's standard inventory methods:

```lua
-- Get full inventory
local inventory = exports['daphne_core']:GetInventory(source)
-- Returns: { {name = "bread", amount = 5}, {name = "water", amount = 2}, ... }

-- Get item
local item = exports['daphne_core']:GetItem(source, 'bread')
-- Returns: {name = "bread", amount = 5, ...}

-- Add item
exports['daphne_core']:AddItem(source, 'bread', 1, nil, {quality = 100})

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

The QBCore adapter automatically syncs player data to state bags:

- **Money**: `daphne:player:[source]:money` - Updated when money changes
- **Job**: `daphne:player:[source]:job` - Updated when job changes
- **Gang**: `daphne:player:[source]:gang` - Updated when gang changes
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

-- Watch gang changes
exports['daphne_core']:WatchPlayerStateBag('gang', function(value, oldValue)
    if value and oldValue and value.name ~= oldValue.name then
        print("Gang changed from " .. oldValue.name .. " to " .. value.name)
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

### Gang-Based Access Control

```lua
-- Server-side: Check if player has specific gang
local gang = exports['daphne_core']:GetGang(source)
if gang and gang.name == 'ballas' and gang.grade.level >= 2 then
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

### Metadata Management

```lua
-- Server-side: Manage player metadata
RegisterServerEvent('player:updateHunger')
AddEventHandler('player:updateHunger', function(amount)
    local source = source
    
    local currentHunger = exports['daphne_core']:GetMetadata(source, 'hunger') or 100
    local newHunger = math.max(0, math.min(100, currentHunger + amount))
    
    exports['daphne_core']:SetMetadata(source, 'hunger', newHunger)
end)
```

## Troubleshooting

### QBCore Not Detected

**Problem**: `[Daphne Core] Qbox/QBCore not found!`

**Solutions**:
1. Ensure `qb-core` or `qbx_core` is started before `daphne_core` in `server.cfg`
2. Check that QBCore resource exists and is properly configured
3. Verify QBCore is using the standard export method: `exports['qb-core']:GetCoreObject()`

### Inventory Not Working

**Problem**: Inventory operations fail or return empty

**Solutions**:
1. For `qb-inventory`: Ensure `qb-inventory` resource is started
2. For `ox_inventory`: Ensure `ox_inventory` resource is started and properly configured
3. Check server console for error messages
4. Verify inventory system is compatible with QBCore

### Gang Operations Not Working

**Problem**: Gang functions return nil

**Solutions**:
1. Verify QBCore has gang system enabled
2. Check that player has a gang assigned
3. Ensure you're using QBCore (gangs are not available in ESX)

### Money Operations Not Syncing

**Problem**: Money changes but state bag doesn't update

**Solutions**:
1. Check that state bag system is working (check server console)
2. Verify player source ID is correct
3. Check for errors in server console
4. Ensure state bag updates aren't being throttled (normal behavior)

## Performance Notes

- The QBCore adapter follows the 0.00ms policy
- State bag updates are batched (50ms interval)
- Throttling prevents excessive updates (100ms per entity)
- Change detection minimizes unnecessary syncs
- Lazy loading for on-demand data access

## Migration from Direct QBCore Usage

If you're migrating from direct QBCore usage to Daphne Core:

### Before (Direct QBCore)

```lua
local QBCore = exports['qb-core']:GetCoreObject()
local Player = QBCore.Functions.GetPlayer(source)
local money = Player.PlayerData.money.cash
Player.Functions.AddMoney('cash', 1000)
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
- [QBCore Documentation](https://docs.qbcore.org/)
- [Qbox Documentation](https://qbox-docs.gitbook.io/)

## Support

For QBCore-specific issues or questions:
- Check the [Troubleshooting](#troubleshooting) section
- Visit [Daphne Studio's Discord Server](https://discord.gg/daphne)
- Review QBCore/Qbox documentation

---

**Note**: This adapter is designed for QBCore and Qbox frameworks. For ESX, use the ESX adapter instead.

