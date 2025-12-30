---Framework detection and configuration
Config = Config or {}
local Config = Config

---Supported frameworks
Config.Frameworks = {
    QBOX = 'qbox',
    QBCORE = 'qb-core',
    ESX = 'es_extended',
    OX = 'ox_core',
    ND_CORE = 'nd_core'
}

---Current detected framework
Config.CurrentFramework = nil

---Framework detection priority (order matters)
Config.DetectionOrder = {
    Config.Frameworks.QBOX,
    Config.Frameworks.QBCORE,
    Config.Frameworks.ESX,
    Config.Frameworks.OX,
    Config.Frameworks.ND_CORE
}

---Detect which framework is running
---@return string|nil framework Framework name or nil if none detected
function Config.DetectFramework()
    -- Check for Qbox/QBCore
    if GetResourceState('qbx_core') == 'started' then
        return Config.Frameworks.QBOX
    elseif GetResourceState('qb-core') == 'started' then
        return Config.Frameworks.QBCORE
    end
    
    -- Check for ESX
    if GetResourceState('es_extended') == 'started' then
        return Config.Frameworks.ESX
    end
    
    -- Check for OX
    if GetResourceState('ox_core') == 'started' then
        return Config.Frameworks.OX
    end
    
    -- Check for ND Core
    -- First check exports (most reliable - if export exists, ND Core is available)
    local success, hasNDCore = pcall(function()
        -- Check exports['ND_Core'] first (correct export name)
        -- Just check if export exists and is a table - method check happens in adapter
        if exports['ND_Core'] and type(exports['ND_Core']) == 'table' then
            return true
        end
        -- Check global NDCore variable
        if NDCore and type(NDCore) == 'table' then
            return true
        end
        -- Check lowercase export as fallback
        if exports['nd_core'] and type(exports['nd_core']) == 'table' then
            return true
        end
        return false
    end)
    
    if success and hasNDCore then
        return Config.Frameworks.ND_CORE
    end
    
    -- Also check resource states as secondary check
    if GetResourceState('ND_Core') == 'started' or GetResourceState('ND_Core') == 'starting' then
        return Config.Frameworks.ND_CORE
    elseif GetResourceState('nd_core') == 'started' or GetResourceState('nd_core') == 'starting' then
        return Config.Frameworks.ND_CORE
    elseif GetResourceState('NDCore') == 'started' or GetResourceState('NDCore') == 'starting' then
        return Config.Frameworks.ND_CORE
    end
    
    return nil
end

---Initialize framework detection
function Config.Initialize()
    Config.CurrentFramework = Config.DetectFramework()
    
    if Config.CurrentFramework then
        print(string.format('[Daphne Core] Framework detected: %s', Config.CurrentFramework))
    else
        print('[Daphne Core] WARNING: No supported framework detected!')
        -- Debug: Show resource states
        print('[Daphne Core] Debug - Checking resource states:')
        print(string.format('  qbx_core: %s', GetResourceState('qbx_core')))
        print(string.format('  qb-core: %s', GetResourceState('qb-core')))
        print(string.format('  es_extended: %s', GetResourceState('es_extended')))
        print(string.format('  ox_core: %s', GetResourceState('ox_core')))
        print(string.format('  ND_Core: %s', GetResourceState('ND_Core')))
        print(string.format('  nd_core: %s', GetResourceState('nd_core')))
        print(string.format('  NDCore: %s', GetResourceState('NDCore')))
        -- Check exports
        local hasExport = pcall(function() return exports['ND_Core'] ~= nil end)
        print(string.format('  exports["ND_Core"]: %s', hasExport and 'available' or 'not available'))
    end
end

---Get current framework
---@return string|nil framework Current framework name
function Config.GetFramework()
    return Config.CurrentFramework
end

---Check if specific framework is active
---@param framework string Framework name
---@return boolean isActive True if framework is active
function Config.IsFramework(framework)
    return Config.CurrentFramework == framework
end

---Proxy configuration
Config.Proxy = {
    Enabled = false,  -- Enable proxy system
    CrossFrameworkEnabled = false,  -- Enable cross-framework proxy (all frameworks can proxy to each other)
    OverrideGlobals = false,  -- Override global variables (QBCore, ESX, NDCore)
    OverrideExports = false,  -- Override exports (exports['qb-core'], exports['es_extended'], etc.)
    FallbackToOriginal = false,  -- Fallback to original framework if proxy fails
    LogProxyCalls = false,  -- Log all proxy calls (debug)
    LogCrossFrameworkCalls = false,  -- Log cross-framework calls
    AutoDetectProxyTarget = false,  -- Automatically detect active adapter as proxy target
    ProxyTarget = nil  -- Manual proxy target (nil = auto detect)
}

-- Export Config as global for use in other scripts
Config = Config

return Config

