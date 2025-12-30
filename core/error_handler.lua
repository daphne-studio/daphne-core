---Error Handler Module
---Provides consistent error handling and pcall wrapper
ErrorHandler = ErrorHandler or {}
local ErrorHandler = ErrorHandler

---Configuration
ErrorHandler.Config = {
    -- Enable error logging
    LogErrors = true,
    
    -- Log level: 'error', 'warn', 'info', 'debug'
    LogLevel = 'error'
}

---Safe pcall wrapper with error logging
---@param func function Function to execute
---@param errorMessage string? Custom error message (optional)
---@return boolean success True if function executed successfully
---@return any result Function result or error message
function ErrorHandler.SafeCall(func, errorMessage)
    if type(func) ~= 'function' then
        if ErrorHandler.Config.LogErrors then
            print(string.format('[ErrorHandler] Invalid function provided: %s', tostring(func)))
        end
        return false, 'Invalid function'
    end
    
    local success, result = pcall(func)
    
    if not success then
        local errorMsg = errorMessage or 'Function execution failed'
        if ErrorHandler.Config.LogErrors then
            print(string.format('[ErrorHandler] %s: %s', errorMsg, tostring(result)))
        end
        return false, result
    end
    
    return true, result
end

---Safe pcall wrapper that returns nil on error
---@param func function Function to execute
---@param errorMessage string? Custom error message (optional)
---@return any result Function result or nil on error
function ErrorHandler.SafeCallNil(func, errorMessage)
    local success, result = ErrorHandler.SafeCall(func, errorMessage)
    if success then
        return result
    end
    return nil
end

---Safe export call wrapper
---@param resourceName string Resource name
---@param exportName string Export name
---@param args table? Arguments table to pass to export
---@return boolean success True if export call succeeded
---@return any result Export result or error message
function ErrorHandler.SafeExport(resourceName, exportName, args)
    args = args or {}
    return ErrorHandler.SafeCall(function()
        if not exports[resourceName] then
            error(string.format('Resource %s not found', resourceName))
        end
        
        if not exports[resourceName][exportName] then
            error(string.format('Export %s not found in resource %s', exportName, resourceName))
        end
        
        -- Call export with unpacked arguments
        if #args > 0 then
            return exports[resourceName][exportName](table.unpack(args))
        else
            return exports[resourceName][exportName]()
        end
    end, string.format('Export call failed: %s:%s', resourceName, exportName))
end

---Safe export call wrapper that returns nil on error
---@param resourceName string Resource name
---@param exportName string Export name
---@param args table? Arguments table to pass to export
---@return any result Export result or nil on error
function ErrorHandler.SafeExportNil(resourceName, exportName, args)
    local success, result = ErrorHandler.SafeExport(resourceName, exportName, args)
    if success then
        return result
    end
    return nil
end

---Log error message
---@param level string Log level ('error', 'warn', 'info', 'debug')
---@param message string Error message
function ErrorHandler.Log(level, message)
    if not ErrorHandler.Config.LogErrors then
        return
    end
    
    local levels = {
        error = 1,
        warn = 2,
        info = 3,
        debug = 4
    }
    
    local configLevel = levels[ErrorHandler.Config.LogLevel] or 1
    local messageLevel = levels[level] or 1
    
    if messageLevel <= configLevel then
        print(string.format('[ErrorHandler:%s] %s', level:upper(), message))
    end
end

-- Export ErrorHandler as global for use in other scripts
ErrorHandler = ErrorHandler

return ErrorHandler

