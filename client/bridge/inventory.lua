inv = {}

function inv.usesMoneyItem()
    return InventoryType == 'ox'
end

function inv.payForTreatment(amount)
    return lib.callback.await('detective_emsjob:payParamedic', false, amount)
end

if InventoryType == 'ox' then
    function inv.getItemCount(item)
        return exports.ox_inventory:Search('count', item) or 0
    end

    function inv.openStash(id)
        exports.ox_inventory:openInventory('stash', id)
    end

    function inv.openShop(name)
        exports.ox_inventory:openInventory('shop', { type = name })
    end
elseif InventoryType == 'qb' then
    function inv.getItemCount(item)
        return lib.callback.await('detective_emsjob:getItemCount', false, item) or 0
    end

    function inv.openStash(id)
        TriggerServerEvent('detective_emsjob:openStash', id)
    end

    function inv.openShop(name)
        TriggerServerEvent('detective_emsjob:openShop', name)
    end
elseif not InventoryType then
    function inv.getItemCount()
        return 0
    end

    function inv.openStash() end

    function inv.openShop() end

    function inv.payForTreatment()
        return false
    end
end

RegisterNetEvent('detective_emsjob:openInventory', function(invType, id)
    if InventoryType ~= 'ox' then return end

    if invType == 'stash' then
        exports.ox_inventory:openInventory('stash', id)
    elseif invType == 'shop' then
        exports.ox_inventory:openInventory('shop', { type = id })
    end
end)
