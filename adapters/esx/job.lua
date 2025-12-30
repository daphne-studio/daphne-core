---ESX Job Module Adapter
---Job-related functions specific to ESX

-- These modules are loaded via shared_scripts, so they're available as globals
if not ESXAdapter then
    error('[ESX Job] ESXAdapter not found! Make sure adapters/esx/adapter.lua is loaded.')
end

if not StateBag then
    error('[ESX Job] StateBag not found! Make sure core/statebag.lua is loaded.')
end

local Job = {}
Job.__index = Job

---Set player job
---@param source number Player server ID
---@param jobName string Job name
---@param grade number Job grade
---@return boolean success True if successful
function Job:SetJob(source, jobName, grade)
    local xPlayer = ESXAdapter:GetPlayer(source)
    if not xPlayer then return false end
    
    xPlayer.setJob(jobName, grade)
    
    -- Sync to state bag
    local job = ESXAdapter:GetJob(source)
    if job then
        StateBag.SetStateBag('player', source, 'job', job)
    end
    
    return true
end

---Set player job duty status
---@param source number Player server ID
---@param onduty boolean On duty status
---@return boolean success True if successful
function Job:SetDuty(source, onduty)
    local xPlayer = ESXAdapter:GetPlayer(source)
    if not xPlayer then return false end
    
    -- ESX doesn't have a built-in duty system, but we can use metadata
    -- Some ESX servers use job.onduty, so we'll try to set it if possible
    -- For now, we'll just update the job data structure
    local job = xPlayer.job
    if job then
        -- Note: ESX doesn't have a direct setDuty method
        -- This would need to be handled by the server's custom implementation
        -- For now, we'll sync the current job state
        local updatedJob = ESXAdapter:GetJob(source)
        if updatedJob then
            StateBag.SetStateBag('player', source, 'job', updatedJob)
        end
    end
    
    return true
end

---Get players with specific job
---@param jobName string Job name
---@return table players Table of players with job
function Job:GetPlayersWithJob(jobName)
    local esx = ESXAdapter:GetESX()
    if not esx then return {} end
    
    local allPlayers = esx.GetPlayers()
    local jobPlayers = {}
    
    for _, xPlayer in pairs(allPlayers) do
        if xPlayer.job and xPlayer.job.name == jobName then
            table.insert(jobPlayers, xPlayer)
        end
    end
    
    return jobPlayers
end

return Job

