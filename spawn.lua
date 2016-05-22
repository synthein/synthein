-- Spawn some ships or other objects based on a table containing all of the
-- data required to produce them. This module is designed to be called in
-- SceneParser and Saves.
local Part = require("part")
local Block = require("block")
local Engine = require("engine")
local Gun = require("gun")
local AIBlock = require("aiBlock")
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
			y = k - baseK
			local partIndex
			if			y < 0 then partIndex = index + 1
			elseif		y > 0 then partIndex = index
			else
				if		x < 0 then partIndex = index + 1
				elseif	x > 0 then partIndex = index
				else			   partIndex = 1
				end
			end
			shipTable.partCoords[partIndex] = {x = x, y = y}
			if loadDataTable[1][1] == x and loadDataTable[1][2]	== y then
				shipTable.loadData[partIndex] = loadDataTable[1][3]
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
			elseif c == '{' or c == '}' then
				break
			end
		end
	end
	return shipTable
end

return Spawn
