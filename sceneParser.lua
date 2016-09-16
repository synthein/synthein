-- This module loads scenes and ship files from res/ships and res/scenes.
local Spawn = require("spawn")

local SceneParser = {}

function SceneParser.loadShip(shipName)
end

function SceneParser.loadScene(sceneName, x, y)
	local ships = {}
	local fileName = string.format("/res/scenes/%s.txt", sceneName)
	for line in love.filesystem.lines(fileName) do
		local shipID = string.match(line, "%w+")
		local locationString = string.match(line, "%([-0-9., ]*%)")
		local location = {}
		for coord in string.gmatch(locationString, "[-0-9.]+") do 
			table.insert(location, tonumber(coord))
		end
		for i = 1,6 do
			if not location[i] then
				location[i] = 0
			end
		end
		local dataString = string.match(line, "%[[-0-9., ]*%]")
		local data = {}
		for var in string.gmatch(dataString, "[-0-9.]+") do 
			table.insert(data, tonumber(var))
		end
		if not data[1] then
			data[1] = 1
		end
		table.insert(ships, Spawn.spawnShip(shipID, location, data))
	end
	return ships
end

return SceneParser
