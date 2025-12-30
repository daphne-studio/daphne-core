# Proxy System Documentation

Complete documentation for daphne-core's proxy system that enables cross-framework compatibility.

## Table of Contents

- [Overview](#overview)
- [How It Works](#how-it-works)
- [Configuration](#configuration)
- [Supported Frameworks](#supported-frameworks)
- [Usage Examples](#usage-examples)
- [Architecture](#architecture)

## Overview

The proxy system allows scripts written for one framework (e.g., QBCore) to run on a server using a different framework (e.g., ESX or ND_Core). This is achieved through a transparent proxy layer that intercepts framework API calls and routes them through daphne-core's normalized bridge interface.

## How It Works

### Basic Flow

1. **Script calls framework API** (e.g., `QBCore.Functions.GetPlayer(source)`)
2. **Proxy intercepts the call** and maps it to daphne-core API
3. **daphne-core processes the call** using the active adapter
4. **Result is converted** back to the original framework format
5. **Script receives result** in expected format

### Example Flow

```
QBCore Script → QBCore Proxy → API Mapper → daphne-core Bridge → ESX Adapter → ESX Framework
                                                                                    ↓
QBCore Script ← QBCore Proxy ← Data Converter ← daphne-core Bridge ← ESX Adapter ←
```

## Configuration

### Enable/Disable Proxy System

In `shared/config.lua`:

```lua
Config.Proxy = {
    Enabled = true,  -- Enable/disable proxy system
    CrossFrameworkEnabled = true,  -- Enable cross-framework mode
    OverrideGlobals = true,  -- Override global variables (✅ Works)
    OverrideExports = true,  -- Override exports (⚠️ Limited - FiveM exports table is read-only)
    LogProxyCalls = false,  -- Log all proxy calls (debug)
    LogCrossFrameworkCalls = true,  -- Log cross-framework calls
}
```

**Note:** `OverrideExports` is set to `true` but has limited functionality due to FiveM's read-only exports table. Global variable override (`OverrideGlobals`) is the primary method for proxy functionality.

### Cross-Framework Mode

When `CrossFrameworkEnabled` is `true`:
- All framework proxies are active simultaneously
- QBCore scripts can run on ESX/ND_Core adapters
- ESX scripts can run on QBCore/ND_Core adapters
- ND_Core scripts can run on QBCore/ESX adapters

When `CrossFrameworkEnabled` is `false`:
- Only the proxy for the active framework is enabled
- Scripts must use the active framework's API

## Supported Frameworks

### QBCore/Qbox
- ✅ Adapter: Available
- ✅ Proxy: Available
- **API Support**: `QBCore.Functions.GetPlayer`, `Player.Functions.AddMoney`, etc.

### ESX Legacy
- ✅ Adapter: Available
- ✅ Proxy: Available
- **API Support**: `ESX.GetPlayerFromId`, `xPlayer.addMoney`, etc.

### ND_Core
- ✅ Adapter: Available
- ✅ Proxy: Available
- **API Support**: `exports['ND_Core']:getPlayer`, `player.addMoney`, etc.

### OX Core
- ⏳ Adapter: Future
- ⏳ Proxy: Future

## Usage Examples

### QBCore Script on ESX Server

```lua
-- This QBCore script works on an ESX server
-- ✅ Use global variable (proxy works)
local QBCore = QBCore
local Player = QBCore.Functions.GetPlayer(source)
Player.Functions.AddMoney('cash', 1000)

-- ❌ Export override doesn't work (FiveM exports table is read-only)
-- local QBCore = exports['qb-core']:GetCoreObject()  -- Won't be proxied
```

### ESX Script on QBCore Server

```lua
-- This ESX script works on a QBCore server
-- ✅ Use global variable (proxy works)
local ESX = ESX
local xPlayer = ESX.GetPlayerFromId(source)
xPlayer.addMoney(1000)

-- ❌ Export override doesn't work (FiveM exports table is read-only)
-- local ESX = exports['es_extended']:getSharedObject()  -- Won't be proxied
```

### ND_Core Script on QBCore Server

```lua
-- This ND_Core script works on a QBCore server
-- Note: ND_Core uses exports, which cannot be overridden
-- The export will use original ND_Core if available, otherwise proxy through global
local player = exports['ND_Core']:getPlayer(source)
if player then
    player.addMoney('cash', 1000, 'Reason')
end

-- Alternative: Use global NDCore variable if available
-- if NDCore then
--     local player = NDCore:getPlayer(source)
-- end
```

## Important Notes

### Export Override Limitation

**FiveM's `exports` table is read-only**, which means we cannot override exports directly. This is a FiveM platform limitation, not a daphne-core limitation.

**What works:**
- ✅ Global variable override (`QBCore`, `ESX`, `NDCore`)
- ✅ Scripts using global variables are automatically proxied

**What doesn't work:**
- ❌ Export override (`exports['qb-core']`, `exports['es_extended']`)
- ❌ Scripts using exports directly cannot be proxied

**Recommendation:**
For best compatibility, scripts should use global variables instead of exports:
```lua
-- ✅ Recommended (proxy works)
local QBCore = QBCore
local ESX = ESX

-- ❌ Not recommended (proxy doesn't work)
local QBCore = exports['qb-core']:GetCoreObject()
local ESX = exports['es_extended']:getSharedObject()
```

## Architecture

### Components

1. **API Mapper** (`core/api_mapper.lua`)
   - Maps framework API calls to daphne-core API
   - Handles parameter conversion

2. **Data Converter** (`core/data_converter.lua`)
   - Converts normalized data to framework-specific formats
   - Creates proxy objects for player data

3. **Proxy Manager** (`core/proxy_manager.lua`)
   - Manages proxy lifecycle
   - Enables/disables proxies

4. **Framework Proxies** (`proxies/`)
   - QBCore Proxy
   - ESX Proxy
   - ND_Core Proxy

5. **Player Object Proxies** (`proxies/`)
   - QBCore Player Proxy
   - ESX xPlayer Proxy
   - ND_Core Player Proxy

## Related Documentation

- [Cross-Framework Proxy Guide](CROSS_FRAMEWORK_PROXY.md) - Detailed cross-framework usage
- [Proxy Mapping Reference](PROXY_MAPPING.md) - Complete API mapping reference
- [ND_Core Proxy Guide](PROXY_ND_CORE.md) - ND_Core-specific proxy documentation
- [Proxy Limitations](PROXY_LIMITATIONS.md) - Limitations and workarounds guide

