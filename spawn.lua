-- Spawn some ships or other objects based on a table containing all of the
-- data required to produce them. This module is designed to be called in
-- SceneParser and Saves.
local Part = require("shipparts/part")
local Block = require("shipparts/block")
local Engine = require("shipparts/engine")
local Gun = require("shipparts/gun")
local AIBlock = require("shipparts/aiBlock")
local PlayerBlock = require("shipparts/playerBlock")
local Tserial = require("tserial")
local Structure = require("structure")

local Spawn = {}

function Spawn.spawnShip(shipTable, physics, x, y, angle)
	for i,part in ipairs(shipTable.parts) do
		if part == 'b'then
			shipTable.parts[i] = Block.create()
		elseif part == 'e' then
			shipTable.parts[i] = Engine.create()
		elseif part == 'g' then
			shipTable.parts[i] = Gun.create()
		elseif part == 'a' then
			shipTable.parts[i] = AIBlock.create()
		elseif part == 'p' then
			shipTable.parts[i] = PlayerBlock.create()
		end
		if shipTable.loadData[i] then
			shipTable.parts[i]:loadData(shipTable.loadData[i])
		end
	end
	shipTable.loadData = nil
	structure = Structure.create(shipTable, physics, x, y, angle)
	return structure
end

function Spawn.loadShipFromFile(ship)
	local contents, size
	if ship then
		if ship < 10 then
			local file = string.format("res/ships/BasicShip%d.txt", ship)
			contents, size = love.filesystem.read(file)
		end
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
			elseif c == '{' then
				local braceLevel = 0
				local endBrace
				for a = 1,(stringLength-i) do
					c = shipString:sub(i + a, i + a)
					if c == '{' then
						braceLevel = braceLevel + 1
					elseif c == '}' then
						if braceLevel == 0 then
							endBrace = a
							break
						else
							braceLevel = braceLevel - 1
						end
					elseif c == '\n' then break
					end
				end
				local loadData = Tserial.unpack(shipString:sub(i, i + endBrace), true)
				table.insert(loadDataTable, loadData)
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
				if loadDataTable[1][1] == x and loadDataTable[1][2]	== y then
					shipTable.loadData[partIndex] = loadDataTable[1][3]
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
	local stringTable = {{"  "}}
	for i,part in ipairs(structure.parts) do
		local x = structure.partCoords[i].x
		local y = structure.partCoords[i].y
		local tempString = "  "
		local loadData = {}

		--Make sure rectangle includes location of part.
		if     x < xLow  then
			for j = 1, (xLow - x) do
				for k = 1, (yHigh - yLow + 1) do
					table.insert(stringTable[k], 1, {"  "})
				end
			end
			xLow = x
		elseif x > xHigh then
			for j = 1, (x - xHigh) do
				for k = 1, (yHigh - yLow + 1) do
					table.insert(stringTable[k], {"  "})
				end
			end
			xHigh = x
		elseif y < yLow  then
			for j = 1, (yLow - y) do
					table.insert(stringTable, 1, {})
				for k = 1, (xHigh - xLow + 1) do
					table.insert(stringTable[1], {"  "})
				end
			end
			yLow = y
		elseif y > yHigh then
			for j = 1, (y - yHigh) do
				table.insert(stringTable, {})
				for k = 1, (xHigh - xLow + 1) do
					table.insert(stringTable[y - yLow + 1], {"  "})
				end
			end
			yHigh = y
		end

		--Find the string representation of the part.
		if     getmetatable(part) == Block then
			tempString = "b0"
		elseif getmetatable(part) == Engine then
			if structure.partOrient[i] == 1 then
				tempString = "e1"
			elseif structure.partOrient[i] == 2 then
				tempString = "e2"
			elseif structure.partOrient[i] == 3 then
				tempString = "e3"
			elseif structure.partOrient[i] == 4 then
				tempString = "e4"
			end
		elseif getmetatable(part) == Gun then
			if structure.partOrient[i] == 1 then
				tempString = "g1"
			elseif structure.partOrient[i] == 2 then
				tempString = "g2"
			elseif structure.partOrient[i] == 3 then
				tempString = "g3"
			elseif structure.partOrient[i] == 4 then
				tempString = "g4"
			end
		elseif getmetatable(part) == AIBlock then
			tempString = "a*"
		elseif getmetatable(part) == PlayerBlock then
			tempString = "p*"
		end
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
		for j = 1,#stringTable[i] do
			string = string .. stringTable[i][j][1]
			if stringTable[i][j][2]then
				dataString = dataString ..
							 Tserial.pack(stringTable[i][j][2], nil, false) ..
							 "\n"
			end
		end
		string = string .. "\n"
	end
	string = string .. "\n" .. dataString
	return string
end

return Spawn
