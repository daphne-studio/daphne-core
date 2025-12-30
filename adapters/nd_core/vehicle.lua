---ND Core Vehicle Module Adapter
---Vehicle-related functions specific to ND Core

-- These modules are loaded via shared_scripts, so they're available as globals
if not NDCoreAdapter then
    error('[ND Core Vehicle] NDCoreAdapter not found! Make sure adapters/nd_core/adapter.lua is loaded.')
end

local Vehicle = {}
Vehicle.__index = Vehicle

---Get vehicle by ID
---@param id number|string Vehicle ID
---@return table|nil vehicle Vehicle data or nil
function Vehicle:GetVehicleById(id)
    local ndCore = NDCoreAdapter:GetNDCore()
    if not ndCore then return nil end
    
    local success, vehicle = pcall(function()
        if ndCore.getVehicleById then
            return ndCore.getVehicleById(id)
        end
        return nil
    end)
    
    if success and vehicle then
        return vehicle
    end
    
    return nil
end

---Get all vehicles owned by character
---@param characterId number Character ID
---@return table vehicles Table of vehicles
function Vehicle:GetVehicles(characterId)
    local ndCore = NDCoreAdapter:GetNDCore()
    if not ndCore then return {} end
    
    local success, vehicles = pcall(function()
        if ndCore.getVehicles then
            return ndCore.getVehicles(characterId)
        end
        return {}
    end)
    
    if success and vehicles then
        return vehicles
    end
    
    return {}
end

---Give vehicle access to player
---@param source number Player server ID
---@param vehicle number Vehicle entity
---@param access boolean Access status
---@return boolean success True if successful
function Vehicle:GiveVehicleAccess(source, vehicle, access)
    local ndCore = NDCoreAdapter:GetNDCore()
    if not ndCore then return false end
    
    local success, result = pcall(function()
        if ndCore.giveVehicleAccess then
            ndCore.giveVehicleAccess(source, vehicle, access)
            return true
        end
        return false
    end)
    
    return success and result or false
end

---Share vehicle keys between players
---@param source number Source player server ID
---@param targetSource number Target player server ID
---@param vehicle number Vehicle entity
---@return boolean success True if successful
function Vehicle:ShareVehicleKeys(source, targetSource, vehicle)
    local ndCore = NDCoreAdapter:GetNDCore()
    if not ndCore then return false end
    
    local success, result = pcall(function()
        if ndCore.shareVehicleKeys then
            return ndCore.shareVehicleKeys(source, targetSource, vehicle)
        end
        return false
    end)
    
    return success and result or false
end

---Transfer vehicle ownership
---@param vehicleId number|string Vehicle ID
---@param fromSource number Source player server ID
---@param toSource number Target player server ID
---@return boolean success True if successful
function Vehicle:TransferVehicleOwnership(vehicleId, fromSource, toSource)
    local ndCore = NDCoreAdapter:GetNDCore()
    if not ndCore then return false end
    
    local success, result = pcall(function()
        if ndCore.transferVehicleOwnership then
            return ndCore.transferVehicleOwnership(vehicleId, fromSource, toSource)
        end
        return false
    end)
    
    return success and result or false
end

return Vehicle

