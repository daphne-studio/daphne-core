# Performance Guide

Complete guide to daphne-core's performance optimizations and best practices for optimal performance.

## Table of Contents

- [0.00ms Policy](#000ms-policy)
- [Cache Strategies](#cache-strategies)
- [State Bag Optimizations](#state-bag-optimizations)
- [Lazy Loading](#lazy-loading)
- [Memory Management](#memory-management)
- [CPU Usage Optimization](#cpu-usage-optimization)
- [Best Practices](#best-practices)

## 0.00ms Policy

daphne-core follows a **0.00ms policy** - the system should consume 0.00ms CPU time when idle.

### How It Works

- **No Polling**: System doesn't poll for changes
- **Event-Driven**: Updates only occur on events or write operations
- **Lazy Loading**: Data loaded only when needed
- **Batch Processing**: Updates batched together
- **Change Detection**: Only changed data synchronized

### Measurement

Monitor CPU usage with FiveM's built-in profiler:

```lua
-- Enable profiling
SetResourceKvp('profiler_enabled', 'true')

-- Check CPU usage
-- Should show 0.00ms for daphne_core when idle
```

### Achieving 0.00ms

1. **No Active Threads**: No `Citizen.CreateThread` loops
2. **Event-Driven**: Only respond to events
3. **Batch Updates**: Updates batched, not continuous
4. **Cache Usage**: Avoid repeated framework calls

## Cache Strategies

### Player Object Cache

Player objects are cached for **5 seconds** (configurable):

```lua
Cache.Config = {
    PlayerTTL = 5000,  -- 5 seconds
    CleanupInterval = 60000  -- 1 minute
}
```

### Cache Hit Optimization

**Always check cache first:**

```lua
-- Good: Check cache first
function Adapter:GetPlayer(source)
    local cached = Cache.GetPlayer(source)
    if cached then
        return cached  -- Cache hit - fast!
    end
    
    -- Cache miss - get from framework
    local player = self:GetFrameworkPlayer(source)
    if player then
        Cache.SetPlayer(source, player)
    end
    return player
end
```

### Cache Invalidation

**Invalidate cache on writes:**

```lua
function Adapter:AddMoney(source, type, amount)
    local success = self:FrameworkAddMoney(source, type, amount)
    if success then
        Cache.InvalidatePlayer(source)  -- Force fresh data
    end
    return success
end
```

### Cache TTL Configuration

Adjust TTL based on your needs:

```lua
-- Shorter TTL for frequently changing data
Cache.SetPlayer(source, player, 2000)  -- 2 seconds

-- Longer TTL for stable data
Cache.SetPlayer(source, player, 10000)  -- 10 seconds
```

## State Bag Optimizations

### Batch Processing

Updates are batched every **50ms**:

```lua
StateBag.Config = {
    BatchInterval = 50,  -- 50ms batch interval
    MaxBatchSize = 50     -- Max updates per batch
}
```

**Benefits:**
- Reduces network operations
- Lowers CPU usage
- Improves performance

### Throttling

Updates throttled to **100ms per entity**:

```lua
StateBag.Config = {
    ThrottleInterval = 100  -- 100ms throttle per entity
}
```

**Benefits:**
- Prevents update spam
- Reduces network traffic
- Lowers CPU usage

### Change Detection

Only changed data is synchronized:

```lua
-- Deep comparison prevents unnecessary updates
if DeepEqual(oldValue, newValue) then
    return  -- Skip update - no change
end
```

**Benefits:**
- Reduces network traffic
- Lowers CPU usage
- Improves performance

### Read vs Write Operations

**Read operations don't trigger updates:**

```lua
-- Read operation - no state bag update
local money = exports['daphne_core']:GetMoney(source, 'cash')

-- Write operation - triggers state bag update
exports['daphne_core']:AddMoney(source, 'cash', 1000)
```

**Why:** Prevents unnecessary updates on every read, improving performance.

## Lazy Loading

### When to Use

Lazy loading loads data only when needed:

```lua
-- Lazy load: Only get player when needed
function Adapter:GetPlayerData(source)
    local player = self:GetPlayer(source)  -- Loaded on demand
    if not player then return nil end
    
    -- Process data
    return self:MapPlayerData(player)
end
```

### Benefits

- **Reduced Memory**: Only loaded data stored
- **Faster Startup**: No bulk loading
- **On-Demand**: Data loaded when needed

### Implementation

```lua
function Adapter:GetPlayer(source)
    -- Check cache first (lazy cache)
    local cached = Cache.GetPlayer(source)
    if cached then
        return cached
    end
    
    -- Lazy load from framework
    local player = self:LoadPlayer(source)
    if player then
        Cache.SetPlayer(source, player)
    end
    
    return player
end
```

## Memory Management

### Cache Cleanup

Automatic cache cleanup every **60 seconds**:

```lua
Cache.Config = {
    CleanupInterval = 60000  -- 1 minute
}
```

**What it does:**
- Removes expired cache entries
- Frees memory
- Prevents memory leaks

### State Bag Cache Cleanup

State bag cache cleared on player disconnect:

```lua
AddEventHandler('playerDropped', function()
    StateBag.ClearCache('player', source)
end)
```

### Memory Optimization Tips

1. **Clear Unused Caches**: Clear caches when no longer needed
2. **Limit Cache Size**: Use TTL to limit cache size
3. **Cleanup on Disconnect**: Clear player caches on disconnect
4. **Monitor Memory**: Check memory usage regularly

## CPU Usage Optimization

### Batch Processing

Batch multiple operations together:

```lua
-- Bad: Multiple individual updates
exports['daphne_core']:AddMoney(source, 'cash', 100)
exports['daphne_core']:AddMoney(source, 'cash', 200)
exports['daphne_core']:AddMoney(source, 'cash', 300)
-- Results in 3 state bag updates

-- Good: Single batch update
exports['daphne_core']:AddMoney(source, 'cash', 600)
-- Results in 1 state bag update
```

### Throttling

Throttling prevents excessive updates:

```lua
-- Rapid updates are throttled
for i = 1, 100 do
    exports['daphne_core']:AddMoney(source, 'cash', 1)
end
-- Only processes updates every 100ms per entity
```

### Change Detection

Change detection prevents unnecessary work:

```lua
-- Only processes if value actually changed
StateBag.SetStateBag('player', source, 'money', moneyData)
-- Skips if moneyData unchanged
```

## Best Practices

### Do's

1. **Use Cache**: Always check cache before framework calls
2. **Invalidate on Writes**: Invalidate cache on write operations
3. **Batch Updates**: Batch multiple updates together
4. **Use State Bags**: Use state bags for reactive updates
5. **Handle Nil**: Always check for nil values
6. **Use pcall**: Wrap framework calls in pcall

### Don'ts

1. **Don't Poll**: Don't poll in loops
2. **Don't Skip Cache**: Don't bypass cache unnecessarily
3. **Don't Update on Reads**: Don't trigger updates on read operations
4. **Don't Ignore Errors**: Always handle errors
5. **Don't Create Threads**: Don't create unnecessary threads

### Performance Checklist

- [ ] Cache used for player objects
- [ ] Cache invalidated on writes
- [ ] State bags used for reactive updates
- [ ] No polling loops
- [ ] Batch updates when possible
- [ ] Handle nil values
- [ ] Use pcall for safety
- [ ] Monitor CPU usage
- [ ] Monitor memory usage

## Performance Metrics

### Target Metrics

- **CPU Usage (Idle)**: 0.00ms
- **CPU Usage (Active)**: < 0.10ms per operation
- **Memory Usage**: < 50MB
- **Cache Hit Rate**: > 80%
- **State Bag Update Rate**: < 20 updates/second

### Monitoring

Monitor performance with:

```lua
-- Check cache stats
local stats = Cache.GetStats()
print("Cache entries: " .. stats.total)
print("Active entries: " .. stats.active)

-- Monitor state bag updates
-- Check server console for update frequency
```

## Related Documentation

- [State Bag System](STATE_BAG_SYSTEM.md) - State bag optimizations
- [Architecture](ARCHITECTURE.md) - System architecture
- [API Reference](API_REFERENCE.md) - Export function documentation

