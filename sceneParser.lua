-- This module loads scenes and ship files from res/ships and res/scenes.
local Spawn = require("spawn")

local SceneParser = {}

function SceneParser.loadShip(shipName)
end

function SceneParser.loadScene(sceneName, x, y)
	local ships = {}
	local index = 0
	local ifShipString = false
	local shipString = ""
	local shipID
	local locationString
	local fileName = string.format("/res/scenes/%s.txt", sceneName)
	for line in love.filesystem.lines(fileName) do
		if ifShipString then
			if string.match(line, "%}") then
				if not string.match(line, "%s%}") then
				shipString = shipString .. ""
				end
				ifShipString = false
				ships[index][4] = shipString
			else
				shipString = shipString .. line .. '\n'
			end
		else
			if string.match(line, "%w%([-0-9., ]*%)%[[-0-9., ]*%]")then
				shipID = string.match(line, "%w+")

				locationString = string.match(line, "%([-0-9., ]*%)")
				local location = {}
				for coord in string.gmatch(locationString, "[-0-9.]+") do 
					table.insert(location, tonumber(coord))
				end
				for i = 1,6 do
					if not location[i] then location[i] = 0 end
				end

				local dataString = string.match(line, "%[[-0-9., ]*%]")
				local data = {}
				for var in string.gmatch(dataString, "[-0-9.]+") do 
					table.insert(data, tonumber(var))
				end
				index = index + 1
				ships[index] = {shipID, location, data}
				if not data[1] then data[1] = 1 end
			elseif string.match(line, "%s*%{") then
				ifShipString = true
			end
		end
	end
	for i,ship in ipairs(ships) do
		ship = Spawn.spawnShip(ship[1],ship[2],ship[3],ship[4])
	end
	return ships
end

return SceneParser
