local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")

local vRP = Proxy.getInterface("vRP")
local vRPclient = Tunnel.getInterface("vRP")

local SouthServer = {}
local SouthClient = Tunnel.getInterface("races")
Tunnel.bindInterface("races", SouthServer)

local preparingRaces = {}
local waitingRaces = {}
local activeRaces = {}

function SouthServer.tryParticipateRace(raceIndex)
    local source = source
    local user_id = vRP.getUserId(source)
    local sConfig = config.races[raceIndex]
    local raceHandler = #activeRaces + 1

    if sConfig.perm then
        if not vRP.hasPermission(user_id,sConfig.perm) then
            TriggerClientEvent('Notify',source,'importante','Sem permissão!')
            return false
        end
    end

    if waitingRaces[raceIndex] then return end

    if not preparingRaces[raceIndex] then
        waitingRaces[raceIndex] = true
        if not vRP.request(source, 'Deseja iniciar essa corrida?', 30) then
            waitingRaces[raceIndex]  = false
            return false
        end
        waitingRaces[raceIndex]  = false
        preparingRaces[raceIndex] = { owner = source, players = {}, bet = 0, timeLeft = 25, bets = {}, raceHandler = raceHandler, positions = {} }
    else
        if not vRP.request(source, 'Deseja participar dessa corrida?', 30) then
            return false
        end
    end

    if #preparingRaces[raceIndex].players >= #sConfig.vehicleCoords then
        TriggerClientEvent('Notify',source,'importante','Corrida atingiu o número máximo de jogadores.')
        return false
    end

    if preparingRaces[raceIndex].timeLeft <= 5 then
        return false
    end

    if sConfig.subscription == 'none' then
        preparingRaces[raceIndex].players[#preparingRaces[raceIndex].players + 1] = source
        preparingRaces[raceIndex].positions[#preparingRaces[raceIndex].positions + 1] = { src = source, distance = 1000.0, checkpoint = 0, lap = 1 }
        return true, preparingRaces[raceIndex].timeLeft, #preparingRaces[raceIndex].players, raceHandler
    end

    if sConfig.subscription == 'item' then
        if vRP.tryGetInventoryItem(user_id, sConfig.item[1], sConfig.item[2], true) then
            preparingRaces[raceIndex].players[#preparingRaces[raceIndex].players + 1] = source
            preparingRaces[raceIndex].positions[#preparingRaces[raceIndex].positions + 1] = { src = source, distance = 1000.0, checkpoint = 0, lap = 1 }
            
            exports['vrp_policia']:marcar_ocorrencia(source,'Recebemos uma denuncia de Corrida Ilegal, verifique o ocorrido',69)
            
            return true, preparingRaces[raceIndex].timeLeft, #preparingRaces[raceIndex].players, raceHandler
        else
            TriggerClientEvent('Notify',source,'negado','Você não possui '..sConfig.item[2]..'x '..sConfig.item[1] )
        end
    end

    if sConfig.subscription == 'bet' then
        local amount = tonumber(vRP.prompt(source, 'Digite a quantidade que deseja apostar. Aposta mínima: '..sConfig.minBet, ''))
        if not amount then return false end
        amount =  math.floor(amount)
        if not preparingRaces[raceIndex] or preparingRaces[raceIndex].timeLeft <= 5 then
            return false
        end
        if amount >= sConfig.minBet then
            if vRP.tryPayment(user_id,amount) then
                preparingRaces[raceIndex].players[#preparingRaces[raceIndex].players + 1] = source
                preparingRaces[raceIndex].bet += amount
                preparingRaces[raceIndex].bets[source] = amount
                preparingRaces[raceIndex].positions[#preparingRaces[raceIndex].positions + 1] = { src = source, distance = 1000.0, checkpoint = 0, lap = 1 }
                return true, preparingRaces[raceIndex].timeLeft,#preparingRaces[raceIndex].players, raceHandler
            end
        end
    end

    if preparingRaces[raceIndex].owner == source then
        preparingRaces[raceIndex] = nil
    end

    return false
end

local function StartRaceHandler(raceIndex)
    local raceHandler = preparingRaces[raceIndex].raceHandler
    local sConfig = config.races[raceIndex]
    activeRaces[raceHandler] = {}
    for k,v in pairs(preparingRaces[raceIndex]) do
        activeRaces[raceHandler][k] = v
    end
    preparingRaces[raceIndex] = nil
    activeRaces[raceHandler].finished = { amount = 0}
    activeRaces[raceHandler].raceIndex = raceIndex
    activeRaces[raceHandler].plys = {}
    for k,v in pairs(activeRaces[raceHandler].players) do
        activeRaces[raceHandler].plys[v] = true
        TriggerClientEvent('races:setPlayers', v, #activeRaces[raceHandler].players, activeRaces[raceHandler].players, true)
        TriggerEvent('eblips:add',{ name = "Corredor", src = v, color = 69 })
    end
    -- local police = exports['core']:getInservice("policia.permissao")
    -- for l,w in pairs(police) do
    --     local player = vRP.getUserSource(parseInt(w))
    --     TriggerClientEvent('races:callPolice', player, sConfig.startCoords, true)
    -- end
end

local function RaceTimeLeftHandler()
    while true do
        for k,v in pairs(preparingRaces) do
            if v.timeLeft then
                v.timeLeft -= 1
                if v.timeLeft <= 0 then
                    v.timeLeft = false
                    StartRaceHandler(k)
                end
            end
        end
        Wait(1000)
    end
end

local function RacePositionHandler()
    while true do
        for k,v in pairs(activeRaces) do
            for _, pos in pairs(v.positions) do
                if v.plys[pos.src] then
                    TriggerClientEvent('races:updateRace', pos.src, _, #v.players)
                end
                activeRaces[k].positions = {}
            end
        end
        Wait(500)
    end
end

CreateThread(RaceTimeLeftHandler)
CreateThread(RacePositionHandler)

RegisterNetEvent('races:cancelRace', function(raceIndex)
    local source = source
    local sConfig = config.races[raceIndex]

    if not preparingRaces[raceIndex] then return end

    if preparingRaces[raceIndex].owner == source then
        for k,v in pairs(preparingRaces[raceIndex].players) do
            if sConfig.subscription == 'item' then
                vRP.giveInventoryItem(vRP.getUserId(v), sConfig.item[1], sConfig.item[2], true)
            end
        
            if sConfig.subscription == 'bet' then
                vRP.giveMoney(user_id, preparingRaces[raceIndex].bets[v])
            end
 
            TriggerClientEvent('races:cancelRace', v)
        end
        preparingRaces[raceIndex] = nil
    else
        for k,v in pairs(preparingRaces[raceIndex].players) do
            if v == source then                 
                TriggerClientEvent('races:cancelRace', v)
                return table.remove(preparingRaces[raceIndex].players, k)
            end
        end
    end
end)

RegisterNetEvent('races:leftRace', function(raceHandler)
    local source = source
    if activeRaces[raceHandler] then
        TriggerEvent('eblips:remove',source)
        activeRaces[raceHandler].plys[source] = false
        for k,v in pairs(activeRaces[raceHandler].players) do
            if v == source then
                table.remove(activeRaces[raceHandler].players, k)   
            end
        end
        for k,v in pairs(activeRaces[raceHandler].players) do
            TriggerClientEvent('races:setPlayers', v, #activeRaces[raceHandler].players, activeRaces[raceHandler].players)
        end
    end
end)

RegisterNetEvent('races:updateRace', function(raceHandler, distance, checkpoint, lap, time)
    local source = source
    if activeRaces[raceHandler] then
        activeRaces[raceHandler].positions[#activeRaces[raceHandler].positions + 1] = { src = source, distance = distance, checkpoint = checkpoint, lap = lap, time = time }
        if #activeRaces[raceHandler].positions == #activeRaces[raceHandler].players then
            table.sort(activeRaces[raceHandler].positions, function(a,b)
                
                if activeRaces[raceHandler].finished[a.src] and activeRaces[raceHandler].finished[b.src] then
                    return a.time < b.time
                end

                if activeRaces[raceHandler].finished[a.src] then 
                    return true
                end

                if activeRaces[raceHandler].finished[b.src] then 
                    return false
                end
                
                if a.lap ~= b.lap then
                    return a.lap > b.lap
                end

                if a.checkpoint ~= b.checkpoint then
                    return a.checkpoint > b.checkpoint
                end

                return a.distance < b.distance

            end)
        end
    end
end)

RegisterNetEvent('races:finishRace', function(raceHandler, time, vehicle, position)
    local source = source
    local user_id = vRP.getUserId(source)
    if not activeRaces[raceHandler] then 
        return
    end
    TriggerEvent('eblips:remove',source)
    local sConfig = config.races[activeRaces[raceHandler].raceIndex]

    vRP._execute('races/register_race',{
        user_id = user_id,
        time = time,
        race = activeRaces[raceHandler].raceIndex,
        vehicle = vehicle,
        position = position
    })
    
    activeRaces[raceHandler].finished[source] = { pos = position, veh = vehicle, time = time }
    activeRaces[raceHandler].finished.amount += 1
    local correctStats = {}
    for k,v in pairs(activeRaces[raceHandler].finished) do
        if k ~= 'amount' then
            correctStats[v.pos] = { name = vRP.userIdentity(vRP.getUserId(k)).name, veh = v.veh, time = v.time }
        end
    end
    for k,v in pairs(activeRaces[raceHandler].finished) do
        if k ~= 'amount' then
            TriggerClientEvent('races:updateRaceStats', k, correctStats, v.pos)
        end
    end

    local playersAmount = #activeRaces[raceHandler].players
    local percentMultiplier = 
            playersAmount == 1 and position == 1 and 1.0 or
            playersAmount == 2 and position == 1 and 0.7 or position == 2 and 0.3 or
            playersAmount >= 3 and position == 1 and 0.5 or position == 2 and 0.3 or position == 3 and 0.2 or 0.0

    if sConfig.subscription == 'bet' then
        vRP.giveInventoryItem(user_id, config.spawnDinheiroSujo,  activeRaces[raceHandler].bet * percentMultiplier)
        TriggerClientEvent('Notify',source,'importante','Você recebeu $'.. activeRaces[raceHandler].bet * percentMultiplier)
    else
        vRP.giveInventoryItem(user_id, config.spawnDinheiroSujo, sConfig.prize * percentMultiplier)
        TriggerClientEvent('Notify',source,'importante','Você recebeu $'.. sConfig.prize * percentMultiplier)
    end

    if playersAmount <= activeRaces[raceHandler].finished.amount then
        activeRaces[raceHandler] = nil
    end

    -- exports["wanted"]:setWanted(user_id,500)
end)

RegisterNetEvent('races:callPolice', function(coords)
    -- local police = exports['core']:getInservice("policia.permissao")
    -- for l,w in pairs(police) do
    --     local player = vRP.getUserSource(parseInt(w))
    --     TriggerClientEvent('races:callPolice', player, coords)
    -- end
end)

RegisterCommand('racerank', function(source,args,rawC)
    local user_id = vRP.getUserId(source)
    local rows = vRP.query('races/get_races',{limit = 10})
    for k,v in pairs(rows) do
        rows[k].name = vRP.userIdentity(v.user_id).name
        rows[k].vehicle = vRP.vehicleName(v.best_vehicle)
    end
    TriggerClientEvent('races:openRank', source, rows)
end)

RegisterCommand('racerank2', function(source,args,rawC)
    local rows = vRP.query('races/get_race',{limit = 10, race = 1})
    for k,v in pairs(rows) do
        rows[k].name = vRP.userIdentity(v.user_id).name
        rows[k].vehicle = vRP.vehicleName(v.best_vehicle)
    end
    TriggerClientEvent('races:openRank2', source, rows)
end)

function SouthServer.getRaceRows(raceIndex, u_id)
    if u_id then
        local rows = vRP.query('races/get_player_race',{limit = 10, race = raceIndex == 'global' and '%%' or raceIndex, user_id = u_id})
        for k,v in pairs(rows) do
            rows[k].name = vRP.userIdentity(v.user_id).name
            rows[k].vehicle = vRP.vehicleName(v.vehicle)
        end
        return rows
    else
        local rows = vRP.query('races/get_race',{limit = 10, race = raceIndex})
        for k,v in pairs(rows) do
            rows[k].name = vRP.userIdentity(v.user_id).name
            rows[k].vehicle = vRP.vehicleName(v.best_vehicle)
        end
        return rows
    end
end

function SouthServer.playerWanted()
    local source = source
    local user_id = vRP.getUserId(source)
    return true
	-- if not exports["wanted"]:checkWanted(user_id) then
	-- 	return true
	-- end
	-- TriggerClientEvent("Notify",source,"atenção","Você está sendo procurado(a), aguarde.")
	-- return false
end