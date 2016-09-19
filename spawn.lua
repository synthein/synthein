-- Spawn some ships or other objects based on a table containing all of the
-- data required to produce them. This module is designed to be called in
-- SceneParser and Saves.
local Part = require("shipparts/part")
local Block = require("shipparts/block")
local Engine = require("shipparts/engine")
local Gun = require("shipparts/gun")
local AIBlock = require("shipparts/aiBlock")
local PlayerBlock = require("shipparts/playerBlock")
local Anchor = require("shipparts/anchor")
local Tserial = require("tserial")
local Util = require("util")
local Structure = require("structure")
local World = require("world")
local AI = require("ai")

local Spawn = {}

function Spawn.spawnShip(shipID, location, data, shipString)
	local stringLength
	if not shipString then
		shipString, stringLength = Spawn.loadShipFromFile(shipID)
	else
		stringLength = #shipString
	end
	local shipTable = Spawn.shipUnpack(shipString, stringLength)
	return Spawn.spawning(shipTable, location, data)
end

function Spawn.spawning(shipTable, location, data)
	local ai = false
	local player = false
	local anchor = false
	for i,part in ipairs(shipTable.parts) do
		if part == 'b'then
			shipTable.parts[i] = Block.create()
		elseif part == 'e' then
			shipTable.parts[i] = Engine.create()
		elseif part == 'g' then
			shipTable.parts[i] = Gun.create()
		elseif part == 'a' then
			shipTable.parts[i] = AIBlock.create()
			ai = true
		elseif part == 'p' then
			shipTable.parts[i] = PlayerBlock.create()
			player = true
		elseif part == 'n' then
			shipTable.parts[i] = Anchor.create()
			anchor = true
		end
		if shipTable.loadData[i] then
			shipTable.parts[i]:loadData(shipTable.loadData[i])
		end
	end
	shipTable.loadData = nil
	local structure = world:createStructure(shipTable, location)
	if ai then
		table.insert(world.ais, AI.create(structure, data[1]))
	elseif player then
		return structure, true
	end
	return structure
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

function Spawn.shipUnpack(shipString, stringLength)
	local shipTable = {}
	shipTable.parts = {}
	shipTable.partCoords = {}
	shipTable.partOrient = {}
	shipTable.loadData = {}
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
						locationString = shipString:sub(i + 1, i + a - 1)
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
		local index = 1
		for i = 1, stringLength do
			local c = shipString:sub(i,i)
			local nc = shipString:sub(i + 1, i + 1)
			local angle = 1
			j = j + 1
			x = (j - baseJ)/2
			y = baseK - k
			local partIndex
			if			y > 0 then partIndex = index + 1
			elseif		y < 0 then partIndex = index
			else
				if		x < 0 then partIndex = index + 1
				elseif	x > 0 then partIndex = index
				else			   partIndex = 1
				end
			end
			shipTable.partCoords[partIndex] = {x = x, y = y}
			if loadDataTable[1] then
				if loadDataTable[1][1][1] == x and loadDataTable[1][1][2]	== y then
					shipTable.loadData[partIndex] = loadDataTable[1][2]
				end	
			end

			if c == '\n' then
				j = 0
				k = k + 1
			elseif c == 'b' then
				shipTable.parts[partIndex] = 'b'
				shipTable.partOrient[partIndex] = 1
				index = index + 1
			elseif c == 'e' then
				if nc == '1' then
					angle = 1
				elseif nc == '2' then
					angle = 2
				elseif nc == '3' then
					angle = 3
				elseif nc == '4' then
					angle = 4
				end
				shipTable.parts[partIndex] = 'e'
				shipTable.partOrient[partIndex] = angle
				index = index + 1
			elseif c == 'g' then
				if nc == '1' then
					angle = 1
				elseif nc == '2' then
					angle = 2
				elseif nc == '3' then
					angle = 3
				elseif nc == '4' then
					angle = 4
				end
				shipTable.parts[partIndex] = 'g'
				shipTable.partOrient[partIndex] = angle
				index = index + 1
			elseif c == 'a' then
				shipTable.parts[partIndex] = 'a'
				shipTable.partOrient[partIndex] = 1
				index = index + 1
			elseif c == 'p' then
				shipTable.parts[partIndex] = 'p'
				shipTable.partOrient[partIndex] = 1
				index = index + 1
			elseif c == 'n' then
				shipTable.parts[partIndex] = 'n'
				shipTable.partOrient[partIndex] = 1
				index = index + 1
			elseif c == '{' or c == '}' then
				break
			end
		end
	end
	return shipTable
end

function Spawn.shipPack(structure, saveThePartData)
	local string = ""
	local xLow, xHigh, yLow, yHigh = 0, 0, 0, 0
	local stringTable = {}
	for i,part in ipairs(structure.parts) do
		local x = structure.partCoords[i].x
		local y = structure.partCoords[i].y
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
		for j = 1, (xHigh - xLow + 1) do
			table.insert(stringTable[i], {"  "})
		end
	end
	for i,part in ipairs(structure.parts) do
		local x = structure.partCoords[i].x
		local y = structure.partCoords[i].y
		local tempString, a, b
		local loadData = {}
		--Find the string representation of the part.
		if     getmetatable(part) == Block then a = "b"
		elseif getmetatable(part) == Engine then a = "e"
		elseif getmetatable(part) == Gun then a = "g"
		elseif getmetatable(part) == AIBlock then a = "a"
		elseif getmetatable(part) == PlayerBlock then a = "p"
		elseif getmetatable(part) == Anchor then a = "n"
		end
		if i == 1 then
			b = "*"
		else
			b = tostring(structure.partOrient[i])
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
		ii = #stringTable - i + 1
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
