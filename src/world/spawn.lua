-- Spawn some ships or other objects based on a table containing all of the
-- data required to produce them. This module is designed to be called in
-- SceneParser and Saves.
local Structure = require("world/structure")
local World = require("world/world")
local StructureParser = require("world/structureParser")

local Spawn = {}

function Spawn.spawnObject(world, key, location, data, shipInfo, shipType)
	local player = false
	--[[
	if key == "structures" then
		local stringLength, shipString
		if shipType then
			shipString, stringLength = Spawn.loadShipFromFile(shipInfo)
		else
			shipString = shipInfo
			stringLength = #shipString
		end

		data, player = StructureParser.shipUnpack(shipString, stringLength, data)
	end
	--]]
	local value = World.objectTypes[key]
	local object = value(world.info, location, data)
	world:addObject(object, key)
	return object, player
end

return Spawn
