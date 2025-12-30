# Frequently Asked Questions

Common questions and solutions for daphne-core.

## Table of Contents

- [Framework Detection](#framework-detection)
- [State Bag Issues](#state-bag-issues)
- [Performance Issues](#performance-issues)
- [Integration Questions](#integration-questions)
- [Troubleshooting](#troubleshooting)

## Framework Detection

### Q: Framework not detected on server start

**A:** Ensure your framework is started **before** daphne_core in server.cfg:

```cfg
ensure qbx_core  # or qb-core
ensure daphne_core
```

Check console for detection messages:
```
[Daphne Core] Framework detected: qbox
[Daphne Core] Bridge initialized with Qbox adapter
```

### Q: Getting "No supported framework detected" error

**A:** Check:
1. Framework resource name matches exactly (`qbx_core`, `qb-core`, or `es_extended`)
2. Framework is started before daphne_core
3. Framework resource is actually running: `GetResourceState('framework_name')`

### Q: Adapter initialization failed

**A:** For QBCore/Qbox:
- Adapter retries 10 times with 500ms delay
- Check if framework exports are available
- Verify framework is fully loaded

For ESX:
- Check if `es_extended` resource is running
- Verify ESX export is available: `exports['es_extended']:getSharedObject()`

## State Bag Issues

### Q: State bag values not updating on client

**A:** State bag updates:
- Only occur on **write operations** (AddMoney, RemoveMoney, SetMetadata)
- Are **batched** (50ms interval) and **throttled** (100ms per entity)
- Read operations don't trigger updates (performance optimization)

**Solution:** Use write operations to trigger updates, or wait for batch processing.

### Q: State bag value is nil on client

**A:** State bags may be `nil` if:
- Player just joined (not yet synced)
- State bag hasn't been set yet
- Player disconnected

**Solution:** Always check for `nil`:
```lua
local money = exports['daphne_core']:GetPlayerStateBag('money')
if money then
    -- Use money
else
    -- Handle nil case
end
```

### Q: State bag watcher not firing

**A:** Check:
1. Watcher is set up correctly
2. State bag value is actually changing
3. Change detection isn't skipping update (value unchanged)

**Solution:** Verify state bag is updating:
```lua
exports['daphne_core']:WatchPlayerStateBag('money', function(value, oldValue)
    print("Money changed!")
    print("New:", json.encode(value))
    print("Old:", json.encode(oldValue))
end)
```

## Performance Issues

### Q: High CPU usage

**A:** Check:
1. No polling loops (use watchers instead)
2. Cache is being used
3. Batch updates when possible
4. No unnecessary state bag updates

**Solution:** Follow performance best practices:
- Use state bag watchers instead of polling
- Check cache before framework calls
- Batch multiple operations together

### Q: Memory usage increasing

**A:** Check:
1. Cache cleanup is working (automatic every 60 seconds)
2. State bag cache cleared on player disconnect
3. No memory leaks in your code

**Solution:** Monitor cache stats:
```lua
local stats = Cache.GetStats()
print("Cache entries: " .. stats.total)
```

## Integration Questions

### Q: How do I use daphne-core in my resource?

**A:** 
1. Add dependency in `fxmanifest.lua`:
```lua
dependencies {
    'daphne_core'
}
```

2. Use exports in your scripts:
```lua
local playerData = exports['daphne_core']:GetPlayerData(source)
```

See [Integration Guide](INTEGRATION_GUIDE.md) for details.

### Q: Can I use daphne-core with multiple frameworks?

**A:** No, daphne-core detects and uses one framework at a time. The detected framework is determined by the detection order in `shared/config.lua`.

### Q: How do I migrate from direct framework calls?

**A:** Replace framework calls with daphne-core exports:

**Before (QBCore):**
```lua
local QBCore = exports['qb-core']:GetCoreObject()
local Player = QBCore.Functions.GetPlayer(source)
local money = Player.PlayerData.money.cash
```

**After:**
```lua
local money = exports['daphne_core']:GetMoney(source, 'cash')
```

See [Integration Guide](INTEGRATION_GUIDE.md) for migration details.

## Troubleshooting

### Q: Exports return nil or false

**A:** Check:
1. Player is online and loaded
2. Framework is initialized (check console logs)
3. Export syntax is correct: `exports['daphne_core']:FunctionName()`
4. Parameters are correct

**Solution:** Add error handling:
```lua
local playerData = exports['daphne_core']:GetPlayerData(source)
if not playerData then
    print("Failed to get player data for source: " .. source)
    return
end
```

### Q: Inventory operations not working

**A:** Check:
1. Inventory system is detected (ox_inventory, qb-inventory, or esx_inventory)
2. For ox_inventory, use `GetItem` instead of `GetInventory` (returns empty table)
3. Item names match exactly

**Solution:** Verify inventory system:
```lua
-- Check if using ox_inventory
local success, _ = pcall(function()
    return exports.ox_inventory
end)
if success then
    print("Using ox_inventory")
end
```

### Q: Cache returning stale data

**A:** Cache:
- Automatically invalidates on write operations
- Has TTL of 5 seconds (configurable)
- Can be manually invalidated

**Solution:** Manually invalidate if needed:
```lua
Cache.InvalidatePlayer(source)
```

### Q: Job/Gang data not updating

**A:** Job/Gang updates:
- Triggered by framework events
- Automatically synced to state bags
- Cache invalidated on changes

**Solution:** Check framework events are firing:
- QBCore: `QBCore:Server:OnPlayerLoaded`
- ESX: `esx:setJob`, `esx:playerLoaded`

## Related Documentation

- [Quick Start](QUICK_START.md) - Getting started guide
- [API Reference](API_REFERENCE.md) - Export function documentation
- [Integration Guide](INTEGRATION_GUIDE.md) - Integration patterns
- [Error Handling](ERROR_HANDLING.md) - Error handling guide

