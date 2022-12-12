-----------------------------------------------------------------------------------------------------------------------------------------
-- LOADMODEL
-----------------------------------------------------------------------------------------------------------------------------------------
function LoadModel(Hash)
	local Time = 1000
	local Hash = GetHashKey(Hash)

	while not HasModelLoaded(Hash) or Time < 0 do
		RequestModel(Hash)
		Time = Time - 1
		Wait(1)
	end

	return true
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- LOADANIM
-----------------------------------------------------------------------------------------------------------------------------------------
function LoadAnim(Dict)
	local Time = 1000

	while not HasAnimDictLoaded(Dict) or Time < 0 do
		RequestAnimDict(Dict)
		Time = Time - 1
		Wait(1)
	end

	return true
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- LOADTEXTURE
-----------------------------------------------------------------------------------------------------------------------------------------
function LoadTexture(Library)
	local Time = 1000

	while not HasStreamedTextureDictLoaded(Library) or Time < 0 do
		RequestStreamedTextureDict(Library,false)
		Time = Time - 1
		Wait(1)
	end

	return true
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- LOADMOVEMENT
-----------------------------------------------------------------------------------------------------------------------------------------
function LoadMovement(Library)
	local Time = 1000

	while not HasAnimSetLoaded(Library) or Time < 0 do
		RequestAnimSet(Library)
		Time = Time - 1
		Wait(1)
	end

	return true
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- LOADPTFXASSET
-----------------------------------------------------------------------------------------------------------------------------------------
function LoadPtfxAsset(Library)
	local Time = 1000

	while not HasNamedPtfxAssetLoaded(Library) or Time < 0 do
		RequestNamedPtfxAsset(Library)
		Time = Time - 1
		Wait(1)
	end

	return true
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- LOADNETWORK
-----------------------------------------------------------------------------------------------------------------------------------------
function LoadNetwork(Network)
	local TimeNetwork = 1000
	local Network = NetworkGetEntityFromNetworkId(Network)
	while not DoesEntityExist(Network) or TimeNetwork < 0 do
		Network = NetworkGetEntityFromNetworkId(Network)
		TimeNetwork = TimeNetwork - 1
		Wait(1)
	end

	local TimeControl = 1000
	local Control = NetworkRequestControlOfEntity(Network)
	while not Control or TimeControl < 0 do
		Control = NetworkRequestControlOfEntity(Network)
		TimeControl = TimeControl - 1
		Wait(1)
	end

	return Network
end