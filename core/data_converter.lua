---Data Converter
---Converts framework-specific data structures to/from normalized daphne-core format
DataConverter = DataConverter or {}
local DataConverter = DataConverter

---Convert Daphne-Core PlayerData to QBCore Player Object
---@param daphneData PlayerData Normalized player data
---@param source number Player server ID
---@return table qbPlayer QBCore Player Object (proxy)
function DataConverter.ToQBCorePlayer(daphneData, source)
    -- Return a proxy object that wraps daphne-core calls
    -- The actual QBCore player object proxy will be created in qbcore_player_proxy.lua
    return {
        _daphneData = daphneData,
        _source = source,
        _isProxy = true,
        PlayerData = {
            citizenid = daphneData.citizenid,
            name = daphneData.name,
            money = daphneData.money or {},
            job = daphneData.job or {},
            gang = daphneData.gang,
            metadata = daphneData.metadata or {}
        }
    }
end

---Convert Daphne-Core PlayerData to ESX xPlayer Object
---@param daphneData PlayerData Normalized player data
---@param source number Player server ID
---@return table xPlayer ESX xPlayer Object (proxy)
function DataConverter.ToESXPlayer(daphneData, source)
    -- Return a proxy object that wraps daphne-core calls
    -- The actual ESX xPlayer object proxy will be created in esx_player_proxy.lua
    local job = daphneData.job or {}
    return {
        _daphneData = daphneData,
        _source = source,
        _isProxy = true,
        identifier = daphneData.citizenid,
        job = {
            name = job.name or 'unemployed',
            label = job.label or 'Unemployed',
            grade = job.grade and job.grade.level or 0,
            grade_name = job.grade and job.grade.name or 'unemployed',
            grade_label = job.grade and job.grade.label or 'Unemployed',
            grade_salary = job.grade and job.grade.payment or 0,
            onduty = job.onduty or false
        }
    }
end

---Convert Daphne-Core PlayerData to ND_Core Player Object
---@param daphneData PlayerData Normalized player data
---@param source number Player server ID
---@return table ndPlayer ND_Core Player Object (proxy)
function DataConverter.ToNDCorePlayer(daphneData, source)
    -- Return a proxy object that wraps daphne-core calls
    -- The actual ND_Core player object proxy will be created in nd_core_player_proxy.lua
    local job = daphneData.job or {}
    local jobInfo = {
        label = job.label or 'Unemployed',
        rank = job.grade and job.grade.level or 0,
        rankName = job.grade and job.grade.name or 'unemployed'
    }
    
    return {
        _daphneData = daphneData,
        _source = source,
        _isProxy = true,
        id = tonumber(daphneData.citizenid) or daphneData.citizenid,
        fullname = daphneData.name,
        firstname = daphneData.name and daphneData.name:match("^([^ ]+)") or '',
        lastname = daphneData.name and daphneData.name:match(" ([^ ]+)$") or '',
        cash = daphneData.money and daphneData.money.cash or 0,
        bank = daphneData.money and daphneData.money.bank or 0,
        metadata = daphneData.metadata or {},
        _jobName = job.name or 'unemployed',
        _jobInfo = jobInfo
    }
end

---Convert Daphne-Core PlayerData to OX Core Player Object (placeholder)
---@param daphneData PlayerData Normalized player data
---@param source number Player server ID
---@return table oxPlayer OX Core Player Object (proxy)
function DataConverter.ToOXPlayer(daphneData, source)
    -- Will be implemented when OX Core adapter is added
    return {
        _daphneData = daphneData,
        _source = source,
        _isProxy = true
    }
end

---Convert QBCore Player Object to Daphne-Core PlayerData
---@param qbPlayer table QBCore Player Object
---@return PlayerData? playerData Normalized player data
function DataConverter.FromQBCorePlayer(qbPlayer)
    if not qbPlayer or not qbPlayer.PlayerData then
        return nil
    end
    
    local pd = qbPlayer.PlayerData
    return {
        source = qbPlayer.PlayerData.source,
        citizenid = pd.citizenid,
        name = pd.charinfo and (pd.charinfo.firstname .. ' ' .. pd.charinfo.lastname) or pd.name or '',
        money = pd.money or {},
        job = pd.job or {},
        gang = pd.gang,
        metadata = pd.metadata or {}
    }
end

---Convert ESX xPlayer Object to Daphne-Core PlayerData
---@param xPlayer table ESX xPlayer Object
---@return PlayerData? playerData Normalized player data
function DataConverter.FromESXPlayer(xPlayer)
    if not xPlayer then
        return nil
    end
    
    local job = xPlayer.job or {}
    local bankAccount = xPlayer.getAccount and xPlayer.getAccount('bank') or {money = 0}
    
    return {
        source = xPlayer.source,
        citizenid = xPlayer.identifier,
        name = xPlayer.getName and xPlayer.getName() or '',
        money = {
            cash = xPlayer.getMoney and xPlayer.getMoney() or 0,
            bank = bankAccount.money or 0
        },
        job = {
            name = job.name or 'unemployed',
            label = job.label or 'Unemployed',
            grade = {
                level = job.grade or 0,
                name = job.grade_name or 'unemployed',
                label = job.grade_label or 'Unemployed',
                payment = job.grade_salary or 0
            },
            onduty = job.onduty or false
        },
        metadata = {}
    }
end

---Convert ND_Core Player Object to Daphne-Core PlayerData
---@param ndPlayer table ND_Core Player Object
---@return PlayerData? playerData Normalized player data
function DataConverter.FromNDCorePlayer(ndPlayer)
    if not ndPlayer then
        return nil
    end
    
    local jobName, jobInfo = nil, {}
    if ndPlayer.getJob then
        jobName, jobInfo = ndPlayer.getJob()
    end
    jobInfo = jobInfo or {}
    
    return {
        source = ndPlayer.source,
        citizenid = tostring(ndPlayer.id),
        name = ndPlayer.fullname or (ndPlayer.firstname .. ' ' .. ndPlayer.lastname) or '',
        money = {
            cash = ndPlayer.cash or (ndPlayer.getData and ndPlayer.getData('cash')) or 0,
            bank = ndPlayer.bank or (ndPlayer.getData and ndPlayer.getData('bank')) or 0
        },
        job = {
            name = jobName or 'unemployed',
            label = jobInfo.label or 'Unemployed',
            grade = {
                level = jobInfo.rank or 0,
                name = jobInfo.rankName or 'unemployed',
                label = jobInfo.rankName or 'Unemployed',
                payment = 0
            },
            onduty = nil
        },
        metadata = ndPlayer.metadata or {}
    }
end

---Convert OX Core Player Object to Daphne-Core PlayerData (placeholder)
---@param oxPlayer table OX Core Player Object
---@return PlayerData? playerData Normalized player data
function DataConverter.FromOXPlayer(oxPlayer)
    -- Will be implemented when OX Core adapter is added
    return nil
end

-- Export DataConverter as global
DataConverter = DataConverter

return DataConverter

