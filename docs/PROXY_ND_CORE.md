# ND_Core Proxy Documentation

Complete documentation for ND_Core proxy functionality in daphne-core.

## Table of Contents

- [Overview](#overview)
- [ND_Core API Support](#nd_core-api-support)
- [Usage Examples](#usage-examples)
- [Cross-Framework Usage](#cross-framework-usage)
- [Limitations](#limitations)

## Overview

ND_Core proxy allows ND_Core scripts to run on servers using QBCore, ESX, or other supported frameworks. The proxy intercepts ND_Core API calls and routes them through daphne-core's normalized bridge interface.

## ND_Core API Support

### Core API

| ND_Core API | Status | Notes |
|-------------|--------|-------|
| `exports['ND_Core']:getPlayer(source)` | ✅ Supported | Returns proxy player object |
| `exports['ND_Core']:getPlayers()` | ⏳ Future | Not yet implemented |

### Player Object Methods

| Method | Status | Notes |
|--------|--------|-------|
| `player.addMoney(type, amount, reason)` | ✅ Supported | Reason parameter ignored |
| `player.removeMoney(type, amount, reason)` | ✅ Supported | Reason parameter ignored |
| `player.deductMoney(type, amount, reason)` | ✅ Supported | Alias for removeMoney |
| `player.getJob()` | ✅ Supported | Returns (jobName, jobInfo) tuple |
| `player.addItem(item, amount)` | ✅ Supported | Direct mapping |
| `player.removeItem(item, amount)` | ✅ Supported | Direct mapping |
| `player.hasItem(item, amount)` | ✅ Supported | Direct mapping |
| `player.getMetadata(key)` | ✅ Supported | Direct mapping |
| `player.setMetadata(key, value)` | ✅ Supported | Direct mapping |
| `player.getData(key)` | ✅ Supported | Alias for getMetadata |

### Player Properties

| Property | Status | Notes |
|----------|--------|-------|
| `player.id` | ✅ Supported | Character ID |
| `player.fullname` | ✅ Supported | Full name |
| `player.firstname` | ✅ Supported | Parsed from fullname |
| `player.lastname` | ✅ Supported | Parsed from fullname |
| `player.cash` | ✅ Supported | Cash amount |
| `player.bank` | ✅ Supported | Bank amount |
| `player.metadata` | ✅ Supported | Metadata table |

## Usage Examples

### Basic Usage

```lua
-- Get player
-- Note: ND_Core uses exports, which cannot be overridden in FiveM
-- The export will use original ND_Core if available, otherwise proxy through global
local player = exports['ND_Core']:getPlayer(source)
if player then
    -- Add money
    player.addMoney('cash', 1000, 'Reward')
    
    -- Get money
    local cash = player.cash
    print('Player cash: $' .. cash)
    
    -- Get job
    local jobName, jobInfo = player.getJob()
    print('Job: ' .. jobName .. ' (Rank: ' .. jobInfo.rankName .. ')')
end

-- Alternative: Use global NDCore variable if available
-- if NDCore then
--     local player = NDCore:getPlayer(source)
-- end
```

### Money Operations

```lua
local player = exports['ND_Core']:getPlayer(source)
if player then
    -- Add cash
    player.addMoney('cash', 500, 'Payment')
    
    -- Add bank money
    player.addMoney('bank', 1000, 'Deposit')
    
    -- Remove money
    player.removeMoney('cash', 200, 'Purchase')
    
    -- Check balance
    if player.cash >= 100 then
        player.removeMoney('cash', 100, 'Item Purchase')
    end
end
```

### Item Operations

```lua
local player = exports['ND_Core']:getPlayer(source)
if player then
    -- Add item
    player.addItem('bread', 5)
    
    -- Remove item
    player.removeItem('bread', 2)
    
    -- Check if has item
    if player.hasItem('bread', 1) then
        print('Player has bread')
    end
end
```

### Metadata Operations

```lua
local player = exports['ND_Core']:getPlayer(source)
if player then
    -- Set metadata
    player.setMetadata('hunger', 100)
    player.setMetadata('thirst', 100)
    
    -- Get metadata
    local hunger = player.getMetadata('hunger')
    local thirst = player.getMetadata('thirst')
    
    -- Get all metadata
    local allMetadata = player.metadata
end
```

## Cross-Framework Usage

### ND_Core Script on QBCore Server

```lua
-- This ND_Core script works on a QBCore server
RegisterNetEvent('shop:purchase', function(item, price)
    local source = source
    local player = exports['ND_Core']:getPlayer(source)
    
    if player then
        if player.cash >= price then
            player.removeMoney('cash', price, 'Shop Purchase')
            player.addItem(item, 1)
            TriggerClientEvent('shop:success', source, item)
        end
    end
end)
```

**What happens:**
1. ND_Core API calls are intercepted
2. Calls are mapped to daphne-core API
3. QBCore adapter processes requests
4. Results are converted to ND_Core format

### ND_Core Script on ESX Server

```lua
-- This ND_Core script works on an ESX server
RegisterNetEvent('shop:purchase', function(item, price)
    local source = source
    local player = exports['ND_Core']:getPlayer(source)
    
    if player then
        if player.cash >= price then
            player.removeMoney('cash', price, 'Shop Purchase')
            player.addItem(item, 1)
            TriggerClientEvent('shop:success', source, item)
        end
    end
end)
```

**What happens:**
1. ND_Core API calls are intercepted
2. Calls are mapped to daphne-core API
3. ESX adapter processes requests
4. Results are converted to ND_Core format

## Limitations

### Export Override Limitation

**FiveM's `exports` table is read-only**, which means:
- ❌ `exports['ND_Core']` cannot be overridden
- ✅ Global `NDCore` variable can be overridden (if ND_Core sets it)
- ⚠️ Scripts using `exports['ND_Core']` will use the original ND_Core export if available

**Note:** ND_Core scripts typically use `exports['ND_Core']:getPlayer(source)`, which will work if ND_Core is installed, but won't be proxied to other frameworks. For cross-framework compatibility, scripts should check for the global `NDCore` variable.

### Framework-Specific Features

- **ND_Core-specific methods**: Some ND_Core-specific methods may not work when proxied to other frameworks
- **Job system differences**: Job structure may differ between frameworks
- **Metadata structure**: Metadata structure may vary

### Not Supported

- Export override (FiveM limitation)
- Direct framework object manipulation
- Framework-specific callbacks
- Third-party ND_Core extensions

## Best Practices

### 1. Use Standard ND_Core API

Stick to standard ND_Core API methods for best compatibility:

```lua
-- Good: Standard API
player.addMoney('cash', 1000, 'Reason')
player.getJob()

-- Avoid: Framework-specific extensions
-- player.customMethod()  -- May not work when proxied
```

### 2. Handle Errors

Always check if player exists:

```lua
local player = exports['ND_Core']:getPlayer(source)
if not player then
    print('Player not found')
    return
end
```

### 3. Use Reason Parameter

Always provide reason for money operations (even though it's ignored when proxied):

```lua
player.addMoney('cash', 1000, 'Shop Payment')
player.removeMoney('cash', 500, 'Item Purchase')
```

## Related Documentation

- [Proxy System](PROXY_SYSTEM.md) - General proxy system documentation
- [Cross-Framework Proxy Guide](CROSS_FRAMEWORK_PROXY.md) - Cross-framework usage guide
- [Proxy Mapping Reference](PROXY_MAPPING.md) - Complete API mapping reference
- [Proxy Limitations](PROXY_LIMITATIONS.md) - Limitations and workarounds guide

