local Engine = require("world/shipparts/modules/engine")
local GridTable = require("gridTable")
local Gun = require("syntheinrust").shipparts.modules.gun
local Location = require("world/location")
local MissileLauncher = require("syntheinrust").shipparts.modules.missileLauncher
local Shield = require("world/shipparts/modules/shield")
local StructureMath = require("world/structureMath")
local StructureParser = require("world/structureParser")
local log = require("log")

local Structure = class(require("world/worldObjects"))

function Structure:__create(worldInfo, location, data, appendix)
	self.worldInfo = worldInfo
	self.physics = worldInfo.physics
	self.createObject = worldInfo.create

	local shipTable
	if appendix then
		local player
		shipTable, player = StructureParser.shipUnpack(appendix, data)
		self.isPlayer = player
	else
		shipTable = data
	end

	local corePart
	if not shipTable.parts then
		self.gridTable = GridTable()
		self.gridTable:index(0, 0, shipTable)
		shipTable:setLocation({0, 0, 1})
		if shipTable.type ~= "generic" then
			corePart = shipTable
		end
	else
		self.gridTable = shipTable.parts
		corePart = shipTable.corePart
	end

	local team = 0
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
		team = corePart:getTeam()
	else
		self.body:setAngularDamping(.1)
		self.body:setLinearDamping(0.01)
		--self.type = "generic"
	end

	local userDataParent = {
		__index = function(t, key)
			log:debug("Undesirable connection in structure body userdata. Key:%s\n%s", key, debug.traceback())
			return self[key]
		end
	}
	local userData = setmetatable({}, userDataParent)

	userData.type = "structure"
	userData.team = team

	self.body:setUserData(userData)
	self.shield = Shield(self.body)

	local function callback(part, structure, x , y)
		structure:addPart(part, x, y, part.location[3])
	end
	self.gridTable:loop(callback, self)

end

function Structure:postCreate(references)
	if self.corePart and self.corePart.postCreate then
		self.corePart:postCreate(references)
	end
end

function Structure:getSaveData(references)
	local team = self.body:getUserData().team
	local leader
	if self.corePart and self.corePart.leader then
		leader = references[self.corePart.leader]
	end

	return {team, leader}, StructureParser.shipPack(self, true)
end

function Structure:getWorldLocation(l)
	local partX, partY, angle = unpack(l)
	local l = {Location.bodyPoint6(self.body, partX, partY)}
	-- Add the rotation of the part onto the angle
	l[3] = (angle - 1) * math.pi/2 + l[3]
	return l
end

function Structure:findPart(cursorX, cursorY)
	local x, y = self.body:getLocalPoint(cursorX, cursorY)

	local part = self.gridTable:index(
		math.floor(x + .5),
		math.floor(y + .5))

	return part
end

-------------------------------
-- Adding and Removing Parts --
-------------------------------
-- Add one part to the structure.
-- x, y are the coordinates in the structure.
-- orientation is the orientation of the part according to the structure.
function Structure:addPart(part, x, y, orientation)
	part:setLocation({x, y, orientation})
	part:addFixtures(self.body)
	--self:calculateSize(x, y)
	--self:recalculateSize()
	if part.isShield then self.shield:addPart(part) end

	self.gridTable:index(x, y, part)
end

-- If there are no more parts in the structure,
-- then mark this structure for destruction.
function Structure:removePart(part)
	if part == self.corePart then
		self.corePart = nil
	end

	local x, y = unpack(part.location)
	self.gridTable:index(x, y, nil, true)
	part:removeFixtures(body)
	if part.isShield then self.shield:removePart(part) end

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
function Structure:annex(annexee, annexeeBaseVector, structureVector)
	local structureSide = structureVector[3]
	structureVector = StructureMath.addUnitVector(structureVector, structureSide)
	local baseVector = StructureMath.subtractVectors(structureVector, annexeeBaseVector)

	local parts = annexee.gridTable:loop()
	for i=1,#parts do
		local part = parts[i]
		local annexeeVector = {part.location[1], part.location[2], part.location[3]}
		local netVector = StructureMath.sumVectors(baseVector, annexeeVector)

		local x, y = unpack(netVector)
		if self.gridTable:index(x, y) then
			annexee:disconnectPart(part.location)
		else
			annexee:removePart(part)
			self:addPart(part, netVector[1], netVector[2], netVector[3])
		end
	end
end

function Structure:testEdge(vector)
	local aX, aY, direction = unpack(vector)
	local bX, bY = StructureMath.step(vector)
	local gridTable = self.gridTable
	local connection = false
	local aPart = gridTable:index(aX, aY)
	if aPart then
		local aSide = StructureMath.subDirections(
			aPart.location[3], direction)
		connection = aPart.connectableSides[aSide]
	end
	local bPart = gridTable:index(bX, bY)
	if bPart then
		local bSide = StructureMath.subDirections(
			bPart.location[3], direction + 2)
		connection = connection and bPart.connectableSides[bSide]
	end
	return aPart, bPart, connection, {bX, aX}
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
	local tested = GridTable()
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

