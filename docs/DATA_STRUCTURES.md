# Data Structures

Complete reference for all data structures used by daphne-core. All structures are normalized across frameworks to provide a consistent API.

## Table of Contents

- [PlayerData](#playerdata)
- [JobData](#jobdata)
- [GangData](#gangdata)
- [VehicleData](#vehicledata)
- [State Bag Data Formats](#state-bag-data-formats)
- [Inventory Item Structure](#inventory-item-structure)
- [Metadata Structure](#metadata-structure)
- [Framework-Specific Mappings](#framework-specific-mappings)

## PlayerData

Complete player information structure returned by `GetPlayerData()`.

### Structure

```lua
{
    source = number,           -- Player server ID
    citizenid = string,        -- Player identifier
    name = string,             -- Player full name
    money = {                  -- Money accounts
        cash = number,
        bank = number,
        -- Additional money types may be present
    },
    job = JobData,             -- Job information (see JobData structure)
    gang = GangData,           -- Gang information (QBCore only, see GangData structure)
    metadata = {}              -- Player metadata (see Metadata Structure)
}
```

### Field Descriptions

| Field | Type | Required | Description |
|-------|------|-----------|-------------|
| `source` | `number` | Yes | Player server ID |
| `citizenid` | `string` | Yes | Player unique identifier (citizenid for QBCore, identifier for ESX) |
| `name` | `string` | Yes | Player's full name (firstname + lastname) |
| `money` | `table` | Yes | Money accounts table |
| `money.cash` | `number` | Yes | Physical cash amount |
| `money.bank` | `number` | Yes | Bank account amount |
| `job` | `JobData` | Yes | Job information object |
| `gang` | `GangData` | No | Gang information (QBCore/Qbox only) |
| `metadata` | `table` | Yes | Player metadata table |

### Example Output

**QBCore/Qbox:**
```json
{
    "source": 1,
    "citizenid": "ABC12345",
    "name": "John Doe",
    "money": {
        "cash": 5000,
        "bank": 25000,
        "crypto": 1000
    },
    "job": {
        "name": "police",
        "label": "Police",
        "grade": {
            "level": 2,
            "name": "officer",
            "label": "Officer",
            "payment": 5000
        },
        "onduty": true
    },
    "gang": {
        "name": "ballas",
        "label": "Ballas",
        "grade": {
            "level": 1,
            "name": "member",
            "label": "Member",
            "payment": 0
        },
        "isboss": false
    },
    "metadata": {
        "hunger": 100,
        "thirst": 100,
        "stress": 0
    }
}
```

**ESX:**
```json
{
    "source": 1,
    "citizenid": "license:abc123def456",
    "name": "Jane Smith",
    "money": {
        "cash": 3000,
        "bank": 15000
    },
    "job": {
        "name": "ambulance",
        "label": "Ambulance",
        "grade": {
            "level": 1,
            "name": "ambulance",
            "label": "Ambulance",
            "payment": 3000
        },
        "onduty": false
    },
    "metadata": {}
}
```

### Framework-Specific Mappings

**QBCore/Qbox:**
- `citizenid`: QBCore citizenid (e.g., "ABC12345")
- `name`: `charinfo.firstname + " " + charinfo.lastname`
- `money`: All money types from `PlayerData.money`
- `gang`: Available if player has a gang

**ESX:**
- `citizenid`: ESX identifier (license)
- `name`: Result of `xPlayer.getName()`
- `money`: Cash and bank accounts only
- `gang`: Not available (returns `nil`)

---

## JobData

Job information structure returned by `GetJob()`.

### Structure

```lua
{
    name = string,            -- Job name (e.g., 'police', 'ambulance')
    label = string,           -- Job display label
    grade = {
        level = number,       -- Grade level (0-based)
        name = string,       -- Grade name
        label = string,      -- Grade display label
        payment = number     -- Grade salary/payment
    },
    onduty = boolean          -- On duty status
}
```

### Field Descriptions

| Field | Type | Required | Description |
|-------|------|-----------|-------------|
| `name` | `string` | Yes | Job internal name |
| `label` | `string` | Yes | Job display name |
| `grade` | `table` | Yes | Grade information |
| `grade.level` | `number` | Yes | Grade level (0 = lowest) |
| `grade.name` | `string` | Yes | Grade internal name |
| `grade.label` | `string` | Yes | Grade display name |
| `grade.payment` | `number` | Yes | Salary/payment amount |
| `onduty` | `boolean` | Yes | Whether player is on duty |

### Example Output

**QBCore/Qbox:**
```json
{
    "name": "police",
    "label": "Police",
    "grade": {
        "level": 2,
        "name": "officer",
        "label": "Officer",
        "payment": 5000
    },
    "onduty": true
}
```

**ESX:**
```json
{
    "name": "ambulance",
    "label": "Ambulance",
    "grade": {
        "level": 1,
        "name": "ambulance",
        "label": "Ambulance",
        "payment": 3000
    },
    "onduty": false
}
```

### Framework-Specific Mappings

**QBCore/Qbox:**
- `onduty`: Available from `PlayerData.job.onduty`
- `grade.payment`: Salary from job grade configuration

**ESX:**
- `onduty`: May not be available depending on ESX version (defaults to `false`)
- `grade.payment`: `grade_salary` from ESX job configuration

---

## GangData

Gang information structure returned by `GetGang()` (QBCore/Qbox only).

### Structure

```lua
{
    name = string,            -- Gang name
    label = string,           -- Gang display label
    grade = {
        level = number,       -- Grade level
        name = string,       -- Grade name
        label = string,      -- Grade display label
        payment = number     -- Grade payment
    },
    isboss = boolean          -- Is gang boss
}
```

### Field Descriptions

| Field | Type | Required | Description |
|-------|------|-----------|-------------|
| `name` | `string` | Yes | Gang internal name |
| `label` | `string` | Yes | Gang display name |
| `grade` | `table` | Yes | Grade information |
| `grade.level` | `number` | Yes | Grade level |
| `grade.name` | `string` | Yes | Grade internal name |
| `grade.label` | `string` | Yes | Grade display name |
| `grade.payment` | `number` | Yes | Payment amount |
| `isboss` | `boolean` | Yes | Whether player is gang boss |

### Example Output

```json
{
    "name": "ballas",
    "label": "Ballas",
    "grade": {
        "level": 1,
        "name": "member",
        "label": "Member",
        "payment": 0
    },
    "isboss": false
}
```

### Framework-Specific Notes

- **QBCore/Qbox**: Fully supported
- **ESX**: Not available (returns `nil`)

---

## VehicleData

Vehicle information structure returned by `GetVehicle()`.

### Structure

```lua
{
    plate = string,          -- Vehicle plate number
    model = string,          -- Vehicle model name
    props = {},              -- Vehicle properties/modifications
    metadata = {},           -- Vehicle metadata
    citizenid = string,      -- Owner citizenid (if available)
    engine = number,         -- Engine health (0-1000, if available)
    body = number,           -- Body health (0-1000, if available)
    fuel = number            -- Fuel level (if available)
}
```

### Field Descriptions

| Field | Type | Required | Description |
|-------|------|-----------|-------------|
| `plate` | `string` | Yes | Vehicle license plate |
| `model` | `string` | Yes | Vehicle model display name |
| `props` | `table` | Yes | Vehicle modifications/properties |
| `metadata` | `table` | Yes | Vehicle metadata |
| `citizenid` | `string` | No | Owner citizenid (QBCore only) |
| `engine` | `number` | No | Engine health (QBCore only) |
| `body` | `number` | No | Body health (QBCore only) |
| `fuel` | `number` | No | Fuel level (QBCore only) |

### Example Output

**QBCore/Qbox:**
```json
{
    "plate": "ABC123",
    "model": "ADDER",
    "props": {
        "modEngine": 3,
        "modBrakes": 2,
        "modTransmission": 2
    },
    "metadata": {
        "mileage": 5000,
        "lastService": 1234567890
    },
    "citizenid": "ABC12345",
    "engine": 1000,
    "body": 1000,
    "fuel": 100
}
```

**ESX:**
```json
{
    "plate": "XYZ789",
    "model": "SENTINEL",
    "props": {},
    "metadata": {}
}
```

### Framework-Specific Mappings

**QBCore/Qbox:**
- `citizenid`: Vehicle owner from database
- `engine`, `body`, `fuel`: Vehicle condition data
- `props`: Vehicle modifications from database

**ESX:**
- Basic vehicle information only
- Owner and condition data not available via standard API

---

## State Bag Data Formats

State bag data structures synced to clients.

### Money State Bag

**Key:** `money`

**Structure:**
```lua
{
    cash = number,
    bank = number,
    -- Additional money types may be present
}
```

**Example:**
```json
{
    "cash": 5000,
    "bank": 25000,
    "crypto": 1000
}
```

### Job State Bag

**Key:** `job`

**Structure:** Same as [JobData](#jobdata)

**Example:**
```json
{
    "name": "police",
    "label": "Police",
    "grade": {
        "level": 2,
        "name": "officer",
        "label": "Officer",
        "payment": 5000
    },
    "onduty": true
}
```

### Gang State Bag

**Key:** `gang`

**Structure:** Same as [GangData](#gangdata)

**Example:**
```json
{
    "name": "ballas",
    "label": "Ballas",
    "grade": {
        "level": 1,
        "name": "member",
        "label": "Member",
        "payment": 0
    },
    "isboss": false
}
```

### Data State Bag

**Key:** `data`

**Structure:** Complete player data snapshot

**Example:**
```json
{
    "citizenid": "ABC12345",
    "name": "John Doe",
    "money": {
        "cash": 5000,
        "bank": 25000
    },
    "job": {
        "name": "police",
        "label": "Police",
        "grade": {
            "level": 2,
            "name": "officer",
            "label": "Officer",
            "payment": 5000
        },
        "onduty": true
    },
    "gang": {
        "name": "ballas",
        "label": "Ballas",
        "grade": {
            "level": 1,
            "name": "member",
            "label": "Member",
            "payment": 0
        },
        "isboss": false
    },
    "metadata": {
        "hunger": 100,
        "thirst": 100
    }
}
```

---

## Inventory Item Structure

Item data structure returned by `GetItem()`.

### Structure

**QBCore/Qbox (qb-inventory):**
```lua
{
    name = string,        -- Item name
    amount = number,      -- Item count
    info = {},           -- Item metadata/info
    label = string,      -- Item display label
    description = string -- Item description
}
```

**ox_inventory:**
```lua
{
    name = string,        -- Item name
    count = number,       -- Item count
    metadata = {},       -- Item metadata
    label = string,      -- Item display label
    weight = number      -- Item weight
}
```

**ESX (esx_inventory):**
```lua
{
    name = string,        -- Item name
    count = number,      -- Item count
    label = string,      -- Item display label
    weight = number      -- Item weight
}
```

### Field Descriptions

| Field | Type | Description |
|-------|------|-------------|
| `name` | `string` | Item internal name |
| `amount` / `count` | `number` | Item quantity |
| `info` / `metadata` | `table` | Item metadata/info |
| `label` | `string` | Item display name |
| `description` | `string` | Item description (QBCore) |
| `weight` | `number` | Item weight (ox_inventory, ESX) |

### Example Output

**QBCore/Qbox (qb-inventory):**
```json
{
    "name": "bread",
    "amount": 5,
    "info": {},
    "label": "Bread",
    "description": "A loaf of bread"
}
```

**ox_inventory:**
```json
{
    "name": "bread",
    "count": 5,
    "metadata": {},
    "label": "Bread",
    "weight": 0.5
}
```

**ESX:**
```json
{
    "name": "bread",
    "count": 5,
    "label": "Bread",
    "weight": 0.5
}
```

---

## Metadata Structure

Player metadata structure.

### Structure

```lua
{
    [key] = value  -- Key-value pairs
}
```

### Common Metadata Keys

**QBCore/Qbox:**
- `hunger`: Hunger level (0-100)
- `thirst`: Thirst level (0-100)
- `stress`: Stress level (0-100)
- `armor`: Armor level
- `phone`: Phone number
- `licenses`: License information

**ESX:**
- Metadata structure varies by ESX version
- May include custom server-specific keys

### Example Output

```json
{
    "hunger": 100,
    "thirst": 100,
    "stress": 0,
    "armor": 0,
    "phone": "555-1234"
}
```

---

## Framework-Specific Mappings

### QBCore/Qbox to Daphne-Core

| QBCore Field | Daphne-Core Field | Notes |
|--------------|-------------------|-------|
| `PlayerData.citizenid` | `citizenid` | Direct mapping |
| `PlayerData.charinfo.firstname + lastname` | `name` | Concatenated |
| `PlayerData.money` | `money` | Direct mapping |
| `PlayerData.job` | `job` | Direct mapping |
| `PlayerData.gang` | `gang` | Direct mapping |
| `PlayerData.metadata` | `metadata` | Direct mapping |

### ESX to Daphne-Core

| ESX Field | Daphne-Core Field | Notes |
|-----------|-------------------|-------|
| `xPlayer.identifier` | `citizenid` | ESX identifier |
| `xPlayer.getName()` | `name` | Method call result |
| `xPlayer.getMoney()` | `money.cash` | Cash account |
| `xPlayer.getAccount('bank').money` | `money.bank` | Bank account |
| `xPlayer.job` | `job` | Mapped structure |
| `xPlayer.getMetadata()` | `metadata` | If available |

---

## Type Definitions (LuaDoc)

```lua
---@class PlayerData
---@field source number
---@field citizenid string
---@field name string
---@field money table<string, number>
---@field job JobData
---@field gang GangData?
---@field metadata table<string, any>

---@class JobData
---@field name string
---@field label string
---@field grade JobGradeData
---@field onduty boolean

---@class JobGradeData
---@field level number
---@field name string
---@field label string
---@field payment number

---@class GangData
---@field name string
---@field label string
---@field grade GangGradeData
---@field isboss boolean

---@class GangGradeData
---@field level number
---@field name string
---@field label string
---@field payment number

---@class VehicleData
---@field plate string
---@field model string
---@field props table<string, any>
---@field metadata table<string, any>
---@field citizenid string?
---@field engine number?
---@field body number?
---@field fuel number?
```

---

## Related Documentation

- [API Reference](API_REFERENCE.md) - Export function documentation
- [State Bag System](STATE_BAG_SYSTEM.md) - State bag usage guide
- [Integration Guide](INTEGRATION_GUIDE.md) - Integration patterns

