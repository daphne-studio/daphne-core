# Error Handling Guide

Complete guide to error handling in daphne-core, including ErrorHandler module usage, SafeCall patterns, and debugging techniques.

## Table of Contents

- [ErrorHandler Module](#errorhandler-module)
- [SafeCall Patterns](#safecall-patterns)
- [Export Error Handling](#export-error-handling)
- [Framework Initialization](#framework-initialization)
- [Error Logging](#error-logging)
- [Debugging Techniques](#debugging-techniques)
- [Common Error Scenarios](#common-error-scenarios)

## ErrorHandler Module

The ErrorHandler module provides safe error handling utilities.

### Location

`core/error_handler.lua`

### Configuration

```lua
ErrorHandler.Config = {
    LogErrors = true,      -- Enable error logging
    LogLevel = 'error'     -- Log level: 'error', 'warn', 'info', 'debug'
}
```

### API Reference

#### SafeCall

Safely execute a function with error handling:

```lua
---@param func function Function to execute
---@param errorMessage string? Custom error message (optional)
---@return boolean success True if function executed successfully
---@return any result Function result or error message
local success, result = ErrorHandler.SafeCall(function()
    return SomeFunction()
end, "Custom error message")
```

**Example:**
```lua
local success, player = ErrorHandler.SafeCall(function()
    return Framework:GetPlayer(source)
end, "Failed to get player")

if success then
    -- Use player
else
    print("Error: " .. tostring(player))
end
```

#### SafeCallNil

Safely execute a function, returning nil on error:

```lua
---@param func function Function to execute
---@param errorMessage string? Custom error message (optional)
---@return any result Function result or nil on error
local result = ErrorHandler.SafeCallNil(function()
    return SomeFunction()
end, "Custom error message")
```

**Example:**
```lua
local player = ErrorHandler.SafeCallNil(function()
    return Framework:GetPlayer(source)
end)

if player then
    -- Use player
else
    -- Handle error
end
```

#### SafeExport

Safely call an export:

```lua
---@param resourceName string Resource name
---@param exportName string Export name
---@param args table? Arguments table
---@return boolean success True if export call succeeded
---@return any result Export result or error message
local success, result = ErrorHandler.SafeExport('resource_name', 'export_name', {arg1, arg2})
```

**Example:**
```lua
local success, result = ErrorHandler.SafeExport('daphne_core', 'GetPlayerData', {source})

if success then
    -- Use result
else
    print("Export error: " .. tostring(result))
end
```

#### SafeExportNil

Safely call an export, returning nil on error:

```lua
---@param resourceName string Resource name
---@param exportName string Export name
---@param args table? Arguments table
---@return any result Export result or nil on error
local result = ErrorHandler.SafeExportNil('resource_name', 'export_name', {arg1, arg2})
```

**Example:**
```lua
local playerData = ErrorHandler.SafeExportNil('daphne_core', 'GetPlayerData', {source})

if playerData then
    -- Use playerData
end
```

## SafeCall Patterns

### Basic Pattern

```lua
local success, result = ErrorHandler.SafeCall(function()
    return RiskyFunction()
end)

if success then
    -- Handle success
    ProcessResult(result)
else
    -- Handle error
    print("Error: " .. tostring(result))
end
```

### Nil Return Pattern

```lua
local result = ErrorHandler.SafeCallNil(function()
    return RiskyFunction()
end)

if result then
    -- Handle success
    ProcessResult(result)
else
    -- Handle error (result is nil)
    print("Function failed")
end
```

### Nested Safe Calls

```lua
local success, player = ErrorHandler.SafeCall(function()
    return Framework:GetPlayer(source)
end)

if success then
    local success2, data = ErrorHandler.SafeCall(function()
        return player:GetData()
    end)
    
    if success2 then
        -- Use data
    end
end
```

## Export Error Handling

### Safe Export Calls

Always use safe export calls:

```lua
-- Bad: Direct export call (may throw error)
local playerData = exports['daphne_core']:GetPlayerData(source)

-- Good: Safe export call
local success, playerData = ErrorHandler.SafeExport('daphne_core', 'GetPlayerData', {source})
if success then
    -- Use playerData
end
```

### Error Recovery

Implement error recovery:

```lua
local function GetPlayerDataSafe(source)
    -- Try primary method
    local success, playerData = ErrorHandler.SafeExport('daphne_core', 'GetPlayerData', {source})
    if success then
        return playerData
    end
    
    -- Fallback method
    local success2, player = ErrorHandler.SafeExport('daphne_core', 'GetPlayer', {source})
    if success2 and player then
        -- Build playerData manually
        return BuildPlayerData(player)
    end
    
    return nil
end
```

### Fallback Patterns

Use fallback patterns for critical operations:

```lua
local function AddMoneySafe(source, type, amount)
    -- Try primary method
    local success = ErrorHandler.SafeExport('daphne_core', 'AddMoney', {source, type, amount})
    if success then
        return true
    end
    
    -- Fallback: Direct framework call
    local success2, result = ErrorHandler.SafeCall(function()
        return Framework:AddMoney(source, type, amount)
    end)
    
    return success2 and result == true
end
```

## Framework Initialization

### Retry Logic

QBCore/Qbox adapter uses retry logic:

```lua
function QboxAdapter:Initialize(retries, delay)
    retries = retries or 10
    delay = delay or 500
    
    for i = 1, retries do
        -- Try to initialize
        if self:TryInitialize() then
            return true
        end
        
        -- Wait before retry
        if i < retries then
            Wait(delay)
        end
    end
    
    return false
end
```

### Error Messages

Initialization errors provide detailed messages:

```lua
print('[Daphne Core] Qbox/QBCore not found!')
print(string.format('[Daphne Core] qbx_core state: %s', GetResourceState('qbx_core')))
print('[Daphne Core] Make sure qbx_core is started BEFORE daphne_core')
```

### Debugging Initialization

Check initialization status:

```lua
-- Check if adapter initialized
if ActiveAdapter and ActiveAdapter.initialized then
    print("Adapter initialized successfully")
else
    print("Adapter not initialized")
end
```

## Error Logging

### Configuration

Configure error logging:

```lua
ErrorHandler.Config = {
    LogErrors = true,      -- Enable/disable logging
    LogLevel = 'error'     -- 'error', 'warn', 'info', 'debug'
}
```

### Log Levels

```lua
ErrorHandler.Log('error', 'Critical error occurred')
ErrorHandler.Log('warn', 'Warning message')
ErrorHandler.Log('info', 'Information message')
ErrorHandler.Log('debug', 'Debug message')
```

### Custom Logging

Implement custom logging:

```lua
function CustomLog(level, message)
    -- Log to file
    local file = io.open('logs/error.log', 'a')
    if file then
        file:write(string.format('[%s] %s: %s\n', os.date(), level, message))
        file:close()
    end
    
    -- Also use ErrorHandler
    ErrorHandler.Log(level, message)
end
```

## Debugging Techniques

### Enable Debug Logging

```lua
ErrorHandler.Config.LogLevel = 'debug'
```

### Check Framework State

```lua
-- Check framework resource state
local state = GetResourceState('qbx_core')
print("Framework state: " .. state)

-- Check if exports available
local success, hasExport = pcall(function()
    return exports['qbx_core'] ~= nil
end)
print("Exports available: " .. tostring(success and hasExport))
```

### Verify Adapter

```lua
-- Check adapter initialization
if QboxAdapter and QboxAdapter.initialized then
    print("QboxAdapter initialized")
else
    print("QboxAdapter not initialized")
end
```

### Test Exports

```lua
-- Test export availability
local success, result = ErrorHandler.SafeExport('daphne_core', 'GetPlayerData', {source})
if success then
    print("Export works: " .. json.encode(result))
else
    print("Export failed: " .. tostring(result))
end
```

## Common Error Scenarios

### Framework Not Detected

**Error:** `[Daphne Core] WARNING: No supported framework detected!`

**Solution:**
1. Ensure framework is started before daphne_core
2. Check framework resource name matches exactly
3. Verify framework is running: `GetResourceState('framework_name')`

### Export Returns Nil

**Error:** Export returns `nil` or `false`

**Solution:**
1. Check if player is online and loaded
2. Verify framework is initialized
3. Check export syntax: `exports['daphne_core']:FunctionName()`
4. Use ErrorHandler.SafeExport for debugging

### Cache Issues

**Error:** Stale data from cache

**Solution:**
1. Cache automatically invalidates on writes
2. Manually invalidate: `Cache.InvalidatePlayer(source)`
3. Check cache TTL configuration

### State Bag Not Updating

**Error:** State bag values not updating

**Solution:**
1. State bags update on writes, not reads
2. Updates are batched (50ms) and throttled (100ms)
3. Check if write operation succeeded
4. Verify state bag key is correct

### Initialization Failed

**Error:** `[Daphne Core] ERROR: Failed to initialize bridge!`

**Solution:**
1. Check framework resource state
2. Verify framework exports are available
3. Check server console for detailed error messages
4. Ensure framework is started before daphne_core

## Best Practices

### Always Use Safe Calls

```lua
-- Bad: Direct call
local player = Framework:GetPlayer(source)

-- Good: Safe call
local success, player = ErrorHandler.SafeCall(function()
    return Framework:GetPlayer(source)
end)
```

### Check Return Values

```lua
-- Always check return values
local playerData = exports['daphne_core']:GetPlayerData(source)
if not playerData then
    -- Handle error
    return
end

-- Use playerData safely
```

### Handle Nil Values

```lua
-- Always check for nil
local money = exports['daphne_core']:GetMoney(source, 'cash')
if money then
    -- Use money
else
    -- Handle nil case
end
```

### Log Errors

```lua
-- Log errors for debugging
local success, result = ErrorHandler.SafeCall(function()
    return RiskyFunction()
end)

if not success then
    ErrorHandler.Log('error', 'RiskyFunction failed: ' .. tostring(result))
end
```

## Related Documentation

- [API Reference](API_REFERENCE.md) - Export function documentation
- [Integration Guide](INTEGRATION_GUIDE.md) - Integration patterns
- [FAQ](FAQ.md) - Common questions and solutions

