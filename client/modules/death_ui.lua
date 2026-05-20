deathUI = {}

local isOpen = false
local canRespawn = false
local deathCam = nil
local camThreadActive = false

local HEAD_BONE = 31086

local function getRespawnSeconds()
    local minutes = Config.RespawnTime
    if not minutes or minutes <= 0 then
        minutes = 5
    end
    return minutes * 60
end

local function getLocaleStrings()
    return {
        death_title = locale('death_title'),
        death_subtitle = locale('death_subtitle'),
        death_call_ems = locale('death_call_ems'),
        death_respawn = locale('death_respawn'),
        death_respawn_wait = locale('death_respawn_wait'),
        death_respawn_ready = locale('death_respawn_ready'),
    }
end

local function getEmsCooldownRemaining()
    if not player.distressCallTime then return 0 end

    local waitMs = 60000 * Config.WaitTimeForNewCall
    local elapsed = GetGameTimer() - player.distressCallTime

    if elapsed >= waitMs then return 0 end

    return math.ceil((waitMs - elapsed) / 1000)
end

local function stopDeathCam()
    camThreadActive = false

    if deathCam then
        RenderScriptCams(false, true, 500, true, false)
        DestroyCam(deathCam, false)
        deathCam = nil
    end
end

local function updateDeathCam()
    if not deathCam then return end

    local ped = cache.ped or PlayerPedId()
    if not DoesEntityExist(ped) then return end

    local head = GetPedBoneCoords(ped, HEAD_BONE, 0.0, 0.0, 0.0)
    local heading = GetEntityHeading(ped)
    local rad = math.rad(heading)
    local dist = 1.15
    local height = 0.48

    local camX = head.x - math.sin(rad) * dist
    local camY = head.y + math.cos(rad) * dist
    local camZ = head.z + height

    SetCamCoord(deathCam, camX, camY, camZ)
    PointCamAtCoord(deathCam, head.x, head.y, head.z + 0.04)
end

local function startDeathCam()
    stopDeathCam()

    deathCam = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)
    SetCamFov(deathCam, 38.0)
    updateDeathCam()
    SetCamActive(deathCam, true)
    RenderScriptCams(true, true, 800, true, false)

    camThreadActive = true
    CreateThread(function()
        while camThreadActive and deathCam do
            updateDeathCam()
            Wait(0)
        end
    end)
end

function deathUI.getRespawnSeconds()
    return getRespawnSeconds()
end

function deathUI.open(deathStartTime)
    isOpen = true
    canRespawn = false

    local totalSeconds = getRespawnSeconds()
    local elapsed = math.floor((GetGameTimer() - deathStartTime) / 1000)
    local remaining = math.max(0, totalSeconds - elapsed)

    if remaining <= 0 then
        canRespawn = true
    end

    local emsCooldownSec = getEmsCooldownRemaining()

    AnimpostfxStop('DeathFailOut')
    startDeathCam()

    SetNuiFocus(true, true)

    SendNUIMessage({
        action = 'show',
        remaining = remaining,
        canRespawn = canRespawn,
        respawnReadyText = locale('death_respawn_ready'),
        emsEnabled = emsCooldownSec <= 0,
        emsCooldown = emsCooldownSec > 0 and (locale('death_ems_cooldown'):format(emsCooldownSec)) or '',
        locale = getLocaleStrings(),
    })
end

function deathUI.update(deathStartTime)
    if not isOpen then return end

    local totalSeconds = getRespawnSeconds()
    local elapsed = math.floor((GetGameTimer() - deathStartTime) / 1000)
    local remaining = math.max(0, totalSeconds - elapsed)

    canRespawn = remaining <= 0

    local emsCooldownSec = getEmsCooldownRemaining()

    SendNUIMessage({
        action = 'update',
        remaining = remaining,
        canRespawn = canRespawn,
        respawnReadyText = locale('death_respawn_ready'),
        emsEnabled = emsCooldownSec <= 0,
        emsCooldown = emsCooldownSec > 0 and (locale('death_ems_cooldown'):format(emsCooldownSec)) or '',
    })
end

function deathUI.close()
    if not isOpen then
        stopDeathCam()
        return
    end

    isOpen = false
    canRespawn = false
    stopDeathCam()
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'hide' })
end

function deathUI.canRespawnNow()
    return canRespawn
end

function deathUI.isVisible()
    return isOpen
end
