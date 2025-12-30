# API Reference

Complete API reference for daphne-core exports. All exports are available via `exports['daphne_core']` on both server and client sides.

## Table of Contents

- [Server Exports](#server-exports)
- [Client Exports](#client-exports)
- [Export Signatures](#export-signatures)

## Server Exports

### GetPlayer

Returns the player object from the framework.

**Signature:**
```lua
exports['daphne_core']:GetPlayer(source)
```

**Parameters:**
- `source` (number): Player server ID

**Returns:**
- `table|nil`: Player object from the framework, or `nil` if not found

**Example:**
```lua
local player = exports['daphne_core']:GetPlayer(source)
if player then
    print("Player found: " .. tostring(player))
end
```

**Framework Differences:**
- **QBCore/Qbox**: Returns QBCore player object with `PlayerData` property
- **ESX**: Returns ESX xPlayer object

**Notes:**
- Player objects are cached for 5 seconds (configurable via Cache module)
- Cache is automatically invalidated on player disconnect
- For QBCore/Qbox, `source` can also be a string identifier (citizenid, phone number)

---

### GetPlayerData

Returns normalized player data including citizenid, name, money, job, etc.

**Signature:**
```lua
exports['daphne_core']:GetPlayerData(source)
```

**Parameters:**
- `source` (number): Player server ID

**Returns:**
- `table|nil`: PlayerData object with normalized structure, or `nil` if not found

**PlayerData Structure:**
```lua
{
    source = number,           -- Player server ID
    citizenid = string,        -- Player identifier (citizenid for QBCore, identifier for ESX)
    name = string,             -- Player full name
    money = {                  -- Money accounts
        cash = number,
        bank = number,
        -- Additional money types may be present
    },
    job = {                    -- Job information
        name = string,
        label = string,
        grade = {
            level = number,
            name = string,
            label = string,
            payment = number
        },
        onduty = boolean
    },
    gang = {                   -- Gang information (QBCore only)
        name = string,
        label = string,
        grade = {
            level = number,
            name = string,
            label = string,
            payment = number
        },
        isboss = boolean
    },
    metadata = {}              -- Player metadata
}
```

**Example:**
```lua
local playerData = exports['daphne_core']:GetPlayerData(source)
if playerData then
    print("Player: " .. playerData.name)
    print("CitizenID: " .. playerData.citizenid)
    print("Cash: $" .. playerData.money.cash)
    print("Bank: $" .. playerData.money.bank)
    print("Job: " .. playerData.job.name .. " - " .. playerData.job.label)
end
```

**Framework Differences:**
- **QBCore/Qbox**: Includes `gang` field if player has a gang
- **ESX**: `citizenid` field contains ESX identifier (license)

---

### GetMoney

Gets player money for a specific type.

**Signature:**
```lua
exports['daphne_core']:GetMoney(source, type)
```

**Parameters:**
- `source` (number): Player server ID
- `type` (string): Money type (e.g., 'cash', 'bank', 'crypto')

**Returns:**
- `number|nil`: Money amount, or `nil` if not found

**Example:**
```lua
local cash = exports['daphne_core']:GetMoney(source, 'cash')
local bank = exports['daphne_core']:GetMoney(source, 'bank')
local crypto = exports['daphne_core']:GetMoney(source, 'crypto') -- QBCore only

if cash then
    print("Player has $" .. cash .. " cash")
end
```

**Framework Differences:**
- **QBCore/Qbox**: Supports custom money types (crypto, etc.)
- **ESX**: Supports cash, bank, and custom accounts

**Common Money Types:**
- `cash`: Physical cash
- `bank`: Bank account
- `crypto`: Cryptocurrency (QBCore only)

---

### AddMoney

Adds money to a player.

**Signature:**
```lua
exports['daphne_core']:AddMoney(source, type, amount)
```

**Parameters:**
- `source` (number): Player server ID
- `type` (string): Money type
- `amount` (number): Amount to add

**Returns:**
- `boolean`: `true` if successful, `false` otherwise

**Example:**
```lua
local success = exports['daphne_core']:AddMoney(source, 'cash', 1000)
if success then
    print("Added $1000 cash to player")
else
    print("Failed to add money")
end
```

**Notes:**
- Automatically invalidates player cache
- Updates state bag with new money values
- State bag update is batched (50ms interval) and throttled (100ms per entity)

---

### RemoveMoney

Removes money from a player.

**Signature:**
```lua
exports['daphne_core']:RemoveMoney(source, type, amount)
```

**Parameters:**
- `source` (number): Player server ID
- `type` (string): Money type
- `amount` (number): Amount to remove

**Returns:**
- `boolean`: `true` if successful, `false` otherwise

**Example:**
```lua
local success = exports['daphne_core']:RemoveMoney(source, 'bank', 500)
if success then
    print("Removed $500 from player's bank")
else
    print("Failed to remove money (insufficient funds or error)")
end
```

**Notes:**
- For ESX, checks if player has sufficient funds before removing
- Automatically invalidates player cache
- Updates state bag with new money values

---

### GetInventory

Gets player inventory.

**Signature:**
```lua
exports['daphne_core']:GetInventory(source)
```

**Parameters:**
- `source` (number): Player server ID

**Returns:**
- `table|nil`: Inventory data, or `nil` if not found

**Example:**
```lua
local inventory = exports['daphne_core']:GetInventory(source)
if inventory then
    for _, item in pairs(inventory) do
        print("Item: " .. item.name .. " x" .. item.amount)
    end
end
```

**Framework Differences:**
- **ox_inventory**: Returns empty table `{}` (ox_inventory works item-by-item via GetItem)
- **qb-inventory**: Returns full inventory array
- **esx_inventory**: Returns ESX inventory array

**Notes:**
- For ox_inventory, use `GetItem` instead to check individual items
- Inventory structure varies by framework and inventory system

---

### GetItem

Gets a specific item from player inventory.

**Signature:**
```lua
exports['daphne_core']:GetItem(source, item)
```

**Parameters:**
- `source` (number): Player server ID
- `item` (string): Item name

**Returns:**
- `table|nil`: Item data, or `nil` if not found

**Item Data Structure:**
```lua
{
    name = string,        -- Item name
    amount = number,      -- Item count/amount
    count = number,       -- Alternative field name (ESX)
    -- Additional fields may be present depending on inventory system
}
```

**Example:**
```lua
local item = exports['daphne_core']:GetItem(source, 'bread')
if item then
    print("Player has " .. (item.amount or item.count) .. " bread")
end
```

**Framework Differences:**
- **ox_inventory**: Uses ox_inventory export API
- **qb-inventory**: Uses QBCore player Functions
- **esx_inventory**: Uses ESX xPlayer inventory methods

---

### AddItem

Adds an item to player inventory.

**Signature:**
```lua
exports['daphne_core']:AddItem(source, item, amount, slot, info)
```

**Parameters:**
- `source` (number): Player server ID
- `item` (string): Item name
- `amount` (number): Amount to add
- `slot` (number, optional): Slot number (for qb-inventory)
- `info` (table, optional): Item info/metadata

**Returns:**
- `boolean`: `true` if successful, `false` otherwise

**Example:**
```lua
-- Add item without metadata
local success = exports['daphne_core']:AddItem(source, 'bread', 5)

-- Add item with metadata (ox_inventory)
local success = exports['daphne_core']:AddItem(source, 'weapon_pistol', 1, nil, {
    serial = 'ABC123',
    registered = true
})
```

**Framework Differences:**
- **ox_inventory**: `info` parameter is used for item metadata
- **qb-inventory**: `slot` parameter can specify inventory slot
- **esx_inventory**: Metadata handling varies by ESX version

---

### RemoveItem

Removes an item from player inventory.

**Signature:**
```lua
exports['daphne_core']:RemoveItem(source, item, amount, slot)
```

**Parameters:**
- `source` (number): Player server ID
- `item` (string): Item name
- `amount` (number): Amount to remove
- `slot` (number, optional): Slot number (for qb-inventory)

**Returns:**
- `boolean`: `true` if successful, `false` otherwise

**Example:**
```lua
local success = exports['daphne_core']:RemoveItem(source, 'bread', 2)
if success then
    print("Removed 2 bread from player")
end
```

**Notes:**
- Checks if player has sufficient quantity before removing
- Returns `false` if player doesn't have enough items

---

### HasItem

Checks if player has an item.

**Signature:**
```lua
exports['daphne_core']:HasItem(source, item, amount)
```

**Parameters:**
- `source` (number): Player server ID
- `item` (string): Item name
- `amount` (number, optional): Amount to check (defaults to 1)

**Returns:**
- `boolean`: `true` if player has the item (and sufficient amount), `false` otherwise

**Example:**
```lua
-- Check if player has any bread
if exports['daphne_core']:HasItem(source, 'bread') then
    print("Player has bread")
end

-- Check if player has at least 5 bread
if exports['daphne_core']:HasItem(source, 'bread', 5) then
    print("Player has at least 5 bread")
end
```

---

### GetJob

Gets player job information.

**Signature:**
```lua
exports['daphne_core']:GetJob(source)
```

**Parameters:**
- `source` (number): Player server ID

**Returns:**
- `table|nil`: JobData object, or `nil` if not found

**JobData Structure:**
```lua
{
    name = string,            -- Job name (e.g., 'police', 'ambulance')
    label = string,           -- Job display label
    grade = {
        level = number,       -- Grade level (0-based)
        name = string,        -- Grade name
        label = string,       -- Grade display label
        payment = number     -- Grade salary/payment
    },
    onduty = boolean          -- On duty status
}
```

**Example:**
```lua
local job = exports['daphne_core']:GetJob(source)
if job then
    print("Job: " .. job.name)
    print("Grade: " .. job.grade.level)
    print("Salary: $" .. job.grade.payment)
    print("On Duty: " .. tostring(job.onduty))
end
```

**Framework Differences:**
- **QBCore/Qbox**: `onduty` field is available
- **ESX**: `onduty` may not be available depending on ESX version

---

### GetGang

Gets player gang information (QBCore only).

**Signature:**
```lua
exports['daphne_core']:GetGang(source)
```

**Parameters:**
- `source` (number): Player server ID

**Returns:**
- `table|nil`: GangData object, or `nil` if not found or not supported

**GangData Structure:**
```lua
{
    name = string,            -- Gang name
    label = string,           -- Gang display label
    grade = {
        level = number,       -- Grade level
        name = string,        -- Grade name
        label = string,       -- Grade display label
        payment = number     -- Grade payment
    },
    isboss = boolean          -- Is gang boss
}
```

**Example:**
```lua
local gang = exports['daphne_core']:GetGang(source)
if gang then
    print("Gang: " .. gang.name)
    print("Is Boss: " .. tostring(gang.isboss))
end
```

**Notes:**
- **QBCore/Qbox only**: ESX does not have gang system
- Returns `nil` for ESX framework

---

### GetVehicle

Gets vehicle data.

**Signature:**
```lua
exports['daphne_core']:GetVehicle(vehicle)
```

**Parameters:**
- `vehicle` (number): Vehicle entity handle

**Returns:**
- `table|nil`: VehicleData object, or `nil` if vehicle doesn't exist

**VehicleData Structure:**
```lua
{
    plate = string,          -- Vehicle plate number
    model = string,          -- Vehicle model name
    props = {},             -- Vehicle properties/modifications
    metadata = {},          -- Vehicle metadata
    citizenid = string,     -- Owner citizenid (if available)
    engine = number,        -- Engine health (if available)
    body = number,          -- Body health (if available)
    fuel = number           -- Fuel level (if available)
}
```

**Example:**
```lua
local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
if vehicle ~= 0 then
    local vehicleData = exports['daphne_core']:GetVehicle(vehicle)
    if vehicleData then
        print("Plate: " .. vehicleData.plate)
        print("Model: " .. vehicleData.model)
        if vehicleData.citizenid then
            print("Owner: " .. vehicleData.citizenid)
        end
    end
end
```

**Framework Differences:**
- **QBCore/Qbox**: May include owner information and vehicle database data
- **ESX**: Basic vehicle information only

---

### GetMetadata

Gets player metadata.

**Signature:**
```lua
exports['daphne_core']:GetMetadata(source, key)
```

**Parameters:**
- `source` (number): Player server ID
- `key` (string, optional): Metadata key (returns all metadata if `nil`)

**Returns:**
- `any|nil`: Metadata value, all metadata table, or `nil` if not found

**Example:**
```lua
-- Get specific metadata
local hunger = exports['daphne_core']:GetMetadata(source, 'hunger')
if hunger then
    print("Hunger: " .. hunger)
end

-- Get all metadata
local metadata = exports['daphne_core']:GetMetadata(source)
if metadata then
    for key, value in pairs(metadata) do
        print(key .. ": " .. tostring(value))
    end
end
```

**Framework Differences:**
- **QBCore/Qbox**: Uses QBCore metadata system
- **ESX**: Uses ESX metadata system (if available)

---

### SetMetadata

Sets player metadata.

**Signature:**
```lua
exports['daphne_core']:SetMetadata(source, key, value)
```

**Parameters:**
- `source` (number): Player server ID
- `key` (string): Metadata key
- `value` (any): Metadata value

**Returns:**
- `boolean`: `true` if successful, `false` otherwise

**Example:**
```lua
-- Set hunger metadata
local success = exports['daphne_core']:SetMetadata(source, 'hunger', 100)
if success then
    print("Set hunger to 100")
end

-- Set thirst metadata
exports['daphne_core']:SetMetadata(source, 'thirst', 75)
```

**Notes:**
- Automatically invalidates player cache
- Updates state bag with new metadata
- State bag update is batched and throttled

---

## Client Exports

### GetPlayer

Returns the local player object.

**Signature:**
```lua
exports['daphne_core']:GetPlayer()
```

**Returns:**
- `table|nil`: Local player object, or `nil` if not found

**Example:**
```lua
local player = exports['daphne_core']:GetPlayer()
if player then
    print("Local player object retrieved")
end
```

**Notes:**
- Automatically uses local player's server ID
- Returns framework-specific player object

---

### GetPlayerData

Returns local player data.

**Signature:**
```lua
exports['daphne_core']:GetPlayerData()
```

**Returns:**
- `table|nil`: PlayerData object for local player, or `nil` if not found

**Example:**
```lua
local playerData = exports['daphne_core']:GetPlayerData()
if playerData then
    print("My name: " .. playerData.name)
    print("My cash: $" .. playerData.money.cash)
end
```

**Notes:**
- Returns same structure as server-side `GetPlayerData`
- Data is read from framework, not state bag

---

### GetMoney

Gets local player money for a specific type.

**Signature:**
```lua
exports['daphne_core']:GetMoney(type)
```

**Parameters:**
- `type` (string): Money type

**Returns:**
- `number|nil`: Money amount, or `nil` if not found

**Example:**
```lua
local cash = exports['daphne_core']:GetMoney('cash')
local bank = exports['daphne_core']:GetMoney('bank')

if cash then
    print("I have $" .. cash .. " cash")
end
```

**Notes:**
- Reads directly from framework
- For reactive updates, use `WatchPlayerStateBag` with 'money' key

---

### GetPlayerStateBag

Gets a player state bag value (client-side).

**Signature:**
```lua
exports['daphne_core']:GetPlayerStateBag(key)
```

**Parameters:**
- `key` (string): State bag key

**Returns:**
- `any|nil`: State bag value, or `nil` if not found

**Example:**
```lua
local moneyData = exports['daphne_core']:GetPlayerStateBag('money')
if moneyData then
    print("Cash: $" .. (moneyData.cash or 0))
    print("Bank: $" .. (moneyData.bank or 0))
end
```

**Available State Bag Keys:**
- `money`: Player money data
- `job`: Player job data
- `gang`: Player gang data (QBCore only)
- `data`: Complete player data snapshot

**Notes:**
- State bags are automatically synced from server
- Values may be `nil` if not yet synced
- Use `WatchPlayerStateBag` for reactive updates

---

### WatchPlayerStateBag

Watches for changes to a player state bag.

**Signature:**
```lua
exports['daphne_core']:WatchPlayerStateBag(key, callback)
```

**Parameters:**
- `key` (string): State bag key to watch
- `callback` (function): Callback function `function(value, oldValue)`

**Returns:**
- `function`: Unwatch function (call to stop watching)

**Example:**
```lua
-- Watch money changes
local unwatch = exports['daphne_core']:WatchPlayerStateBag('money', function(value, oldValue)
    if value and oldValue then
        if value.cash ~= oldValue.cash then
            local difference = value.cash - oldValue.cash
            print("Cash changed by: $" .. difference)
        end
    end
end)

-- Stop watching after 60 seconds
SetTimeout(60000, function()
    unwatch()
end)
```

**Callback Parameters:**
- `value` (any): New state bag value
- `oldValue` (any): Previous state bag value (may be `nil` on first call)

**Example - Job Change Detection:**
```lua
exports['daphne_core']:WatchPlayerStateBag('job', function(value, oldValue)
    if value and oldValue and value.name ~= oldValue.name then
        print("Job changed from " .. oldValue.name .. " to " .. value.name)
        -- Update UI, permissions, etc.
    end
end)
```

**Notes:**
- Watchers persist until resource restart or unwatch is called
- Multiple watchers can watch the same key
- Callback is called immediately with current value if available
- State bag updates are batched and throttled on server side

---

## Export Signatures Summary

### Server Exports

| Export | Parameters | Returns |
|--------|-----------|---------|
| `GetPlayer` | `source: number` | `table\|nil` |
| `GetPlayerData` | `source: number` | `table\|nil` |
| `GetMoney` | `source: number, type: string` | `number\|nil` |
| `AddMoney` | `source: number, type: string, amount: number` | `boolean` |
| `RemoveMoney` | `source: number, type: string, amount: number` | `boolean` |
| `GetInventory` | `source: number` | `table\|nil` |
| `GetItem` | `source: number, item: string` | `table\|nil` |
| `AddItem` | `source: number, item: string, amount: number, slot?: number, info?: table` | `boolean` |
| `RemoveItem` | `source: number, item: string, amount: number, slot?: number` | `boolean` |
| `HasItem` | `source: number, item: string, amount?: number` | `boolean` |
| `GetJob` | `source: number` | `table\|nil` |
| `GetGang` | `source: number` | `table\|nil` |
| `GetVehicle` | `vehicle: number` | `table\|nil` |
| `GetMetadata` | `source: number, key?: string` | `any\|nil` |
| `SetMetadata` | `source: number, key: string, value: any` | `boolean` |

### Client Exports

| Export | Parameters | Returns |
|--------|-----------|---------|
| `GetPlayer` | - | `table\|nil` |
| `GetPlayerData` | - | `table\|nil` |
| `GetMoney` | `type: string` | `number\|nil` |
| `GetPlayerStateBag` | `key: string` | `any\|nil` |
| `WatchPlayerStateBag` | `key: string, callback: function` | `function` |

---

## Error Handling

All exports use safe error handling internally. If a framework call fails:

- Exports return `nil` or `false` instead of throwing errors
- Errors are logged to console with `[Daphne Core]` prefix
- Framework initialization failures are logged with detailed messages

**Best Practice:**
Always check return values:

```lua
local playerData = exports['daphne_core']:GetPlayerData(source)
if not playerData then
    -- Handle error: player not found or framework error
    return
end

-- Use playerData safely
```

---

## Performance Notes

- Player objects are cached for 5 seconds (configurable)
- State bag updates are batched (50ms interval) and throttled (100ms per entity)
- Read operations do not trigger state bag updates (performance optimization)
- Write operations (AddMoney, RemoveMoney, SetMetadata) automatically update state bags

---

## Related Documentation

- [Data Structures](DATA_STRUCTURES.md) - Detailed data structure definitions
- [State Bag System](STATE_BAG_SYSTEM.md) - State bag usage guide
- [Integration Guide](INTEGRATION_GUIDE.md) - Integration patterns and examples

