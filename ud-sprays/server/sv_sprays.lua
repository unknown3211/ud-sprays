local QBCore = exports['qb-core']:GetCoreObject()

for itemName, sprayData in pairs(Config.Sprays) do
    QBCore.Functions.CreateUseableItem(itemName, function(source, item)
        TriggerClientEvent("ud:SprayText", source, sprayData.model)
    end)
end

RegisterServerEvent('sprays:saveToDatabase')
AddEventHandler('sprays:saveToDatabase', function(x, y, z, rotation, modelName)
    print("Received model: " .. tostring(modelName))
    local query = "INSERT INTO sprays (model_name, pos_x, pos_y, pos_z, rotation) VALUES (?, ?, ?, ?, ?)"
    exports.oxmysql:execute(query, { modelName, x, y, z, rotation })
end)

RegisterServerEvent('sprays:requestAllSprays')
AddEventHandler('sprays:requestAllSprays', function()
    print("Sprays requested from server!")
    local src = source
    local query = "SELECT * FROM sprays"
    
    exports.oxmysql:fetch(query, {}, function(sprays)
        if sprays and #sprays > 0 then
            TriggerClientEvent('sprays:loadAllSprays', src, sprays)
        else
            print("No sprays found in the database.")
        end
    end)
end)

AddEventHandler('onResourceStart', function(resource)
    if GetCurrentResourceName() == resource then
        local query = "SELECT * FROM sprays"
        exports.oxmysql:fetch(query, {}, function(sprays)
            print("Fetching from the database...")
            if sprays and #sprays > 0 then
                print("Found " .. #sprays .. " sprays in the database!")
                for _, playerId in ipairs(GetPlayers()) do
                    TriggerClientEvent('sprays:loadAllSprays', playerId, sprays)
                end
            else
                print("No sprays found in the database.")
            end
        end)
    end
end)

RegisterCommand('loadsprays', function(source, args, rawCommand)
    TriggerEvent('sprays:requestAllSprays')
end, false)
