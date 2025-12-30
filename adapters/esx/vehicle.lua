---ESX Vehicle Module Adapter
---Vehicle-related functions specific to ESX

-- These modules are loaded via shared_scripts, so they're available as globals
if not ESXAdapter then
    error('[ESX Vehicle] ESXAdapter not found! Make sure adapters/esx/adapter.lua is loaded.')
end

if not StateBag then
    error('[ESX Vehicle] StateBag not found! Make sure core/statebag.lua is loaded.')
end

local Vehicle = {}
Vehicle.__index = Vehicle

---Get vehicle by plate
---@param plate string Vehicle plate
---@return table|nil vehicleData Vehicle data or nil
function Vehicle:GetVehicleByPlate(plate)
    -- ESX doesn't have a direct GetVehicleByPlate export
    -- This would typically require a database query
    -- For now, return nil as ESX vehicle system varies by server
    return nil
end

---Get vehicles by identifier
---@param identifier string Player identifier
---@return table vehicles Table of vehicles owned by player
function Vehicle:GetVehiclesByIdentifier(identifier)
    -- ESX doesn't have a standard vehicle ownership system
    -- This would typically require a database query or custom export
    -- For now, return empty table
    return {}
end

---Set vehicle metadata
---@param vehicle number Vehicle entity
---@param metadata table Metadata to set
---@return boolean success True if successful
function Vehicle:SetVehicleMetadata(vehicle, metadata)
    if not DoesEntityExist(vehicle) then
        return false
    end
    
    local vehicleData = ESXAdapter:GetVehicle(vehicle)
    if not vehicleData then return false end
    
    -- Update metadata
    vehicleData.metadata = metadata
    
    -- Sync to state bag
    StateBag.SetStateBag('vehicle', vehicle, 'data', vehicleData)
    
    return true
end

---Get vehicle metadata
---@param vehicle number Vehicle entity
---@return table|nil metadata Vehicle metadata or nil
function Vehicle:GetVehicleMetadata(vehicle)
    local vehicleData = ESXAdapter:GetVehicle(vehicle)
    if not vehicleData then return nil end
    
    return vehicleData.metadata or {}
end

return Vehicle

