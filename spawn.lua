-- Spawn some ships or other objects based on a table containing all of the
-- data required to produce them. This module is designed to be called in
-- SceneParser and Saves.
local Part = require("part")
local Block = require("block")
local Engine = require("engine")
local Gun = require("gun")

function spawnShip(shipTable, physics, x, y, angle)
	for i,part in ipairs(shipTable.parts) do
		if part = 'b'then
			part = Block.create()
		elseif part == 'e' then
			part = Engine.create()
		elseif part == 'g' then
			part = Gun.create()
		elseif part == 'a' then
			part = AIBlock.create()
		end
		--load data from shipTable.loadData
		shipTable.loadData = nil
	end
	structure = Strucutre.create(shipTable, physics, x, y, angle)
	return structure
end

function loadShipFromFile(ship)
	local contents, size
	if ship then
		if ship < 10 then
			local file = string.format("res/ships/BasicShip%d.txt", ship)
			contents, size = love.filesystem.read(file)
		end
	return contents, size
end

function shipUnpack(shipString, stringLength)
	local shipTable = {}
	shipTable.parts = {}
	shipTable.partCoords = {}
	shipTable.partOrient = {}
	shipTable.loadData = {}
	if shipString and size then
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
			end
		end
	
		j = 0
		k = 0
		for i = 1, stringLength do
			local c = shipString:sub(i,i)
			local nc = shipString:sub(i + 1, i + 1)
			local nnc = shipString:sub(i + 2, i + 2)
			local angle = 1
			j = j + 1
			x = (j - baseJ)/2
			y = k - baseK
			self.partCoords[i].x = x
			self.partCoords[i].y = y
			
			if c == '\n' then 
				j = 0
				k = k + 1
			elseif c == 'b' then
				shipTable.parts[i] = 'b'
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
				shipTable.parts[i] = 'e'
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
				shipTable.parts[i] = 'g'
			end
			if nnc == "{" then
				--add loadData
			end
		end
	end
	return shipTable
end
