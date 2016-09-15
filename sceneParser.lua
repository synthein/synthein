-- This module loads scenes and ship files from res/ships and res/scenes.
local Spawn = require("spawn")

local SceneParser = {}

function SceneParser.loadShip(shipName)
end

function SceneParser.loadScene(sceneName, x, y)
	local file = string.format("res/scenes/%s.txt", sceneName)
	local contents, size = love.filesystem.read(file)
	local shipID = string.match(contents, "%w+")
	local locationString = string.match(contents, "%([-0-9., ]*%)")
	local location = {}
	for coord in string.gmatch(locationString, "[-0-9.]+") do 
		table.insert(location, tonumber(coord))
	end
	for i = 1,6 do
		if not location[i] then
			location[i] = 0
		end
	end
	return {Spawn.spawnShip(shipID, location)}
end

return SceneParser
