local QBCore = exports['qb-core']:GetCoreObject()

local function isNear()
    if #(vector3(-297.4869, -1332.349, 31.296113) - GetEntityCoords(PlayerPedId())) < 5.0 then
        return true
    end
    return false
end

CreateThread(function()
    while not HasModelLoaded('g_m_y_famfor_01') do
        RequestModel('g_m_y_famfor_01')
        Wait(10)
    end

    ped = CreatePed(1, 'g_m_y_famfor_01',-297.734, -1332.666, 30.295812, 316.82653, false, false)
    FreezeEntityPosition(ped, true)
    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)

    exports['qb-target']:AddTargetEntity(ped, {
        options = {
            {
                label = 'Purchase Spray Can',
                icon = 'fa-solid fa-clock',
                action = function()
                    TriggerEvent('ud-sprays:OpenSprayMenu')
                end,
                canInteract = function()
                    return not IsEntityDead(PlayerPedId()) and isNear()
                end
            },
        },
        distance = 2.0
    })
end)

RegisterNetEvent('ud-sprays:OpenSprayMenu')
AddEventHandler('ud-sprays:OpenSprayMenu', function()
    exports['qb-menu']:openMenu({
        {
            header = "UD Sprays Menu",
            isMenuHeader = true
        },
        {
            header = 'Cerberus Spray',
            icon = "fas fa-spray-can",
            txt = "$" .. Config.ItemPrice['cerberuspaint'],
            params = {
                event = "ud-sprays:hasmoney",
                args = {
                    sprayKey = 'cerberuspaint'
                }
            }
        },
        {
            header = 'CG Spray',
            icon = "fas fa-spray-can",
            txt = "$" .. Config.ItemPrice['cgpaint'],
            params = {
                event = "ud-sprays:hasmoney",
                args = {
                    sprayKey = 'cgpaint'
                }
            }
        },
        {
            header = 'Ballas Spray',
            icon = "fas fa-spray-can",
            txt = "$" .. Config.ItemPrice['ballaspaint'],
            params = {
                event = "ud-sprays:hasmoney",
                args = {
                    sprayKey = 'ballaspaint'
                }
            }
        },
    })
end)

RegisterNetEvent('ud-sprays:hasmoney')
AddEventHandler('ud-sprays:hasmoney', function(data)
    local sprayKey = data.sprayKey
    TriggerServerEvent("ud-sprays:server:hasmoney", sprayKey)
end)

