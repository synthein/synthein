-- SceneParser serializes and deserializes scenes and ships as strings.
local Spawn = require("spawn")
local Util = require("util")

local SceneParser = {}

local locStr = "%([-%d., e]*%)"
local lstStr = "%[[-%w., %*]*%]"
local varStr = "[-%w. %*]*[,%]]"
local namStr = "%a[%w]+"
--local strStr = '".*"'
local numStr = "-?[%d.e]*"

function SceneParser.loadShip(shipName)
end

function SceneParser.loadScene(sceneLines, world, location, inputs)
	local ships = {}
	local index = 0
	local ifShipString = false
	local shipString = ""
	local shipID
	local locationString

	for line in sceneLines do
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
			if string.match(line, namStr .. locStr .. lstStr) then
				shipID = string.match(line, "%w+")
				locationString = string.match(line, locStr)
				local l = {}
				for coord in string.gmatch(locationString, numStr) do 
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

				local dataString = string.match(line, lstStr)
				local data = {}
				for var in string.gmatch(dataString, varStr) do
					if string.match(var, "%a") then
						if string.match(var, '"[%w]+"') then
						elseif string.match(var, "%*[%w]+") then
							local inputKey = string.match(var, "[%w]+")
							table.insert(data, inputs[inputKey])
						else
							table.insert(data, string.match(var, "[%w]+"))
						end
					elseif string.match(var, numStr) then
						table.insert(data, tonumber(string.match(var, numStr)))
					else
						table.insert(data, false)
					end
				end
				index = index + 1
				ships[index] = {shipID, l, data}
			elseif string.match(line, "%s*%{") then
				ifShipString = true
			end
		end
	end
	spawnedShips = {}
	local shipType = {}
	local references = {}
print(#ships)
	for i,ship in ipairs(ships) do
		spawnedShips[i], shipType[i] = Spawn.spawnShip(ship[1], world, ship[2], ship[3], ship[4])
		references[ship[1]] = spawnedShips[i]
	end
	for i,ship in ipairs(spawnedShips) do
		ship:postCreate(references)
	end
	return spawnedShips, shipType
end

function SceneParser.saveScene(world)
	local sceneString = ""
	local references = {}
	local structures = world.objects.structures
	for i,structure in ipairs(structures) do
		references[structure] = "ship" .. tostring(i)
	end

	for i,structure in ipairs(structures) do
		local team, leader
		if structure.corePart then
			team = structure.corePart:getTeam()
		end
		if not team then
			team = 0
		end
		if 	structure.corePart and structure.corePart.leader then
			leader = references[structure.corePart.leader]
		end
		
		sceneString = sceneString .. references[structure] .. 
					 Util.packLocation(structures[i]) .. 
					 Util.packData({team, leader}) .. "\n" ..
					 "{\n" .. Spawn.shipPack(structures[i], true) .. 
					 "\n}\n"
	end

	return sceneString
end

return SceneParser
