local GridTable = require("gridTable")
local Settings = require("settings")
local StructureMath = require("world/structureMath")
local StructureParser = require("world/structureParser")
local LocationTable = require("locationTable")
local Engine = require("world/shipparts/engine")
local Gun = require("world/shipparts/gun")

local Structure = class(require("world/worldObjects"))

function Structure:__create(worldInfo, location, data, appendix)
	self.worldInfo = worldInfo
	self.physics = worldInfo.physics
	self.events = worldInfo.events
	self.maxDiameter = 1
	self.size = 1

	local shipTable
	if appendix then
		shipTable, player = StructureParser.shipUnpack(appendix, data)
		self.isPlayer = player
	else
		shipTable = data
	end

	local corePart
	if not shipTable.parts then
		self.gridTable = GridTable.create()
		self.gridTable:index(0, 0, shipTable)
		shipTable:setLocation({0, 0, 1})
		if shipTable.type ~= "generic" then
			corePart = shipTable
		end
	else
		self.gridTable = shipTable.parts
		corePart = shipTable.corePart
	end

	if corePart then
		if corePart.type == "control" then
			self.body:setAngularDamping(1)
			self.body:setLinearDamping(.1)
			--self.type = "ship"
		elseif corePart.type == "anchor" then
			self.body:setType("static")
			--self.type = "anchor"
		end

		corePart.worldInfo = worldInfo
		self.corePart = corePart
	else
		self.body:setAngularDamping(.1)
		self.body:setLinearDamping(0.01)
		--self.type = "generic"
	end

	self.body:setUserData(self)

	self.guns = {}
	self.engines = {}
	self.heal = {}
	local function callback(part, structure, x , y)
		structure:addFixture(part)
		if part.gun then self.guns[part.gun] = {part.location} end
		if part.engine then self.engines[part.engine] = {part.location} end
		if part.heal then self.heal[part.heal] = {part} end
	end
	self.gridTable:loop(callback, self)
end

function Structure:postCreate(references)
	if self.corePart and self.corePart.postCreate then
		self.corePart:postCreate(references)
	end
end

function Structure:type()
	return "structure"
end

-------------------------
-- Setters and Getters --
-------------------------
function Structure:getTeam()
	if self.corePart then
		return self.corePart:getTeam()
	end
	return 0
end

function Structure:getSaveData(references)
	local team = self:getTeam()
	local leader
	if self.corePart and self.corePart.leader then
		leader = references[self.corePart.leader]
	end

	return {team, leader}, StructureParser.shipPack(self, true)
end

function Structure:getWorldLocation(l)
	local body = self.body
	local partX, partY, angle = unpack(l)

	local x, y = body:getWorldPoints(partX, partY)
	angle = (angle - 1) * math.pi/2 + body:getAngle()
	local vx, vy = body:getLinearVelocityFromLocalPoint(partX, partY)
	local w = body:getAngularVelocity()

	return LocationTable(x, y, angle, vx, vy, w)
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
	if part.gun then self.guns[part.gun] = {part.location} end
	if part.engine then self.engines[part.engine] = {part.location} end
	if part.heal then self.heal[part.heal] = {part} end
end

-- If there are no more parts in the structure,
-- then mark this structure for destruction.
function Structure:removePart(part)
	if part == self.corePart then
		self.corePart = nil
	end

	local x, y = unpack(part.location)
	self.gridTable:index(x, y, nil, true)
	part.fixture:destroy()
	if part.gun then self.guns[part.gun] = nil end
	if part.engine then self.engines[part.engine] = nil end
	if part.heal then self.heal[part.heal] = nil end

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

	local annexeeBaseVector = {annexeeX, annexeeY, annexeeSide}
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

