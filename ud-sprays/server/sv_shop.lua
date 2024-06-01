local QBCore = exports['qb-core']:GetCoreObject()

RegisterServerEvent('ud-sprays:server:hasmoney')
AddEventHandler('ud-sprays:server:hasmoney', function(sprayKey)
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)
    local money = Player.PlayerData.money['cash']
    
    if not Config.Sprays[sprayKey] or not Config.ItemPrice[sprayKey] then
        TriggerClientEvent('QBCore:Notify', source, "Invalid item selected!", 'error')
        return
    end

    local sprayPrice = Config.ItemPrice[sprayKey]

    if money >= sprayPrice then
        Player.Functions.RemoveMoney('cash', sprayPrice, 'spray-purchase')
        Player.Functions.AddItem(sprayKey, 1, false)
        TriggerClientEvent("inventory:client:ItemBox", source, sprayKey, "add", 1)
        TriggerClientEvent('QBCore:Notify', source, "Item purchased successfully!", 'success')
    else
        TriggerClientEvent('QBCore:Notify', source, "You don't have enough money to purchase this item!", 'error')
    end
end)