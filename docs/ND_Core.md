# ND Core Adapter Documentation

Complete documentation for using Daphne Core with ND Core framework.

## Overview

The ND Core adapter provides full compatibility with ND Core framework, allowing you to use Daphne Core's unified API regardless of your framework choice. The adapter automatically detects your inventory system and handles ND Core-specific features seamlessly, including the unique groups system, character-based architecture, and license system.

## Features

- ✅ Full ND Core support
- ✅ Automatic inventory system detection (`ox_inventory`)
- ✅ ND Core groups system integration (jobs are groups)
- ✅ Character-based system (multi-character support)
- ✅ License system support
- ✅ Vehicle keys and ownership system
- ✅ Player metadata support
- ✅ State bag synchronization
- ✅ Performance optimized (0.00ms policy)

## Installation

1. Ensure `ND_Core` is installed and configured
2. Ensure `daphne_core` is started after `ND_Core` in your `server.cfg`
3. If using `ox_inventory`, ensure it's started before `daphne_core`
4. Restart your server

### server.cfg Example

```cfg
ensure ND_Core  # Note: resource name uses capital letters
ensure ox_inventory  # optional, if using ox_inventory
ensure daphne_core
```

**Important Notes:**
- The resource name is `ND_Core` (with capital letters)
- The export name is `exports['ND_Core']` (also with capital letters)
- The adapter will detect ND Core even if the resource state shows as "stopped", as long as the export is available

## Inventory System Support

The ND Core adapter automatically detects and supports inventory systems:

### ox_inventory

- Automatically detected when `ox_inventory` resource is running
- Uses `exports.ox_inventory` API
- Supports metadata and advanced item features
- Note: `GetInventory()` returns empty table for ox_inventory (works item-by-item)

### ND Core Inventory

- Uses ND Core's built-in inventory system
- Full item management support
- Compatible with standard ND Core inventory items

## API Usage

### Server-Side

#### Get Player Data

```lua
local playerData = exports['daphne_core']:GetPlayerData(source)
if playerData then
    print("Player: " .. playerData.name)
    print("Character ID: " .. playerData.citizenid)
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
    print("Rank: " .. job.grade.name)
end

-- Note: Job setting requires direct ND Core access
-- Use NDCoreAdapter for advanced job operations
```

#### Metadata Operations

```lua
-- Get all metadata
local metadata = exports['daphne_core']:GetMetadata(source)
if metadata then
    print("Metadata: " .. json.encode(metadata))
end

-- Get specific metadata key
local value = exports['daphne_core']:GetMetadata(source, 'key')

-- Set metadata
exports['daphne_core']:SetMetadata(source, 'key', 'value')
```

#### Inventory Operations

