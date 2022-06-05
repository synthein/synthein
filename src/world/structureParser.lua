local GridTable = require("gridTable")
local PartRegistry = require("world/shipparts/partRegistry")
local parse = require("parse")

local blueprintDir = "res/ships/" --"blueprints/"

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

function StructureParser.loadBlueprintFromFile(ship)
	local fileName = blueprintDir .. ship .. ".txt"

	if not love.filesystem.getInfo(fileName, "file") then
		return nil, string.format("File %s does not exist", fileName)
	end

	local contents, size
	if fileName then
		contents, size = love.filesystem.read(fileName)
		return contents, size
	end
	return nil, nil
end

local function parseLetterPair(string)
	if not string:match("%a[1234*]") then return end

	local c  = string:sub(1, 1)
	local nc = string:sub(2, 2)

	local orientation = nc == '*' and 1 or tonumber(nc)

	return c, orientation
end

function StructureParser.blueprintUnpack(appendix)
	local shipString, stringLength
	if string.match(appendix, "[*\n]") then
		shipString = appendix
		stringLength = #appendix
	else
		shipString, stringLength = StructureParser.loadBlueprintFromFile(appendix)
	end

	if not (shipString and stringLength) then return end

	local baseX, baseY, corePart, player
	local lines = {}
	-- TODO make sure the line match can use end of file instead of new line
	for line in shipString:gmatch(".-\n") do
		table.insert(lines, line:sub(1, #line - 1))
		local find = line:find("*")
		if find then
			baseY = #lines
			baseX = find - 1
		end
	end

	if not (baseX and baseY) then return end

	local blueprint = GridTable()

	for i, line in ipairs(lines) do
		for j = 1,#line-1 do
			local lp = line:sub(j, j + 1)

			-- Location handling.
			local x = (j - baseX)/2
			local y = baseY - i
			local c, orientation = parseLetterPair(lp)

			if c and orientation then
				-- Add to grid table
				blueprint:index(x, y, {c, orientation})
			end
		end
	end

	return blueprint
end

function StructureParser.shipUnpack(appendix, shipData)
	local shipString, stringLength
	if string.match(appendix, "[*\n]") then
		shipString = appendix
		stringLength = #appendix
	else
		shipString, stringLength = StructureParser.loadShipFromFile(appendix)
	end

	if not (shipString and stringLength) then return end

	local baseX, baseY, corePart, player
	local lines = {}
	-- TODO make sure the line match can use end of file instead of new line
	for line in shipString:gmatch(".-\n") do
		table.insert(lines, line:sub(1, #line - 1))
		local find = line:find("*")
		if find then
			baseY = #lines
			baseX = find - 1
			local c = line:sub(baseX, baseX)
			corePart = PartRegistry.isCorePart[c]
			player = c == 'p'
		end
	end

	if not (baseX and baseY) then return end

	local loadDataTable = {}
	local location = {}
	local loadData = {}

	for i = 1, stringLength do
		local c = shipString:sub(i,i)
		if c == '(' then
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
			table.insert(loadDataTable, {location, loadData})
		end
	end

	local shipTable = {}
	shipTable.parts = GridTable()

	for i, line in ipairs(lines) do
		for j = 1,#line-1 do
			local lp = line:sub(j, j + 1)

			-- Location handling.
			local x = (j - baseX)/2
			local y = baseY - i
			local c, orientation = parseLetterPair(lp)

			if c and orientation and (PartRegistry.partsList[c] ~= nil) then
				local part = PartRegistry.createPart(c, shipData)
				part:setLocation({x, y, orientation})

				-- Add to grid table
				shipTable.parts:index(x, y, part)
			end
		end
	end

	if corePart then
		shipTable.corePart = shipTable.parts:index(0, 0)
	end

	for i, t in ipairs(loadDataTable) do
		local part = shipTable.parts:index(t[1][1], t[1][2])
		if part then
			part:loadData(t[2])
		end
	end

	return shipTable, player
end

function StructureParser.blueprintPack(blueprint)
	local string = ""
	local xLow, yLow, xHigh, yHigh = blueprint:getLimits()
	local stringTable = {}
	for y = yHigh, yLow, -1 do
		for x = xLow, xHigh, 1  do
			part = blueprint:index(x, y)
			if part then
				string = string .. part[1]
				if x == 0 and y == 0 then
					string = string .. "*"
				else
					string = string .. tostring(part[2])
				end
			else
				string = string .. "  "
			end
		end
		string = string .. "\n"
	end

	return string
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

--Ideas to try. Do not delete

--[[ -- Inside loop over each line

y = y - 1
local length = #line
local m = line:find("[.%[\n]") or length + 1
local types = line:sub(1, m - 1)
local dataString = line:sub(m, length)

local dataTable = {}
for partData in dataString:gmatch("[.%[]([^.%[%]\n]*)%]?") do
	partDataTable = {}
	for number in partData:gmatch("[^,]") do
		table.insert(partDataTable, tonumber(number))
	end
	table.insert(dataTable, partDataTable)
end

		-- Data handling.
		partCounter = partCounter + 1
		local partData = dataTable[partCounter]
		if partData then part:loadData(partData) end

--]]
