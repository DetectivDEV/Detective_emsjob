player = {}
distressCalls = {}

RegisterNetEvent("detective_emsjob:updateDeathStatus", function(death)
    local data = {}
    data.target = source
    data.status = death.isDead
    data.killedBy = death?.weapon or false

    updateStatus(data)
end)

RegisterNetEvent("detective_emsjob:revivePlayer", function(data)
    if not hasJob(source, Config.EmsJobs) or not source or source < 1 then return end

    local sourcePed = GetPlayerPed(source)
    local targetPed = GetPlayerPed(data.targetServerId)

    if data.targetServerId < 1 or #(GetEntityCoords(sourcePed) - GetEntityCoords(targetPed)) > 4.0 then
        print(source .. ' probile modder')
    else
        local dataToSend = {}
        dataToSend.revive = true

        TriggerClientEvent('detective_emsjob:healPlayer', tonumber(data.targetServerId), dataToSend)
    end
end)

RegisterNetEvent("detective_emsjob:healPlayer", function(data)
    if not hasJob(source, Config.EmsJobs) or not source or source < 1 then return end


    local sourcePed = GetPlayerPed(source)
    local targetPed = GetPlayerPed(data.targetServerId)

    if data.targetServerId < 1 or #(GetEntityCoords(sourcePed) - GetEntityCoords(targetPed)) > 4.0 then
        return print(source .. ' probile modder')
    end


    if data.injury then
        TriggerClientEvent('detective_emsjob:healPlayer', tonumber(data.targetServerId), data)
    else
        data.anim = "medic"
        TriggerClientEvent("detective_emsjob:playHealAnim", source, data)
        data.anim = "dead"
        TriggerClientEvent("detective_emsjob:playHealAnim", data.targetServerId, data)
    end
end)

RegisterNetEvent("detective_emsjob:createDistressCall", function(data)
    if not source or source < 1 then return end
    distressCalls[#distressCalls + 1] = {
        msg = data.msg,
        gps = data.gps,
        location = data.location,
        name = getPlayerName(source)
    }

    local players = GetPlayers()

    for i = 1, #players do
        local id = tonumber(players[i])

        if hasJob(id, Config.EmsJobs) then
            TriggerClientEvent("detective_emsjob:createDistressCall", id, getPlayerName(source))
        end
    end
end)

RegisterNetEvent("detective_emsjob:callCompleted", function(call)
    for i = #distressCalls, 1, -1 do
        if distressCalls[i].gps == call.gps and distressCalls[i].msg == call.msg then
            table.remove(distressCalls, i)
            break
        end
    end
end)

RegisterNetEvent("detective_emsjob:removAddItem", function(data)
    if not inv then return end

    if data.toggle then
        inv.removeItem(source, data.item, data.quantity)
    else
        inv.addItem(source, data.item, data.quantity)
    end
end)

RegisterNetEvent("detective_emsjob:useItem", function(data)
    if not hasJob(source, Config.EmsJobs) or not inv then return end

    inv.setItemDurability(source, data.item, data.value)
end)

RegisterNetEvent("detective_emsjob:removeInventory", function()
    if not inv then return end
    if player[source] and player[source].isDead and Config.RemoveItemsOnRespawn then
        inv.clearPlayerInventory(source)
    end
end)

RegisterNetEvent("detective_emsjob:putOnStretcher", function(data)
    if not player[data.target].isDead then return end
    TriggerClientEvent("detective_emsjob:putOnStretcher", data.target, data.toggle)
end)

RegisterNetEvent("detective_emsjob:togglePatientFromVehicle", function(data)
    if not player[data.target].isDead then return end

    TriggerClientEvent("detective_emsjob:togglePatientFromVehicle", data.target, data.vehicle)
end)

RegisterNetEvent('detective_emsjob:openStash', function(id)
    if not inv then return end
    inv.openStash(source, id)
end)

RegisterNetEvent('detective_emsjob:openShop', function(name)
    if not inv then return end
    inv.openShop(source, name)
end)

lib.callback.register('detective_emsjob:getDeathStatus', function(source, target)
    return player[target] and player[target] or getDeathStatus(target or source)
end)

lib.callback.register('detective_emsjob:getData', function(source, target)
    local data = {}
    if not target or target < 1 then
        return { injuries = false, status = { isDead = false }, killedBy = false }
    end

    data.injuries = Player(target).state.injuries or false

    local status = getDeathStatus(target)
    if type(status) ~= 'table' then
        status = { isDead = status == true }
    elseif status.isDead == nil then
        status.isDead = false
    end

    data.status = status
    data.killedBy = player[target]?.killedBy or false

    return data
end)

lib.callback.register('detective_emsjob:getDistressCalls', function(source)
    return distressCalls
end)

lib.callback.register('detective_emsjob:openMedicalBag', function(source)
    if not inv then return nil end
    return inv.openMedicalBag(source)
end)

lib.callback.register('detective_emsjob:getItem', function(source, name)
    if not inv then return nil end
    return inv.getItemByName(source, name)
end)

lib.callback.register('detective_emsjob:getItemCount', function(source, item)
    if not inv then return 0 end
    return inv.getItemCount(source, item)
end)

lib.callback.register('detective_emsjob:payParamedic', function(source, amount)
    if not inv then return false end
    return inv.payForTreatment(source, amount)
end)

lib.callback.register('detective_emsjob:getMedicsOniline', function(source)
    local count = 0
    local players = GetPlayers()

    for i = 1, #players do
        local id = tonumber(players[i])

        if hasJob(id, Config.EmsJobs) then
            count += 1
        end
    end
    return count
end)

AddEventHandler('onServerResourceStart', function(resourceName)
    if resourceName ~= GetCurrentResourceName() or not inv then return end

    inv.registerHospitalInventories()
    inv.registerMedicalBagProtection()
end)

