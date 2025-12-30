# Proxy Mapping Reference

Complete reference for API mappings between frameworks and daphne-core.

## Table of Contents

- [QBCore Mappings](#qbcore-mappings)
- [ESX Mappings](#esx-mappings)
- [ND_Core Mappings](#nd_core-mappings)
- [Mapping Details](#mapping-details)

## QBCore Mappings

### Core Functions

| QBCore API | Daphne-Core API | Parameters | Notes |
|------------|-----------------|------------|-------|
| `QBCore.Functions.GetPlayer(source)` | `GetPlayer(source)` | `source` (number\|string) | Direct mapping |
| `QBCore.Functions.GetPlayers()` | Custom | - | Returns all players |
| `QBCore.Functions.GetPlayerByCitizenId(citizenid)` | `GetPlayer(citizenid)` | `citizenid` (string) | Uses GetPlayer with identifier |
| `QBCore.Functions.GetPlayerByPhone(phone)` | Custom | `phone` (string) | Custom implementation needed |

### Player Functions

| QBCore API | Daphne-Core API | Parameters | Notes |
|------------|-----------------|------------|-------|
| `Player.Functions.AddMoney(type, amount)` | `AddMoney(source, type, amount)` | `type`, `amount` | Parameter reorder |
| `Player.Functions.RemoveMoney(type, amount)` | `RemoveMoney(source, type, amount)` | `type`, `amount` | Parameter reorder |
| `Player.Functions.GetMoney(type)` | `GetMoney(source, type)` | `type` | Parameter reorder |
| `Player.Functions.AddItem(item, amount, slot, info)` | `AddItem(source, item, amount, slot, info)` | All parameters | Direct mapping |
| `Player.Functions.RemoveItem(item, amount, slot)` | `RemoveItem(source, item, amount, slot)` | All parameters | Direct mapping |
| `Player.Functions.HasItem(item, amount)` | `HasItem(source, item, amount)` | `item`, `amount` | Parameter reorder |
| `Player.Functions.GetItem(item)` | `GetItem(source, item)` | `item` | Parameter reorder |
| `Player.Functions.SetJob(job, grade)` | Custom | `job`, `grade` | Framework-specific |
| `Player.Functions.SetGang(gang, grade)` | Custom | `gang`, `grade` | QBCore-specific |
| `Player.Functions.GetMetadata(key)` | `GetMetadata(source, key)` | `key` | Parameter reorder |
| `Player.Functions.SetMetadata(key, value)` | `SetMetadata(source, key, value)` | `key`, `value` | Parameter reorder |

### Player Data

| QBCore Property | Daphne-Core Property | Notes |
|----------------|----------------------|-------|
| `Player.PlayerData.citizenid` | `citizenid` | Direct mapping |
| `Player.PlayerData.name` | `name` | Direct mapping |
| `Player.PlayerData.money` | `money` | Direct mapping |
| `Player.PlayerData.job` | `job` | Direct mapping |
| `Player.PlayerData.gang` | `gang` | QBCore-specific |
| `Player.PlayerData.metadata` | `metadata` | Direct mapping |

## ESX Mappings

### Core Functions

| ESX API | Daphne-Core API | Parameters | Notes |
|---------|-----------------|------------|-------|
| `ESX.GetPlayerFromId(source)` | `GetPlayer(source)` | `source` (number) | Direct mapping |
| `ESX.GetPlayers()` | Custom | - | Returns all players |
| `ESX.GetPlayerFromIdentifier(identifier)` | Custom | `identifier` (string) | Custom implementation needed |

### xPlayer Methods

| ESX API | Daphne-Core API | Parameters | Notes |
|---------|-----------------|------------|-------|
| `xPlayer.addMoney(amount)` | `AddMoney(source, 'cash', amount)` | `amount` | Type mapping to 'cash' |
| `xPlayer.removeMoney(amount)` | `RemoveMoney(source, 'cash', amount)` | `amount` | Type mapping to 'cash' |
| `xPlayer.getMoney()` | `GetMoney(source, 'cash')` | - | Type mapping to 'cash' |
| `xPlayer.addAccountMoney(account, amount)` | `AddMoney(source, account, amount)` | `account`, `amount` | Account → type mapping |
| `xPlayer.removeAccountMoney(account, amount)` | `RemoveMoney(source, account, amount)` | `account`, `amount` | Account → type mapping |
| `xPlayer.getAccount(account)` | `GetMoney(source, account)` | `account` | Returns account object |
| `xPlayer.addItem(item, count, metadata)` | `AddItem(source, item, count, nil, metadata)` | All parameters | Slot parameter added |
| `xPlayer.removeItem(item, count)` | `RemoveItem(source, item, count)` | `item`, `count` | Direct mapping |
| `xPlayer.hasItem(item, count)` | `HasItem(source, item, count)` | `item`, `count` | Direct mapping |
| `xPlayer.getInventory()` | `GetInventory(source)` | - | Direct mapping |
| `xPlayer.setJob(job, grade)` | Custom | `job`, `grade` | Framework-specific |
| `xPlayer.getMetadata()` | `GetMetadata(source)` | - | Returns all metadata |
| `xPlayer.setMetadata(key, value)` | `SetMetadata(source, key, value)` | `key`, `value` | Direct mapping |

### xPlayer Properties

| ESX Property | Daphne-Core Property | Notes |
|--------------|----------------------|-------|
| `xPlayer.identifier` | `citizenid` | Direct mapping |
| `xPlayer.getName()` | `name` | Method call |
| `xPlayer.job` | `job` | Direct mapping |
| `xPlayer.source` | `source` | Direct mapping |

## ND_Core Mappings

### Core Functions

| ND_Core API | Daphne-Core API | Parameters | Notes |
|-------------|-----------------|------------|-------|
| `exports['ND_Core']:getPlayer(source)` | `GetPlayer(source)` | `source` (number) | Direct mapping |

### Player Methods

| ND_Core API | Daphne-Core API | Parameters | Notes |
|-------------|-----------------|------------|-------|
| `player.addMoney(type, amount, reason)` | `AddMoney(source, type, amount)` | `type`, `amount` | Reason ignored |
| `player.removeMoney(type, amount, reason)` | `RemoveMoney(source, type, amount)` | `type`, `amount` | Reason ignored |
| `player.deductMoney(type, amount, reason)` | `RemoveMoney(source, type, amount)` | `type`, `amount` | Alias for removeMoney |
| `player.cash` | `GetMoney(source, 'cash')` | - | Property access |
| `player.bank` | `GetMoney(source, 'bank')` | - | Property access |
| `player.getJob()` | `GetJob(source)` | - | Returns tuple (jobName, jobInfo) |
| `player.addItem(item, amount)` | `AddItem(source, item, amount)` | `item`, `amount` | Direct mapping |
| `player.removeItem(item, amount)` | `RemoveItem(source, item, amount)` | `item`, `amount` | Direct mapping |
| `player.hasItem(item, amount)` | `HasItem(source, item, amount)` | `item`, `amount` | Direct mapping |
| `player.getMetadata(key)` | `GetMetadata(source, key)` | `key` | Direct mapping |
| `player.setMetadata(key, value)` | `SetMetadata(source, key, value)` | `key`, `value` | Direct mapping |
| `player.getData(key)` | `GetMetadata(source, key)` | `key` | Alias for getMetadata |

### Player Properties

| ND_Core Property | Daphne-Core Property | Notes |
|------------------|----------------------|-------|
| `player.id` | `citizenid` | Direct mapping |
| `player.fullname` | `name` | Direct mapping |
| `player.firstname` | Parsed from `name` | Parsed |
| `player.lastname` | Parsed from `name` | Parsed |
| `player.cash` | `money.cash` | Direct mapping |
| `player.bank` | `money.bank` | Direct mapping |
| `player.metadata` | `metadata` | Direct mapping |

## Mapping Details

### Parameter Reordering

Some APIs require parameter reordering:

**QBCore:**
```lua
-- QBCore: Player.Functions.AddMoney(type, amount)
-- Daphne: AddMoney(source, type, amount)
-- Proxy adds source parameter
```

**ESX:**
```lua
-- ESX: xPlayer.addMoney(amount)
-- Daphne: AddMoney(source, 'cash', amount)
-- Proxy adds source and 'cash' type
```

### Type Mapping

ESX uses account-based money system, while QBCore/ND_Core use type-based:

**ESX → Daphne:**
- `xPlayer.addMoney(amount)` → `AddMoney(source, 'cash', amount)`
- `xPlayer.addAccountMoney('bank', amount)` → `AddMoney(source, 'bank', amount)`

**Daphne → ESX:**
- `AddMoney(source, 'cash', amount)` → `xPlayer.addMoney(amount)`
- `AddMoney(source, 'bank', amount)` → `xPlayer.addAccountMoney('bank', amount)`

### Data Structure Conversion

Player data structures differ between frameworks:

**QBCore PlayerData:**
```lua
{
    citizenid = string,
    name = string,
    money = {cash = number, bank = number},
    job = {name = string, grade = {level = number}},
    gang = {name = string},
    metadata = {}
}
```

**ESX xPlayer:**
```lua
{
    identifier = string,
    getName() = function,
    getMoney() = function,
    job = {name = string, grade = number},
    getAccount(account) = function
}
```

**ND_Core Player:**
```lua
{
    id = number/string,
    fullname = string,
    cash = number,
    bank = number,
    getJob() = function,  -- Returns (jobName, jobInfo)
    metadata = {}
}
```

All are converted to normalized Daphne-Core format and then back to target framework format.

## Related Documentation

- [Proxy System](PROXY_SYSTEM.md) - General proxy system documentation
- [Cross-Framework Proxy Guide](CROSS_FRAMEWORK_PROXY.md) - Cross-framework usage guide
- [ND_Core Proxy Guide](PROXY_ND_CORE.md) - ND_Core-specific documentation

