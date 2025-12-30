---Framework detection and configuration
Config = Config or {}
local Config = Config

---Supported frameworks
Config.Frameworks = {
    QBOX = 'qbox',
    QBCORE = 'qb-core',
    ESX = 'es_extended',
    OX = 'ox_core'
}

---Current detected framework
Config.CurrentFramework = nil

---Framework detection priority (order matters)
Config.DetectionOrder = {
    Config.Frameworks.QBOX,
    Config.Frameworks.QBCORE,
    Config.Frameworks.ESX,
    Config.Frameworks.OX
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
    
    return nil
end

---Initialize framework detection
function Config.Initialize()
    Config.CurrentFramework = Config.DetectFramework()
    
    if Config.CurrentFramework then
        print(string.format('[Daphne Core] Framework detected: %s', Config.CurrentFramework))
    else
        print('[Daphne Core] WARNING: No supported framework detected!')
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

-- Export Config as global for use in other scripts
Config = Config

return Config

