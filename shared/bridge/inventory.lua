local function resolveInventoryType()
    if Config.Inventory == 'ox' then
        return 'ox'
    elseif Config.Inventory == 'qb' then
        return 'qb'
    end

    if GetResourceState('ox_inventory'):find('start') then
        return 'ox'
    end

    if GetResourceState('qb-inventory'):find('start') then
        return 'qb'
    end

    return nil
end

InventoryType = resolveInventoryType()

if not InventoryType then
    print('^1[detective_emsjob] No inventory found. Start ox_inventory or qb-inventory, or set Config.Inventory.^0')
end
