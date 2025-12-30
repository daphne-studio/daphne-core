---Client-side Proxy Initialization
---Initializes client-side proxies

-- Load dependencies (these are loaded via shared_scripts)
if not Config then
    error('[Client Proxy] Config not found!')
end

if not ProxyManager then
    error('[Client Proxy] ProxyManager not found!')
end

if not QBCoreProxy then
    error('[Client Proxy] QBCoreProxy not found!')
end

if not ESXProxy then
    error('[Client Proxy] ESXProxy not found!')
end

if not NDCoreProxy then
    error('[Client Proxy] NDCoreProxy not found!')
end

---Initialize client-side proxies
local function InitializeClientProxies()
    -- Initialize Config first
    Config.Initialize()
    
    -- Check if proxy system is enabled
    if not Config.Proxy or not Config.Proxy.Enabled then
        print('[Client Proxy] Proxy system is disabled')
        return
    end
    
    -- Register all proxies
    ProxyManager.RegisterProxy('qbcore', QBCoreProxy)
    ProxyManager.RegisterProxy('esx', ESXProxy)
    ProxyManager.RegisterProxy('nd_core', NDCoreProxy)
    
    -- Initialize proxies
    QBCoreProxy:Initialize()
    ESXProxy:Initialize()
    NDCoreProxy:Initialize()
    
    -- Cross-framework mode initialization
    if Config.Proxy.CrossFrameworkEnabled then
        ProxyManager.EnableAllProxies()
        print('[Client Proxy] Cross-framework proxy mode enabled')
        print('[Client Proxy] Active adapter: ' .. (Config.GetFramework() or 'none'))
    else
        -- Only enable proxy for active framework
        local activeFramework = Config.GetFramework()
        if activeFramework then
            ProxyManager.EnableProxy(activeFramework)
            print(string.format('[Client Proxy] Enabled proxy for active framework: %s', activeFramework))
        end
    end
    
    print('[Client Proxy] Proxy initialization complete')
end

---Initialize on client resource start
AddEventHandler('onClientResourceStart', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        -- Wait a bit for all dependencies to load
        Wait(100)
        InitializeClientProxies()
    end
end)

