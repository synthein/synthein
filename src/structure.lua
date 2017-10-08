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

--Structure.PARTSIZE = 20

function Structure.create(worldInfo, location, shipTable)
	local self = {}
	setmetatable(self, Structure)

	self.worldInfo = worldInfo
	self.physics = worldInfo.physics
	self.events = worldInfo.events
	self.maxDiameter = 1
	self.size = 1
	self.isDestroyed = false

	if not shipTable.parts then
		self.gridTable = GridTable.create()
		self.gridTable:index(0, 0, shipTable)
		shipTable:setLocation({0, 0, 1})
		if shipTable.type ~= "generic" then
			self.corePart = shipTable
		end
	else
		self.gridTable = shipTable.parts
	end

	local x = location[1]
	local y = location[2]
	if shipTable.corePart then
		if shipTable.corePart.type == "control" then
			self.body = love.physics.newBody(self.physics, x, y, "dynamic")
			self.body:setAngularDamping(1)
			self.body:setLinearDamping(.1)
			self.type = "ship"
		elseif shipTable.corePart.type == "anchor" then
			self.body = love.physics.newBody(self.physics, x, y, "static")
			self.type = "anchor"
		end
		self.corePart = shipTable.corePart
	else
		self.body = love.physics.newBody(self.physics, x, y, "dynamic")
		self.body:setAngularDamping(.1)
		self.body:setLinearDamping(0.01)
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
		local function callback(part, structure)
			structure:addFixture(part)
		end
		self.gridTable:loop(callback, self)
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

-------------------------
-- Setters and Getters --
-------------------------
function Structure:getLocation()
	return self.body:getX(), self.body:getY(), self.body:getAngle()
end

function Structure:getTeam()
	if self.corePart then
		return self.corePart:getTeam()
	end
	return 0
end

-------------------------------
-- Adding and Removing Parts --
-------------------------------
function Structure:addFixture(part)
	local shape = love.physics.newRectangleShape(part.location[1],
												 part.location[2],
												 1, 1)
	local fixture = love.physics.newFixture(self.body, shape)
	part:setFixture(fixture)
end

-- Add one part to the structure.
-- x, y are the coordinates in the structure.
-- orientation is the orientation of the part according to the structure.
function Structure:addPart(part, x, y, orientation)
	part:setLocation({x, y, orientation})
	self:addFixture(part)
	--self:calculateSize(x, y)
	self:recalculateSize()

	self.gridTable:index(x, y, part)
end

-- If there are no more parts in the structure, 
-- then mark this structure for destruction.
function Structure:removePart(part)
	if part == self.corePart then
		self.corePart = nil
	end

	x, y = unpack(part.location)
	self.gridTable:index(x, y, nil, true)
	part.fixture:destroy()

--	for i,fixture in ipairs(self.body:getFixtureList()) do
--		if not fixture:isDestroyed() then
--			return
--		end
--	end
	
	local parts = self.gridTable:loop()
	if #parts <= 0 then
		self.isDestroyed = true
	end
end

-----------------------------------------
-- Adding and removing groups of parts --
-----------------------------------------

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

	local x, y = unpack(netVector)
	if self.gridTable:index(x, y) then
		annexee:disconnectPart(part)
	else
		annexee:removePart(part)
		self:addPart(part, netVector[1], netVector[2], netVector[3])
	end
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

function Structure:recalculateSize()
	self.maxDiameter = 1
	local function callback(part, self, x, y)
		local x = math.abs(x)
		local y = math.abs(y)
		local d = math.max(x, y) + x + y + 1
		if self.maxDiameter < d then
			self.maxDiameter = d
			self.size = math.ceil(self.maxDiameter * 0.5625/
								  Settings.chunkSize)
		end
	end

	self.gridTable:loop(callback, self)
end

-- Part was disconnected or destroyed remove part and handle outcome.
function Structure:disconnectPart(part)
	self:removePart(part)
	if self.isDestroyed then
		return
	end	

	local savedPart
	if not part.isDestroyed then
		savedPart = part
	end

	local createStructures
	local partList = self:testConnection()
	local structureList = {}

	if savedPart then
		structureList[1] = {savedPart}
	else
		structureList[1] = {}
	end

	for i = #partList,1,-1 do
		for i = #structureList, partList[i][2]-1 do
			table.insert(structureList, {})
		end

		if partList[i][2] ~= 1 then
			local receivingStructure
			if savedPart then
				receivingStructure = 1
			else
				receivingStructure = partList[i][2]
			end

			table.insert(structureList[receivingStructure], partList[i][1])
		end
	end

	if savedPart then
		structureList = {structureList[1]}
	end

	for i = 1, #structureList do
		local partList = structureList[i]
		if #partList > 0 then
			local basePart = partList[1]
			local baseVector = basePart.location
			local location = {basePart:getWorldLocation()}

			baseVector = StructureMath.subtractVectors({0,0,3}, baseVector)
			
			local structure = GridTable.create()
			for j, part in ipairs(partList) do
				local partVector = {unpack(part.location)}
				local netVector = StructureMath.sumVectors(baseVector, partVector)
				if part ~= savedPart then
					self:removePart(part)
				end
				part:setLocation(netVector)
				structure:index(netVector[1], netVector[2], part)

			end
			table.insert(self.events.create, {"structures", location, {parts = structure}})
		end
	end
	

	self:recalculateSize()
end

-------------------------
-- Mangement functions --
-------------------------

-- Restructure input from player or output from ai
-- make the information easy for parts to handle.
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

-- Handle commands
-- Update each part
function Structure:update(dt, worldInfo)
	local partsInfo = {}
	if self.corePart then
		local body = self.body
		local vX, vY = body:getLinearVelocity()
		local location = {body:getX(), body:getY(), body:getAngle(),
					  vX, vY, body:getAngularVelocity()}
		partsInfo = self:command(self.corePart:getOrders(location, worldInfo))
	end

	local function callback(part, inputs, x, y)
		local dt, partsInfo = unpack(inputs)	
		part:update(dt, partsInfo)
	end

	self.gridTable:loop(callback, {dt, partsInfo})
end

return Structure
