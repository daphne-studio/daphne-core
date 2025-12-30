---ND Core Job Module Adapter
---Job/Group-related functions specific to ND Core

-- These modules are loaded via shared_scripts, so they're available as globals
if not NDCoreAdapter then
    error('[ND Core Job] NDCoreAdapter not found! Make sure adapters/nd_core/adapter.lua is loaded.')
end

if not StateBag then
    error('[ND Core Job] StateBag not found! Make sure core/statebag.lua is loaded.')
end

local Job = {}
Job.__index = Job

---Set player job
---@param source number Player server ID
---@param jobName string Job name
---@param rank number Job rank
---@return boolean success True if successful
function Job:SetJob(source, jobName, rank)
    local player = NDCoreAdapter:GetPlayer(source)
    if not player then return false end
    
    local success, result = pcall(function()
        if player.setJob then
            return player.setJob(jobName, rank)
        end
        return false
    end)
    
    if success then
        -- Sync to state bag
        local job = NDCoreAdapter:GetJob(source)
        if job then
            StateBag.SetStateBag('player', source, 'job', job, false)
        end
        return true
    end
    
    return false
end

---Get players with specific job
---@param jobName string Job name
---@return table players Table of players with job
function Job:GetPlayersWithJob(jobName)
    local ndCore = NDCoreAdapter:GetNDCore()
    if not ndCore then return {} end
    
    local success, players = pcall(function()
        if ndCore.getPlayers then
            return ndCore.getPlayers('job', jobName, true)
        end
        return {}
    end)
    
    if success and players then
        return players
    end
    
    return {}
end

---Get player group
---@param source number Player server ID
---@param groupName string Group name
---@return table|nil group Group data or nil
function Job:GetGroup(source, groupName)
    local player = NDCoreAdapter:GetPlayer(source)
    if not player then return nil end
    
    local success, group = pcall(function()
        if player.getGroup then
            return player.getGroup(groupName)
        end
        return nil
    end)
    
    if success and group then
        return group
    end
    
    return nil
end

---Add group to player
---@param source number Player server ID
---@param groupName string Group name
---@param rank number? Group rank (optional, default: 1)
---@return table|nil group Group data or nil
function Job:AddGroup(source, groupName, rank)
    local player = NDCoreAdapter:GetPlayer(source)
    if not player then return nil end
    
    rank = rank or 1
    
    local success, group = pcall(function()
        if player.addGroup then
            return player.addGroup(groupName, rank)
        end
        return nil
    end)
    
    if success and group then
        Cache.InvalidatePlayer(source)
        return group
    end
    
    return nil
end

---Remove group from player
---@param source number Player server ID
---@param groupName string Group name
---@return table|nil group Removed group data or nil
function Job:RemoveGroup(source, groupName)
    local player = NDCoreAdapter:GetPlayer(source)
    if not player then return nil end
    
    local success, group = pcall(function()
        if player.removeGroup then
            return player.removeGroup(groupName)
        end
        return nil
    end)
    
    if success and group then
        Cache.InvalidatePlayer(source)
        return group
    end
    
    return nil
end

return Job

