---State Bag Manager - Performance optimized
---Handles state bag updates with batching, throttling, and change detection
StateBag = StateBag or {}
local StateBag = StateBag
StateBag.__index = StateBag

---State bag update queue
StateBag._updateQueue = {}
StateBag._updateTimer = nil
StateBag._lastUpdate = 0

---Configuration
StateBag.Config = {
    -- Batch update interval (ms) - updates are batched together
    BatchInterval = 50,
    
    -- Minimum time between updates for same entity (ms) - throttling
    ThrottleInterval = 100,
    
    -- Maximum batch size
    MaxBatchSize = 50,
    
    -- State bag prefix
    Prefix = 'daphne'
}

---Entity state bag cache
StateBag._cache = {}

---Pending updates per entity
StateBag._pendingUpdates = {}

---Deep comparison helper function (optimized)
---Performs shallow comparison first, then selective deep comparison
---@param a any First value
---@param b any Second value
---@param depth number? Maximum depth for deep comparison (default: 3)
---@param visited table? Visited references to prevent circular references
---@return boolean areEqual True if values are equal
local function DeepEqual(a, b, depth, visited)
    depth = depth or 3
    visited = visited or {}
    
    -- Shallow comparison first (fast path)
    if a == b then
        return true
    end
    
    -- Type check
    local typeA = type(a)
    local typeB = type(b)
    if typeA ~= typeB then
        return false
    end
    
    -- If depth limit reached, fall back to reference comparison
    if depth <= 0 then
        return a == b
    end
    
    -- Handle tables
    if typeA == 'table' then
        -- Check for circular references
        if visited[a] and visited[a] == b then
            return true
        end
        visited[a] = b
        
        -- Count keys in both tables
        local countA = 0
        local countB = 0
        for _ in pairs(a) do countA = countA + 1 end
        for _ in pairs(b) do countB = countB + 1 end
        
        if countA ~= countB then
            return false
        end
        
        -- Compare each key-value pair
        for key, valueA in pairs(a) do
            local valueB = b[key]
            if valueB == nil then
                return false
            end
            
            -- Recursive comparison with reduced depth
            if not DeepEqual(valueA, valueB, depth - 1, visited) then
                return false
            end
        end
        
        return true
    end
    
    -- For other types, use simple equality
    return a == b
end

---Get state bag name for entity
---@param entityType string Entity type (player, vehicle, object)
---@param entityId number|string Entity ID
---@param key string State bag key
---@return string stateBagName Full state bag name
function StateBag.GetStateBagName(entityType, entityId, key)
    -- State bag names use format: prefix:type:id:key
    return string.format('%s:%s:%s:%s', StateBag.Config.Prefix, entityType, tostring(entityId), key)
end

---Get entity state bag
---@param entityType string Entity type (player, vehicle, object)
---@param entityId number|string Entity ID
---@param key string State bag key
---@return table|nil stateBag State bag object or nil
function StateBag.GetStateBag(entityType, entityId, key)
    local entity = nil
    
    if entityType == 'player' then
        -- For players, we need to get the ped from source
        if IsDuplicityVersion() then
            -- Server-side: get ped from source
            entity = GetPlayerPed(entityId)
        else
            -- Client-side: use local ped
            entity = PlayerPedId()
        end
        if entity and entity ~= 0 then
            return Entity(entity).state
        end
    elseif entityType == 'vehicle' then
        if type(entityId) == 'number' and DoesEntityExist(entityId) then
            return Entity(entityId).state
        end
    elseif entityType == 'object' then
        if type(entityId) == 'number' and DoesEntityExist(entityId) then
            return Entity(entityId).state
        end
    end
    
    return nil
end

---Set state bag value (queued for batch update)
---@param entityType string Entity type (player, vehicle, object)
---@param entityId number|string Entity ID
---@param key string State bag key
---@param value any Value to set
---@param immediate boolean? If true, update immediately (bypass queue)
function StateBag.SetStateBag(entityType, entityId, key, value, immediate)
    local stateBagName = StateBag.GetStateBagName(entityType, entityId, key)
    local cacheKey = string.format('%s:%s:%s', entityType, entityId, key)
    
    -- Change detection - skip if value hasn't changed
    -- Optimized: Uses shallow comparison first, then selective deep comparison
    -- This is much faster than JSON encoding for large tables
    if StateBag._cache[cacheKey] ~= nil then
        local cachedValue = StateBag._cache[cacheKey]
        if DeepEqual(cachedValue, value) then
            return -- No change, skip update
        end
    end
    
    -- Update cache
    StateBag._cache[cacheKey] = value
    
    if immediate then
        -- Immediate update
        local stateBag = StateBag.GetStateBag(entityType, entityId, key)
        if stateBag then
            -- Set state bag value with replication
            if IsDuplicityVersion() then
                -- Server-side: use set method with replication
                stateBag:set(stateBagName, value, true)
            else
                -- Client-side: direct assignment
                stateBag[stateBagName] = value
            end
        end
        return
    end
    
    -- Queue update
    if not StateBag._pendingUpdates[cacheKey] then
        StateBag._pendingUpdates[cacheKey] = {
            entityType = entityType,
            entityId = entityId,
            key = key,
            value = value,
            timestamp = GetGameTimer()
        }
    else
        -- Update existing pending update
        StateBag._pendingUpdates[cacheKey].value = value
        StateBag._pendingUpdates[cacheKey].timestamp = GetGameTimer()
    end
    
    -- Start batch timer if not running
    if not StateBag._updateTimer then
        StateBag._updateTimer = SetTimeout(StateBag.Config.BatchInterval, function()
            StateBag.ProcessBatch()
        end)
    end
