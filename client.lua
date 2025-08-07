
local isAffected = false
local gasBlip = nil

RegisterNetEvent('joker:releaseGas')
AddEventHandler('joker:releaseGas', function()
    if isAffected then return end
    isAffected = true

    -- Play Joker laugh
    TriggerEvent('InteractSound_CL:PlayOnOne', 'joker_laugh', 1.0)

    -- Start Joker visuals
    StartScreenEffect('ChopVision', 0, true)

    -- Countdown with sounds, UI, and screen shakes
    for i = 10, 1, -1 do
        TriggerEvent('InteractSound_CL:PlayOnOne', 'countdown_' .. i, 0.8)
        SendNUIMessage({
            action = 'show',
            message = 'Joker Gas Incoming! ' .. i .. 's',
            color = 'crazy'
        })

        ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', i * 0.1)
        Wait(1000)
    end

    -- Final explosion sound and heavy screen shake
    TriggerEvent('InteractSound_CL:PlayOnOne', 'explosion', 1.5)
    ShakeGameplayCam('EXPLOSION_SHAKE', 2.0)

    -- Request explosions, blip, and emergency broadcast sync
    TriggerServerEvent('joker:triggerExplosionsBlipAlert')

    -- Extra smoke particles
    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)
    UseParticleFxAssetNextCall('core')
    local gas1 = StartParticleFxLoopedAtCoord('exp_grd_bzgas_smoke', pos.x, pos.y, pos.z + 1.0, 0.0, 0.0, 0.0, 2.5, false, false, false, false)
    local gas2 = StartParticleFxLoopedAtCoord('exp_grd_bzgas_smoke', pos.x + 1.0, pos.y, pos.z + 1.0, 0.0, 0.0, 0.0, 2.5, false, false, false, false)

    -- Laugh uncontrollably for 10 seconds
    local endTime = GetGameTimer() + 10000
    while GetGameTimer() < endTime do
        TaskStartScenarioInPlace(ped, 'WORLD_HUMAN_CHEERING', 0, true)
        SendNUIMessage({
            action = 'show',
            message = 'HAHAHA! You can’t stop laughing!',
            color = 'crazy'
        })
        Wait(1000)
    end

    ClearPedTasksImmediately(ped)

    -- Pass out for 10 seconds
    SendNUIMessage({
        action = 'show',
        message = 'You passed out!',
        color = 'red'
    })

    TaskStartScenarioInPlace(ped, 'WORLD_HUMAN_BUM_SLUMPED', 0, true)
    Wait(10000)

    -- Cleanup
    ClearPedTasksImmediately(ped)
    StopParticleFxLooped(gas1, 0)
    StopParticleFxLooped(gas2, 0)
    StopScreenEffect('ChopVision')

    -- Hide UI
    SendNUIMessage({
        action = 'hide'
    })

    isAffected = false
end)

RegisterNetEvent('joker:syncExplosionsBlipAlert')
AddEventHandler('joker:syncExplosionsBlipAlert', function(pos)
    -- Explosions
    for _ = 1, 5 do
        local offsetX = math.random(-5, 5)
        local offsetY = math.random(-5, 5)
        local explosionPos = vector3(pos.x + offsetX, pos.y + offsetY, pos.z)

        AddExplosion(explosionPos.x, explosionPos.y, explosionPos.z, 2, 1.0, true, false, 1.0)
    end

    -- Add blip to map
    if gasBlip then RemoveBlip(gasBlip) end

    gasBlip = AddBlipForCoord(pos.x, pos.y, pos.z)
    SetBlipSprite(gasBlip, 436) -- Joker face icon
    SetBlipColour(gasBlip, 1) -- Red color
    SetBlipScale(gasBlip, 1.2)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentSubstringPlayerName('Joker Gas Event')
    EndTextCommandSetBlipName(gasBlip)

    -- Remove blip after 1 minute
    Wait(60000)
    RemoveBlip(gasBlip)

    -- Emergency broadcast alert for all players
    TriggerEvent('chat:addMessage', {
        args = {"[EMERGENCY ALERT]", "Joker Gas has been released! Brace yourselves!"}
    })

    -- Play emergency siren sound for everyone
    TriggerEvent('InteractSound_CL:PlayOnOne', 'siren', 1.0)
end)

RegisterCommand('releasegas', function()
    TriggerServerEvent('joker:triggerGas')
end, false)
