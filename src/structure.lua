local Part = require("shipparts/part")
local AI = require("ai")
local AIBlock = require("shipparts/aiBlock")
local Util = require("util")
local Particles = require("particles")
local GridTable = require("gridTable")
local Settings = require("settings")
local StructureMath = require("structureMath")

local Structure = {}
Structure.__index = Structure

Structure.PARTSIZE = 20

function Structure.create(worldInfo, location, shipTable, data)
	local self = {}
	setmetatable(self, Structure)

	self.worldInfo = worldInfo
	self.physics = worldInfo.physics
	self.events = worldInfo.events
	self.gridTable = GridTable.create()
	--self.parts = {}
	self.maxDiameter = 1
	self.size = 1
	self.isDestroyed = false

	if not shipTable.parts then
		if shipTable.type == "generic" then
			shipTable = {parts = {shipTable},
						 partCoords = {{x = 0, y = 0}},
						 partOrient = {1}}
		else
			shipTable = {corePart = shipTable}
		end
	end
	local x = location[1]
	local y = location[2]
	if shipTable.corePart then
		if shipTable.corePart.type == "control" then
			self.body = love.physics.newBody(self.physics, x, y, "dynamic")
			self.body:setAngularDamping(0.25)
			self.body:setLinearDamping(0.125)
			self.type = "ship"
		elseif shipTable.corePart.type == "anchor" then
			self.body = love.physics.newBody(self.physics, x, y, "static")
			self.type = "anchor"
		end
		self:addPart(shipTable.corePart, 0, 0, 1)
		self.corePart = shipTable.corePart
	else
		self.body = love.physics.newBody(self.physics, x, y, "dynamic")
		self.body:setAngularDamping(0.2)
		self.body:setLinearDamping(0.1)
		self.type = "generic"
	end
	if location[3] then
		self.body:setAngle(location[3])
	end
	if location[4] and location[5] then
		self.body:setLinearVelocity(location[4], location[5])
	end
	if location[6] then
		self.body:setAngularVelocity(location[6])
	end
	self.body:setUserData(self)

	if shipTable.parts then
		for i,part in ipairs(shipTable.parts) do
			self:addPart(part,
						 shipTable.partCoords[i].x,
						 shipTable.partCoords[i].y,
						 shipTable.partOrient[i])
		end
	end
	return self
end

function Structure:postCreate(references)
	if self.corePart and self.corePart.postCreate then
		self.corePart:postCreate(references)
	end
end

-- The table set to nill.

function Structure:destroy()
	self.body:destroy()
	self.isDestroyed = true
end

function Structure:getLocation()
	return self.body:getX(), self.body:getY(), self.body:getAngle()
end

-- Annex another structure into this one.
-- ** After calling this method, the annexed structure will be destroyed and
-- should be removed from any tables it is referenced in.
-- Parameters:
-- annexee is the structure to annex
-- annexeePart is the block that will connect to this structure
-- orientation is the side of annexee to attach
-- structurePart is the block to connect the structure to
-- side is the side of structurePart to add the annexee to
function Structure:annex(annexee, annexeePart, annexeePartSide,
				structurePart, structurePartSide)
	local structureOffsetX = structurePart.location[1]
	local structureOffsetY = structurePart.location[2]

	local annexeeX = annexeePart.location[1]
	local annexeeY = annexeePart.location[2]

	local annexeeSide = StructureMath.toDirection(annexeePartSide + annexeePart.location[3])
	local structureSide = StructureMath.toDirection(structurePartSide + structurePart.location[3])

	local annexeeBaseVector = {annexeeX, annexeeY, annexeePartSide}
	local structureVector = {structureOffsetX, structureOffsetY, structureSide}

	structureVector = StructureMath.addUnitVector(structureVector, structureSide)
	local baseVector = StructureMath.subtractVectors(structureVector, annexeeBaseVector)

	local parts = annexee.gridTable:loop()
	for i=1,#parts do
		self:annexPart(annexee, parts[i], baseVector)
	end
end

