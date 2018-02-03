-- Spawn some ships or other objects based on a table containing all of the
-- data required to produce them. This module is designed to be called in
-- SceneParser and Saves.
local PartRegistry = require("shipparts/partRegistry")
local Util = require("util")
local Structure = require("structure")
local GridTable = require("gridTable")
local World = require("world")

local Spawn = {}

function Spawn.spawnObject(world, key, location, data, shipInfo, shipType)
	local player = false
	if key == "structures" then
		local stringLength, shipString
		if shipType then
			shipString, stringLength = Spawn.loadShipFromFile(shipInfo)
		else
			shipString = shipInfo
			stringLength = #shipString
		end

		data, player = Spawn.shipUnpack(shipString, stringLength, data)
	end

	local value = World.objectTypes[key]
	local object = value.create(world.info, location, data)
	world:addObject(object, key)
	return object, player
end








function Spawn.spawnShip(shipID, world, location, data, shipString)
	local stringLength
	if not shipString then
		shipString, stringLength = Spawn.loadShipFromFile(shipID)
	else
		stringLength = #shipString
	end
	local shipTable = Spawn.shipUnpack(shipString, stringLength, data)
	return Spawn.spawning(world, location, shipTable)
end

function Spawn.spawning(world, location, shipTable)
	shipTable.loadData = nil
	local structure = Structure.create(world.info, location, shipTable)
	return structure, shipTable.shipType
end

function Spawn.loadShipFromFile(ship)
	local contents, size
	if ship then
		local file = string.format("res/ships/" .. ship .. ".txt")
		contents, size = love.filesystem.read(file)
		return contents, size
	end
	return nil, nil
end

function Spawn.shipUnpack(shipString, stringLength, shipData)
	local shipTable = {}
	local player = false
	shipTable.parts = GridTable.create()
	local loadDataTable = {}
	local location = {}
	local loadData = {}
	if shipString and stringLength then
		local j, k, x, y, baseJ, baseK
		j = 0
		k = 0
		for i = 1, stringLength do
			local c = shipString:sub(i,i)
			j = j + 1
			if c == '\n' then
				j = 0
				k = k + 1
			elseif c == '*' then
				baseJ = j - 1
				baseK = k
			elseif c == '(' then
				for a = 1,(stringLength-i) do
					c = shipString:sub(i + a, i + a)
					if c == ')' then
						local locationString = shipString:sub(i + 1, i + a - 1)
						location = {}
						for coord in string.gmatch(locationString, "[-0-9.]+") do
							table.insert(location, tonumber(coord))
						end
					end
				end
			elseif c == '[' then
				for a = 1,(stringLength-i) do
					c = shipString:sub(i + a, i + a)
					if c == ']' then
						local dataString = shipString:sub(i + 1, i + a - 1)
						loadData = {}
						for var in string.gmatch(dataString, "[-0-9.]+") do
							table.insert(loadData, tonumber(var))
						end
					end
				end
--			elseif c == '{' then
--				local braceLevel = 0
--				local endBrace
--				for a = 1,(stringLength-i) do
--					c = shipString:sub(i + a, i + a)
--					if c == '{' then
--						braceLevel = braceLevel + 1
--					elseif c == '}' then
--						if braceLevel == 0 then
--							endBrace = a
--							break
--						else
--							braceLevel = braceLevel - 1
--						end
--					elseif c == '\n' then break
--					end
--				end
--				local loadData = Tserial.unpack(shipString:sub(i, i + endBrace), true)
				table.insert(loadDataTable, {location, loadData})
			end
		end

		j = 0
		k = 0
		for i = 1, stringLength do
			local c = shipString:sub(i,i)
			local nc = shipString:sub(i + 1, i + 1)
--			local angle = 1
			local data
			j = j + 1
			x = (j - baseJ)/2
			y = baseK - k
			if loadDataTable[1] then
				if loadDataTable[1][1][1] == x and loadDataTable[1][1][2]	== y then
					data = loadDataTable[1][2]
				end
			end

			if c == '\n' then
				j = 0
				k = k + 1
			elseif c == 'b' or c == 'e' or c == 'g' or c == 'a' or c == 'p' or c == 'n' then
				local part = PartRegistry.createPart(c, shipData)
				local orientation
				if nc == '*' then
					if c == 'a' or c == 'p' or c == 'n'then
						shipTable.corePart = part
						if c == 'p' then
							player = true
						end
					end
					orientation = 1
				elseif nc == '1' or nc == '2' or nc == '3' or nc == '4' then
					orientation = tonumber(nc)
				end
				if data then
					part:loadData(data)
				end
				part:setLocation({x, y, orientation})
				shipTable.parts:index(x, y, part)
			elseif c == '{' or c == '}' then
				break
			end
		end
	end
	return shipTable, player
end

function Spawn.shipPack(structure, saveThePartData)
	PartRegistry.setPartChars()
	local string = ""
	local xLow, xHigh, yLow, yHigh = 0, 0, 0, 0
	local parts = structure.gridTable:loop()
	local stringTable = {}
	for _, part in ipairs(parts) do
		local x = part.location[1]
		local y = part.location[2]
		if     x < xLow  then
			xLow = x
		elseif x > xHigh then
			xHigh = x
		end
		if y < yLow  then
			yLow = y
		elseif y > yHigh then
			yHigh = y
		end
	end
	for i = 1, (yHigh - yLow + 1) do
		table.insert(stringTable, {})
		for _ = 1, (xHigh - xLow + 1) do
			table.insert(stringTable[i], {"  "})
		end
	end
	for i, part in ipairs(parts) do
		local x = part.location[1]
		local y = part.location[2]
		local tempString, a, b
--		local loadData = {}

		a = part.partChar
--[[
		--Find the string representation of the part.
		if     getmetatable(part) == Block then a = "b"
		elseif getmetatable(part) == EngineBlock then a = "e"
		elseif getmetatable(part) == GunBlock then a = "g"
		elseif getmetatable(part) == AIBlock then a = "a"
		elseif getmetatable(part) == PlayerBlock then a = "p"
		elseif getmetatable(part) == Anchor then a = "n"
		end
--]]

		if part == structure.corePart or (not structure.corePart and i==1) then
			b = "*"
		else
			b = tostring(part.location[3])
		end
		tempString = a .. b
		--Add data to table
		if saveThePartData then
			stringTable[y - yLow + 1][x - xLow + 1] = {tempString, part:saveData()}
		else
			stringTable[y - yLow + 1][x - xLow + 1] = {tempString}
		end
	end
	--Put strings together
	local dataString = ""
	for i = 1,#stringTable do
		local ii = #stringTable - i + 1
		for j = 1,#stringTable[ii] do
			string = string .. stringTable[ii][j][1]
			if stringTable[ii][j][2]then
				dataString = dataString ..
							 Util.packLocation({j + xLow - 1, ii + yLow - 1}) ..
							 Util.packData(stringTable[ii][j][2]) ..
							 --Tserial.pack(stringTable[i][j][2], nil, true) ..
							 "\n"
			end
		end
		string = string .. "\n"
	end
	string = string .. "\n" .. dataString
	return string
end

return Spawn
