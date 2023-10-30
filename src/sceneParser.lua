local Vector = require("vector")

-- SceneParser serializes and deserializes scenes and ships as strings.
local Parse = require("parse")

local lume = require("vendor/lume")

local SceneParser = {}

local numStr = "[-%d.e]*"
--local strStr = '".*"'
local varStr = "([-%w.%*]+),?%s*"
local namStr = "(%a%w+)"

local typStr = namStr
--local locStr = "(%([-%d., e]*%))"
local locStr = "%((.-)%)"
--local lstStr = "(%[[-%w., %*]*%])"
local lstStr = "%[(.-)%]"
local idStr = namStr .. "%s*="
local objStr = typStr .. "%s*" .. locStr .. "%s*" .. lstStr .. "%s*(%w*)%s*({?)"

--[[
function SceneParser.loadShip(shipName)
end
--]]
function SceneParser.loadScene(sceneLines, world, location, inputs)
	local ship
	local index = 0
	local ifShipString = false
	local shipString = ""
	local playerShips = {}
	local objects = {}
	local references = {}
	local maxTeam = 0

	if type(sceneLines) == "string" then
		local fileName = "res/scenes/" .. sceneLines .. ".txt"
		sceneLines = love.filesystem.lines(fileName)
	end

	local function spawnObject(ship)
		local shipID, type, location, data, appendix = unpack(ship)
		local object, player, team = world:spawnObject(
			type, location, data, appendix)
		table.insert(objects, object)
		if player then
			table.insert(playerShips, object)
		end
		if shipID then
			references[shipID] = object
		end

		maxTeam = math.max(maxTeam, team)
	end

	for line in sceneLines do
		if ifShipString then
			if string.match(line, "%}") then
				if not string.match(line, "%s%}") then
				shipString = shipString .. ""
				end
				ifShipString = false
				ship[5] = shipString
				spawnObject(ship)
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

				local type, locationString, dataString, appendix, bracket =
					string.match(line, objStr)
				if bracket == "{" then
					ifShipString = true
				end

				local l = Vector.add(location, Parse.parseNumbers(locationString))

				local data = {}
				for var in string.gmatch(dataString, varStr) do
					if string.match(var, "%a") then
						if string.match(var, '"[%w]+"') then
							-- Pass string arguments to the structure parser
							-- unchanged.
						elseif string.match(var, "%*[%w]+") then
							-- This is a variable that is not defined in this
							-- scene file.
							local inputKey = string.match(var, "[%w]+")
							table.insert(data, inputs[inputKey])
						else
							-- This is a variable defined in this scene file.
							table.insert(data, string.match(var, "[%w]+"))
						end
					elseif string.match(var, numStr) then
						table.insert(data, tonumber(string.match(var, numStr)))
					else
						table.insert(data, false)
					end
				end

				index = index + 1
				if type == "structure" and appendix == "" then
					ship = {shipID, type, l, data}
				else
					spawnObject({shipID, type, l, data, appendix})
				end

			elseif string.match(line, "%s*%{") then
				ifShipString = true
			end
		end
	end

	for _, object in ipairs(objects) do
		object:postCreate(references)
	end
	return playerShips, maxTeam
end

function SceneParser.saveScene(world)
	local references = {}
	local sceneString = "teamhostility = " ..
		lume.serialize(world.info.teamHostility.playerHostility) ..
		"\n[scene]\n"

	local indexes = {}
	for k, _ in pairs(world.objectTypes) do
		indexes[k] = 1
	end

	for _, object in ipairs(world.objects) do
		local type = object.type
		local index = indexes[type]
		references[object] = type .. tostring(index)
		indexes[type] = index + 1
	end

	for _, object in ipairs(world.objects) do
		local data, appendix = object:getSaveData(references)
		local string = ""
			.. references[object] .. " = " .. object.type
			.. "(" .. Parse.packLocation(object:getLocation()) .. ")"
			.. Parse.packData(data) .. "\n"
			.. (appendix and "{\n" .. appendix .. "\n}\n" or "")

		sceneString = sceneString .. string
	end

	return sceneString
end

return SceneParser
