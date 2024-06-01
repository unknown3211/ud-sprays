local QBCore = exports['qb-core']:GetCoreObject()
local isPlacing = false
local tempSpray = nil
local SprayCoords = nil
local currentModelName = nil
local SprayRotation = 0.0

RegisterNetEvent('QBCore:Client:OnPlayerLoaded')
AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
    TriggerServerEvent('sprays:requestAllSprays')
end)

RegisterNetEvent('sprays:loadAllSprays')
AddEventHandler('sprays:loadAllSprays', function(sprays)
    for _, spray in ipairs(sprays) do
        local model = GetHashKey(spray.model)

        if not HasModelLoaded(model) then
            RequestModel(model)
            while not HasModelLoaded(model) do
                Citizen.Wait(0)
            end
        end

        local createdSpray = CreateObject(model, spray.pos_x, spray.pos_y, spray.pos_z, false, false, false)
        SetEntityHeading(createdSpray, spray.rotation)
    end
end)

RegisterNetEvent('ud:SprayText')
AddEventHandler('ud:SprayText', function(modelName)
    local player = PlayerId()
    local ped = GetPlayerPed(-1)
    SprayCoords = GetEntityCoords(ped)

    StartSprayPlacement(modelName)
end)

function StartSprayPlacement(modelName)
    currentModelName = modelName
    isPlacing = true
    local playerPed = GetPlayerPed(-1)
    local startCoord = GetEntityCoords(playerPed)
    local endCoord = GetOffsetFromEntityInWorldCoords(playerPed, 0.0, 5.0, 0.0) 
    local hit, _, endCoords, _, entityHit = GetShapeTestResult(CastRayPointToPoint(startCoord.x, startCoord.y, startCoord.z, endCoord.x, endCoord.y, endCoord.z, -1, playerPed, 0))
    
    if not hit then
        return
    end

    local heading
    if IsEntityAnObject(entityHit) then
        heading = GetEntityHeading(entityHit)
    else
        heading = GetEntityHeading(playerPed)
    end

    SprayCoords = endCoords

    local model = GetHashKey(modelName)
    RequestModel(model)
    while not HasModelLoaded(model) do
        Citizen.Wait(0)
    end

    tempSpray = CreateObject(model, SprayCoords.x, SprayCoords.y, SprayCoords.z, false, false, false)
    SetEntityHeading(tempSpray, heading)
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        if tempSpray then
            local x, y, z = table.unpack(GetEntityCoords(tempSpray, false))
            local pHit = IsLookingAtWall()
        
            if pHit then
                DrawMarker(23, x, y, z + 0.5, 0.0, 0.0, 0.0, 90.0, 0.0, 0.0, 1.5, 1.5, 0.05, 0, 255, 0, 100, false, true, 2, false, nil, nil, false, false, 0, 0, 1, false)
            end
        end

        if isPlacing and tempSpray then
            local forwardVector = GetEntityForwardVector(GetPlayerPed(-1))
            local rightVector = vector3(forwardVector.y, -forwardVector.x, 0)

            if IsControlPressed(0, 173) then  -- Down Arrow
                SprayCoords = SprayCoords + vector3(0.0, 0.0, -0.2)
            elseif IsControlPressed(0, 172) then  -- Up Arrow
                SprayCoords = SprayCoords + vector3(0.0, 0.0, 0.2)
            elseif IsControlPressed(0, 174) then  -- Left Arrow
                SprayCoords = SprayCoords - rightVector * 0.2
            elseif IsControlPressed(0, 175) then  -- Right Arrow
                SprayCoords = SprayCoords + rightVector * 0.2
            end

            SetEntityCoordsNoOffset(tempSpray, SprayCoords.x, SprayCoords.y, SprayCoords.z, true, true, true)

            local dWheel = GetControlNormal(0, 108) - GetControlNormal(0, 109)  -- Num Pad 4 + 6
            if dWheel ~= 0 then
                SprayRotation = SprayRotation + dWheel * 5.0
                SetEntityHeading(tempSpray, SprayRotation)
            end

            if IsControlJustReleased(0, 191) then  -- Enter Key
                isPlacing = false
                SetEntityAsNoLongerNeeded(tempSpray)

                local sprayCoords = GetEntityCoords(tempSpray)
                local sprayRotation = GetEntityHeading(tempSpray)

                print("Sending model: " .. tostring(modelName))
                TriggerServerEvent('sprays:saveToDatabase', SprayCoords.x, SprayCoords.y, SprayCoords.z, SprayRotation, currentModelName)

                tempSpray = nil
                StartSprayingAnimation()
            end
        end
    end
end)

function IsLookingAtWall()
    local playerPed = GetPlayerPed(-1)
    local startCoord = GetEntityCoords(playerPed)
    local stepSize = 10.0
    local distance = 10.0

    for angle = 0, 360, stepSize do
        local rotation = GetEntityHeading(playerPed) + angle
        local x = distance * math.sin(math.rad(rotation))
        local y = distance * math.cos(math.rad(rotation))
        
        local endCoord = startCoord + vector3(x, y, 0.0)
        local _, hit, _, _, entityHit = GetShapeTestResult(CastRayPointToPoint(startCoord.x, startCoord.y, startCoord.z, endCoord.x, endCoord.y, endCoord.z, -1, playerPed, 0))

        if hit then
            return true
        end
    end

    return false
end

function StartSprayingAnimation()
    local ped = GetPlayerPed(-1)
    local animDict2 = 'switch@franklin@lamar_tagging_wall'
    local animation2 = 'lamar_tagging_exit_loop_lamar'

    RequestAnimDict(animDict2)
    while not HasAnimDictLoaded(animDict2) do
        Citizen.Wait(0)
    end

    TaskPlayAnim(ped, animDict2, animation2, 8.0, -8.0, -1, 49, 0, false, false, false)

    --TriggerEvent("attachItemRadio","spraycan")
    QBCore.Functions.Progressbar("spraytext", "Spraying...", 10000, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {
        animDict = animDict2,
        anim = animation2,
        flags = 49,
    }, {}, {}, function()
        StopAnimTask(ped, animDict2, animation2, 1.0)
        --TriggerEvent("destroyPropRadio")
    end, function()
        StopAnimTask(ped, animDict2, animation2, 1.0)
        --TriggerEvent("destroyPropRadio")
    end)
end
