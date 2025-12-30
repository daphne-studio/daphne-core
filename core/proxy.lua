---Proxy Core Module
---Base proxy functionality and utilities
Proxy = Proxy or {}
local Proxy = Proxy

---Check if proxy system is enabled
---@return boolean enabled
function Proxy.IsEnabled()
    if not Config or not Config.Proxy then
        return false
    end
    return Config.Proxy.Enabled == true
end

---Log proxy call if logging is enabled
---@param framework string Framework name
---@param method string Method name
---@param args table Arguments
function Proxy.LogCall(framework, method, args)
    if not Config or not Config.Proxy then
        return
    end
    
    if Config.Proxy.LogProxyCalls then
        -- Simple args representation (json.encode may not be available)
        local argsStr = ''
        if args then
            local parts = {}
            for i, v in ipairs(args) do
                table.insert(parts, tostring(v))
            end
            argsStr = table.concat(parts, ', ')
        end
        print(string.format('[Proxy] %s.%s called with args: %s', framework, method, argsStr))
    end
end

---Log cross-framework call if logging is enabled
---@param fromFramework string Source framework
---@param toFramework string Target framework
---@param method string Method name
function Proxy.LogCrossFrameworkCall(fromFramework, toFramework, method)
    if not Config or not Config.Proxy then
        return
    end
    
    if Config.Proxy.LogCrossFrameworkCalls then
        print(string.format('[Proxy] Cross-framework call: %s.%s → %s', fromFramework, method, toFramework))
    end
end

---Get active adapter framework
---@return string? framework Active framework name
function Proxy.GetActiveAdapter()
    if not Config then
        return nil
    end
    return Config.GetFramework()
end

---Check if cross-framework mode is enabled
---@return boolean enabled
function Proxy.IsCrossFrameworkEnabled()
    if not Config or not Config.Proxy then
        return false
    end
    return Config.Proxy.CrossFrameworkEnabled == true
end

-- Export Proxy as global
Proxy = Proxy

return Proxy

