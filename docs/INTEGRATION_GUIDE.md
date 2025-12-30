# Integration Guide

Complete guide to integrating daphne-core into your resources and migrating existing scripts.

## Table of Contents

- [Using daphne-core as Dependency](#using-daphne-core-as-dependency)
- [State Bag Integration](#state-bag-integration)
- [Event Handling](#event-handling)
- [Framework Migration](#framework-migration)
- [Common Patterns](#common-patterns)
- [Testing Strategies](#testing-strategies)

## Using daphne-core as Dependency

### Declaring Dependency

In your `fxmanifest.lua`:

```lua
fx_version 'cerulean'
game 'gta5'

dependencies {
    'daphne_core'
}

-- Your scripts
server_scripts {
    'server/*.lua'
}

client_scripts {
    'client/*.lua'
}
```

### Export Usage

Use exports in your scripts:

```lua
-- Server-side
local playerData = exports['daphne_core']:GetPlayerData(source)
local money = exports['daphne_core']:GetMoney(source, 'cash')

-- Client-side
local playerData = exports['daphne_core']:GetPlayerData()
local cash = exports['daphne_core']:GetMoney('cash')
```

### Error Handling

Always handle errors:

```lua
local playerData = exports['daphne_core']:GetPlayerData(source)
if not playerData then
    -- Handle error: player not found or framework error
    return
end

-- Use playerData safely
```

## State Bag Integration

### Reading State Bags

Read state bag values on client:

```lua
-- Get money state bag
local moneyData = exports['daphne_core']:GetPlayerStateBag('money')
if moneyData then
    print("Cash: $" .. (moneyData.cash or 0))
end
```

### Watching Changes

Watch for state bag changes:

```lua
-- Watch money changes
exports['daphne_core']:WatchPlayerStateBag('money', function(value, oldValue)
    if value then
        -- Update UI
        UpdateMoneyDisplay(value.cash, value.bank)
    end
end)
```

### HUD Integration

Integrate with HUD systems:

```lua
-- Update HUD when money changes
exports['daphne_core']:WatchPlayerStateBag('money', function(value, oldValue)
    if value then
        -- Update your HUD
        exports['your_hud']:UpdateMoney(value.cash, value.bank)
    end
end)

-- Update HUD when job changes
exports['daphne_core']:WatchPlayerStateBag('job', function(value, oldValue)
    if value then
        exports['your_hud']:UpdateJob(value.name, value.grade.level)
    end
end)
```

## Event Handling

### Framework Events

daphne-core listens to framework events automatically:

- **QBCore/Qbox**: `QBCore:Server:OnPlayerLoaded`, `QBCore:Server:OnPlayerUnload`
- **ESX**: `esx:playerLoaded`, `esx:playerDropped`, `esx:setJob`, `esx:setAccountMoney`

### Custom Events

Create custom events that use daphne-core:

```lua
-- Server-side event
RegisterNetEvent('myresource:purchase', function(itemName, price)
    local source = source
    
    -- Check money
    local cash = exports['daphne_core']:GetMoney(source, 'cash')
    if not cash or cash < price then
        TriggerClientEvent('myresource:notification', source, 'Not enough cash')
        return
    end
    
    -- Remove money
    if exports['daphne_core']:RemoveMoney(source, 'cash', price) then
        -- Give item
        exports['daphne_core']:AddItem(source, itemName, 1)
        TriggerClientEvent('myresource:notification', source, 'Purchase successful')
    end
end)
```

## Framework Migration

### From QBCore Direct Calls

**Before:**
```lua
local QBCore = exports['qb-core']:GetCoreObject()
local Player = QBCore.Functions.GetPlayer(source)
local money = Player.PlayerData.money.cash
```

**After:**
```lua
local money = exports['daphne_core']:GetMoney(source, 'cash')
```

### From ESX Direct Calls

**Before:**
```lua
local xPlayer = ESX.GetPlayerFromId(source)
local money = xPlayer.getMoney()
```

**After:**
```lua
local money = exports['daphne_core']:GetMoney(source, 'cash')
```

### Migration Checklist

- [ ] Replace framework direct calls with daphne-core exports
- [ ] Update error handling
- [ ] Test with both frameworks (if supporting multiple)
- [ ] Update state bag usage (if applicable)
- [ ] Remove framework-specific code

## Common Patterns

### Money Operations

```lua
-- Check if player has enough money
local function HasEnoughMoney(source, amount, moneyType)
    moneyType = moneyType or 'cash'
    local money = exports['daphne_core']:GetMoney(source, moneyType)
    return money and money >= amount
end

-- Transfer money between players
local function TransferMoney(source, targetId, amount, moneyType)
    moneyType = moneyType or 'bank'
    
    -- Check source has enough
    if not HasEnoughMoney(source, amount, moneyType) then
        return false, "Insufficient funds"
    end
    
    -- Remove from source
    if not exports['daphne_core']:RemoveMoney(source, moneyType, amount) then
        return false, "Failed to remove money"
    end
    
    -- Add to target
    if not exports['daphne_core']:AddMoney(targetId, moneyType, amount) then
        -- Refund
        exports['daphne_core']:AddMoney(source, moneyType, amount)
        return false, "Failed to add money"
    end
    
    return true, "Transfer successful"
end
```

### Job Checks

```lua
-- Check if player has job
local function HasJob(source, jobName, minGrade)
    minGrade = minGrade or 0
    local job = exports['daphne_core']:GetJob(source)
    
    if not job then
        return false
    end
    
    return job.name == jobName and job.grade.level >= minGrade
end

-- Check if player is on duty
local function IsOnDuty(source, jobName)
    local job = exports['daphne_core']:GetJob(source)
    
    if not job or job.name ~= jobName then
        return false
    end
    
    return job.onduty == true
end
```

### Permission Systems

```lua
-- Job-based permissions
local function HasPermission(source, permission)
    local job = exports['daphne_core']:GetJob(source)
    if not job then return false end
    
    -- Define permissions
    local permissions = {
        ['police.armory'] = {job = 'police', grade = 2},
        ['police.impound'] = {job = 'police', grade = 1},
        ['ambulance.pharmacy'] = {job = 'ambulance', grade = 1}
    }
    
    local perm = permissions[permission]
    if not perm then return false end
    
    return job.name == perm.job and job.grade.level >= perm.grade
end
```

### Shop Systems

```lua
-- Shop purchase handler
RegisterNetEvent('shop:purchase', function(itemName, price)
    local source = source
    
    -- Validate item exists
    local item = ShopItems[itemName]
    if not item then
        TriggerClientEvent('shop:notification', source, 'Item not found')
        return
    end
    
    -- Check money
    local money = exports['daphne_core']:GetMoney(source, item.moneyType)
    if not money or money < price then
        TriggerClientEvent('shop:notification', source, 'Not enough money')
        return
    end
    
    -- Remove money
    if not exports['daphne_core']:RemoveMoney(source, item.moneyType, price) then
        TriggerClientEvent('shop:notification', source, 'Purchase failed')
        return
    end
    
    -- Add item
    if exports['daphne_core']:AddItem(source, itemName, 1) then
        TriggerClientEvent('shop:notification', source, 'Purchase successful')
    else
        -- Refund
        exports['daphne_core']:AddMoney(source, item.moneyType, price)
        TriggerClientEvent('shop:notification', source, 'Failed to add item')
    end
end)
```

## Testing Strategies

### Unit Testing

Test individual functions:

```lua
-- Test money operations
local function TestMoneyOperations()
    local testSource = 1
    
    -- Test GetMoney
    local money = exports['daphne_core']:GetMoney(testSource, 'cash')
    assert(money ~= nil, "GetMoney failed")
    
    -- Test AddMoney
    local success = exports['daphne_core']:AddMoney(testSource, 'cash', 100)
    assert(success == true, "AddMoney failed")
    
    -- Verify money added
    local newMoney = exports['daphne_core']:GetMoney(testSource, 'cash')
    assert(newMoney == money + 100, "Money not added correctly")
end
```

### Integration Testing

Test full workflows:

```lua
-- Test shop purchase workflow
local function TestShopPurchase()
    local testSource = 1
    
    -- Setup: Give player money
    exports['daphne_core']:AddMoney(testSource, 'cash', 1000)
    
    -- Test purchase
    TriggerEvent('shop:purchase', testSource, 'bread', 5)
    
    -- Verify: Check item added
    local hasItem = exports['daphne_core']:HasItem(testSource, 'bread', 1)
    assert(hasItem == true, "Item not added")
    
    -- Verify: Check money removed
    local money = exports['daphne_core']:GetMoney(testSource, 'cash')
    assert(money == 995, "Money not removed correctly")
end
```

## Related Documentation

- [API Reference](API_REFERENCE.md) - Export function documentation
- [State Bag System](STATE_BAG_SYSTEM.md) - State bag usage guide
- [Examples Collection](EXAMPLES_COLLECTION.md) - More examples