function Structure:annexPart(annexee, part, baseVector)
	local annexeeVector = {part.location[1], part.location[2], part.location[3]}
	local netVector = StructureMath.sumVectors(baseVector, annexeeVector)

	local partThere = false
	local x, y = unpack(netVector)
print(x, y)
	if self.gridTable:index(x, y) then
			partThere = true
	end

	local newStructure
	if partThere then
		local location = {part:getWorldLocation()}
		table.insert(self.events.create, {"structures", location, part})
	else
		self:addPart(part, netVector[1], netVector[2], netVector[3])
	end
	annexee:removePart(part)
end

function Structure:removeSection(part) --index)
	--If there is only one block in the structure then esacpe.
	if part == self.corePart then
		return nil
	end
	--local part = self.parts[index]
	local partLocation = part.location
	local partOrient = (-partLocation[3] + 1) % 4 + 1
	local x, y , angle = part:getWorldLocation()
	self:removePart(part)
	local newStructure = Structure.create(self.worldInfo, {x, y, angle}, part)
	local partList = self:testConnection()
	for i = #partList,1,-1 do
		if partList[i][2] ~= 1 then
			newStructure:annexPart(self, partList[i][1], {-partLocation[1], -partLocation[2], partOrient})
		end
	end

	self:recalculateSize()

	return newStructure
end