function Structure:splitOffParts(partList)
	local basePart = partList[1]
	local baseVector = basePart.location
	local basePartFixture = basePart.modules["hull"].fixture
	
	local location = {Location.fixturePoint6(
		basePartFixture, baseVector[1], baseVector[2])}
	--Include the part orientation into the structures rotation.
	location[3] = location[3] + StructureMath.directionToAngle(baseVector[3])
	
	--Invert base vector. Changes the sum into difference between vectors.
	baseVector = StructureMath.subtractVectors({0,0,3}, baseVector)

	local structure = GridTable()
	for _, eachPart in ipairs(partList) do
		self:removePart(eachPart)

		local partVector = {unpack(eachPart.location)}
		local netVector = StructureMath.sumVectors(baseVector, partVector)
		eachPart:setLocation(netVector)
		structure:index(netVector[1], netVector[2], eachPart)
	end

	self.createObject("structure", location, {parts = structure})
end

function Structure:fracture(location)
	local x, y = unpack(location)
	local part = self.gridTable:index(x, y)
	--Remove destroyed part.
	self:removePart(part)

	--List adjacent grid points.
	local points = StructureMath.adjacentPoints(part.location)

	local clusters = self:testConnection(points)

	--Generate arguments for spawning new structures.
	for _, cluster in ipairs(clusters) do
		self:splitOffParts(cluster)
	end
end

-- Part was disconnected or destroyed remove part and handle outcome.
function Structure:disconnectPart(location)
	local x, y = unpack(location)
	local part = self.gridTable:index(x, y)

	--If there is only one part this is pointless return early.
	if #self.gridTable:loop() == 1 then
		return
	end

	--Remove part from grid table for the connection testing. Fully removed in loop.
	self.gridTable:index(x, y, nil, true)

	--List adjacent grid points.
	local points = StructureMath.adjacentPoints(part.location)
	
	--Group connected parts into clusters.
	local clusters = self:testConnection(points)
	local mainCluster = {part}

	--If there is a corePart split one group off the corePart Group.
	--If there is no corePart then there is no reference point so split it multiple ways.
	if self.corePart then
		--Put all clusters into one new structure
		for _, cluster in ipairs(clusters) do
			for _, eachPart in ipairs(cluster) do
				table.insert(mainCluster, eachPart)
			end
		end
	else
		--Keep clusters separate.
		for _, cluster in ipairs(clusters) do
			self:splitOffParts(cluster)
		end
	end

	self:splitOffParts(mainCluster)
end

-------------------------
-- Mangement functions --
-------------------------

-- Restructure input from player or output from ai
-- make the information easy for parts to handle.
function Structure:command(dt)
	--TODO This is a wasteful way to do this look for a better way.
	local capabilities = {}
	for i, part in ipairs(self.gridTable:loop()) do
		for key, module in pairs(part.modules) do
			if key == "repair" then
				capabilities.repair = true
				capabilities.repairLocation =StructureMath.addDirectionVector(
					part.location, part.location[3], 1.2)
			elseif key == "gun" then
				capabilities.combat = true
			end
		end
	end


	local orders = {}
	if self.corePart then
		orders = self.corePart:getOrders(self.body, capabilities)
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

	local function create(object, location)
		location = StructureMath.sumVectors(location, object[2])
		object[2] = self:getWorldLocation(location)
		self.createObject(unpack(object))
	end

	local function getPart(location, pointer)
		pointer[3] = 0
		local x, y = unpack(StructureMath.sumVectors(location, pointer))
		return self.gridTable:index(x, y)
	end

	local moduleInputs = {
		dt = dt,
		body = self.body, --TODO: nothing seems to use this? Maybe delete it.
		getPart = getPart,
		controls = {
			gun = Gun.process(gunOrders),
			missileLauncher = MissileLauncher.process(gunOrders),
			engine = Engine.process(engineOrders)
		},
		teamHostility = self.worldInfo.teamHostility
	}

	for i, part in ipairs(self.gridTable:loop()) do
		local location = part.location
		
		local newObject, disconnect = part:update(moduleInputs, location)

		if newObject then
			create(newObject, location)
		end
		if disconnect then
			--TODO Likely edge case bug destroy 2 blocks at the same time.
			self:fracture(location)
		end
	end

	return commands
end

-- Handle commands
-- Update each part
function Structure:update(dt)
	local partsInfo = self:command(dt)
	self.shield:update(dt)
end

return Structure
