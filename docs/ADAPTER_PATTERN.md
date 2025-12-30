# Adapter Pattern Guide

Complete guide to daphne-core's adapter pattern implementation. Learn how adapters work and how to add support for new frameworks.

## Table of Contents

- [Overview](#overview)
- [Bridge Interface](#bridge-interface)
- [Existing Adapters](#existing-adapters)
- [Adding New Adapters](#adding-new-adapters)
- [Required Methods](#required-methods)
- [Optional Methods](#optional-methods)
- [Best Practices](#best-practices)

## Overview

daphne-core uses the Adapter Design Pattern to provide a unified API across different FiveM frameworks. Each framework has its own adapter that implements the Bridge interface.

### Pattern Benefits

- **Unified API**: Same code works with any supported framework
- **Easy Extension**: Add new frameworks by creating an adapter
- **Framework Agnostic**: Scripts don't need framework-specific code
- **Maintainable**: Framework-specific logic isolated in adapters

## Bridge Interface

The Bridge interface defines the contract that all adapters must implement.

### Abstract Bridge Class

Located in `core/bridge.lua`:

```lua
---@class Bridge
Bridge = Bridge or {}
Bridge.__index = Bridge

-- All methods throw errors if not implemented
function Bridge:Initialize()
    error("Bridge:Initialize() must be implemented by adapter")
end

function Bridge:GetPlayer(source)
    error("Bridge:GetPlayer() must be implemented by adapter")
end

-- ... other methods
```

### Interface Methods

All adapters must implement these methods (see [Required Methods](#required-methods) for details):

- `Initialize()` - Initialize adapter
- `GetPlayer(source)` - Get player object
- `GetPlayerData(source)` - Get normalized player data
- `GetMoney(source, type)` - Get player money
- `AddMoney(source, type, amount)` - Add money
- `RemoveMoney(source, type, amount)` - Remove money
- `GetInventory(source)` - Get player inventory
- `GetJob(source)` - Get player job
- `GetVehicle(vehicle)` - Get vehicle data

## Existing Adapters

### QboxAdapter

**Location:** `adapters/qbox/adapter.lua`

**Framework Support:** QBCore and Qbox

**Features:**
- Full QBCore/Qbox support
- Gang system support (QBCore exclusive)
- Metadata management
- Vehicle ownership system
- Supports both `qb-inventory` and `ox_inventory`

**Initialization:**
```lua
function QboxAdapter:Initialize(retries, delay)
    -- Tries multiple methods to get QBCore object
    -- 1. qbx_core exports
    -- 2. qb-core exports
    -- 3. GetCoreObject method
    -- 4. Global QBCore variable
end
```

**Key Implementation Details:**
- Uses exports directly (`exports['qbx_core']:GetPlayer()`)
- Caches player objects for performance
- Invalidates cache on write operations
- Updates state bags reactively

### ESXAdapter

**Location:** `adapters/esx/adapter.lua`

**Framework Support:** ESX Legacy

**Features:**
- Full ESX Legacy support
- Account system (cash, bank, custom accounts)
- Metadata support (if available)
- Supports both `esx_inventory` and `ox_inventory`

**Initialization:**
```lua
function ESXAdapter:Initialize()
    -- Gets ESX object via export
    -- exports['es_extended']:getSharedObject()
    -- Or global ESX variable
end
```

**Key Implementation Details:**
- Uses ESX xPlayer object
- Maps ESX data structures to normalized format
- Handles ESX account system
- Updates state bags reactively

### NDCoreAdapter

**Location:** `adapters/nd_core/adapter.lua`

**Framework Support:** ND Core

**Features:**
- Full ND Core support
- Character-based system (multi-character support)
- Groups system (jobs are groups)
- License system support
- Vehicle keys and ownership system
- Metadata support
- Supports `ox_inventory` (auto-detected)

**Initialization:**
```lua
function NDCoreAdapter:Initialize(retries, delay)
    -- Tries multiple methods to get ND Core object
    -- 1. exports['ND_Core'] export (primary method, capital letters)
    -- 2. Global NDCore variable
    -- 3. exports['nd_core'] export (fallback)
    -- Uses retry logic (10 retries, 500ms delay by default)
end
```

**Export Information:**
- Export name: `exports['ND_Core']` (capital letters)
- Resource name: `ND_Core` (may vary, but export is consistent)
- Detection: Adapter detects via export availability, not just resource state

**Key Implementation Details:**
- Uses `NDCore.getPlayer(source)` to get player objects
- Character-based: `player.id` is character ID
- Jobs are managed through groups system (`player.getJob()`)
- Caches player objects for performance
- Invalidates cache on write operations
- Updates state bags reactively
- Handles ND Core events: `ND:moneyChange`, `ND:characterLoaded`, `ND:characterUnloaded`, `ND:updateCharacter`

## Adding New Adapters

### Step 1: Create Adapter Directory

Create a new directory for your adapter:

```
adapters/
  your_framework/
    adapter.lua
    player.lua      (optional)
    money.lua       (optional)
    inventory.lua   (optional)
    job.lua         (optional)
    vehicle.lua     (optional)
```

### Step 2: Create Adapter File

Create `adapters/your_framework/adapter.lua`:

```lua
---Your Framework Adapter
---Implements Bridge interface for Your Framework

-- Load dependencies
if not Bridge then
    error('[YourFramework Adapter] Bridge not found!')
end

if not Config then
    error('[YourFramework Adapter] Config not found!')
end

if not StateBag then
    error('[YourFramework Adapter] StateBag not found!')
end

if not Cache then
    error('[YourFramework Adapter] Cache not found!')
end

---@class YourFrameworkAdapter : Bridge
YourFrameworkAdapter = YourFrameworkAdapter or setmetatable({}, Bridge)
local YourFrameworkAdapter = YourFrameworkAdapter
YourFrameworkAdapter.__index = YourFrameworkAdapter

YourFrameworkAdapter.name = 'YourFramework'
YourFrameworkAdapter.initialized = false
YourFrameworkAdapter.Framework = nil

---Initialize adapter
---@return boolean success
function YourFrameworkAdapter:Initialize()
    if self.initialized then
        return true
    end
    
    -- Get framework object
    local success, framework = pcall(function()
        -- Your framework initialization code
        return YourFramework:GetObject()
    end)
    
    if not success or not framework then
        print('[Daphne Core] YourFramework not found!')
        return false
    end
    
    self.Framework = framework
    self.initialized = true
    
    print('[Daphne Core] YourFramework adapter initialized successfully')
    return true
end

---Get player object
---@param source number Player server ID
---@return table|nil player Player object
function YourFrameworkAdapter:GetPlayer(source)
    -- Check cache first
    local cachedPlayer = Cache.GetPlayer(source)
    if cachedPlayer then
        return cachedPlayer
    end
    
    -- Get from framework
    local framework = self:GetFramework()
    if not framework then return nil end
    
    local success, player = pcall(function()
        return framework:GetPlayer(source)
    end)
    
    if success and player then
        Cache.SetPlayer(source, player)
    end
    
    return player
end

---Get player data
---@param source number Player server ID
---@return PlayerData|nil data Player data
function YourFrameworkAdapter:GetPlayerData(source)
    local player = self:GetPlayer(source)
    if not player then return nil end
    
    -- Map framework data to normalized format
    local playerData = {
        source = source,
        citizenid = player.identifier,  -- Adjust to your framework
        name = player.getName(),         -- Adjust to your framework
        money = {
            cash = player.getMoney(),    -- Adjust to your framework
            bank = player.getBank()      -- Adjust to your framework
        },
        job = {
            -- Map job data
        },
        metadata = {}
    }
    
    return playerData
end

-- Implement other required methods...

-- Export adapter
YourFrameworkAdapter = YourFrameworkAdapter
return YourFrameworkAdapter
```

### Step 3: Add Framework Detection

Update `shared/config.lua`:

```lua
Config.Frameworks = {
    QBOX = 'qbox',
    QBCORE = 'qb-core',
    ESX = 'es_extended',
    YOUR_FRAMEWORK = 'your_framework'  -- Add your framework
}

function Config.DetectFramework()
    -- Add detection logic
    if GetResourceState('your_framework') == 'started' then
        return Config.Frameworks.YOUR_FRAMEWORK
    end
    
    -- ... existing detection code
end
```

### Step 4: Update Bridge Initialization

Update `server/bridge.lua`:

```lua
local function InitializeBridge()
    Config.Initialize()
    
    local framework = Config.GetFramework()
    
    if framework == Config.Frameworks.YOUR_FRAMEWORK then
        if not YourFrameworkAdapter then
            error('[Server Bridge] YourFrameworkAdapter not found!')
        end
        ActiveAdapter = YourFrameworkAdapter
        if ActiveAdapter:Initialize() then
            print('[Daphne Core] Bridge initialized with YourFramework adapter')
            return true
        end
    end
    
    -- ... existing initialization code
end
```

### Step 5: Update fxmanifest.lua

Add your adapter to `fxmanifest.lua`:

```lua
shared_scripts {
    -- ... existing scripts
    'adapters/your_framework/adapter.lua',
    'adapters/your_framework/player.lua',      -- if you have these
    'adapters/your_framework/money.lua',
    -- ... other modules
}
```

## Required Methods

All adapters must implement these methods:

### Initialize

```lua
---Initialize adapter
---@return boolean success
function Adapter:Initialize()
    -- Initialize framework connection
    -- Return true if successful, false otherwise
end
```

### GetPlayer

```lua
---Get player object
---@param source number Player server ID
---@return table|nil player Player object
function Adapter:GetPlayer(source)
    -- Return framework player object
    -- Should use cache for performance
end
```

### GetPlayerData

```lua
---Get normalized player data
---@param source number Player server ID
---@return PlayerData|nil data Player data
function Adapter:GetPlayerData(source)
    -- Return normalized PlayerData structure
    -- See DATA_STRUCTURES.md for format
end
```

### GetMoney

```lua
---Get player money
---@param source number Player server ID
---@param type string Money type
---@return number|nil amount Money amount
function Adapter:GetMoney(source, type)
    -- Return money amount for specified type
end
```

### AddMoney

```lua
---Add money to player
---@param source number Player server ID
---@param type string Money type
---@param amount number Amount to add
---@return boolean success
function Adapter:AddMoney(source, type, amount)
    -- Add money via framework
    -- Invalidate cache
    -- Update state bag
    -- Return true if successful
end
```

### RemoveMoney

```lua
---Remove money from player
---@param source number Player server ID
---@param type string Money type
---@param amount number Amount to remove
---@return boolean success
function Adapter:RemoveMoney(source, type, amount)
    -- Remove money via framework
    -- Check sufficient funds first
    -- Invalidate cache
    -- Update state bag
    -- Return true if successful
end
```

### GetInventory

```lua
---Get player inventory
---@param source number Player server ID
---@return table|nil inventory Inventory data
function Adapter:GetInventory(source)
    -- Return inventory array or empty table
    -- For ox_inventory, return {} (works item-by-item)
end
```

### GetJob

```lua
---Get player job
---@param source number Player server ID
---@return JobData|nil job Job data
function Adapter:GetJob(source)
    -- Return normalized JobData structure
    -- See DATA_STRUCTURES.md for format
end
```

### GetVehicle

```lua
---Get vehicle data
---@param vehicle number Vehicle entity
---@return VehicleData|nil data Vehicle data
function Adapter:GetVehicle(vehicle)
    -- Return normalized VehicleData structure
    -- See DATA_STRUCTURES.md for format
end
```

## Optional Methods

These methods are optional but recommended:

### GetGang

```lua
---Get player gang (if supported)
---@param source number Player server ID
---@return GangData|nil gang Gang data
function Adapter:GetGang(source)
    -- Return normalized GangData structure
    -- Return nil if not supported
end
```

### GetMetadata

```lua
---Get player metadata
---@param source number Player server ID
---@param key string? Metadata key (optional)
---@return any|nil metadata Metadata value
function Adapter:GetMetadata(source, key)
    -- Return metadata value or all metadata
end
```

### SetMetadata

```lua
---Set player metadata
---@param source number Player server ID
---@param key string Metadata key
---@param value any Metadata value
---@return boolean success
function Adapter:SetMetadata(source, key, value)
    -- Set metadata via framework
    -- Invalidate cache
    -- Update state bag
    -- Return true if successful
end
```

## Best Practices

### 1. Use Cache

Always check cache before querying framework:

```lua
function Adapter:GetPlayer(source)
    local cachedPlayer = Cache.GetPlayer(source)
    if cachedPlayer then
        return cachedPlayer
    end
    
    -- Get from framework and cache
    local player = self:GetFrameworkPlayer(source)
    if player then
        Cache.SetPlayer(source, player)
    end
    
    return player
end
```

### 2. Invalidate Cache on Writes

Invalidate cache when modifying player data:

```lua
function Adapter:AddMoney(source, type, amount)
    local success = self:FrameworkAddMoney(source, type, amount)
    if success then
        Cache.InvalidatePlayer(source)  -- Important!
        -- Update state bag
    end
    return success
end
```

### 3. Update State Bags Reactively

Update state bags on write operations:

```lua
function Adapter:AddMoney(source, type, amount)
    local success = self:FrameworkAddMoney(source, type, amount)
    if success then
        Cache.InvalidatePlayer(source)
        local playerData = self:GetPlayerData(source)
        if playerData and playerData.money then
            StateBag.SetStateBag('player', source, 'money', playerData.money, false)
        end
    end
    return success
end
```

### 4. Use pcall for Safety

Wrap framework calls in pcall:

```lua
function Adapter:GetPlayer(source)
    local success, player = pcall(function()
        return self.Framework:GetPlayer(source)
    end)
    
    if not success then
        print('[Adapter] Error getting player: ' .. tostring(player))
        return nil
    end
    
    return player
end
```

### 5. Normalize Data Structures

Always return normalized data structures:

```lua
function Adapter:GetPlayerData(source)
    local player = self:GetPlayer(source)
    if not player then return nil end
    
    -- Map to normalized format
    return {
        source = source,
        citizenid = player.identifier,  -- Normalize field names
        name = player.getName(),
        money = {
            cash = player.getCash(),     -- Normalize structure
            bank = player.getBank()
        },
        -- ... other fields
    }
end
```

### 6. Handle Framework Differences

Handle framework-specific differences gracefully:

```lua
function Adapter:GetMoney(source, type)
    local player = self:GetPlayer(source)
    if not player then return nil end
    
    -- Handle different money types
    if type == 'cash' then
        return player.getCash()
    elseif type == 'bank' then
        return player.getBank()
    else
        -- Try custom account
        local account = player.getAccount(type)
        return account and account.money or nil
    end
end
```

## Testing Checklist

When creating a new adapter, test:

- [ ] Framework detection works
- [ ] Adapter initializes successfully
- [ ] GetPlayer returns correct player object
- [ ] GetPlayerData returns normalized structure
- [ ] GetMoney returns correct amounts
- [ ] AddMoney adds money correctly
- [ ] RemoveMoney removes money correctly
- [ ] GetInventory returns inventory (or empty table for ox_inventory)
- [ ] GetJob returns normalized job data
- [ ] GetVehicle returns vehicle data
- [ ] Cache works correctly
- [ ] State bags update on writes
- [ ] Error handling works (nil checks, pcall)

## Related Documentation

- [Architecture](ARCHITECTURE.md) - System architecture
- [Data Structures](DATA_STRUCTURES.md) - Data structure formats
- [API Reference](API_REFERENCE.md) - Export function documentation
- [Integration Guide](INTEGRATION_GUIDE.md) - Integration patterns