end

---Process batched updates
function StateBag.ProcessBatch()
    StateBag._updateTimer = nil
    
    local now = GetGameTimer()
    local updatesToProcess = {}
    local count = 0
    
    -- Collect updates that are ready (throttled)
    for cacheKey, update in pairs(StateBag._pendingUpdates) do
        local timeSinceUpdate = now - update.timestamp
        
        -- Check throttle interval
        if timeSinceUpdate >= StateBag.Config.ThrottleInterval or count < StateBag.Config.MaxBatchSize then
            table.insert(updatesToProcess, update)
            StateBag._pendingUpdates[cacheKey] = nil
            count = count + 1
            
            if count >= StateBag.Config.MaxBatchSize then
                break
            end
        end
    end
    
    -- Process updates
    for _, update in ipairs(updatesToProcess) do
        local stateBag = StateBag.GetStateBag(update.entityType, update.entityId, update.key)
        if stateBag then
            local stateBagName = StateBag.GetStateBagName(update.entityType, update.entityId, update.key)
            -- Set with replication on server-side
            if IsDuplicityVersion() then
                -- Server-side: use set method with replication
                stateBag:set(stateBagName, update.value, true)
            else
                -- Client-side: direct assignment (read-only on client)
                stateBag[stateBagName] = update.value
            end
        end
    end
    
    -- Schedule next batch if there are pending updates
    if next(StateBag._pendingUpdates) then
        StateBag._updateTimer = SetTimeout(StateBag.Config.BatchInterval, function()
            StateBag.ProcessBatch()
        end)
    end
    
    StateBag._lastUpdate = now
end

---Clear state bag cache
---@param entityType string? Entity type (optional, clears all if nil)
---@param entityId number|string? Entity ID (optional)
---@param key string? State bag key (optional)
function StateBag.ClearCache(entityType, entityId, key)
    if not entityType then
        StateBag._cache = {}
        return
    end
    
    if not entityId then
        -- Clear all for entity type
        for cacheKey, _ in pairs(StateBag._cache) do
            if cacheKey:match('^' .. entityType .. ':') then
                StateBag._cache[cacheKey] = nil
            end
        end
        return
    end
    
    if not key then
        -- Clear all for entity
        local prefix = string.format('%s:%s:', entityType, entityId)
        for cacheKey, _ in pairs(StateBag._cache) do
            if cacheKey:match('^' .. prefix) then
                StateBag._cache[cacheKey] = nil
            end
        end
        return
    end
    
    -- Clear specific cache entry
    local cacheKey = string.format('%s:%s:%s', entityType, entityId, key)
    StateBag._cache[cacheKey] = nil
end

---Watch state bag changes
---@param entityType string Entity type
---@param entityId number|string Entity ID
---@param key string State bag key
---@param callback fun(value: any, oldValue: any) Callback function
---@return function unwatch Unwatch function
function StateBag.WatchStateBag(entityType, entityId, key, callback)
    local stateBagName = StateBag.GetStateBagName(entityType, entityId, key)
    
    -- Get initial value
    local stateBag = StateBag.GetStateBag(entityType, entityId, key)
    local lastValue = nil
    if stateBag then
        lastValue = stateBag[stateBagName]
    end
    
    -- Add state bag change handler
    AddStateBagChangeHandler(stateBagName, nil, function(bagName, key, value, reserved, replicated)
        local oldValue = lastValue
        lastValue = value
        callback(value, oldValue)
    end)
    
    return function()
        -- Unwatch functionality (state bag handlers can't be removed, but we can ignore)
        -- In practice, this is a no-op but provides API consistency
    end
end

-- Export StateBag as global for use in other scripts
StateBag = StateBag

return StateBag

