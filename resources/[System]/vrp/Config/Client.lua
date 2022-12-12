-----------------------------------------------------------------------------------------------------------------------------------------
-- RichPresence
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("vRP:playerActive")
AddEventHandler("vRP:playerActive",function(user_id,name)
	SetDiscordAppId()
	SetDiscordRichPresenceAsset("south")
	SetRichPresence("#"..user_id.." "..name)
	SetDiscordRichPresenceAssetSmall("south")
	SetDiscordRichPresenceAssetText("South Network")
	SetDiscordRichPresenceAssetSmallText("South Network")
	SetDiscordRichPresenceAction(0,"Entrar na Cidade","#")
	SetDiscordRichPresenceAction(1,"Nosso Discord","#")
end)