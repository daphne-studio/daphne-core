# Daphne Core - Framework Bridge

A flexible, high-performance framework bridge system for FiveM that uses the Adapter Design Pattern to support multiple frameworks seamlessly. Built with performance in mind, following the 0.00ms policy and utilizing FiveM's Lua 5.4 state bag mechanism.

![Daphne Core](https://i.imgur.com/7Mnbs5X.png)

## Features

- **Lightweight & Performant**: Minimal overhead with 0.00ms CPU usage in idle state
- **Adapter Pattern Architecture**: Easily extensible to support multiple frameworks
- **Cross-Framework Proxy System**: Run scripts written for one framework on servers using different frameworks
- **State Bag Integration**: Leverages FiveM's Lua 5.4 state bag mechanism for efficient data synchronization
- **Framework Agnostic**: Clean abstraction layer that works with any supported framework
- **Currently Supports**: Qbox/QBCore, ESX Legacy, and ND_Core frameworks
- **Future Ready**: Easy to add support for OX Core and other frameworks

## Overview

```lua
-- 1. Get player data
local playerData = exports['daphne_core']:GetPlayerData(source)
if playerData then
    print("Player Name: " .. playerData.name)
end

-- 2. Get player money
local cash = exports['daphne_core']:GetMoney(source, 'cash')
local bank = exports['daphne_core']:GetMoney(source, 'bank')

-- 3. Add money to player
exports['daphne_core']:AddMoney(source, 'cash', 1000)

-- 4. Get player job
local job = exports['daphne_core']:GetJob(source)
if job then
    print("Job: " .. job.name .. " - Grade: " .. job.grade.level)
end

-- 5. Watch state bag changes (client-side)
exports['daphne_core']:WatchPlayerStateBag('money', function(value, oldValue)
    if value and oldValue then
        print("Cash changed from $" .. oldValue.cash .. " to $" .. value.cash)
    end
end)
```

## Table of Contents

- [Motivation](#motivation)
- [Installation](#installation)
  - [Framework-Specific Notes](#framework-specific-notes)
- [Quick Start](#quick-start)
- [Architecture](#architecture)
- [Usage Examples](#usage-examples)
  - [Server-Side Usage](#server-side-usage)
  - [Client-Side Usage](#client-side-usage)
  - [Cross-Framework Proxy](#cross-framework-proxy)
- [State Bag System](#state-bag-system)
- [Adding Support for New Frameworks](#adding-support-for-new-frameworks)
- [Documentation](#documentation)
- [Examples](#examples)
- [Contributing](#contributing)
- [License](#license)

## Motivation

Building FiveM resources should be straightforward and framework-agnostic. Most scripts today are tightly coupled to a specific framework (QBCore, ESX, ND_Core), making it difficult to switch frameworks or maintain compatibility across different server setups.

daphne-core provides a clean abstraction layer that eliminates framework-specific code from your resources. Write once, run anywhere—whether your server uses QBCore, ESX, ND_Core, or any future framework we add support for.

The bridge system uses the proven Adapter Design Pattern, ensuring:
- **Zero Framework Lock-in**: Switch frameworks without changing your code
- **Performance First**: Minimal overhead with intelligent caching and batching
- **Easy Extension**: Add new framework support by implementing a simple adapter interface
- **Future Proof**: Built on FiveM's native state bag system for long-term compatibility

## Installation

### Prerequisites

- FiveM Server
- Lua 5.4 (included with FiveM)
- One of the supported frameworks:
  - **Qbox** or **QBCore** framework
  - **ESX Legacy** framework
  - **ND_Core** framework

### Installation Steps

1. **Download daphne-core** and place it in your FiveM server's `resources` directory

2. **Add to server.cfg:**
   ```cfg
   # Ensure your framework starts first
   ensure qbx_core  # or qb-core for QBCore
   # OR
   ensure es_extended  # for ESX
   # OR
   ensure ND_Core  # for ND Core
   
   # Then ensure daphne_core
   ensure daphne_core
   ```

3. **Restart your server**

### Framework-Specific Notes

**For Qbox/QBCore:**
- Ensure `qbx_core` or `qb-core` is started before `daphne_core`
- Compatible with QBX inventory systems and ox_inventory
- Supports all standard QBX/QBCore features including gang system
- See [QBCore Documentation](docs/QBCore.md) for detailed information

**For ESX Legacy:**
- Ensure `es_extended` is started before `daphne_core`
- Automatic inventory system detection (`esx_inventory` or `ox_inventory`)
- Supports ESX job system, accounts, and metadata
- See [ESX Documentation](docs/ESX.md) for detailed information

**For ND_Core:**
- Ensure `ND_Core` is started before `daphne_core` (note: resource name uses capital letters)
- Compatible with ND_Core inventory systems and ox_inventory
- Supports ND_Core job system and metadata
- See [ND_Core Documentation](docs/ND_Core.md) for detailed information

## Quick Start

After installation, verify that daphne-core is working:

```lua
-- Server-side test
RegisterCommand('testdaphne', function(source, args)
    local playerData = exports['daphne_core']:GetPlayerData(source)
    if playerData then
        print("✓ daphne-core is working!")
        print("Player: " .. playerData.name)
    else
        print("✗ daphne-core initialization failed")
    end
end, false)
```

Check your server console for initialization messages:
```
[Daphne Core] Framework detected: qbox
[Daphne Core] Bridge initialized with Qbox adapter
```

## Architecture

The bridge system follows the Adapter Design Pattern, allowing seamless integration with different FiveM frameworks:

```
┌─────────────────────────────────────────────────────────┐
│                    Bridge Interface                     │
│              (core/bridge.lua)                         │
└─────────────────────────────────────────────────────────┘
                        ▲
                        │
        ┌───────────────┴───────────────┐
        │                               │
┌───────▼────────┐    ┌───────▼────────┐    ┌────────▼────────┐
│  Qbox Adapter  │    │  ESX Adapter  │    │  ND_Core Adapter│
│                │    │               │    │                 │
└────────────────┘    └───────────────┘    └─────────────────┘
```

### Core Components

- **Core Bridge** (`core/bridge.lua`): Abstract interface that all adapters must implement
- **State Bag Manager** (`core/statebag.lua`): Handles state bag updates with batching and throttling
- **Framework Detection** (`shared/config.lua`): Automatically detects the active framework
- **Adapters** (`adapters/[framework]/`): Framework-specific implementations
- **Proxy System** (`proxies/`): Cross-framework compatibility layer

## Usage Examples

### Server-Side Usage

```lua
-- Get player data
local playerData = exports['daphne_core']:GetPlayerData(source)
if playerData then
    print("Player Name: " .. playerData.name)
    print("CitizenID: " .. playerData.citizenid)
end

-- Get player money
local cash = exports['daphne_core']:GetMoney(source, 'cash')
local bank = exports['daphne_core']:GetMoney(source, 'bank')

-- Add money to player
exports['daphne_core']:AddMoney(source, 'cash', 1000)

-- Remove money from player
exports['daphne_core']:RemoveMoney(source, 'bank', 500)

-- Get player job
local job = exports['daphne_core']:GetJob(source)
if job then
    print("Job: " .. job.name .. " - Grade: " .. job.grade.level)
end

-- Get player inventory
local inventory = exports['daphne_core']:GetInventory(source)

-- Get vehicle data
local vehicleData = exports['daphne_core']:GetVehicle(vehicle)
if vehicleData then
    print("Vehicle Plate: " .. vehicleData.plate)
end
```

### Client-Side Usage

```lua
-- Get local player data
local playerData = exports['daphne_core']:GetPlayerData()
if playerData then
    print("My Name: " .. playerData.name)
end

-- Get local player money
local cash = exports['daphne_core']:GetMoney('cash')

-- Get player state bag value
local moneyData = exports['daphne_core']:GetPlayerStateBag('money')
if moneyData then
    print("Cash: $" .. moneyData.cash)
end

-- Watch player state bag changes
exports['daphne_core']:WatchPlayerStateBag('money', function(value, oldValue)
    if value and oldValue then
        if value.cash ~= oldValue.cash then
            print("Cash changed from $" .. oldValue.cash .. " to $" .. value.cash)
        end
    end
end)
```

### Cross-Framework Proxy

daphne-core includes a powerful proxy system that allows scripts written for one framework to run on servers using different frameworks:

```lua
-- QBCore script running on ESX server
local QBCore = QBCore  -- ✅ Use global variable (proxy works)
local Player = QBCore.Functions.GetPlayer(source)
Player.Functions.AddMoney('cash', 1000)

-- ESX script running on QBCore server
local ESX = ESX  -- ✅ Use global variable (proxy works)
local xPlayer = ESX.GetPlayerFromId(source)
xPlayer.addMoney(1000)

-- ND_Core script running on QBCore server
local player = NDCore:getPlayer(source)  -- ✅ Use global variable (proxy works)
player.addMoney('cash', 1000, 'Example')
```

**Important:** FiveM's `exports` table is read-only, so export override doesn't work. Scripts must use global variables for proxy support. See [Proxy Limitations](docs/PROXY_LIMITATIONS.md) for details.

## State Bag System

The bridge automatically syncs player data to state bags for efficient client-server communication:

- **Player Money**: `daphne:player:[source]:money`
- **Player Job**: `daphne:player:[source]:job`
- **Player Gang**: `daphne:player:[source]:gang` (QBCore only)
- **Player Data**: `daphne:player:[source]:data`
- **Vehicle Data**: `daphne:vehicle:[entity]:data`

### Performance Features

- **Batch Updates**: Multiple state bag updates are batched together (50ms interval)
- **Throttling**: Rate limiting prevents excessive updates (100ms throttle per entity)
- **Change Detection**: Only changed data is synchronized
- **Lazy Loading**: Data is loaded when needed

## Adding Support for New Frameworks

To add support for a new framework:

1. **Create a new adapter directory**: `adapters/[framework_name]/`

2. **Create `adapter.lua` implementing the Bridge interface:**

```lua
-- adapters/[framework_name]/adapter.lua
local Bridge = Bridge -- Available from core/bridge.lua

local FrameworkAdapter = setmetatable({}, Bridge)
FrameworkAdapter.__index = FrameworkAdapter

FrameworkAdapter.name = '[Framework Name]'

function FrameworkAdapter:Initialize()
    -- Initialize framework connection
    return true
end

function FrameworkAdapter:GetPlayer(source)
    -- Implement framework-specific player retrieval
end

-- Implement all required Bridge methods...
-- See docs/ADAPTER_PATTERN.md for complete interface

FrameworkAdapter = FrameworkAdapter
return FrameworkAdapter
```

3. **Add framework detection in `shared/config.lua`:**

```lua
function Config.DetectFramework()
    -- Add detection logic
    if GetResourceState('framework_resource') == 'started' then
        return Config.Frameworks.FRAMEWORK_NAME
    end
end
```

4. **Update `server/bridge.lua` and `client/client.lua`** to use the new adapter

For detailed instructions, see [Adapter Pattern Guide](docs/ADAPTER_PATTERN.md).

## Documentation

Complete documentation is available in the `docs/` directory:

### Getting Started
- **[Quick Start Guide](docs/QUICK_START.md)** - Get started in 5 minutes
- **[Data Structures](docs/DATA_STRUCTURES.md)** - Complete data structure reference

### Core Documentation
- **[Architecture](docs/ARCHITECTURE.md)** - System architecture and design patterns
- **[Adapter Pattern Guide](docs/ADAPTER_PATTERN.md)** - Adapter implementation and extension guide
- **[State Bag System](docs/STATE_BAG_SYSTEM.md)** - State bag usage and optimization guide
- **[Performance Guide](docs/PERFORMANCE.md)** - Performance optimizations and best practices
- **[Error Handling](docs/ERROR_HANDLING.md)** - Error handling patterns and debugging

### Integration & Examples
- **[Integration Guide](docs/INTEGRATION_GUIDE.md)** - Integration patterns and migration guide
- **[Examples Collection](docs/EXAMPLES_COLLECTION.md)** - Code examples and walkthroughs
- **[Examples Directory](examples/README.md)** - Example files directory

### Reference
- **[Documentation Index](docs/INDEX.md)** - Complete documentation navigation
- **[FAQ](docs/FAQ.md)** - Frequently asked questions and troubleshooting
- **[Changelog](docs/CHANGELOG.md)** - Version history and changes

### Framework-Specific Documentation
- **[QBCore/Qbox Guide](docs/QBCore.md)** - Complete QBCore/Qbox adapter documentation
- **[ESX Legacy Guide](docs/ESX.md)** - Complete ESX adapter documentation
- **[ND_Core Guide](docs/ND_Core.md)** - Complete ND_Core adapter documentation

### Proxy System Documentation
- **[Proxy System](docs/PROXY_SYSTEM.md)** - Complete proxy system documentation
- **[Cross-Framework Proxy Guide](docs/CROSS_FRAMEWORK_PROXY.md)** - Cross-framework usage guide
- **[Proxy Limitations](docs/PROXY_LIMITATIONS.md)** - Limitations and workarounds guide
- **[Proxy Mapping Reference](docs/PROXY_MAPPING.md)** - Complete API mapping reference
- **[ND_Core Proxy Guide](docs/PROXY_ND_CORE.md)** - ND_Core-specific proxy documentation

## Examples

Comprehensive usage examples are available in the `examples/` directory:

- **[Basic Server Examples](examples/server_basic.lua)** - Server-side usage patterns
- **[Basic Client Examples](examples/client_basic.lua)** - Client-side usage patterns
- **[Advanced State Bag Examples](examples/statebag_advanced.lua)** - Advanced state bag patterns
- **[Resource Integration](examples/resource_integration.lua)** - Complete integration examples
- **[QBCore Integration](examples/qbcore_integration.lua)** - QBCore-specific examples
- **[ESX Integration](examples/esx_integration.lua)** - ESX-specific examples
- **[Cross-Framework Examples](examples/cross_framework_example.lua)** - Cross-framework proxy examples
- **[QBCore on ESX Example](examples/qbcore_on_esx_example.lua)** - QBCore script running on ESX
- **[ESX on QBCore Example](examples/esx_on_qbcore_example.lua)** - ESX script running on QBCore
- **[ND_Core Examples](examples/nd_core_on_qbcore_example.lua)** - ND_Core cross-framework examples

See [examples/README.md](examples/README.md) and [Examples Collection](docs/EXAMPLES_COLLECTION.md) for more details.

## Contributing

Contributions are welcome! When adding support for new frameworks or features:

1. Follow the existing adapter pattern
2. Maintain performance standards (0.00ms policy)
3. Add proper error handling
4. Update documentation
5. Add examples if introducing new features

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

For support and updates, visit: [Daphne Studio's Discord Server](https://discord.gg/daphne)

## Version

Current Version: 1.0.0

---

**Note**: This bridge system is designed to be framework-agnostic. The adapter pattern allows for easy extension to support additional frameworks in the future.
