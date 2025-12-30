---Base Proxy Class
---Base class for all framework proxies
BaseProxy = BaseProxy or {}
local BaseProxy = BaseProxy
BaseProxy.__index = BaseProxy

---Create a new proxy instance
---@param frameworkName string Framework name
---@param apiMappings table API mappings table
---@return table proxy Proxy instance
function BaseProxy:new(frameworkName, apiMappings)
    local proxy = {}
    proxy.frameworkName = frameworkName
    proxy.apiMappings = apiMappings or {}
    proxy.apiMapper = APIMapper
    proxy.dataConverter = DataConverter
    -- Set metatable with __index pointing to BaseProxy
    setmetatable(proxy, {__index = BaseProxy})
    return proxy
end

---Map framework API call to Daphne-Core API
---@param method string Framework API method name
---@param ... any Arguments for the API call
---@return string? daphneMethod Mapped Daphne-Core method name
---@return table? mappedArgs Mapped arguments
function BaseProxy:MapToDaphne(method, ...)
    local args = {...}
    
    -- Use appropriate mapper based on framework
    if self.frameworkName == 'qbcore' or self.frameworkName == 'qbox' then
        return self.apiMapper.MapQBCoreToDaphne(method, args)
    elseif self.frameworkName == 'esx' then
        return self.apiMapper.MapESXToDaphne(method, args)
    elseif self.frameworkName == 'nd_core' then
        return self.apiMapper.MapNDCoreToDaphne(method, args)
    elseif self.frameworkName == 'ox' then
        return self.apiMapper.MapOXToDaphne(method, args)
    end
    
    return nil, nil
end

---Convert Daphne-Core data to framework format
---@param data table Daphne-Core normalized data
---@param targetFormat string Target framework format
---@return table? convertedData Converted data
function BaseProxy:ConvertFromDaphne(data, targetFormat)
    targetFormat = targetFormat or self.frameworkName
    
    if targetFormat == 'qbcore' or targetFormat == 'qbox' then
        return self.dataConverter.ToQBCorePlayer(data, data.source)
    elseif targetFormat == 'esx' then
        return self.dataConverter.ToESXPlayer(data, data.source)
    elseif targetFormat == 'nd_core' then
        return self.dataConverter.ToNDCorePlayer(data, data.source)
    elseif targetFormat == 'ox' then
        return self.dataConverter.ToOXPlayer(data, data.source)
    end
    
    return data
end

---Call Daphne-Core export function
---@param method string Daphne-Core method name
---@param ... any Arguments
---@return any result Result from Daphne-Core
function BaseProxy:CallDaphne(method, ...)
    local args = {...}
    
    -- Log the call if enabled
    if Proxy then
        Proxy.LogCall(self.frameworkName, method, args)
    end
    
    -- Call daphne-core export
    local success, result = pcall(function()
        if exports['daphne_core'] and exports['daphne_core'][method] then
            return exports['daphne_core'][method](table.unpack(args))
        end
        return nil
    end)
    
    if not success then
        print(string.format('[Proxy] ERROR: Failed to call daphne-core:%s - %s', method, tostring(result)))
        return nil
    end
    
    return result
end

---Get active adapter framework
---@return string? framework Active framework name
function BaseProxy:GetActiveAdapter()
    return Proxy and Proxy.GetActiveAdapter() or (Config and Config.GetFramework())
end

---Check if cross-framework mode is enabled
---@return boolean enabled
function BaseProxy:IsCrossFrameworkEnabled()
    return Proxy and Proxy.IsCrossFrameworkEnabled() or false
end

---Initialize proxy (to be overridden by subclasses)
---@return boolean success
function BaseProxy:Initialize()
    -- Default implementation - does nothing
    -- Subclasses should override this
    return true
end

-- Export BaseProxy as global
BaseProxy = BaseProxy

return BaseProxy

