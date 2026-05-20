--- Wait until a supported target resource is running (this job may load before target in server.cfg).
local function waitForTargetResource()
    local mode = Config.TargetResource or 'auto'
    if mode ~= 'auto' and mode ~= 'ox_target' and mode ~= 'qb-target' then
        mode = 'auto'
    end

    local deadline = GetGameTimer() + 120000

    while GetGameTimer() < deadline do
        local oxOk = GetResourceState('ox_target') == 'started'
        local qbOk = GetResourceState('qb-target') == 'started'

        if mode == 'ox_target' and oxOk then
            return 'ox_target'
        end
        if mode == 'qb-target' and qbOk then
            return 'qb-target'
        end
        if mode == 'auto' then
            if oxOk then
                return 'ox_target'
            end
            if qbOk then
                return 'qb-target'
            end
        end

        Wait(50)
    end

    return nil
end

local targetResource = waitForTargetResource()

if targetResource == 'ox_target' then
    function addLocalEntity(entity, _options)
        local options = {}

        for i = 1, #_options do
            local option = _options[i]

            options[#options + 1] = {
                label = option.label,
                icon = option.icon,
                groups = option.groups,
                distance = 3,
                onSelect = option.fn
            }
        end
        exports.ox_target:addLocalEntity(entity, options)
    end

    function addGlobalVehicle(_options)
        local options = {}

        for i = 1, #_options do
            local option = _options[i]

            options[#options + 1] = {
                label = option.label,
                icon = option.icon,
                groups = option.groups,
                canInteract = option.cn,
                onSelect = option.fn
            }
        end

        exports.ox_target:addGlobalVehicle(options)
    end

    function addModel(models, _options)
        local options = {}

        for i = 1, #_options do
            local option = _options[i]

            options[#options + 1] = {
                label = option.label,
                icon = option.icon,
                groups = option.groups,
                canInteract = option.cn,
                onSelect = option.fn
            }
        end
        exports.ox_target:addModel(models, options)
    end

    function addBoxZone(coords, _options)
        local options = {}

        for i = 1, #_options do
            local option = _options[i]

            options[#options + 1] = {
                label = option.label,
                icon = option.icon,
                groups = option.groups,
                onSelect = option.fn
            }
        end

        exports.ox_target:addBoxZone({ coords = coords, options = options })
    end

    function addGlobalPlayer(_options)
        local options = {}

        for i = 1, #_options do
            local option = _options[i]

            options[#options + 1] = {
                label = option.label,
                icon = option.icon,
                groups = option.groups,
                canInteract = option.cn,
                onSelect = option.fn
            }
        end

        exports.ox_target:addGlobalPlayer(options)
    end
elseif targetResource == 'qb-target' then
    local function convertJobs(groups)
        if not groups then return nil end
        local jobs = {}

        for _, job in pairs(groups) do
            jobs[job] = 0
        end

        return jobs
    end

    --- Some qb-target forks omit exports; try alternatives without hard errors.
    local warned = {}

    local function qbTry(label, attempts)
        for i = 1, #attempts do
            local ok = pcall(attempts[i])
            if ok then
                return true
            end
        end
        if not warned[label] then
            warned[label] = true
            print(
                ('^3[detective_emsjob] qb-target: "%s" is missing or failed. Install official qb-target, or add ox_target and set Config.TargetResource = "ox_target".^7'):format(
                    label))
        end
        return false
    end

    function addLocalEntity(entity, _options)
        local options = {}

        for i = 1, #_options do
            local option = _options[i]
            local jobs = convertJobs(option.groups)

            options[#options + 1] = {
                label = option.label,
                icon = option.icon,
                job = jobs,
                action = option.fn
            }
        end

        qbTry('AddTargetEntity', {
            function()
                exports['qb-target']:AddTargetEntity(entity, {
                    options = options,
                    distance = 3.0,
                })
            end,
        })
    end

    function addGlobalVehicle(_options)
        local options = {}

        for i = 1, #_options do
            local option = _options[i]
            local jobs = convertJobs(option.groups)

            options[#options + 1] = {
                label = option.label,
                icon = option.icon,
                job = jobs,
                canInteract = option.cn,
                action = option.fn
            }
        end

        local payload = { options = options, distance = 2.5 }
        qbTry('AddGlobalVehicle', {
            function()
                exports['qb-target']:AddGlobalVehicle({ options = options })
            end,
            function()
                exports['qb-target']:AddGlobalType(2, payload)
            end,
        })
    end

    function addModel(models, _options)
        local options = {}

        for i = 1, #_options do
            local option = _options[i]
            local jobs = convertJobs(option.groups)

            options[#options + 1] = {
                label = option.label,
                icon = option.icon,
                job = jobs,
                canInteract = option.cn,
                action = option.fn
            }
        end

        qbTry('AddTargetModel', {
            function()
                exports['qb-target']:AddTargetModel(models, { options = options })
            end,
        })
    end

    function addBoxZone(coords, _options)
        local options = {}

        for i = 1, #_options do
            local option = _options[i]
            local jobs = convertJobs(option.groups)

            options[#options + 1] = {
                label = option.label,
                icon = option.icon,
                job = jobs,
                canInteract = option.cn,
                action = option.fn
            }
        end

        local zoneName = ('detective_emsjob_%.2f_%.2f_%.2f'):format(coords.x, coords.y, coords.z)
        local targetOpts = { options = options, distance = 2.5 }

        qbTry('AddBoxZone', {
            function()
                exports['qb-target']:AddBoxZone(zoneName, coords, 1.5, 1.6, {}, targetOpts)
            end,
            function()
                exports['qb-target']:AddCircleZone(zoneName, coords, 2.5, {}, targetOpts)
            end,
        })
    end

    function addGlobalPlayer(_options)
        local options = {}

        for i = 1, #_options do
            local option = _options[i]
            local jobs = convertJobs(option.groups)

            options[#options + 1] = {
                label = option.label,
                icon = option.icon,
                job = jobs,
                canInteract = option.cn,
                action = option.fn,
            }
        end

        qbTry('AddGlobalPlayer', {
            function()
                exports['qb-target']:AddGlobalPlayer({ options = options, distance = 2.5 })
            end,
        })
    end
else
    print("^1[detective_emsjob] No ox_target or qb-target found after waiting. Targeting disabled.^7")
    print("^3[detective_emsjob] Start ox_target or qb-target before this resource, or set Config.TargetResource correctly.^7")

    function addLocalEntity() end

    function addGlobalVehicle() end

    function addModel() end

    function addBoxZone() end

    function addGlobalPlayer() end
end
