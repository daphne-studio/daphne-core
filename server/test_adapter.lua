---Adapter Implementation Test Command
---Tests all adapter implementations against Bridge interface

-- These modules are loaded via shared_scripts, so they're available as globals
if not Bridge then
    error('[Test Adapter] Bridge not found! Make sure core/bridge.lua is loaded.')
end

---Required Bridge methods to test
local RequiredMethods = {
    'Initialize',
    'GetPlayer',
    'GetPlayerData',
    'GetMoney',
    'AddMoney',
    'RemoveMoney',
    'GetInventory',
    'GetJob',
    'GetVehicle'
}

---Test result structure
local TestResult = {
    method = '',
    status = '', -- 'ok', 'missing', 'not_overridden', 'error'
    message = ''
}

---Check if a method is overridden (not just inheriting from Bridge)
---@param adapter table Adapter instance
---@param methodName string Method name
---@return boolean isOverridden True if method is overridden
local function IsMethodOverridden(adapter, methodName)
    -- Check if method exists in adapter itself (not just in metatable chain)
    local adapterMethod = rawget(adapter, methodName)
    if adapterMethod and type(adapterMethod) == 'function' then
        -- Method is directly defined in adapter, so it's overridden
        return true
    end
    
    -- Check if method exists through metatable lookup
    if adapter[methodName] and type(adapter[methodName]) == 'function' then
        -- Compare function references - if they're different, it's overridden
        local bridgeMethod = Bridge[methodName]
        if bridgeMethod then
            -- If the function reference is different, it's overridden
            if adapter[methodName] ~= bridgeMethod then
                return true
            end
        else
            -- Method exists but Bridge doesn't have it (shouldn't happen, but handle it)
            return true
        end
    end
    
    -- Try to detect override by attempting to call and checking error message
    -- This is a fallback for methods that might be defined in a way we can't detect
    if methodName ~= 'Initialize' then
        -- For non-Initialize methods, we can't safely test without parameters
        -- But if we got here and the method exists, it's likely overridden
        -- (since Bridge methods throw errors immediately)
        return adapter[methodName] ~= nil
    end
    
    return false
end

---Test a single method on an adapter
---@param adapter table Adapter instance
---@param adapterName string Adapter name
---@param methodName string Method name to test
---@return TestResult result Test result
local function TestMethod(adapter, adapterName, methodName)
    local result = {
        method = methodName,
        status = '',
        message = ''
    }
    
    -- Check if method exists
    if not adapter[methodName] then
        result.status = 'missing'
        result.message = 'Method does not exist'
        return result
    end
    
    -- Check if method is a function
    if type(adapter[methodName]) ~= 'function' then
        result.status = 'error'
        result.message = 'Method exists but is not a function'
        return result
    end
    
    -- Always test by actually calling the method and checking the error message
    -- This is the most reliable way to detect if Bridge base method is being called
    local success, err = pcall(function()
        if methodName == 'Initialize' then
            adapter:Initialize()
        elseif methodName == 'GetPlayer' then
            adapter:GetPlayer(0) -- Test with source 0 (invalid but safe)
        elseif methodName == 'GetPlayerData' then
            adapter:GetPlayerData(0) -- Test with source 0
        elseif methodName == 'GetMoney' then
            adapter:GetMoney(0, 'cash') -- Test with source 0
        elseif methodName == 'AddMoney' then
            adapter:AddMoney(0, 'cash', 0) -- Test with source 0, amount 0
        elseif methodName == 'RemoveMoney' then
            adapter:RemoveMoney(0, 'cash', 0) -- Test with source 0, amount 0
        elseif methodName == 'GetInventory' then
            adapter:GetInventory(0) -- Test with source 0
        elseif methodName == 'GetJob' then
            adapter:GetJob(0) -- Test with source 0
        elseif methodName == 'GetVehicle' then
            adapter:GetVehicle(0) -- Test with vehicle 0 (invalid but safe)
        end
    end)
    
    if not success then
        local errStr = tostring(err)
        -- Check if error is the Bridge base error
        if string.find(errStr, 'must be implemented by adapter') or string.find(errStr, 'Bridge:' .. methodName) then
            result.status = 'not_overridden'
            result.message = 'Method calls Bridge base implementation (not overridden) - Error: ' .. errStr
            return result
        else
            -- Method is implemented but may have failed for other reasons
            -- (e.g., invalid parameters, framework not running, player not found)
            result.status = 'ok'
            result.message = 'Method implemented (test call failed but not Bridge error: ' .. string.sub(errStr, 1, 100) .. ')'
            return result
        end
    else
        -- Method call succeeded (or returned nil gracefully without error)
        result.status = 'ok'
        result.message = 'Method implemented and callable'
        return result
    end
    
    return result
