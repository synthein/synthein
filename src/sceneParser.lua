-- This module loads scenes and ship files from res/ships and res/scenes.
local Spawn = require("spawn")
local Util = require("util")

local SceneParser = {}

function SceneParser.loadShip(shipName)
end

function SceneParser.loadScene(sceneName, world, location, ifSave)
	local ships = {}
	local index = 0
	local ifShipString = false
	local shipString = ""
	local shipID
	local locationString
	local fileName
	if ifSave then
		fileName = string.format("%s.txt", sceneName)
	else
		fileName = string.format("/res/scenes/%s.txt", sceneName)
	end
	if not love.filesystem.exists(fileName) then 
		return {}, {}
	end
	for line in love.filesystem.lines(fileName) do
		if ifShipString then
			if string.match(line, "%}") then
				if not string.match(line, "%s%}") then
				shipString = shipString .. ""
				end
				ifShipString = false
				ships[index][4] = shipString
				shipString = ""
			else
				shipString = shipString .. line .. '\n'
			end
		else
			if string.match(line, "%w%([-0-9., ]*%)%[[-0-9., ]*%]")then
				shipID = string.match(line, "%w+")

				locationString = string.match(line, "%([-0-9., ]*%)")
				local l = {}
				for coord in string.gmatch(locationString, "[-0-9.]+") do 
					table.insert(l, tonumber(coord))
				end
				for i = 1,6 do
					if not l[i] then l[i] = 0 end
				end

				if not location[3] then location[3] = 0 end

				l[1], l[2] = Util.computeAbsCoords(l[1], l[2], location[3])
				l[4], l[5] = Util.computeAbsCoords(l[4], l[5], location[3])
				
				for i = 1,3 do
					l[i] = l[i] + location[i]
				end

				local dataString = string.match(line, "%[[-0-9., ]*%]")
				local data = {}
				for var in string.gmatch(dataString, "[-0-9.]+") do 
					table.insert(data, tonumber(var))
				end
				if not data[1] then data[1] = 1 end
				index = index + 1
				ships[index] = {shipID, l, data}
			elseif string.match(line, "%s*%{") then
				ifShipString = true
			end
		end
	end
	spawnedShips = {}
	local shipType = {}
	for i,ship in ipairs(ships) do
		spawnedShips[i], shipType[i] = Spawn.spawnShip(ship[1], world, ship[2], ship[3], ship[4])
	end
	return spawnedShips, shipType
end

function SceneParser.saveScene(sceneName, world)
	local fileString = ""
	local team
	for i,structure in ipairs(world.structures) do
		if structure.corePart then
			team = structure.corePart:getTeam()
		end
		if not team then
			team = 0
		end
		fileString = fileString .. "ship" .. tostring(i) .. 
					 Util.packLocation(world.structures[i]) .. 
					 Util.packData({team}) .. "\n" ..
					 "{\n" .. Spawn.shipPack(world.structures[i], true) .. 
					 "\n}\n"
	end
	if not love.filesystem.exists(sceneName .. ".txt") then
		file = love.filesystem.newFile(sceneName .. ".txt")
		file:open("w")
		file:write(fileString)
		file:close()
	else
		love.filesystem.write(sceneName .. ".txt", fileString)
	end
end

return SceneParser
