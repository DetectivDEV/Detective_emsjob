local ESX = GetResourceState('es_extended'):find('start') and exports['es_extended']:getSharedObject() or nil

if not ESX then return end

function removeAccountMoney(target, account, amount)
    local xPlayer = ESX.GetPlayerFromId(target)
    xPlayer.removeAccountMoney(account, amount)
end

function removePlayerMoney(target, amount)
    local xPlayer = ESX.GetPlayerFromId(target)
    if not xPlayer then return false end

    if xPlayer.getAccount('money').money >= amount then
        xPlayer.removeAccountMoney('money', amount)
        return true
    end

    return false
end

function hasJob(target, jobs)
    local xPlayer = ESX.GetPlayerFromId(target)

    if type(jobs) == "table" then
        for index, jobName in pairs(jobs) do
            if xPlayer.job.name == jobName then return true end
        end
    else
        return xPlayer.job.name == jobs
    end

    return false
end

function playerJob(target)
    local xPlayer = ESX.GetPlayerFromId(target)

    return xPlayer.job.name
end

function updateStatus(data)
    local xPlayer = ESX.GetPlayerFromId(data.target)

    MySQL.update('UPDATE users SET is_dead = ? WHERE identifier = ?', { data.status, xPlayer.identifier })

    if not player[data.target] then
        player[data.target] = {}
    end

    player[data.target].isDead = data.status

    if data.status == true then
        player[data.target].killedBy = data.killedBy
    end
end

function getPlayerName(target)
    local xPlayer = ESX.GetPlayerFromId(target)

    return xPlayer.getName()
end

function getDeathStatus(target)
    local xPlayer = ESX.GetPlayerFromId(target)
    if not xPlayer then
        return { isDead = false }
    end

    local isDead = MySQL.scalar.await('SELECT `is_dead` FROM `users` WHERE `identifier` = ? LIMIT 1', {
        xPlayer.identifier
    })

    return {
        isDead = isDead == true or tonumber(isDead) == 1,
    }
end

ESX.RegisterUsableItem(Config.MedicBagItem, function(source)
    if not hasJob(source, Config.EmsJobs) then return end

    TriggerClientEvent("detective_emsjob:placeMedicalBag", source)
end)

CreateThread(function()
    for k, v in pairs(Config.EmsJobs) do
        TriggerEvent('esx_society:registerSociety', v, v, 'society_' .. v, 'society_' .. v, 'society_' .. v, { type = 'public' })
    end
end)
