---Proxy Manager
---Manages all framework proxies and their lifecycle
ProxyManager = ProxyManager or {}
local ProxyManager = ProxyManager

---Registered proxies
ProxyManager.proxies = {}

---Enabled proxies
ProxyManager.enabled = {}

---Register a proxy for a framework
---@param framework string Framework name
---@param proxyObject table Proxy object
function ProxyManager.RegisterProxy(framework, proxyObject)
    if not framework or not proxyObject then
        print('[Proxy Manager] ERROR: Cannot register proxy - framework or proxyObject is nil')
        return false
    end
    
    ProxyManager.proxies[framework] = proxyObject
    print(string.format('[Proxy Manager] Registered proxy for framework: %s', framework))
    return true
end

---Get proxy for a framework
---@param framework string Framework name
---@return table|nil proxy Proxy object or nil
function ProxyManager.GetProxy(framework)
    return ProxyManager.proxies[framework]
end

---Check if proxy is enabled for a framework
---@param framework string Framework name
---@return boolean enabled
function ProxyManager.IsProxyEnabled(framework)
    return ProxyManager.enabled[framework] == true
end

---Enable proxy for a framework
---@param framework string Framework name
function ProxyManager.EnableProxy(framework)
    if not ProxyManager.proxies[framework] then
        print(string.format('[Proxy Manager] WARNING: Cannot enable proxy for %s - proxy not registered', framework))
        return false
    end
    
    ProxyManager.enabled[framework] = true
    print(string.format('[Proxy Manager] Enabled proxy for framework: %s', framework))
    return true
end

---Disable proxy for a framework
---@param framework string Framework name
function ProxyManager.DisableProxy(framework)
    ProxyManager.enabled[framework] = false
    print(string.format('[Proxy Manager] Disabled proxy for framework: %s', framework))
    return true
end

---Enable all registered proxies
function ProxyManager.EnableAllProxies()
    for framework, _ in pairs(ProxyManager.proxies) do
        ProxyManager.EnableProxy(framework)
    end
    print('[Proxy Manager] Enabled all registered proxies')
end

---Disable all proxies
function ProxyManager.DisableAllProxies()
    for framework, _ in pairs(ProxyManager.enabled) do
        ProxyManager.DisableProxy(framework)
    end
    print('[Proxy Manager] Disabled all proxies')
end

---Get proxy for a specific framework
---@param framework string Framework name
---@return table|nil proxy Proxy object or nil
function ProxyManager.GetProxyForFramework(framework)
    return ProxyManager.GetProxy(framework)
end

---Check if cross-framework is enabled
---@return boolean enabled
function ProxyManager.IsCrossFrameworkEnabled()
    if not Config or not Config.Proxy then
        return false
    end
    return Config.Proxy.CrossFrameworkEnabled == true
end

---Get active adapter framework
---@return string? framework Active framework name
function ProxyManager.GetActiveAdapter()
    if not Config then
        return nil
    end
    return Config.GetFramework()
end

---Initialize proxies based on configuration
function ProxyManager.InitializeProxies()
    if not Proxy.IsEnabled() then
        print('[Proxy Manager] Proxy system is disabled')
        return
    end
    
    local activeFramework = Config.GetFramework()
    
    if ProxyManager.IsCrossFrameworkEnabled() then
        -- Enable all proxies for cross-framework mode
        ProxyManager.EnableAllProxies()
        print('[Proxy Manager] Cross-framework mode enabled - all proxies active')
    else
        -- Only enable proxy for active framework
        if activeFramework then
            ProxyManager.EnableProxy(activeFramework)
        else
            print('[Proxy Manager] WARNING: No active framework detected')
        end
    end
end

-- Export ProxyManager as global
ProxyManager = ProxyManager

return ProxyManager


