# Cross-Framework Proxy Guide

Complete guide to using cross-framework proxy functionality in daphne-core.

## Table of Contents

- [What is Cross-Framework Proxy?](#what-is-cross-framework-proxy)
- [How to Enable](#how-to-enable)
- [Supported Combinations](#supported-combinations)
- [Usage Examples](#usage-examples)
- [Limitations](#limitations)
- [Best Practices](#best-practices)

## What is Cross-Framework Proxy?

Cross-framework proxy allows scripts written for one framework to run seamlessly on a server using a different framework. For example:

- A QBCore script can run on an ESX server
- An ESX script can run on a QBCore server
- An ND_Core script can run on any supported framework

## How to Enable

### Step 1: Enable in Config

Edit `shared/config.lua`:

```lua
Config.Proxy = {
    Enabled = true,
    CrossFrameworkEnabled = true,  -- Enable cross-framework mode
    OverrideGlobals = true,  -- ✅ Works - Override global variables
    OverrideExports = true,  -- ⚠️ Limited - FiveM exports table is read-only
}
```

**Important:** `OverrideExports` has limited functionality because FiveM's `exports` table is read-only. The proxy system primarily works through global variable override (`OverrideGlobals`).

### Step 2: Restart Server

After enabling, restart your server. The proxy system will automatically:
- Detect the active framework
- Enable all framework proxies
- Override global variables and exports

## Supported Combinations

### QBCore Scripts

**Can run on:**
- ✅ QBCore/Qbox adapter (native)
- ✅ ESX adapter (via proxy)
- ✅ ND_Core adapter (via proxy)

**Example:**
```lua
-- Works on any adapter
-- ✅ Use global variable (proxy works)
local QBCore = QBCore
local Player = QBCore.Functions.GetPlayer(source)
Player.Functions.AddMoney('cash', 1000)

-- ❌ Export doesn't work (FiveM exports table is read-only)
-- local QBCore = exports['qb-core']:GetCoreObject()  -- Won't be proxied
```

### ESX Scripts

**Can run on:**
- ✅ ESX adapter (native)
- ✅ QBCore/Qbox adapter (via proxy)
- ✅ ND_Core adapter (via proxy)

**Example:**
```lua
-- Works on any adapter
-- ✅ Use global variable (proxy works)
local ESX = ESX
local xPlayer = ESX.GetPlayerFromId(source)
xPlayer.addMoney(1000)

-- ❌ Export doesn't work (FiveM exports table is read-only)
-- local ESX = exports['es_extended']:getSharedObject()  -- Won't be proxied
```

### ND_Core Scripts

**Can run on:**
- ✅ ND_Core adapter (native)
- ✅ QBCore/Qbox adapter (via proxy)
- ✅ ESX adapter (via proxy)

**Example:**
```lua
-- Works on any adapter
-- Note: ND_Core uses exports, which cannot be overridden
-- The export will use original ND_Core if available
local player = exports['ND_Core']:getPlayer(source)
if player then
    player.addMoney('cash', 1000, 'Reason')
end

-- Alternative: Use global NDCore variable if available
-- if NDCore then
--     local player = NDCore:getPlayer(source)
-- end
```

## Usage Examples

### Example 1: QBCore Script on ESX Server

```lua
-- Server-side script
-- ✅ Use global variable for proxy support
local QBCore = QBCore

RegisterNetEvent('shop:purchase', function(item, price)
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)
    
    if Player then
        local cash = Player.Functions.GetMoney('cash')
        if cash >= price then
            Player.Functions.RemoveMoney('cash', price)
            Player.Functions.AddItem(item, 1)
            TriggerClientEvent('shop:success', source, item)
        else
            TriggerClientEvent('shop:error', source, 'Not enough cash')
        end
    end
end)
```

**What happens:**
1. QBCore API calls are intercepted by QBCore Proxy
2. Calls are mapped to daphne-core API
3. ESX adapter processes the requests
4. Results are converted back to QBCore format
5. Script receives QBCore-formatted data

### Example 2: ESX Script on QBCore Server

```lua
-- Server-side script
-- ✅ Use global variable for proxy support
local ESX = ESX

RegisterNetEvent('shop:purchase', function(item, price)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    
    if xPlayer then
        local cash = xPlayer.getMoney()
        if cash >= price then
            xPlayer.removeMoney(price)
            xPlayer.addItem(item, 1)
            TriggerClientEvent('shop:success', source, item)
        else
            TriggerClientEvent('shop:error', source, 'Not enough cash')
        end
    end
end)
```

**What happens:**
1. ESX API calls are intercepted by ESX Proxy
2. Calls are mapped to daphne-core API
3. QBCore adapter processes the requests
4. Results are converted back to ESX format
5. Script receives ESX-formatted data

### Example 3: ND_Core Script on QBCore Server

```lua
-- Server-side script
RegisterNetEvent('shop:purchase', function(item, price)
    local source = source
    local player = exports['ND_Core']:getPlayer(source)
    
    if player then
        local cash = player.cash
        if cash >= price then
            player.removeMoney('cash', price, 'Shop Purchase')
            player.addItem(item, 1)
            TriggerClientEvent('shop:success', source, item)
        else
            TriggerClientEvent('shop:error', source, 'Not enough cash')
        end
    end
end)
```

## Limitations

### Export Override Limitation

**FiveM's `exports` table is read-only**, which means:
- ❌ Export override (`exports['qb-core']`, `exports['es_extended']`) does not work
- ✅ Global variable override (`QBCore`, `ESX`, `NDCore`) works perfectly
- ⚠️ Scripts using exports directly cannot be proxied

**Workaround:** Modify scripts to use global variables instead of exports:
```lua
-- Change from:
local QBCore = exports['qb-core']:GetCoreObject()

-- To:
local QBCore = QBCore
```

### Framework-Specific Features

Some framework-specific features may not be available when proxied:

- **QBCore Gang System**: Only available when QBCore adapter is active
- **ESX Account System**: Custom accounts may not work on QBCore adapter
- **Framework Events**: Original framework events are not proxied (use daphne-core events)

### Performance Considerations

- Proxy adds minimal overhead (metatable lookups)
- Data conversion happens on-the-fly
- Cache is used to minimize conversions

### Not Supported

- Export override (FiveM limitation)
- Framework-specific callbacks
- Third-party framework extensions
- Direct framework object manipulation (use proxy methods instead)

## Best Practices

### 1. Use daphne-core Exports Directly

For new scripts, use daphne-core exports directly:

```lua
-- Recommended for new scripts
local money = exports['daphne_core']:GetMoney(source, 'cash')
exports['daphne_core']:AddMoney(source, 'cash', 1000)
```

### 2. Use Proxy for Legacy Scripts

For existing scripts, proxy allows them to work with minimal modification:

```lua
-- Legacy QBCore script - modify to use global variable
-- Change from: local QBCore = exports['qb-core']:GetCoreObject()
-- To: local QBCore = QBCore
local QBCore = QBCore  -- ✅ Proxy works
local Player = QBCore.Functions.GetPlayer(source)
```

**Note:** Scripts using `exports['qb-core']:GetCoreObject()` need to be modified to use the global `QBCore` variable for proxy support.

### 3. Test Cross-Framework Compatibility

Always test scripts with different adapters to ensure compatibility:

```lua
-- Test with different adapters
local activeFramework = Config.GetFramework()
print('Testing on: ' .. activeFramework)
```

### 4. Handle Errors Gracefully

Proxy may fail if framework-specific features are used:

```lua
local success, player = pcall(function()
    return QBCore.Functions.GetPlayer(source)
end)

if not success or not player then
    -- Handle error
    return
end
```

## Related Documentation

- [Proxy System](PROXY_SYSTEM.md) - General proxy system documentation
- [Proxy Mapping Reference](PROXY_MAPPING.md) - Complete API mapping reference
- [ND_Core Proxy Guide](PROXY_ND_CORE.md) - ND_Core-specific documentation
- [Proxy Limitations](PROXY_LIMITATIONS.md) - Limitations and workarounds guide

