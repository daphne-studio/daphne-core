# Daphne Core - Framework Bridge

A flexible, high-performance framework bridge system for FiveM that uses the Adapter Design Pattern to support multiple frameworks seamlessly. Built with performance in mind, following the 0.00ms policy and utilizing FiveM's Lua 5.4 state bag mechanism.

![Daphne Core](https://i.imgur.com/7Mnbs5X.png)

## Features

- **Adapter Pattern Architecture**: Easily extensible to support multiple frameworks
- **State Bag Integration**: Leverages FiveM's Lua 5.4 state bag mechanism for efficient data synchronization
- **Performance Optimized**: Batch updates, throttling, and change detection for minimal CPU usage
- **Framework Agnostic**: Clean abstraction layer that works with any supported framework
- **Currently Supports**: Qbox/QBCore and ESX Legacy frameworks
- **Future Ready**: Easy to add support for OX Core and other frameworks

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
│  Qbox Adapter  │    │  ESX Adapter  │    │  Future Adapters│
│                │    │               │    │  (OX Core, etc) │
└────────────────┘    └───────────────┘    └─────────────────┘
```

### Core Components

- **Core Bridge** (`core/bridge.lua`): Abstract interface that all adapters must implement
- **State Bag Manager** (`core/statebag.lua`): Handles state bag updates with batching and throttling
- **Framework Detection** (`shared/config.lua`): Automatically detects the active framework
- **Adapters** (`adapters/[framework]/`): Framework-specific implementations

## Installation

1. Place the `daphne_core` folder in your FiveM server's `resources` directory
2. Add `ensure daphne_core` to your `server.cfg`
3. Make sure your framework (Qbox/QBCore or ESX Legacy) is started before `daphne_core`
4. Restart your server

### Framework-Specific Notes

**For Qbox/QBCore:**
- Ensure `qbx_core` or `qb-core` is started before `daphne_core`

**For ESX Legacy:**
- Ensure `es_extended` is started before `daphne_core`
- Supports both `esx_inventory` and `ox_inventory` (auto-detected)
- See [ESX Documentation](docs/ESX.md) for detailed ESX-specific information

## Usage

> **📚 For more detailed examples and integration patterns, see the [Examples Directory](examples/README.md)**

### Server-Side

```lua
-- Get player data
local playerData = exports['daphne_core']:GetPlayerData(source)
if playerData then
    print("Player Name: " .. playerData.name)
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

### Client-Side

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

## API Reference

### Server Exports

#### `GetPlayer(source)`
Returns the player object from the framework.

**Parameters:**
- `source` (number): Player server ID

**Returns:**
- `table|nil`: Player object or nil if not found

#### `GetPlayerData(source)`
Returns player data including citizenid, name, money, job, etc.

**Parameters:**
- `source` (number): Player server ID

**Returns:**
- `table|nil`: Player data or nil if not found

#### `GetMoney(source, type)`
Gets player money for a specific type.

**Parameters:**
- `source` (number): Player server ID
- `type` (string): Money type (e.g., 'cash', 'bank', 'crypto')

**Returns:**
- `number|nil`: Money amount or nil if not found

#### `AddMoney(source, type, amount)`
Adds money to a player.

**Parameters:**
- `source` (number): Player server ID
- `type` (string): Money type
- `amount` (number): Amount to add

**Returns:**
- `boolean`: True if successful

#### `RemoveMoney(source, type, amount)`
Removes money from a player.

**Parameters:**
- `source` (number): Player server ID
- `type` (string): Money type
- `amount` (number): Amount to remove

**Returns:**
- `boolean`: True if successful

#### `GetInventory(source)`
Gets player inventory.

**Parameters:**
- `source` (number): Player server ID

**Returns:**
- `table|nil`: Inventory data or nil if not found

#### `GetJob(source)`
Gets player job information.

**Parameters:**
- `source` (number): Player server ID

**Returns:**
- `table|nil`: Job data or nil if not found

#### `GetVehicle(vehicle)`
Gets vehicle data.

**Parameters:**
- `vehicle` (number): Vehicle entity

**Returns:**
- `table|nil`: Vehicle data or nil if not found

#### `GetGang(source)` (QBCore only)
Gets player gang information.

**Parameters:**
- `source` (number): Player server ID

**Returns:**
- `table|nil`: Gang data or nil if not found

#### `GetMetadata(source, key)`
Gets player metadata.

**Parameters:**
- `source` (number): Player server ID
- `key` (string, optional): Metadata key (returns all metadata if nil)

**Returns:**
- `any|nil`: Metadata value or all metadata if key is nil

#### `SetMetadata(source, key, value)`
Sets player metadata.

**Parameters:**
- `source` (number): Player server ID
- `key` (string): Metadata key
- `value` (any): Metadata value

**Returns:**
- `boolean`: True if successful

#### `GetItem(source, item)`
Gets item from player inventory.

**Parameters:**
- `source` (number): Player server ID
- `item` (string): Item name

**Returns:**
- `table|nil`: Item data or nil if not found

#### `AddItem(source, item, amount, slot, info)`
Adds item to player inventory.

**Parameters:**
- `source` (number): Player server ID
- `item` (string): Item name
- `amount` (number): Amount to add
- `slot` (number, optional): Slot number
- `info` (table, optional): Item info/metadata

**Returns:**
- `boolean`: True if successful

#### `RemoveItem(source, item, amount, slot)`
Removes item from player inventory.

**Parameters:**
- `source` (number): Player server ID
- `item` (string): Item name
- `amount` (number): Amount to remove
- `slot` (number, optional): Slot number

**Returns:**
- `boolean`: True if successful

#### `HasItem(source, item, amount)`
Checks if player has item.

**Parameters:**
- `source` (number): Player server ID
- `item` (string): Item name
- `amount` (number, optional): Amount to check (defaults to 1)

**Returns:**
- `boolean`: True if player has item

### Client Exports

#### `GetPlayer()`
Returns the local player object.

**Returns:**
- `table|nil`: Player object or nil if not found

#### `GetPlayerData()`
Returns local player data.

**Returns:**
- `table|nil`: Player data or nil if not found

#### `GetMoney(type)`
Gets local player money for a specific type.

**Parameters:**
- `type` (string): Money type

**Returns:**
- `number|nil`: Money amount or nil if not found

#### `GetPlayerStateBag(key)`
Gets a player state bag value.

**Parameters:**
- `key` (string): State bag key

**Returns:**
- `any|nil`: State bag value or nil if not found

#### `WatchPlayerStateBag(key, callback)`
Watches for changes to a player state bag.

**Parameters:**
- `key` (string): State bag key
- `callback` (function): Callback function `function(value, oldValue)`

**Returns:**
- `function`: Unwatch function

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

1. Create a new adapter directory: `adapters/[framework_name]/`
2. Create `adapter.lua` implementing the Bridge interface:

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

FrameworkAdapter = FrameworkAdapter
return FrameworkAdapter
```

3. Add framework detection in `shared/config.lua`:

```lua
function Config.DetectFramework()
    -- Add detection logic
    if GetResourceState('framework_resource') == 'started' then
        return Config.Frameworks.FRAMEWORK_NAME
    end
end
```

4. Update `server/bridge.lua` and `client/client.lua` to use the new adapter

## Requirements

- FiveM Server
- Lua 5.4 (included with FiveM)
- One of the supported frameworks:
  - **Qbox** or **QBCore** framework
  - **ESX Legacy** framework

## Supported Frameworks

### Qbox/QBCore
- Full support for Qbox and QBCore frameworks
- Compatible with QBX inventory systems and ox_inventory
- Supports all standard QBX/QBCore features
- Gang system support (QBCore exclusive)
- Player metadata management
- Vehicle ownership system
- See [QBCore Documentation](docs/QBCore.md) for detailed information

### ESX Legacy
- Full support for ESX Legacy framework
- Automatic inventory system detection (`esx_inventory` or `ox_inventory`)
- Supports ESX job system, accounts, and metadata
- See [ESX Documentation](docs/ESX.md) for detailed information

## Performance

The bridge system is designed with performance in mind:

- **0.00ms CPU usage** in idle state
- **Batch processing** for state bag updates
- **Change detection** to minimize unnecessary syncs
- **Lazy loading** for on-demand data access

## Examples

Comprehensive usage examples are available in the `examples/` directory:

- **[Basic Server Examples](examples/server_basic.lua)** - Server-side usage patterns
- **[Basic Client Examples](examples/client_basic.lua)** - Client-side usage patterns
- **[Advanced State Bag Examples](examples/statebag_advanced.lua)** - Advanced state bag patterns
- **[Resource Integration](examples/resource_integration.lua)** - Complete integration examples

See [examples/README.md](examples/README.md) for more details.

## Framework-Specific Documentation

- **[QBCore/Qbox Guide](docs/QBCore.md)** - Complete QBCore/Qbox adapter documentation, features, and examples
- **[ESX Legacy Guide](docs/ESX.md)** - Complete ESX adapter documentation, features, and examples

## Contributing

Contributions are welcome! When adding support for new frameworks:

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

