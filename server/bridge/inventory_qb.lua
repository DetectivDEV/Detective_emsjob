if InventoryType ~= 'qb' then return end

inv = {}

local qbInventory = exports['qb-inventory']

function inv.usesMoneyItem()
    return false
end

function inv.addItem(source, item, quantity)
    qbInventory:AddItem(source, item, quantity, false, false, 'detective_emsjob')
end

function inv.removeItem(source, item, quantity)
    qbInventory:RemoveItem(source, item, quantity, false, 'detective_emsjob')
end

function inv.clearPlayerInventory(source)
    qbInventory:ClearInventory(source)
end

function inv.getItemCount(source, item)
    return qbInventory:GetItemCount(source, item) or 0
end

function inv.getItemByName(source, name)
    local item = qbInventory:GetItemByName(source, name)
    if not item then return nil end

    local durability = item.info and (item.info.durability or item.info.quality)

    return {
        slot = item.slot,
        metadata = durability and { durability = durability } or {},
    }
end

function inv.setItemDurability(source, itemName, consumeValue)
    local item = qbInventory:GetItemByName(source, itemName)
    if not item then return end

    local info = item.info or {}
    local durability = info.durability or info.quality or 100
    info.durability = durability - consumeValue
    info.quality = info.durability

    qbInventory:SetItemData(source, itemName, 'info', info, item.slot)
end

function inv.openMedicalBag(source)
    local stashId = 'medicalBag_' .. source
    qbInventory:CreateInventory(stashId, {
        label = 'Medical Bag',
        maxweight = 50 * 1000,
        slots = 10,
    })
    return stashId
end

function inv.openStash(source, id)
    local stashConfig

    for _, hospital in pairs(Config.Hospitals) do
        if hospital.stash[id] then
            stashConfig = hospital.stash[id]
            break
        end
    end

    if stashConfig then
        qbInventory:CreateInventory(id, {
            label = stashConfig.label,
            maxweight = stashConfig.weight * 1000,
            slots = stashConfig.slots,
        })
    end

    qbInventory:OpenInventory(source, id)
end

function inv.openShop(source, name)
    qbInventory:OpenShop(source, name)
end

local function convertShopItems(items)
    local shopItems = {}

    for i = 1, #items do
        shopItems[#shopItems + 1] = {
            name = items[i].name,
            price = items[i].price,
            amount = 50,
        }
    end

    return shopItems
end

function inv.registerHospitalInventories()
    for _, hospital in pairs(Config.Hospitals) do
        for id, stash in pairs(hospital.stash) do
            qbInventory:CreateInventory(id, {
                label = stash.label,
                maxweight = stash.weight * 1000,
                slots = stash.slots,
            })
        end

        for id, pharmacy in pairs(hospital.pharmacy) do
            local items = convertShopItems(pharmacy.items)
            qbInventory:CreateShop({
                name = id,
                label = pharmacy.label,
                coords = pharmacy.pos,
                slots = #items,
                items = items,
            })
        end
    end
end

function inv.registerMedicalBagProtection()
end

function inv.payForTreatment(source, amount)
    if type(removePlayerMoney) == 'function' then
        return removePlayerMoney(source, amount)
    end

    return false
end
