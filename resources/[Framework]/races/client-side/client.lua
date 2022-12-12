local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")

local vRP = Proxy.getInterface("vRP")
local vRPserver = Tunnel.getInterface("vRP")

local SouthClient = {}
local SouthServer = Tunnel.getInterface("races")
Tunnel.bindInterface("races", SouthClient)

local inRace = false
local PlayerPed, PlayerCds, PlayerVeh, PlayerVehClass = 0, vec3(0.0,0.0,0.0), 0, nil
local TimeLeftForRaceStart, CurrentRace, VehicleCoordsSelected, CurrentCheckpoint, CurrentRaceHandler, ActiveCheckpoint, CurrentRacePlayers, CurrentPos, CurrentLap, CanShowRaceStats, timeDiff = 60, nil, 1, 1, nil, nil, {}, 0, 1
local raceMapBlip, racingPeds, WaitingForRace = nil, {}, false

local function FormatTime(time, milliseconds)
    time = milliseconds and math.floor(time / 10) or time
    if milliseconds then
        time = math.floor(time / 10)
    end
    if time < 10 then
        return '0' .. time
    else
        return time < 10 and '0' .. time or time
    end
end

local function FormatTimeToNUI(time)
    if time < 1000 then
        return '00:00:' .. FormatTime(time, true)
    end
    if time < 10000 then
        local milliseconds = time % 1000
        local seconds = math.floor((time - milliseconds) / 1000)
        return '00:0' .. seconds .. ':' .. FormatTime(milliseconds, true)
    end
    if time < 60000 then
        local milliseconds = time % 1000
        local seconds = math.floor((time - milliseconds) / 1000)
        return '00:' .. seconds .. ':' .. FormatTime(milliseconds, true)
    end
    if time >= 60000 then
        local result = time % 60000
        local milliseconds = result % 1000
        local seconds = math.floor((result - milliseconds) / 1000)
        local milliseconds = time % 1000
        local minutes = math.floor((time - result) / 60000)
        return FormatTime(minutes) .. ':' .. FormatTime(seconds) .. ':' .. FormatTime(milliseconds, true)
    end
    return time
end

