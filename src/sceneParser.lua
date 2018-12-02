local LocationTable = require("locationTable")

-- SceneParser serializes and deserializes scenes and ships as strings.
local Spawn = require("world/spawn")
local Util = require("util")
local Tserial = require("vendor/tserial")

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

	if type(sceneLines) == "string" then
		local fileName = "res/scenes/" .. sceneLines .. ".txt"
		sceneLines = love.filesystem.lines(fileName)
	end

	local function spawnObject(ship)
		local shipID, type, location, data, appendix = unpack(ship)
		local object, player = Spawn.spawnObject(world, type, location,
												 data, appendix)
		table.insert(objects, object)
		if player then
			table.insert(playerShips, object)
		end
		if shipID then
			references[shipID] = object
		end
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

				local l = location + LocationTable(locationString)

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
	return playerShips
end

function SceneParser.saveScene(world)
	local references = {}
	local sceneString = "teamhostility = " ..
		Tserial.pack(world.info.teamHostility.playerHostility, nil, false) ..
		"\n[scene]\n"


	for _, object in ipairs(world.objects) do
		references[object] = object:type() .. tostring(index)
	end

	for _, object in ipairs(world.objects) do
		local data, appendix = object:getSaveData(references)
		local string = ""
			.. references[object] .. " = " .. object:type()
			.. "(" .. tostring(object:getLocation()) .. ")"
			.. Util.packData(data) .. "\n"
			.. (appendix and "{\n" .. appendix .. "\n}\n" or "")

		sceneString = sceneString .. string
	end

	return sceneString
end

return SceneParser
