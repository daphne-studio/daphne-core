---Server-side Proxy Initialization
---Initializes all proxies on server start

-- Load dependencies (these are loaded via shared_scripts)
if not Config then
    error('[Server Proxy] Config not found!')
end

if not ProxyManager then
    error('[Server Proxy] ProxyManager not found!')
end

if not QBCoreProxy then
    error('[Server Proxy] QBCoreProxy not found!')
end

if not ESXProxy then
    error('[Server Proxy] ESXProxy not found!')
end

if not NDCoreProxy then
    error('[Server Proxy] NDCoreProxy not found!')
end

---Override global variables
local function OverrideGlobalVariables()
    if not Config.Proxy or not Config.Proxy.OverrideGlobals then
        return
    end
    
    -- QBCore proxy will handle its own global override
    -- ESX proxy will handle its own global override
    -- ND_Core proxy will handle its own global override
    
    print('[Server Proxy] Global variable override enabled')
end

---Override exports
local function OverrideExports()
    if not Config.Proxy or not Config.Proxy.OverrideExports then
        return
    end
    
    -- QBCore proxy will handle its own export override
    -- ESX proxy will handle its own export override
    -- ND_Core proxy will handle its own export override
    
    print('[Server Proxy] Export override enabled')
end

---Initialize all proxies
local function InitializeProxies()
    -- Initialize Config first
    Config.Initialize()
    
    -- Check if proxy system is enabled
    if not Config.Proxy or not Config.Proxy.Enabled then
        print('[Server Proxy] Proxy system is disabled')
        return
    end
    
    -- Register all proxies
    ProxyManager.RegisterProxy('qbcore', QBCoreProxy)
    ProxyManager.RegisterProxy('esx', ESXProxy)
    ProxyManager.RegisterProxy('nd_core', NDCoreProxy)
    -- OX proxy will be added when OX Core adapter is implemented
    
    -- Initialize proxies
    QBCoreProxy:Initialize()
    ESXProxy:Initialize()
    NDCoreProxy:Initialize()
    
    -- Cross-framework mode initialization
    if Config.Proxy.CrossFrameworkEnabled then
        ProxyManager.EnableAllProxies()
        print('[Server Proxy] Cross-framework proxy mode enabled')
        print('[Server Proxy] Active adapter: ' .. (Config.GetFramework() or 'none'))
        print('[Server Proxy] QBCore scripts can run on: ' .. (Config.GetFramework() or 'none'))
        print('[Server Proxy] ESX scripts can run on: ' .. (Config.GetFramework() or 'none'))
        print('[Server Proxy] ND_Core scripts can run on: ' .. (Config.GetFramework() or 'none'))
    else
        -- Only enable proxy for active framework
        local activeFramework = Config.GetFramework()
        if activeFramework then
            ProxyManager.EnableProxy(activeFramework)
            print(string.format('[Server Proxy] Enabled proxy for active framework: %s', activeFramework))
        else
            print('[Server Proxy] WARNING: No active framework detected')
        end
    end
    
    -- Override globals and exports
    OverrideGlobalVariables()
    OverrideExports()
    
    print('[Server Proxy] Proxy initialization complete')
end

---Initialize on resource start
AddEventHandler('onResourceStart', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        -- Wait a bit for all dependencies to load
        Wait(100)
        InitializeProxies()
    end
end)

---Retry initialization if framework starts after daphne_core
AddEventHandler('onResourceStart', function(resourceName)
    if resourceName == 'qbx_core' or resourceName == 'qb-core' or 
       resourceName == 'es_extended' or 
       resourceName == 'ND_Core' or resourceName == 'nd_core' or resourceName == 'NDCore' then
        -- Wait a bit for framework to fully initialize
        Wait(500)
        if Config.Proxy and Config.Proxy.Enabled then
            print(string.format('[Server Proxy] Framework resource %s started, reinitializing proxies...', resourceName))
            InitializeProxies()
        end
    end
end)