```lua
-- Get inventory (works with both ND Core inventory and ox_inventory)
local inventory = exports['daphne_core']:GetInventory(source)

-- For ND Core inventory: Returns full inventory table
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

ND Core Player → Bridge PlayerData:

```lua
{
    source = source,
    citizenid = tostring(player.id),  -- Character ID
    name = player.fullname,
    money = {
        cash = player.cash,
        bank = player.bank
    },
    job = {
        name = "police",
        label = "Police",
        grade = {
            level = 2,
            name = "officer",
            label = "Officer",
            payment = 0  -- ND Core doesn't have payment info
        },
        onduty = nil  -- ND Core doesn't have duty system
    },
    metadata = player.metadata or {}
}
```

### Job Data

ND Core job → Bridge JobData:

```lua
{
    name = "police",           -- Job name
    label = "Police",          -- Job label
    grade = {
        level = 2,            -- Rank level (number)
        name = "officer",      -- Rank name
        label = "Officer",     -- Rank label
        payment = 0            -- Payment (ND Core doesn't have this)
    },
    onduty = nil               -- On duty status (ND Core doesn't have this)
}
```

## ND Core-Specific Features

### Groups System

ND Core uses a groups system where jobs are actually groups. The adapter handles this seamlessly:

```lua
-- Get player group via ND Core export
local NDCore = exports['ND_Core']
local player = NDCore:getPlayer(source)
local group = player.getGroup('police')
if group then
    print("Group: " .. group.label)
    print("Rank: " .. group.rankName)
    print("Rank Level: " .. group.rank)
end

-- Add group to player
player.addGroup('police', 2)  -- Add police group with rank 2

-- Remove group from player
player.removeGroup('police')
```

### Character-Based System

ND Core is character-based, supporting multi-character functionality:

```lua
-- Get ND Core export
local NDCore = exports['ND_Core']

-- Get character by ID
local character = NDCore.fetchCharacter(characterId, source)

-- Get all characters for a player
local characters = NDCore.fetchAllCharacters(source)

-- Set active character
local player = NDCore.setActiveCharacter(source, characterId)
```

### License System

ND Core has a built-in license system:

```lua
-- Get player via ND Core export
local NDCore = exports['ND_Core']
local player = NDCore:getPlayer(source)

-- Create license
player.createLicense('driver', os.time() + 2592000)  -- Expires in a month

-- Get license
local license = player.getLicense(licenseIdentifier)
if license then
    print("License Type: " .. license.type)
    print("Status: " .. license.status)
    print("Expires: " .. license.expires)
end

-- Update license
player.updateLicense(licenseIdentifier, {
    status = 'suspended'
})
```

### Vehicle Keys System

ND Core has an advanced vehicle keys system:

```lua
-- Get ND Core export
local NDCore = exports['ND_Core']

-- Give vehicle access
NDCore.giveVehicleAccess(source, vehicle, true)

-- Share vehicle keys between players
NDCore.shareVehicleKeys(source, targetSource, vehicle)

-- Transfer vehicle ownership
NDCore.transferVehicleOwnership(vehicleId, fromSource, toSource)
```

### Direct ND Core Access

For advanced ND Core features, you can access ND Core directly:

```lua
-- Get ND Core object via adapter
local ndCore = NDCoreAdapter:GetNDCore()

-- Or access ND Core directly via export
local NDCore = exports['ND_Core']  -- Export name uses capital letters

-- Example usage
local player = NDCore:getPlayer(source)
local allPlayers = NDCore.getPlayers()
```

## Inventory System Details

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

### ND Core Inventory

When using ND Core's built-in inventory:

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

## State Bag Synchronization

The ND Core adapter automatically syncs player data to state bags:

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

### Groups Management

```lua
-- Server-side: Manage player groups
-- Get player via ND Core export
local NDCore = exports['ND_Core']
local player = NDCore:getPlayer(source)

-- Add group
player.addGroup('police', 2)  -- Add police group with rank 2

-- Get group
local group = player.getGroup('police')
if group then
    print("Group: " .. group.label)
    print("Rank: " .. group.rankName)
end

-- Remove group
player.removeGroup('police')
```

## Troubleshooting

### ND Core Not Detected

**Problem**: `[Daphne Core] ND Core not found!`

**Solutions**:
1. Ensure `ND_Core` is started before `daphne_core` in `server.cfg` (resource name uses capital letters)
2. Check that `ND_Core` resource exists and is properly configured
3. Verify ND Core export is available: `exports['ND_Core']` (export name uses capital letters)
4. The adapter detects ND Core via export availability, not just resource state
5. Check server console debug output for resource states and export availability
6. Even if resource shows as "stopped", if `exports['ND_Core']` is available, it should work

### Inventory Not Working

**Problem**: Inventory operations fail or return empty

**Solutions**:
1. For `ox_inventory`: Ensure `ox_inventory` resource is started and properly configured
2. For ND Core inventory: Ensure ND Core inventory system is properly set up
3. Check server console for error messages
4. Verify inventory system is compatible with ND Core

### Money Operations Not Syncing

**Problem**: Money changes but state bag doesn't update

**Solutions**:
1. Check that state bag system is working (check server console)
2. Verify player source ID is correct
3. Check for errors in server console
4. Ensure state bag updates aren't being throttled (normal behavior)

### Character Data Not Loading

**Problem**: Player data returns nil or incorrect

**Solutions**:
1. Verify character is loaded in ND Core
2. Check that player source ID is correct
3. Ensure ND Core character system is properly initialized
4. Check server console for ND Core errors

## Performance Notes

- The ND Core adapter follows the 0.00ms policy
- State bag updates are batched (50ms interval)
- Throttling prevents excessive updates (100ms per entity)
- Change detection minimizes unnecessary syncs
- Lazy loading for on-demand data access
- Player objects are cached for performance

## Migration from Direct ND Core Usage

If you're migrating from direct ND Core usage to Daphne Core:

### Before (Direct ND Core)

```lua
local NDCore = exports['ND_Core']
local player = NDCore:getPlayer(source)
local money = player.cash
player.addMoney('cash', 1000)
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
- [ND Core Documentation](https://github.com/ND-Framework/ND_Core)

## Support

For ND Core-specific issues or questions:
- Check the [Troubleshooting](#troubleshooting) section
- Visit [Daphne Studio's Discord Server](https://discord.gg/qEwgy9B5br)
- Review ND Core documentation

---

**Note**: This adapter is designed for ND Core framework. The adapter handles ND Core's unique features including the groups system, character-based architecture, and license system seamlessly.

