# State Bag System

Complete guide to daphne-core's state bag system. State bags provide efficient client-server synchronization with automatic batching, throttling, and change detection.

## Table of Contents

- [Overview](#overview)
- [State Bag Fundamentals](#state-bag-fundamentals)
- [Batch Update Mechanism](#batch-update-mechanism)
- [Throttling System](#throttling-system)
- [Change Detection](#change-detection)
- [State Bag Keys](#state-bag-keys)
- [Client-Side Usage](#client-side-usage)
- [Watch Patterns](#watch-patterns)
- [Performance Considerations](#performance-considerations)

## Overview

daphne-core uses FiveM's state bag system to synchronize player data from server to clients efficiently. The system includes:

- **Batch Processing**: Updates are batched together (50ms interval)
- **Throttling**: Rate limiting prevents excessive updates (100ms per entity)
- **Change Detection**: Only changed data is synchronized
- **Automatic Sync**: Write operations automatically update state bags

## State Bag Fundamentals

### What are State Bags?

State bags are FiveM's built-in mechanism for synchronizing data between server and clients. They provide:

- **Efficient**: Only changed data is transmitted
- **Automatic**: FiveM handles network synchronization
- **Reactive**: Clients can watch for changes

### How daphne-core Uses State Bags

daphne-core automatically syncs player data to state bags when:

- Player loads (initial sync)
- Money changes (AddMoney, RemoveMoney)
- Metadata changes (SetMetadata)
- Job changes (via framework events)
- Gang changes (via framework events)

### Benefits

- **Performance**: Batched updates reduce network overhead
- **Reactivity**: Clients can watch for changes without polling
- **Consistency**: Single source of truth on server
- **Efficiency**: Only changed data is transmitted

## Batch Update Mechanism

### How It Works

State bag updates are queued and processed in batches:

1. **Queue**: Updates are added to a queue
2. **Batch Timer**: Every 50ms, queued updates are processed
3. **Process**: Updates are sent to clients in batches
4. **Repeat**: Process continues if more updates are queued

### Configuration

Batch interval is configured in `core/statebag.lua`:

```lua
StateBag.Config = {
    BatchInterval = 50,  -- 50ms batch interval
    ThrottleInterval = 100,  -- 100ms throttle per entity
    MaxBatchSize = 50  -- Maximum updates per batch
}
```

### Example Flow

```
Time 0ms:   AddMoney() called → Update queued
Time 10ms:  RemoveMoney() called → Update queued
Time 20ms:  SetMetadata() called → Update queued
Time 50ms:  Batch processed → All 3 updates sent together
```

### Benefits

- **Reduced Network Traffic**: Multiple updates combined into one batch
- **Lower CPU Usage**: Fewer network operations
- **Better Performance**: Batch processing is more efficient

## Throttling System

### How It Works

Throttling prevents excessive updates for the same entity:

1. **Track Updates**: Each entity's updates are tracked with timestamps
2. **Check Throttle**: Before processing, check if 100ms has passed since last update
3. **Process or Delay**: Process if throttled, otherwise delay to next batch

### Throttle Interval

Default throttle interval is **100ms per entity**:

```lua
ThrottleInterval = 100  -- Minimum time between updates for same entity
```

### Example

```
Time 0ms:   Update for player 1 → Processed immediately
Time 10ms:  Update for player 1 → Throttled (only 10ms since last)
Time 50ms:  Update for player 1 → Throttled (only 50ms since last)
Time 100ms: Update for player 1 → Processed (100ms+ since last)
```

### Benefits

- **Prevents Spam**: Rapid updates are throttled
- **Reduces Load**: Fewer unnecessary updates
- **Better Performance**: Throttling reduces CPU usage

## Change Detection

### How It Works

Change detection ensures only changed data is synchronized:

1. **Cache Previous Value**: Store previous state bag value
2. **Deep Comparison**: Compare new value with cached value
3. **Skip if Same**: Skip update if values are identical
4. **Update if Different**: Update state bag if values differ

### Deep Comparison Algorithm

The system uses optimized deep comparison:

```lua
-- Shallow comparison first (fast path)
if a == b then return true end

-- Type check
if type(a) ~= type(b) then return false end

-- Deep comparison for tables (limited depth)
-- Prevents circular reference issues
```

### Optimization Techniques

- **Shallow First**: Fast path for simple values
- **Limited Depth**: Prevents infinite recursion
- **Reference Tracking**: Prevents circular reference loops
- **Selective Comparison**: Only compares changed fields

### Example

```lua
-- First update
StateBag.SetStateBag('player', 1, 'money', {cash = 1000, bank = 5000})
-- → Update sent (no previous value)

-- Second update (same value)
StateBag.SetStateBag('player', 1, 'money', {cash = 1000, bank = 5000})
-- → Update skipped (value unchanged)

-- Third update (different value)
StateBag.SetStateBag('player', 1, 'money', {cash = 1500, bank = 5000})
-- → Update sent (cash changed)
```

### Benefits

- **Reduced Network Traffic**: Unchanged data not transmitted
- **Lower CPU Usage**: Fewer state bag operations
- **Better Performance**: Only necessary updates sent

## State Bag Keys

### Naming Convention

State bag keys follow the format:

```
daphne:type:id:key
```

Where:
- `daphne`: Prefix
- `type`: Entity type (`player`, `vehicle`, `object`)
- `id`: Entity ID (server ID for players, entity handle for vehicles)
- `key`: Data key (`money`, `job`, `gang`, `data`)

### Available Keys

#### Player State Bags

**Key:** `daphne:player:[source]:money`
- **Type:** `table`
- **Structure:** `{cash = number, bank = number, ...}`
- **Updated:** On money changes (AddMoney, RemoveMoney)

**Key:** `daphne:player:[source]:job`
- **Type:** `table`
- **Structure:** JobData object
- **Updated:** On job changes (via framework events)

**Key:** `daphne:player:[source]:gang`
- **Type:** `table`
- **Structure:** GangData object (QBCore only)
- **Updated:** On gang changes (via framework events)

**Key:** `daphne:player:[source]:data`
- **Type:** `table`
- **Structure:** Complete player data snapshot
- **Updated:** On metadata changes (SetMetadata)

#### Vehicle State Bags

**Key:** `daphne:vehicle:[entity]:data`
- **Type:** `table`
- **Structure:** VehicleData object
- **Updated:** On vehicle data changes

### Example Keys

```
daphne:player:1:money      -- Player 1's money
daphne:player:1:job        -- Player 1's job
daphne:player:1:gang      -- Player 1's gang
daphne:player:1:data       -- Player 1's complete data
daphne:vehicle:123:data   -- Vehicle entity 123's data
```

## Client-Side Usage

### Reading State Bags

Use `GetPlayerStateBag()` to read state bag values:

```lua
-- Get money state bag
local moneyData = exports['daphne_core']:GetPlayerStateBag('money')
if moneyData then
    print("Cash: $" .. (moneyData.cash or 0))
    print("Bank: $" .. (moneyData.bank or 0))
end

-- Get job state bag
local jobData = exports['daphne_core']:GetPlayerStateBag('job')
if jobData then
    print("Job: " .. jobData.name)
end
```

### Watching Changes

Use `WatchPlayerStateBag()` to watch for changes:

```lua
exports['daphne_core']:WatchPlayerStateBag('money', function(value, oldValue)
    if value and oldValue then
        if value.cash ~= oldValue.cash then
            print("Cash changed!")
        end
    end
end)
```

### Best Practices

1. **Check for Nil**: State bag values may be `nil` if not yet synced
2. **Handle First Call**: `oldValue` may be `nil` on first callback
3. **Compare Values**: Always compare `value` and `oldValue` before using
4. **Unwatch When Done**: Call unwatch function to stop watching

## Watch Patterns

### Basic Watch

```lua
local unwatch = exports['daphne_core']:WatchPlayerStateBag('money', function(value, oldValue)
    if value then
        print("Money updated")
    end
end)

-- Stop watching after 60 seconds
SetTimeout(60000, function()
    unwatch()
end)
```

### Debounced Watch

```lua
local lastCall = 0
local delay = 500

exports['daphne_core']:WatchPlayerStateBag('money', function(value, oldValue)
    local now = GetGameTimer()
    if now - lastCall >= delay then
        -- Process update
        print("Money changed (debounced)")
        lastCall = now
    end
end)
```

### Multiple Key Watch

```lua
local moneyWatcher = exports['daphne_core']:WatchPlayerStateBag('money', function(value, oldValue)
    print("Money changed")
end)

local jobWatcher = exports['daphne_core']:WatchPlayerStateBag('job', function(value, oldValue)
    print("Job changed")
end)

-- Stop all watchers
function StopWatchers()
    moneyWatcher()
    jobWatcher()
end
```

### Conditional Watch

```lua
exports['daphne_core']:WatchPlayerStateBag('job', function(value, oldValue)
    if value and oldValue and value.name ~= oldValue.name then
        -- Only process if job name actually changed
        print("Job changed from " .. oldValue.name .. " to " .. value.name)
    end
end)
```

## Performance Considerations

### Optimization Tips

1. **Use State Bags for Reactive Updates**: Don't poll, watch instead
2. **Batch Your Updates**: Multiple rapid updates are automatically batched
3. **Check Values Before Updating**: Change detection prevents unnecessary updates
4. **Unwatch When Done**: Stop watching when no longer needed

### Common Pitfalls

1. **Polling Instead of Watching**: Don't poll state bags in loops
   ```lua
   -- Bad: Polling
   Citizen.CreateThread(function()
       while true do
           Wait(100)
           local money = exports['daphne_core']:GetPlayerStateBag('money')
           -- Process money
       end
   end)
   
   -- Good: Watching
   exports['daphne_core']:WatchPlayerStateBag('money', function(value, oldValue)
       -- Process money changes
   end)
   ```

2. **Not Handling Nil Values**: State bags may be `nil` initially
   ```lua
   -- Bad: Assumes value exists
   local money = exports['daphne_core']:GetPlayerStateBag('money')
   print(money.cash)  -- Error if money is nil
   
   -- Good: Check for nil
   local money = exports['daphne_core']:GetPlayerStateBag('money')
   if money then
       print(money.cash or 0)
   end
   ```

3. **Not Unwatching**: Watchers persist until resource restart
   ```lua
   -- Bad: Watcher never stopped
   exports['daphne_core']:WatchPlayerStateBag('money', function() end)
   
   -- Good: Store unwatch function
   local unwatch = exports['daphne_core']:WatchPlayerStateBag('money', function() end)
   -- Call unwatch() when done
   ```

### Performance Metrics

- **Batch Interval**: 50ms (configurable)
- **Throttle Interval**: 100ms per entity (configurable)
- **Max Batch Size**: 50 updates per batch (configurable)
- **Change Detection**: Optimized deep comparison (limited depth)

### Best Practices

1. **Server-Side**: Write operations automatically update state bags
2. **Client-Side**: Use watchers for reactive updates
3. **Avoid Polling**: Use state bag watchers instead
4. **Handle Nil**: Always check for `nil` values
5. **Unwatch**: Stop watching when no longer needed

## Related Documentation

- [API Reference](API_REFERENCE.md) - Export function documentation
- [Data Structures](DATA_STRUCTURES.md) - State bag data formats
- [Performance Guide](PERFORMANCE.md) - Performance optimizations
- [Integration Guide](INTEGRATION_GUIDE.md) - Integration patterns

