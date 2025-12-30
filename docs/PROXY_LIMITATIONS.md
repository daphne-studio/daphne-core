# Proxy System Limitations

Complete guide to proxy system limitations and workarounds.

## Table of Contents

- [Export Override Limitation](#export-override-limitation)
- [Framework-Specific Features](#framework-specific-features)
- [Performance Considerations](#performance-considerations)
- [Workarounds](#workarounds)

## Export Override Limitation

### The Problem

**FiveM's `exports` table is read-only**, which means we cannot override exports directly. This is a FiveM platform limitation, not a daphne-core limitation.

### What Works

✅ **Global Variable Override**
- `QBCore` global variable can be overridden
- `ESX` global variable can be overridden
- `NDCore` global variable can be overridden (if framework sets it)

### What Doesn't Work

❌ **Export Override**
- `exports['qb-core']` cannot be overridden
- `exports['es_extended']` cannot be overridden
- `exports['ND_Core']` cannot be overridden

### Impact

Scripts using exports directly cannot be proxied:

```lua
-- ❌ Won't be proxied (uses export)
local QBCore = exports['qb-core']:GetCoreObject()

-- ❌ Won't be proxied (uses export)
local ESX = exports['es_extended']:getSharedObject()

-- ⚠️ Uses original ND_Core export (if available)
local player = exports['ND_Core']:getPlayer(source)
```

### Solution

Modify scripts to use global variables:

```lua
-- ✅ Will be proxied (uses global variable)
local QBCore = QBCore

-- ✅ Will be proxied (uses global variable)
local ESX = ESX

-- ✅ Will be proxied (if NDCore global exists)
if NDCore then
    local player = NDCore:getPlayer(source)
end
```

## Framework-Specific Features

### QBCore-Specific Features

- **Gang System**: Only available when QBCore adapter is active
- **Custom Metadata**: May not work on ESX/ND_Core adapters
- **Vehicle System**: QBCore-specific vehicle methods may not work

### ESX-Specific Features

- **Account System**: Custom accounts may not work on QBCore adapter
- **Job System**: ESX job structure differs from QBCore
- **Inventory System**: ESX inventory methods may differ

### ND_Core-Specific Features

- **Character System**: ND_Core character methods may not work on other adapters
- **Job System**: ND_Core job structure differs from other frameworks
- **Metadata System**: ND_Core metadata structure may differ

## Performance Considerations

### Overhead

- **Metatable Lookups**: Proxy adds minimal overhead through metatable lookups
- **Data Conversion**: Data conversion happens on-the-fly
- **Cache**: Cache is used to minimize conversions

### Optimization Tips

1. **Use daphne-core exports directly** for new scripts (no proxy overhead)
2. **Cache player objects** when possible
3. **Avoid frequent proxy calls** in loops

## Workarounds

### For QBCore Scripts

**Before (won't work):**
```lua
local QBCore = exports['qb-core']:GetCoreObject()
```

**After (will work):**
```lua
local QBCore = QBCore
```

### For ESX Scripts

**Before (won't work):**
```lua
local ESX = exports['es_extended']:getSharedObject()
```

**After (will work):**
```lua
local ESX = ESX
```

### For ND_Core Scripts

**Before (uses original export):**
```lua
local player = exports['ND_Core']:getPlayer(source)
```

**After (will work if NDCore global exists):**
```lua
local player = nil
if NDCore then
    player = NDCore:getPlayer(source)
elseif exports['ND_Core'] then
    player = exports['ND_Core']:getPlayer(source)
end
```

## Best Practices

### 1. Use Global Variables

Always use global variables instead of exports for proxy support:

```lua
-- ✅ Good
local QBCore = QBCore
local ESX = ESX

-- ❌ Bad
local QBCore = exports['qb-core']:GetCoreObject()
local ESX = exports['es_extended']:getSharedObject()
```

### 2. Check for Framework Availability

Check if framework is available before using:

```lua
if QBCore then
    -- Use QBCore
elseif ESX then
    -- Use ESX
end
```

### 3. Use daphne-core Exports for New Scripts

For new scripts, use daphne-core exports directly (no proxy overhead):

```lua
-- Best practice for new scripts
local money = exports['daphne_core']:GetMoney(source, 'cash')
exports['daphne_core']:AddMoney(source, 'cash', 1000)
```

## Related Documentation

- [Proxy System](PROXY_SYSTEM.md) - General proxy system documentation
- [Cross-Framework Proxy Guide](CROSS_FRAMEWORK_PROXY.md) - Cross-framework usage guide
- [Proxy Mapping Reference](PROXY_MAPPING.md) - Complete API mapping reference


