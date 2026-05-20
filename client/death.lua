local DoScreenFadeOut              = DoScreenFadeOut
local IsScreenFadedOut             = IsScreenFadedOut
local NetworkResurrectLocalPlayer  = NetworkResurrectLocalPlayer
local ShakeGameplayCam             = ShakeGameplayCam
local AnimpostfxPlay               = AnimpostfxPlay
local CreateThread                 = CreateThread
local Wait                         = Wait
local SetEntityCoords              = SetEntityCoords
local TaskPlayAnim                 = TaskPlayAnim
local FreezeEntityPosition         = FreezeEntityPosition
local ClearPedTasks                = ClearPedTasks
local SetEntityHealth              = SetEntityHealth
local SetEntityInvincible          = SetEntityInvincible
local SetEveryoneIgnorePlayer      = SetEveryoneIgnorePlayer
local GetGameTimer                 = GetGameTimer
local IsControlJustPressed         = IsControlJustPressed
local TriggerServerEvent           = TriggerServerEvent
local AddEventHandler              = AddEventHandler
local SetEntityHeading             = SetEntityHeading
local DoScreenFadeIn               = DoScreenFadeIn
local PlayerPedId                  = PlayerPedId
local NetworkGetPlayerIndexFromPed = NetworkGetPlayerIndexFromPed
local IsPedAPlayer                 = IsPedAPlayer
local IsPedDeadOrDying             = IsPedDeadOrDying
local IsPedFatallyInjured          = IsPedFatallyInjured


function stopPlayerDeath()
    player.isDead = false
    -- player.injuries = {}

    local playerPed = cache.ped or PlayerPedId()

    DoScreenFadeOut(800)

    while not IsScreenFadedOut() do
        Wait(50)
    end

    local coords = cache.coords or GetEntityCoords(playerPed)
    NetworkResurrectLocalPlayer(coords.x, coords.y, coords.z, coords.w, false, false)

    local deathStatus = { isDead = false }
    TriggerServerEvent('detective_emsjob:updateDeathStatus', deathStatus)

    playerPed = PlayerPedId()

    if cache.vehicle then
        SetPedIntoVehicle(cache.ped, cache.vehicle, cache.seat)
    end

    ClearPedBloodDamage(playerPed)
    SetEntityInvincible(playerPed, false)
    SetEveryoneIgnorePlayer(cache.playerId, false)
    ClearPedTasks(playerPed)
    AnimpostfxStopAll()

    DoScreenFadeIn(700)
    TaskPlayAnim(playerPed, Config.DeathAnimations["revive"].dict, Config.DeathAnimations["revive"].clip, 8.0, -8.0, -1, 0, 0, 0, 0, 0)

    -- LocalPlayer.state:set("injuries", {}, true)
    LocalPlayer.state:set("dead", false, true)
    player.distressCallTime = nil

    deathUI.close()

    playerSpawned()
    healPlayer()
end

function healPlayer()
    local playerPed = cache.ped or PlayerPedId()
    local maxHealth = GetEntityMaxHealth(playerPed)

    SetEntityHealth(playerPed, maxHealth)
    healStatus()
end

RegisterNetEvent("detective_emsjob:healPlayer", function(data)
    if data.revive then
        stopPlayerDeath()
    elseif data.injury then
        treatInjury(data.bone)
    elseif data.heal then
        healPlayer()
    end
end)

local function respawnPlayer()
    local playerPed = cache.ped or PlayerPedId()

    if Config.RemoveItemsOnRespawn then
        TriggerServerEvent("detective_emsjob:removeInventory")
    end

    lib.requestAnimDict("anim@gangops@morgue@table@")
    lib.requestAnimDict("switch@franklin@bed")

    local hospital = utils.getClosestHospital()
    local bed = nil

    DoScreenFadeOut(500)
    while not IsScreenFadedOut() do Wait(1) end

    for i = 1, #hospital.respawn do
        local _bed = hospital.respawn[i]
        local isBedOccupied = utils.isBedOccupied(_bed.bedPoint)
        if not isBedOccupied then
            bed = _bed
            break
        end
    end

    if not bed then bed = hospital.respawn[1] end

    player.respawning = true

    SetEntityCoords(playerPed, bed.bedPoint)
    SetEntityHeading(playerPed, bed.bedPoint.w)
    TaskPlayAnim(playerPed, "anim@gangops@morgue@table@", "body_search", 2.0, 2.0, -1, 1, 0, false, false, false)
    FreezeEntityPosition(playerPed, true)


    DoScreenFadeIn(300)
    Wait(5000)
    SetEntityCoords(playerPed, vector3(bed.bedPoint.x, bed.bedPoint.y, bed.bedPoint.z) + vector3(0.0, 0.0, -1.0))
    FreezeEntityPosition(playerPed, false)
    SetEntityHeading(cache.ped, bed.bedPoint.w + 90.0)
    TaskPlayAnim(playerPed, "switch@franklin@bed", "sleep_getup_rubeyes", 1.0, 1.0, -1, 8, -1, 0, 0, 0)

    Wait(5000)

    stopPlayerDeath()
    ClearPedTasks(playerPed)
    SetEntityCoords(playerPed, bed.spawnPoint)
    player.respawning = false