end

---Test all methods for an adapter
---@param adapter table Adapter instance or class
---@param adapterName string Adapter name
---@return table results Array of TestResult
local function TestAdapter(adapter, adapterName)
    print(string.format('[Daphne Core] Testing %s...', adapterName))
    
    -- Debug: Check adapter type
    local adapterType = type(adapter)
    local hasMetatable = getmetatable(adapter) ~= nil
    print(string.format('[Daphne Core]   Adapter type: %s, has metatable: %s', adapterType, tostring(hasMetatable)))
    
    local results = {}
    local passed = 0
    local failed = 0
    
    for _, methodName in ipairs(RequiredMethods) do
        local result = TestMethod(adapter, adapterName, methodName)
        table.insert(results, result)
        
        -- Print result
        local statusSymbol = '✓'
        local statusColor = '^2' -- Green
        if result.status == 'missing' then
            statusSymbol = '✗'
            statusColor = '^1' -- Red
            failed = failed + 1
        elseif result.status == 'not_overridden' then
            statusSymbol = '⚠'
            statusColor = '^3' -- Yellow
            failed = failed + 1
        elseif result.status == 'error' then
            statusSymbol = '✗'
            statusColor = '^1' -- Red
            failed = failed + 1
        else
            passed = passed + 1
        end
        
        print(string.format('%s[Daphne Core] %s %s%s() - %s', 
            statusColor, statusSymbol, result.method, statusColor == '^2' and '' or '^7', result.message))
    end
    
    print(string.format('[Daphne Core] %s: %d/%d methods implemented', adapterName, passed, #RequiredMethods))
    
    return results
end

---Run tests for all adapters
local function RunTests()
    print('[Daphne Core] === Adapter Implementation Test ===')
    print('')
    
    local allResults = {}
    local totalPassed = 0
    local totalFailed = 0
    
    -- Test ESXAdapter
    if ESXAdapter then
        local results = TestAdapter(ESXAdapter, 'ESXAdapter')
        allResults['ESXAdapter'] = results
        
        for _, result in ipairs(results) do
            if result.status == 'ok' then
                totalPassed = totalPassed + 1
            else
                totalFailed = totalFailed + 1
            end
        end
    else
        print('[Daphne Core] ⚠ ESXAdapter not found (may not be loaded)')
    end
    
    print('')
    
    -- Test QboxAdapter
    if QboxAdapter then
        local results = TestAdapter(QboxAdapter, 'QboxAdapter')
        allResults['QboxAdapter'] = results
        
        for _, result in ipairs(results) do
            if result.status == 'ok' then
                totalPassed = totalPassed + 1
            else
                totalFailed = totalFailed + 1
            end
        end
    else
        print('[Daphne Core] ⚠ QboxAdapter not found (may not be loaded)')
    end
    
    print('')
    
    -- Test Bridge export system (how it's actually used at runtime)
    -- Note: server/bridge.lua exports Bridge as global, which should override core/bridge.lua
    print('[Daphne Core] Testing Bridge export system (runtime usage)...')
    
    -- Check which Bridge is being used
    if Bridge and type(Bridge) == 'table' then
        -- Check if this is the abstract Bridge (core/bridge.lua) or export Bridge (server/bridge.lua)
        -- Abstract Bridge throws error immediately, export Bridge calls GetAdapter first
        local success, err = pcall(function()
            Bridge:GetPlayerData(0)
        end)
        
        if not success then
            local errStr = tostring(err)
            -- Check if error is from core/bridge.lua (abstract Bridge)
            if string.find(errStr, 'must be implemented by adapter') or string.find(errStr, '@daphne_core/core/bridge.lua') then
                print('[Daphne Core] ✗ CRITICAL: Bridge:GetPlayerData() calls abstract Bridge base method')
                print('[Daphne Core]   This means server/bridge.lua Bridge export is NOT loaded or NOT overriding core Bridge')
                print(string.format('[Daphne Core]   Error location: %s', errStr))
                print('')
                print('[Daphne Core]   DIAGNOSIS:')
                print('[Daphne Core]   - core/bridge.lua is loaded via shared_scripts')
                print('[Daphne Core]   - server/bridge.lua should override Bridge global via server_scripts')
                print('[Daphne Core]   - But server/bridge.lua Bridge export is not being used')
                print('')
                print('[Daphne Core]   POSSIBLE CAUSES:')
                print('[Daphne Core]   1. server/bridge.lua is not in server_scripts in fxmanifest.lua')
                print('[Daphne Core]   2. server/bridge.lua loads before core/bridge.lua (should load after)')
                print('[Daphne Core]   3. Bridge global assignment in server/bridge.lua is not executing')
                print('')
                
                -- Check adapter availability
                local framework = Config and Config.GetFramework and Config.GetFramework()
                print(string.format('[Daphne Core]   Current framework: %s', framework or 'none detected'))
                if framework == Config.Frameworks.QBOX or framework == Config.Frameworks.QBCORE then
                    if QboxAdapter then
                        print('[Daphne Core]   ✓ QboxAdapter is available')
                    else
                        print('[Daphne Core]   ✗ QboxAdapter is NOT available')
                    end
                elseif framework == Config.Frameworks.ESX then
                    if ESXAdapter then
                        print('[Daphne Core]   ✓ ESXAdapter is available')
                    else
                        print('[Daphne Core]   ✗ ESXAdapter is NOT available')
                    end
                end
                
                -- Mark this as a failure
                totalFailed = totalFailed + 1
            else
                -- Error from adapter or framework (not Bridge base error)
                print('[Daphne Core] ✓ Bridge:GetPlayerData() uses export Bridge (error from adapter/framework, not Bridge base)')
                print(string.format('[Daphne Core]   Error: %s', string.sub(errStr, 1, 150)))
            end
        else
            print('[Daphne Core] ✓ Bridge:GetPlayerData() uses export Bridge and is callable')
        end
    else
        print('[Daphne Core] ⚠ Bridge export not found or not a table')
        totalFailed = totalFailed + 1
    end
    
    print('')
    print('[Daphne Core] === Test Summary ===')
    print(string.format('[Daphne Core] Total: %d passed, %d failed', totalPassed, totalFailed))
    
    -- Print detailed failure report
    if totalFailed > 0 then
        print('')
        print('[Daphne Core] === Failure Details ===')
        for adapterName, results in pairs(allResults) do
            local hasFailures = false
            for _, result in ipairs(results) do
                if result.status ~= 'ok' then
                    if not hasFailures then
                        print(string.format('[Daphne Core] %s:', adapterName))
                        hasFailures = true
                    end
                    print(string.format('  ✗ %s() - %s: %s', result.method, result.status, result.message))
                end
            end
        end
    end
    
    print('')
    print('[Daphne Core] === Test Complete ===')
end

---Register test command
RegisterCommand('testadapter', function(source, args, rawCommand)
    RunTests()
end, true) -- true = restricted (admin only)

RegisterCommand('testbridge', function(source, args, rawCommand)
    RunTests()
end, true) -- true = restricted (admin only)

-- Also allow console execution
AddEventHandler('onResourceStart', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        -- Optionally run tests automatically on resource start (commented out by default)
        -- Uncomment the line below to enable auto-testing on resource start
        -- RunTests()
    end
end)

