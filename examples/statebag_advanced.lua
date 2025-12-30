---Advanced State Bag Usage Examples
---This file demonstrates advanced state bag usage patterns

-- Example 1: Custom state bag watcher with debouncing
local function CreateDebouncedWatcher(key, callback, delay)
    delay = delay or 500
    local lastCall = 0
    local lastValue = nil
    
    return exports['daphne_core']:WatchPlayerStateBag(key, function(value, oldValue)
        local now = GetGameTimer()
        
        -- Debounce: only call callback if enough time has passed
        if now - lastCall >= delay then
            callback(value, oldValue, lastValue)
            lastValue = value
            lastCall = now
        end
    end)
end

-- Usage:
-- CreateDebouncedWatcher('money', function(value, oldValue, lastValue)
--     print('Money changed (debounced)')
-- end, 1000)

-- Example 2: Watch multiple state bag keys
local function WatchMultipleKeys(keys, callback)
    local watchers = {}
    local values = {}
    
    for _, key in ipairs(keys) do
        values[key] = exports['daphne_core']:GetPlayerStateBag(key)
        watchers[key] = exports['daphne_core']:WatchPlayerStateBag(key, function(value, oldValue)
            values[key] = value
            callback(key, value, oldValue, values)
        end)
    end
    
    return watchers, values
end

-- Usage:
-- local watchers, values = WatchMultipleKeys({'money', 'job'}, function(key, value, oldValue, allValues)
--     print(string.format('%s changed', key))
--     if allValues.money and allValues.job then
--         print('Both money and job are available')
--     end
-- end)

-- Example 3: State bag cache with TTL (Time To Live)
local StateBagCache = {}
StateBagCache._cache = {}
StateBagCache._ttl = 5000 -- 5 seconds

function StateBagCache.Get(key, ttl)
    ttl = ttl or StateBagCache._ttl
    local cacheKey = key
    local cached = StateBagCache._cache[cacheKey]
    
    if cached and (GetGameTimer() - cached.timestamp) < ttl then
        return cached.value
    end
    
    -- Cache miss or expired, get fresh value
    local value = exports['daphne_core']:GetPlayerStateBag(key)
    StateBagCache._cache[cacheKey] = {
        value = value,
        timestamp = GetGameTimer()
    }
    
    return value
end

function StateBagCache.Clear(key)
    if key then
        StateBagCache._cache[key] = nil
    else
        StateBagCache._cache = {}
    end
end

-- Usage:
-- local money = StateBagCache.Get('money', 3000) -- Cache for 3 seconds
-- StateBagCache.Clear('money') -- Clear specific key
-- StateBagCache.Clear() -- Clear all cache

-- Example 4: State bag change aggregator
local ChangeAggregator = {}
ChangeAggregator._changes = {}
ChangeAggregator._interval = 1000

function ChangeAggregator.Watch(key, callback)
    return exports['daphne_core']:WatchPlayerStateBag(key, function(value, oldValue)
        if not ChangeAggregator._changes[key] then
            ChangeAggregator._changes[key] = {}
        end
        
        table.insert(ChangeAggregator._changes[key], {
            value = value,
            oldValue = oldValue,
            timestamp = GetGameTimer()
        })
    end)
end

function ChangeAggregator.Process(callback)
    if not ChangeAggregator._timer then
        ChangeAggregator._timer = SetInterval(function()
            if next(ChangeAggregator._changes) then
                callback(ChangeAggregator._changes)
                ChangeAggregator._changes = {}
            end
        end, ChangeAggregator._interval)
    end
end

function ChangeAggregator.Stop()
    if ChangeAggregator._timer then
        ClearInterval(ChangeAggregator._timer)
        ChangeAggregator._timer = nil
    end
end

-- Usage:
-- ChangeAggregator.Watch('money', function() end) -- Watch for changes
-- ChangeAggregator.Process(function(changes)
--     -- Process all changes at once every second
--     for key, changeList in pairs(changes) do
--         print(string.format('%s had %d changes', key, #changeList))
--     end
-- end)

-- Example 5: State bag validator
local StateBagValidator = {}

function StateBagValidator.ValidateMoney(value)
    if not value then return false end
    if type(value.cash) ~= 'number' or value.cash < 0 then return false end
    if type(value.bank) ~= 'number' or value.bank < 0 then return false end
    return true
end

function StateBagValidator.ValidateJob(value)
    if not value then return false end
    if not value.name or type(value.name) ~= 'string' then return false end
    if not value.grade or not value.grade.level then return false end
    return true
end

function StateBagValidator.WatchWithValidation(key, validator, callback)
    return exports['daphne_core']:WatchPlayerStateBag(key, function(value, oldValue)
        if validator(value) then
            callback(value, oldValue)
        else
            print(string.format('[Validator] Invalid value for %s', key))
        end
    end)
end

-- Usage:
-- StateBagValidator.WatchWithValidation('money', StateBagValidator.ValidateMoney, function(value, oldValue)
--     print('Valid money data received')
-- end)