end

local function initPlayerDeath(logged_dead)
    if player.isDead then return end

    player.isDead = true
    startCommandTimer()

    for _, anim in pairs(Config.DeathAnimations) do
        lib.requestAnimDict(anim.dict)
    end

    if logged_dead then goto logged_dead end

    if Config.ExtraEffects then
        ShakeGameplayCam('DEATH_FAIL_IN_EFFECT_SHAKE', 1.0)
        Wait(2000)
    end
    if not player.isDead then return end

    ::logged_dead::
    local playerPed = cache.ped or PlayerPedId()

    AnimpostfxStopAll()
    DoScreenFadeIn(500)

    CreateThread(function()
        while player.isDead do
            DisableFirstPersonCamThisFrame()
            Wait(0)
        end
    end)

    local coords = cache.coords or GetEntityCoords(playerPed)
    NetworkResurrectLocalPlayer(coords.x, coords.y, coords.z, GetEntityHeading(playerPed), false, false)
    playerPed = PlayerPedId()

    if cache.vehicle then
        SetPedIntoVehicle(cache.ped, cache.vehicle, cache.seat)
    end

    SetEntityInvincible(cache.ped, true)
    SetEntityHealth(cache.ped, 100)
    SetEveryoneIgnorePlayer(cache.playerId, true)

    local deathTime = GetGameTimer()

    deathUI.open(deathTime)

    CreateThread(function()
        while player.isDead do
            local sleep = 500

            if player.respawning then
                deathUI.close()
            elseif not player.gettingRevived then
                AnimpostfxStop('DeathFailOut')

                local anim = cache.vehicle and Config.DeathAnimations["car"] or Config.DeathAnimations["normal"]

                if not IsEntityPlayingAnim(playerPed, anim.dict, anim.clip, 3) then
                    TaskPlayAnim(playerPed, anim.dict, anim.clip, 50.0, 8.0, -1, 1, 1.0, false, false, false)
                end

                if not deathUI.isVisible() then
                    deathUI.open(deathTime)
                end

                deathUI.update(deathTime)
            end

            Wait(sleep)
        end

        deathUI.close()
    end)
end

RegisterNUICallback('callEms', function(_, cb)
    if not player.isDead then
        cb('ok')
        return
    end

    createDistressCall()
    cb('ok')
end)

RegisterNUICallback('respawn', function(_, cb)
    if not player.isDead or not deathUI.canRespawnNow() then
        cb('ok')
        return
    end

    local confirmation = lib.alertDialog({
        header = locale('death_respawn_confirm_title'),
        content = locale('death_respawn_confirm_desc'),
        centered = true,
        cancel = true,
    })

    if confirmation == 'confirm' then
        respawnPlayer()
    end

    cb('ok')
end)

function onPlayerLoaded()
    exports.spawnmanager:setAutoSpawn(false) -- for qbcore

    local data = lib.callback.await('detective_emsjob:getDeathStatus', false)

    if data?.isDead then
        initPlayerDeath(true)
        utils.showNotification("logged_dead")
    end
end

AddEventHandler('gameEventTriggered', function(event, data)
    if event ~= 'CEventNetworkEntityDamage' then return end

    local victim, victimDied, weapon = data[1], data[4], data[7]
    utils.debug(weapon)


    if not IsPedAPlayer(victim) then return end

    local playerPed = cache.playerId or PlayerId()

    if NetworkGetPlayerIndexFromPed(victim) ~= playerPed then return end

    local victimDiedAndPlayer = victimDied and NetworkGetPlayerIndexFromPed(victim) == playerPed and (IsPedDeadOrDying(victim, true) or IsPedFatallyInjured(victim))

    if victimDiedAndPlayer then
        local deathData = {}

        deathData.isDead = true
        deathData.weapon = weapon

        TriggerServerEvent('detective_emsjob:updateDeathStatus', deathData)
        LocalPlayer.state:set("dead", true, true)
        initPlayerDeath()
    end

    updateInjuries(victim, weapon)

    utils.debug(LocalPlayer.state.injuries)
end)


exports("isDead", function()
    return player.isDead
end)

RegisterNetEvent('detective_emsjob:adminKill', function()
    if player.isDead then return end

    local deathData = {
        isDead = true,
        weapon = false,
    }

    TriggerServerEvent('detective_emsjob:updateDeathStatus', deathData)
    LocalPlayer.state:set('dead', true, true)
    initPlayerDeath()
end)

