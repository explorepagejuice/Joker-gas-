
RegisterServerEvent('joker:triggerGas')
AddEventHandler('joker:triggerGas', function()
    TriggerClientEvent('joker:releaseGas', -1)
end)

RegisterServerEvent('joker:triggerExplosionsBlipAlert')
AddEventHandler('joker:triggerExplosionsBlipAlert', function()
    local src = source
    local ped = GetPlayerPed(src)
    local pos = GetEntityCoords(ped)

    -- Sync explosions, blip, and alert for all players
    TriggerClientEvent('joker:syncExplosionsBlipAlert', -1, pos)
end)
