---Qbox Job Module Adapter
---Job-related functions specific to Qbox

-- These modules are loaded via shared_scripts, so they're available as globals
if not QboxAdapter then
    error('[Qbox Job] QboxAdapter not found! Make sure adapters/qbox/adapter.lua is loaded.')
end

if not StateBag then
    error('[Qbox Job] StateBag not found! Make sure core/statebag.lua is loaded.')
end

local Job = {}
Job.__index = Job

---Set player job
---@param source number Player server ID
---@param jobName string Job name
---@param grade number Job grade
---@return boolean success True if successful
function Job:SetJob(source, jobName, grade)
    local player = QboxAdapter:GetPlayer(source)
    if not player then return false end
    
    local success = player.Functions.SetJob(jobName, grade)
    
    if success then
        -- Sync to state bag
        StateBag.SetStateBag('player', source, 'job', player.PlayerData.job)
    end
    
    return success
end

---Set player job duty status
---@param source number Player server ID
---@param onduty boolean On duty status
---@return boolean success True if successful
function Job:SetDuty(source, onduty)
    local player = QboxAdapter:GetPlayer(source)
    if not player then return false end
    
    local success = player.Functions.SetJobDuty(onduty)
    
    if success then
        -- Sync to state bag
        StateBag.SetStateBag('player', source, 'job', player.PlayerData.job)
    end
    
    return success
end

---Get players with specific job
---@param jobName string Job name
---@return table players Table of players with job
function Job:GetPlayersWithJob(jobName)
    local qbCore = QboxAdapter:GetQBCore()
    if not qbCore then return {} end
    
    local players = qbCore:GetQBPlayers()
    local jobPlayers = {}
    
    for _, player in pairs(players) do
        if player.PlayerData.job.name == jobName then
            table.insert(jobPlayers, player)
        end
    end
    
    return jobPlayers
end

---Set player gang
---@param source number Player server ID
---@param gangName string Gang name
---@param grade number Gang grade
---@return boolean success True if successful
function Job:SetGang(source, gangName, grade)
    local player = QboxAdapter:GetPlayer(source)
    if not player then return false end
    
    local success = player.Functions.SetGang(gangName, grade)
    
    if success then
        -- Sync to state bag
        StateBag.SetStateBag('player', source, 'gang', player.PlayerData.gang)
    end
    
    return success
end

---Get players with specific gang
---@param gangName string Gang name
---@return table players Table of players with gang
function Job:GetPlayersWithGang(gangName)
    local qbCore = QboxAdapter:GetQBCore()
    if not qbCore then return {} end
    
    local players = qbCore:GetQBPlayers()
    local gangPlayers = {}
    
    for _, player in pairs(players) do
        if player.PlayerData.gang and player.PlayerData.gang.name == gangName then
            table.insert(gangPlayers, player)
        end
    end
    
    return gangPlayers
end

return Job

