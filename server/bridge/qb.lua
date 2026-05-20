local function getQB()
    if GetResourceState('qbx_core'):find('start') then
        local ok, core = pcall(function()
            return exports.qbx_core:GetCoreObject()
        end)
        if ok and core then return core end
    end

    if GetResourceState('qb-core'):find('start') then
        return exports['qb-core']:GetCoreObject()
    end
end

QBCore = getQB()

if not QBCore then return end

function removeAccountMoney(target, account, amount)
    local xPlayer = QBCore.Functions.GetPlayer(target)
    xPlayer.Functions.RemoveMoney(account, amount)
end

function removePlayerMoney(target, amount)
    local xPlayer = QBCore.Functions.GetPlayer(target)
    if not xPlayer then return false end

    if xPlayer.Functions.GetMoney('cash') >= amount then
        return xPlayer.Functions.RemoveMoney('cash', amount, 'detective_emsjob-paramedic')
    end

    return false
end

function hasJob(target, jobs)
    local xPlayer = QBCore.Functions.GetPlayer(target)

    if type(jobs) == "table" then
        for index, jobName in pairs(jobs) do
            if xPlayer.PlayerData.job.name == jobName then return true end
        end
    else
        return xPlayer.PlayerData.job.name == jobs
    end

    return false
end

function playerJob(target)
    local xPlayer = QBCore.Functions.GetPlayer(target)

    return xPlayer.PlayerData.job.name
end

function updateStatus(data)
    local Player = QBCore.Functions.GetPlayer(data.target)

    Player.Functions.SetMetaData("isdead", data.status)

    if not player[data.target] then
        player[data.target] = {}
    end

    player[data.target].isDead = data.status

    if data.status == true then
        player[data.target].killedBy = data.killedBy
    end
end

function getPlayerName(target)
    local xPlayer = QBCore.Functions.GetPlayer(target)

    return xPlayer.PlayerData.charinfo.firstname .. " " .. xPlayer.PlayerData.charinfo.lastname
end

function getDeathStatus(target)
    local xPlayer = QBCore.Functions.GetPlayer(target)
    if not xPlayer then
        return { isDead = false }
    end

    local raw = xPlayer.PlayerData.metadata['isdead']
    return {
        isDead = raw == true or tonumber(raw) == 1,
    }
end

QBCore.Functions.CreateUseableItem(Config.MedicBagItem, function(source, item)
    if not hasJob(source, Config.EmsJobs) then return end

    TriggerClientEvent("detective_emsjob:placeMedicalBag", source)
end)

QBCore.Functions.CreateUseableItem('emstablet', function(source)
    if not hasJob(source, Config.EmsJobs) then return end

    TriggerClientEvent('detective_emsjob:useEmsTablet', source)
end)