function Structure:testConnection()
	local parts = self.gridTable:loop()
	local partsLayout = GridTable.create()
	for i, part in ipairs(parts) do
		local x, y = unpack(part.location)
		partsLayout:index(x, y, {i, 0, 0})
	end

	local index
	if self.corePart then
		for i,part in ipairs(parts) do
			if self.corePart == part then
				index = i
			end
		end
	else
		index = 1
	end
	local x, y = unpack(parts[index].location)
	local p = partsLayout:index(x, y)
	p[2] = 1
	p[3] = 1

	local structureIndex = 1
	local checkParts = {{x, y}}
	while #checkParts ~= 0 do
		local x = checkParts[#checkParts][1]
		local y = checkParts[#checkParts][2]
		table.remove(checkParts, #checkParts)

		local p = partsLayout:index(x, y)
		local partIndex = p[1]
		for i = 1,4 do
			if parts[partIndex].connectableSides[i] then
				local x1 = x
				local y1 = y
				if i == 1 then
					y1 = y + 1
				elseif i == 2 then
					x1 = x - 1
				elseif i == 3 then
					y1 = y - 1
				elseif i == 4 then
					x1 = x + 1
				end

				local part, side, newIndex, state

				local p = partsLayout:index(x1, y1)

				if p then
					newIndex = p[1]
					state = p[2]
				end
				if newIndex and newIndex ~= 0 and state == 0 then
					part = parts[newIndex]
					side = (i - part.location[3] + 2) % 4 + 1
				end
				if part and side and part.connectableSides[side] then
					table.insert(checkParts, {x1, y1})
					p[2] = 1
					p[3] = structureIndex
				end
			end
		end

		if #checkParts == 0 then
			for i in ipairs (parts) do
				partIndex = i
				local x, y = unpack(parts[partIndex].location)
				local p = partsLayout:index(x, y)

				if p[2] == 0 then
					structureIndex = structureIndex + 1
					p[2] = 1
					p[3] = structureIndex

					table.insert(checkParts, {x, y})
					break
				end
			end
		end
	end

	local partList = {}
	for i,part in ipairs(parts) do
		local x, y = unpack(part.location)
		local p = partsLayout:index(x, y)
		table.insert(partList, {part, p[3]})
	end
	return partList
end

-- Add one part to the structure.
-- x, y are the coordinates in the structure.
-- orientation is the orientation of the part according to the structure.
function Structure:addPart(part, x, y, orientation)
	local x1, y1, x2, y2, x3, y3, x4, y4 = part.physicsShape:getPoints()
	local width = math.abs(x1 - x3)
	local height = math.abs(y1 - y3)
	local shape = love.physics.newRectangleShape(
		x*self.PARTSIZE, y*self.PARTSIZE, width, height)
	local fixture = love.physics.newFixture(self.body, shape)
	part:setFixture(fixture)
	part:setLocation({x, y, orientation})
	self:calculateSize(x, y)

	self.gridTable:index(x, y, part)
	--table.insert(self.parts, part)
	--table.insert(self.partCoords, {x = x, y = y})
	--table.insert(self.partOrient, orientation)
end

function Structure:recalculateSize()
	self.maxDiameter = 1
	self.gridTable:loop(Structure.partCalculateSize, self)
end

function Structure.partCalculateSize(part, structure, x, y)
	structure:calculateSize(x, y)
end

function Structure:calculateSize(x, y)
	local x = math.abs(x)
	local y = math.abs(y)
	local d = math.max(x, y) + x + y + 1
	if self.maxDiameter < d then
		self.maxDiameter = d
		self.size = math.ceil(self.maxDiameter * 0.5625 / Settings.chunkSize)
	end
end

-- Check if a part is in this structure.
-- If it is, return the index of the part.
-- If it is not, return nil.
function Structure:findPart(query)
	for i, part in ipairs(self.parts) do
		if part == query then
			return i
		end
	end

	return nil
end

-- Find the specified part and destroy it. If there are no more parts in the
-- structure, then mark this structure for destruction.
function Structure:removePart(part)
--	local partIndex

	-- Find out if the argument is a part object or index.
--	if type(part) == "table" then
--		partIndex = self:findPart(part)
--	elseif type(part) == "number" then
	--	partIndex = part
--	else
--		error("Argument to Structure:removePart is not a part.")
--	end
	-- Destroy the part.
	if part == self.corePart then
		self.corePart = nil
	end

	x, y = unpack(part.location)
	self.gridTable:index(x, y, nil, true)
	--table.remove(self.parts, partIndex)

	if #self.body:getFixtureList() == 0 then
		self.isDestroyed = true
	end
end

function Structure:removeSections()
	local partList = self:testConnection()
	local structureList = {}
	local locationList = {}
	for i = #partList,1,-1 do
		if partList[i][2] ~= 1 then
			for i = #structureList, partList[i][2]-1 do
				table.insert(structureList, {parts = {}, partCoords = {}, partOrient = {}})
			end

			local part = partList[i][1]
			local partX = part.location[1]
			local partY = part.location[2]
			local partOrient = part.location[3]
			table.insert(structureList[partList[i][2]].parts, part)
			table.insert(structureList[partList[i][2]].partCoords, {x = partX, y = partY})
			table.insert(structureList[partList[i][2]].partOrient, partOrient)
			self:removePart(part)
		end
	end

	self:recalculateSize()

	for i, structure in ipairs(structureList) do
		table.insert(self.events.create, {"structures", {self:getLocation()}, structure})
	end

	return newObjects
end

function Structure:command(orders)
	local perpendicular = 0
	local parallel = 0
	local rotate = 0
	local shoot = false

	for j, order in ipairs(orders) do
		if order == "forward" then parallel = parallel + 1 end
		if order == "back" then parallel = parallel - 1 end
		if order == "strafeLeft" then perpendicular = perpendicular - 1 end
		if order == "strafeRight" then perpendicular = perpendicular + 1 end
		if order == "right" then rotate = rotate - 1 end
		if order == "left" then rotate = rotate + 1 end
		if order == "shoot" then shoot = true end
	end

	local engines = {0, 0, 0, 0, parallel, perpendicular, rotate, self.body}

	if parallel > 0 then
		engines[1] = 1
	elseif parallel < 0 then
		engines[3] = 1
	end

	if perpendicular > 0 then
		engines[4] = 1
	elseif perpendicular < 0 then
		engines[2] = 1
	end

	local commands = {engines = engines, guns = {shoot = shoot}}
	
	return commands
end

function Structure:update(dt)
	local newObjects = {}
	local partsInfo = {}
	if self.corePart then
		
		partsInfo = self:command(self.corePart:getOrders())
	end

	self.gridTable:loop(Structure.updatePart, {dt, partsInfo})

	return {}
end

function Structure.updatePart(part, inputs, x, y)
	local dt, partsInfo = unpack(inputs)	
	part:update(dt, partsInfo)
end

return Structure
