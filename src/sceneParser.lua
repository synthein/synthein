-- SceneParser serializes and deserializes scenes and ships as strings.
local Spawn = require("spawn")
local Util = require("util")

local SceneParser = {}

local numStr = "[-%d.e]*"
--local strStr = '".*"'
local varStr = "[-%w. %*]*[,%]]"
local namStr = "(%a%w+)"

local locStr = "(%([-%d., e]*%))"
local lstStr = "(%[[-%w., %*]*%])"
local idStr = namStr .. "%s*="
local objStr = locStr .. "%s*" .. lstStr .. "%s*(%w*)%s*({?)"

function SceneParser.loadShip(shipName)
end

function SceneParser.loadScene(sceneLines, world, location, inputs)
	local ship
	local index = 0
	local ifShipString = false
	local shipString = ""
	local playerShips = {}
	local objects = {}
	local references = {}
	local key = "structures"

	function spawnObject(key, ship)
		local shipID, location, data, shipInfo, shipType = unpack(ship)
		local object, player = Spawn.spawnObject(world, key, location,
												 data, shipInfo, shipType)
		table.insert(objects, object)
		if player then
			table.insert(playerShips, object)
		end
		if ship[1] then
			references[ship[1]] = object
		end
	end

	for line in sceneLines do
		if ifShipString then
			if string.match(line, "%}") then
				if not string.match(line, "%s%}") then
				shipString = shipString .. ""
				end
				ifShipString = false
				ship[4] = shipString
				ship[5] = false
				spawnObject(key, ship)
				shipString = ""
			else
				shipString = shipString .. line .. '\n'
			end
		else
			if string.match(line, locStr) then
				local shipID = string.match(line, idStr)
				if not shipID then
					shipID = false
				end
				
				local locationString, dataString, shipType, bracket = 
					string.match(line, objStr)
				if bracket == "{" then
					ifShipString = true
				end

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
				if shipType == "" then
					ship = {shipID, l, data}
				else
					ship = {shipID, l, data, shipType, true}
					spawnObject(key, ship)
				end
				
			elseif string.match(line, "%s*%{") then
				ifShipString = true
			end
		end
	end

	for i,object in ipairs(objects) do
		object:postCreate(references)
	end
	return playerShips
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
