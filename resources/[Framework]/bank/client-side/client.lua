-----------------------------------------------------------------------------------------------------------------------------------------
-- VRP
-----------------------------------------------------------------------------------------------------------------------------------------
local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")
-----------------------------------------------------------------------------------------------------------------------------------------
-- CONNECTION
-----------------------------------------------------------------------------------------------------------------------------------------
vSERVER = Tunnel.getInterface("bank")
-----------------------------------------------------------------------------------------------------------------------------------------
-- BANK:OPENSYSTEM
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler("bank:openSystem",function()
	if vSERVER.requestWanted() then
		SetNuiFocus(true,true)
		SendNUIMessage({ action = "show" })
		vRP.playAnim(false,{"amb@prop_human_atm@male@idle_a","idle_a"},false)
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- CLOSE
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("close",function()
	vRP.removeObjects()
	SetNuiFocus(false,false)
	SendNUIMessage({ action = "hide" })
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- DEPOSIT
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("deposit",function(data)
	if parseInt(data["value"]) > 0 and MumbleIsConnected() then
		vSERVER.bankDeposit(data["value"])
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- WITHDRAW
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("withdraw",function(data)
	if parseInt(data["value"]) > 0 and MumbleIsConnected() then
		vSERVER.bankWithdraw(data["value"])
	end
end)