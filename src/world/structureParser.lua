local GridTable = require("gridTable")
local PartRegistry = require("world/shipparts/partRegistry")
local parse = require("parse")

local StructureParser = {}

function StructureParser.loadShipFromFile(ship)
	local contents, size
	if ship then
		local file = string.format("res/ships/" .. ship .. ".txt")
		contents, size = love.filesystem.read(file)
		return contents, size
	end
	return nil, nil
end

function StructureParser.shipUnpack(appendix, shipData)
	local shipString, stringLength
	if string.match(appendix, "[*\n]") then
		shipString = appendix
		stringLength = #appendix
	else
		shipString, stringLength = StructureParser.loadShipFromFile(appendix)
	end

	local shipTable = {}
	local player = false
	shipTable.parts = GridTable()
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
						location = parse.parseNumbers(locationString)
					end
				end
			elseif c == '[' then
				for a = 1,(stringLength-i) do
					c = shipString:sub(i + a, i + a)
					if c == ']' then
						local dataString = shipString:sub(i + 1, i + a - 1)
						loadData = parse.parseNumbers(dataString)
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
			elseif PartRegistry.partsList[c] ~= nil then
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

function StructureParser.shipPack(structure, saveThePartData)
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
							 parse.packLocation({j + xLow - 1, ii + yLow - 1}) ..
							 parse.packData(stringTable[ii][j][2]) ..
							 --Tserial.pack(stringTable[i][j][2], nil, true) ..
							 "\n"
			end
		end
		string = string .. "\n"
	end
	string = string .. "\n" .. dataString
	return string
end

return StructureParser