function Structure:testConnection(testPoints)
	local keep = {}
	for _, location in ipairs(testPoints) do
		local x, y = unpack(location)
		 if self.gridTable:index(x, y) then
			if x ~= 0 or y ~= 0 then
				table.insert(keep, {x, y})
			end
		end
	end
	testPoints = keep
	local testedPoints = {}
	local points = {}
	local clusters = {}
	local tested = GridTable.create()
	if self.gridTable:index(0, 0) then
		tested:index(0, 0, 2)
	end

	while #testPoints ~= 0 do
		table.insert(points, table.remove(testPoints))
		local testedPointX, TestedPointY = unpack(points[1])
		tested:index(testedPointX, TestedPointY, 1)

		while #points ~= 0 do
			local point = table.remove(points)
			table.insert(testedPoints, point)
			for i = 1,4 do
				local newPoint = StructureMath.addUnitVector(point, i)

				local part = self.gridTable:index(unpack(point))
				local newPart = self.gridTable:index(unpack(newPoint))
				if part and newPart then
					local partSide = (i - part.location[3]) % 4 + 1
					local partConnect = part.connectableSides[partSide]
					local newPartSide = (i - newPart.location[3] + 2) % 4 + 1
					local newPartConnect = newPart.connectableSides[newPartSide]
					if partConnect and newPartConnect then
						for j = #testPoints, 1, -1 do
							local ax, ay = unpack(newPoint)
							local bx, by = unpack(testPoints[j])
							if ax == bx and ay == by then
								table.remove(testPoints, j)
							end
						end
						local value = tested:index(unpack(newPoint))

						if value == 2 then
							for _, testedPoint in ipairs(testedPoints) do
								local x, y = unpack(testedPoint)
								tested:index(x, y, 2)
							end

							for _, eachPoint in ipairs(points) do
								local x, y = unpack(eachPoint)
								tested:index(x, y, 2)
							end
							testedPoints = {}
							points = {}
							break
						elseif value ~= 1 then
							local x, y = unpack(newPoint)
							tested:index(x, y, 1)
							table.insert(points, newPoint)
						end
					end
				end
			end
		end

		if #testedPoints ~= 0 then
			table.insert(clusters, testedPoints)
			testedPoints = {}
		end
	end

	for _, group in ipairs(clusters) do
		for j, location in ipairs(group) do
			group[j] = self.gridTable:index(unpack(location))
		end
	end

	return clusters
end

function Structure:recalculateSize()
	self.maxDiameter = 1
	local function callback(part, self, x, y)
		x = math.abs(x)
		y = math.abs(y)
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
	if #self.gridTable:loop() == 1 and not part.isDestroyed then
		-- if structure will bedestoryed
		if part.isDestroyed then
			self:removePart(part)
		end
		return
	end

	--self:removePart(part)
	local x, y = unpack(part.location)
	self.gridTable:index(x, y, nil, true)

	local savedPart
	if part.isDestroyed then
		self:removePart(part)
	else
		savedPart = part
	end


	local points = {}
	for i = 1,4 do
		table.insert(points, StructureMath.addUnitVector(part.location, i))
	end
	local clusters = self:testConnection(points)
	local structureList

	if savedPart then
		if not self.corePart then
			structureList = clusters
			table.insert(structureList, {savedPart})
		else
			structureList = {{savedPart}}
			for _, group in ipairs(clusters) do
				for _, eachPart in ipairs(group) do
					table.insert(structureList[1], eachPart)
				end
			end
		end
	else
		structureList = clusters
	end

	for i = 1, #structureList do
		local partList = structureList[i]
		local basePart = partList[1]
		local baseVector = basePart.location
		local location = basePart:getWorldLocation()

		baseVector = StructureMath.subtractVectors({0,0,3}, baseVector)

		local structure = GridTable.create()
		for _, eachPart in ipairs(partList) do
			local partVector = {unpack(eachPart.location)}
			local netVector = StructureMath.sumVectors(baseVector, partVector)
			--if eachPart ~= savedPart then
				self:removePart(eachPart)
			--end
			eachPart:setLocation(netVector)
			structure:index(netVector[1], netVector[2], eachPart)

		end

		local newStructure = {"structure", location, {parts = structure}}
		table.insert(self.events.create, newStructure)
	end


	self:recalculateSize()
end

-------------------------
-- Mangement functions --
-------------------------

-- Restructure input from player or output from ai
-- make the information easy for parts to handle.
function Structure:command(dt)
	local orders
	if self.corePart then
		orders = self.corePart:getOrders()
	else
		return {}
	end

	local engineOrders = {}
	local gunOrders = {}

	for _, order in ipairs(orders) do
		if order == "forward" then table.insert(engineOrders, order) end
		if order == "back" then table.insert(engineOrders, order) end
		if order == "strafeLeft" then table.insert(engineOrders, order) end
		if order == "strafeRight" then table.insert(engineOrders, order) end
		if order == "right" then table.insert(engineOrders, order) end
		if order == "left" then table.insert(engineOrders, order) end
		if order == "shoot" then table.insert(gunOrders, order) end
	end

	gunControls = Gun.process(gunOrders)

	for gun, t in pairs(self.guns) do
		local partX, partY, angle = unpack(t[1])

		local x, y = unpack(StructureMath.addUnitVector(l, angle))
		local clear = not self.gridTable:index(x, y)

		if gun:update(dt, shoot, clear) then
			local location = self:getWorldLocation(t[1])
			local part = self.gridTable:index(partX, partY)

			table.insert(self.events.create, {"shot", location, part})
		end
	end

	engineControls = Engine.process(engineOrders)

	for engine, t in pairs(self.engines) do
		engine:update(self.body, t[1], engineControls)
	end

	for heal, t in pairs(self.heal) do
		heal:update(dt, t[1])
	end

	return commands
end

-- Handle commands
-- Update each part
function Structure:update(dt)
	local partsInfo = self:command(dt)

	-- Call update on each part
    self.gridTable:loop("update", {dt, partsInfo}, true)
end

return Structure