local function initBlips()
    for k,v in pairs(config.races) do
        if v.blip then
            local blip = AddBlipForCoord(v.startCoords)
            SetBlipSprite(blip, 523)
            SetBlipColour(blip, 2)
            SetBlipScale(blip,0.5)
            SetBlipAsShortRange(blip,true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(' '..v.name)
            EndTextCommandSetBlipName(blip)
        end
    end
end

local function handleLeftRace()
    SendNUIMessage({action = 'hideRaceInfo'})
    CreateThread(initRace)
    DeleteCheckpoint(ActiveCheckpoint)
end

local function handleLeftCarDuringRace()
    local sConfig = config.races[CurrentRace]
    while inRace do
        if PlayerVeh == 0 and inRace then
            inRace = false
            TriggerServerEvent("races:leftRace",CurrentRaceHandler)
            handleLeftRace()
            if sConfig.explosive and inRace then
                local veh = GetVehiclePedIsIn(PlayerPed,true)
                Wait(3000)
                if DoesEntityExist(veh) and inRace then
                    local vehCoords = GetEntityCoords(veh)
                    NetworkExplodeVehicle(veh, true, false, false)
                    inRace = false
                end
            end
        end
        Wait(500)
    end
end

local function createBlip(coords)
    if raceMapBlip then
        RemoveBlip(raceMapBlip)
    end
    raceMapBlip = AddBlipForCoord(coords)
    SetBlipSprite(raceMapBlip, 38)
    SetBlipScale(raceMapBlip, 0.4)
    SetBlipColour(raceMapBlip, 2)
    SetBlipAsShortRange(raceMapBlip, true)
    SetBlipRoute(raceMapBlip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString('Checkpoint')
    EndTextCommandSetBlipName(raceMapBlip)
end

local function handleNearestPlayers()
    local vehBlips = {}
    while inRace do
        for k,v in pairs(GetGamePool('CVehicle')) do
            if racingPeds[VehToNet(v)] then
                if not vehBlips[v] then
                    local blip = AddBlipForEntity(v)
                    vehBlips[v] = blip
                    SetBlipAsFriendly(blip, false)
                    SetBlipSprite(blip, 6)
                    SetBlipScale(blip, 0.4)
                    SetBlipColour(blip, 1)
                    SetBlipAsShortRange(blip, false)
                    SetBlipRoute(blip, false)
                    SetBlipRotation(blip, math.ceil(GetEntityHeading(v)))
                    BeginTextCommandSetBlipName("STRING")
                    AddTextComponentString('Corredor')
                    EndTextCommandSetBlipName(blip)
                    SetTimeout(5000, function()
                        RemoveBlip(blip)
                        vehBlips[v] = nil
                    end)
                else
                    SetBlipRotation(vehBlips[v], math.ceil(GetEntityHeading(v)))
                end
            end
        end
        Wait(50)
    end
    for k,v in pairs(vehBlips) do
        RemoveBlip(v)
    end
end

local function initParticipateRace()
    local sConfig = config.races[CurrentRace]
    local sCoords = sConfig.vehicleCoords[VehicleCoordsSelected]
    WaitingForRace = true
    DoScreenFadeOut(1000)
    Wait(1000)
    SetEntityCoordsNoOffset(PlayerVeh, sCoords.x,sCoords.y,sCoords.z, false, false, false)
    SetEntityHeading(PlayerVeh, sCoords.w)
    FreezeEntityPosition(PlayerVeh, true)
    SetVehicleOnGroundProperly(PlayerVeh)
    DoScreenFadeIn(1000)
    TimeLeftForRaceStart -= 1
    SendNUIMessage({action = 'WaitForRace', timeLeft = TimeLeftForRaceStart})
    CreateThread(function()
        while WaitingForRace do
            if PlayerVeh == 0 then
                TriggerServerEvent('races:cancelRace', CurrentRace)
            end
            Wait(100)
        end
    end)
    while WaitingForRace do
        Wait(0)
    end
    FreezeEntityPosition(PlayerVeh, false)
    CurrentCheckpoint = 1
    local sCheck = config.races[CurrentRace].checkpoints[CurrentCheckpoint]
    local sCheck2 = config.races[CurrentRace].checkpoints[CurrentCheckpoint + 1]
    local checkP = CreateCheckpoint(7, sCheck + vec3(0.0,0.0,3.0), sCheck2 + vec3(0.0,0.0,3.0), 10.0, 0,255, 0, 150, 0)
    createBlip(sCheck)
    local startTime = GetGameTimer()
    SetCheckpointRgba(checkP, 255, 255, 255, 50)
    ActiveCheckpoint = checkP
    CreateThread(handleLeftCarDuringRace)
    CreateThread(handleNearestPlayers)
    for lap = 1, sConfig.laps do
        CurrentLap = lap
        while inRace do
            local DistanceBetweenRaceCheckPoint = #(PlayerCds - sCheck)
            timeDiff = GetGameTimer() - startTime
            if DistanceBetweenRaceCheckPoint <= 25.0 then
                if sConfig.callPolice then
                    TriggerServerEvent('races:callPolice', sCheck)
                end
                if CurrentCheckpoint == #config.races[CurrentRace].checkpoints then
                    CurrentCheckpoint = 1
                    sCheck = config.races[CurrentRace].checkpoints[CurrentCheckpoint]
                    sCheck2 = config.races[CurrentRace].checkpoints[CurrentCheckpoint + 1]
                    DeleteCheckpoint(checkP)
                    if lap ~= sConfig.laps then
                        checkP = CreateCheckpoint(7, sCheck + vec3(0.0,0.0,3.0), sCheck2 + vec3(0.0,0.0,3.0), 10.0, 0,255, 0, 150, 0)
                        createBlip(sCheck)
                        SetCheckpointRgba(checkP, 255, 255, 255, 50)
                    end
                    break
                end
                CurrentCheckpoint += 1
                sCheck = config.races[CurrentRace].checkpoints[CurrentCheckpoint]
                sCheck2 = config.races[CurrentRace].checkpoints[CurrentCheckpoint == #config.races[CurrentRace].checkpoints and 1 or CurrentCheckpoint + 1]
                DeleteCheckpoint(checkP)
                checkP = CreateCheckpoint(7, sCheck + vec3(0.0,0.0,3.0), sCheck2 + vec3(0.0,0.0,3.0), 10.0, 0,255, 0, 150, 0)
                createBlip(sCheck)
                ActiveCheckpoint = checkP
                SetCheckpointRgba(checkP, 255, 255, 255, 50)
            end

            if sConfig.timeLimit then
                if timeDiff > sConfig.timeLimit then
                    TriggerServerEvent("races:leftRace", CurrentRaceHandler)
                    handleLeftRace()
                    if sConfig.explosive then
                        local veh = GetVehiclePedIsIn(PlayerPed,true)
                        Wait(3000)
                        if DoesEntityExist(veh) then
                            NetworkExplodeVehicle(veh, true, false, false)
                            return
                        end
                    end
                end
            end

            SendNUIMessage({
                action = 'updateInfos',
                currentPos = CurrentPos,
                lastPos = CurrentRacePlayers,
                time = FormatTimeToNUI( sConfig.timeLimit and sConfig.timeLimit - timeDiff or timeDiff),
                currentCheckpoint = CurrentCheckpoint,
                lastCheckpoint = #config.races[CurrentRace].checkpoints,
                currentLap = lap,
                lastLap = sConfig.laps,
                showRed = sConfig.timeLimit and sConfig.timeLimit - timeDiff < 10000 or false
            })
            Wait(50)
        end
    end
    racingPeds = {}
    RemoveBlip(raceMapBlip)
    DeleteCheckpoint(checkP)
    if not inRace then
        return
    end
    local veh, netVeh, plate, vname = vRP.vehList(3.0)
    TriggerServerEvent("races:finishRace", CurrentRaceHandler, GetGameTimer() - startTime, vname, CurrentPos)
    SendNUIMessage({
        action = 'hideRaceInfo'
    })
    inRace = false
    CanShowRaceStats = true
    while true do
        Wait(4)
        DisableControlAction(0,200,true)
        if IsDisabledControlJustReleased(0, 200) then
            break
        end
    end
    CanShowRaceStats = false
    SendNUIMessage({
        action = 'hideRaceStats'
    })
    
    CreateThread(initRace)
    return
end

function initRace()
    while not inRace do
        local msec = 1000
        if PlayerVeh ~= 0 then
            for k,v in pairs(config.races) do
                local DistanceBetweenRacePoint = #(PlayerCds - v.startCoords)
                if DistanceBetweenRacePoint <= 25.0 and not v.blockedCategories[PlayerVehClass] then
                    msec = 4
                    DrawMarker(4, v.startCoords.x, v.startCoords.y, v.startCoords.z + 1.5, 0.0,0.0,0.0,0.0,0.0,0.0, 2.0, 0.2, 2.0, 0, 255, 0, 125, true, false, 0, true, nil, nil, false)
                    DrawMarker(25, v.startCoords, 0.0,0.0,0.0,0.0,0.0,0.0, 15.0, 15.0, 15.0, 0, 255, 0, 125, false, false, 0, false, nil, nil, false)
                    if DistanceBetweenRacePoint <= 10.0 then
                        if IsControlJustPressed(0,38) and SouthServer.playerWanted() then
                            local success, timeLeft, sVehCoords, raceHandler = SouthServer.tryParticipateRace(k)
                            if success then
                                TimeLeftForRaceStart = timeLeft
                                VehicleCoordsSelected = sVehCoords
                                CurrentRace = k
                                CurrentRaceHandler = raceHandler
                                CurrentPos = sVehCoords
                                inRace = true
                                CreateThread(initParticipateRace)
                            end
                            Wait(5000)
                        end
                    end
                end
            end
        end
        Wait(msec)
    end
end

local function initPlayer()
    while true do
        PlayerPed = PlayerPedId()
        PlayerCds = GetEntityCoords(PlayerPed)
        PlayerVeh = GetVehiclePedIsIn(PlayerPed, false)
        PlayerVehClass = PlayerVeh ~= 0 and GetVehicleClass(PlayerVeh) or nil
        Wait(500)
    end
end

CreateThread(initRace)
CreateThread(initPlayer)
CreateThread(initBlips)

RegisterNetEvent('races:cancelRace',function()
    inRace = false
    local veh = GetVehiclePedIsIn(PlayerPed, true)
    FreezeEntityPosition(veh, false)
    TriggerServerEvent('races:setVehicleCollision', VehToNet(PlayerVeh), false)
    SendNUIMessage({action = 'cancelRace', timeLeft = TimeLeftForRaceStart})
    CreateThread(initRace)
end)

RegisterNetEvent('races:setPlayers', function(playerAmount, players, startRace)
    CurrentRacePlayers = playerAmount
    for k,v in pairs(players) do
        racingPeds[VehToNet(GetVehiclePedIsIn(GetPlayerPed(GetPlayerFromServerId(v))))] = true
    end
    if startRace then
        WaitingForRace = false
    end
end)

RegisterNetEvent('races:updateRace', function(position, playerAmount)
    CurrentPos = position
    CurrentRacePlayers = playerAmount
    local sCheck = config.races[CurrentRace].checkpoints[CurrentCheckpoint]
    TriggerServerEvent('races:updateRace', CurrentRaceHandler, #(GetEntityCoords(PlayerPed) - sCheck), CurrentCheckpoint, CurrentLap, timeDiff)
end)

RegisterNetEvent('races:updateRaceStats', function(stats, position)
    if CanShowRaceStats then
        for k,v in pairs(stats) do
            stats[k] = { name = v.name, pos = v.pos, time = FormatTimeToNUI(v.time), veh = v.veh }
        end
        SendNUIMessage({
            action = 'showRaceStats',
            stats = stats,
            position = position
        })
    end
end)

RegisterNetEvent('races:callPolice', function(coords, notify)
    local blip = AddBlipForCoord(coords)
    SetBlipSprite(blip, 38)
    SetBlipScale(blip, 0.6)
    SetBlipColour(blip, 1)
    SetBlipAsShortRange(blip, true)
    SetBlipRoute(blip, false)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString('Corredor Ilegal')
    EndTextCommandSetBlipName(blip)
    SetTimeout(60000,function()
        RemoveBlip(blip)
    end)
    if notify then
        PlaySoundFrontend(-1,"Out_Of_Bounds_Timer","DLC_HEISTS_GENERAL_FRONTEND_SOUNDS",false)
        TriggerEvent('Notify','importante','Corrida ilegal em andamento.')
        TriggerEvent("NotifyPush",{ code = 90, title = "Corrida Ilegal", text = "Corredores ilegais aterrozando o trânsito da cidade",  x = coords.x, y = coords.y, z = coords.z, name = "Ocorrência", rgba = {140,35,35} })
    end
end)

local racesRows = {}
local playersRows = {}

RegisterNetEvent('races:openRank', function(rows)
    for k,v in pairs(rows) do
        rows[k].time = FormatTimeToNUI(v.time)
    end
    racesRows.global = rows
    SendNUIMessage({
        action = 'openRank',
        rows = rows,
        races = config.races
    })
    SetNuiFocus(true,true)
end)

RegisterNetEvent('races:openRank2', function(rows)
    for k,v in pairs(rows) do
        rows[k].time = FormatTimeToNUI(v.time)
    end
    SendNUIMessage({
        action = 'openRank2',
        rows = rows
    })
    SetNuiFocus(true,true)
end)

RegisterNUICallback('getRaceRows', function(data,cb)
    if data.u_id then
        if not playersRows[data.race] then
            playersRows[data.race] = {}
            playersRows[data.race][data.u_id] = SouthServer.getRaceRows(data.race, data.u_id)
            for k,v in pairs(playersRows[data.race][data.u_id] ) do
                playersRows[data.race][data.u_id] [k].time = FormatTimeToNUI(v.time)
            end
        else
            if not playersRows[data.race][data.u_id] then
                playersRows[data.race][data.u_id] = SouthServer.getRaceRows(data.race, data.u_id)
                for k,v in pairs(playersRows[data.race][data.u_id] ) do
                    playersRows[data.race][data.u_id] [k].time = FormatTimeToNUI(v.time)
                end
            end
        end
        cb({
            rows = playersRows[data.race][data.u_id]
        })
    else
        if not racesRows[data.race] then
            racesRows[data.race] = SouthServer.getRaceRows(data.race)
            for k,v in pairs(racesRows[data.race]) do
                racesRows[data.race][k].time = FormatTimeToNUI(v.time)
            end
        end
        cb({
            rows = racesRows[data.race]
        })
    end
end)

RegisterNUICallback('close', function(data,cb)
    SetNuiFocus(false,false)
    cb({})
    racesRows = {}
end)

-- RegisterCommand('getcoordsforcars', function()
--     local mhash = `elegy`
--     RequestModel(mhash)
--     while not HasModelLoaded(mhash) do Wait(10) end
--     local veh = CreateVehicle(mhash, x,y,z, heading, false, false)
--     for i = 1, 5 do
--         local cds = GetOffsetFromEntityInWorldCoords(veh, 0.0, 3.5 * i, 0.0)
--         vRP.prompt(cds, cds)
--         local veh2 = CreateVehicle(mhash, cds, heading, false, false)
--     end
-- end)