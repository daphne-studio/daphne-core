---Qbox Vehicle Module Adapter
---Vehicle-related functions specific to Qbox

-- These modules are loaded via shared_scripts, so they're available as globals
if not QboxAdapter then
    error('[Qbox Vehicle] QboxAdapter not found! Make sure adapters/qbox/adapter.lua is loaded.')
end

if not StateBag then
    error('[Qbox Vehicle] StateBag not found! Make sure core/statebag.lua is loaded.')
end

local Vehicle = {}
Vehicle.__index = Vehicle

---Get vehicle by plate
---@param plate string Vehicle plate
---@return table|nil vehicleData Vehicle data or nil
function Vehicle:GetVehicleByPlate(plate)
    local success, vehicleData = pcall(function()
        return exports['qbx_core']:GetVehicleByPlate(plate) or exports['qb-core']:GetVehicleByPlate(plate)
    end)
    
    if success and vehicleData then
        return vehicleData
    end
    
    return nil
end

---Get vehicle by citizenid
---@param citizenid string Citizen ID
---@return table vehicles Table of vehicles owned by player
function Vehicle:GetVehiclesByCitizenId(citizenid)
    local success, vehicles = pcall(function()
        return exports['qbx_core']:GetVehiclesByCitizenId(citizenid) or exports['qb-core']:GetVehiclesByCitizenId(citizenid)
    end)
    
    if success and vehicles then
        return vehicles
    end
    
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
    
    local vehicleData = QboxAdapter:GetVehicle(vehicle)
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
    local vehicleData = QboxAdapter:GetVehicle(vehicle)
    if not vehicleData then return nil end
    
    return vehicleData.metadata or {}
end

return Vehicle

