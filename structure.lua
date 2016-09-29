local Part = require("shipparts/part")
local AI = require("ai")
local AIBlock = require("shipparts/aiBlock")
local Util = require("util")

local Structure = {}
Structure.__index = Structure

Structure.PARTSIZE = 20
Structure.physics = nil

function Structure.setPhysics(setphysics)
	Structure.physics = setphysics
end

function Structure.create(shipTable, location, data)
	local self = {}
	setmetatable(self, Structure)
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
			self.body = love.physics.newBody(Structure.physics, x, y, "dynamic")
			self.body:setAngularDamping(1)
			self.body:setLinearDamping(0.5)
			self.type = "ship"
		elseif shipTable.corePart.type == "anchor" then
			self.body = love.physics.newBody(Structure.physics, x, y, "static")
			self.type = "anchor"
		end
		self:addPart(shipTable.corePart, 0, 0, 0)
	else
		self.body = love.physics.newBody(Structure.physics, x, y, "dynamic")
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
	self.parts = {}
	self.partCoords = {}
	self.partOrient = {}
	self.fixtures = {}
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

-- The table set to nill.

function Structure:destroy()

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
function Structure:annex(annexee, annexeePart, annexeeSide, structurePart,
	                     structureSide)
	local aIndex = annexee:findPart(annexeePart)
	local bIndex = self:findPart(structurePart)
	annexeeSide = (annexeeSide + annexee.partOrient[aIndex] - 2) % 4 + 1
	local newStructures = {}
	local structureOffsetX, structureOffsetY
	if bIndex ~= 0 then
		structureOffsetX = self.partCoords[bIndex].x
		structureOffsetY = self.partCoords[bIndex].y
		structureSide = (structureSide + self.partOrient[bIndex] - 2) % 4 + 1
	else
		structureOffsetX = 0
		structureOffsetY = 0
	end

	if structureSide == 1 then
		structureOffsetY = structureOffsetY + 1
	elseif structureSide == 2 then
		structureOffsetX = structureOffsetX - 1
	elseif structureSide == 3 then
		structureOffsetY = structureOffsetY - 1
	elseif structureSide == 4 then
		structureOffsetX = structureOffsetX + 1
	end

	local annexeeOrientation = (structureSide - annexeeSide - 2) % 4 +1

			local annexeeX = annexee.partCoords[aIndex].x
			local annexeeY = annexee.partCoords[aIndex].y

	for i=1,#annexee.parts do
		local x, y
		local annexeeOffsetX = annexee.partCoords[1].x - annexeeX
		local annexeeOffsetY = annexee.partCoords[1].y - annexeeY

		if annexeeOrientation == 1 then
			x = structureOffsetX + annexeeOffsetX
			y = structureOffsetY + annexeeOffsetY
		elseif annexeeOrientation == 2 then
			x = structureOffsetX - annexeeOffsetY
			y = structureOffsetY + annexeeOffsetX
		elseif annexeeOrientation == 3 then
			x = structureOffsetX - annexeeOffsetX
			y = structureOffsetY - annexeeOffsetY
		elseif annexeeOrientation == 4 then
			x = structureOffsetX + annexeeOffsetY
			y = structureOffsetY - annexeeOffsetX
		end

		-- Find out the orientation of the part based on the orientation of
		-- both structures.
		local partOrientation = annexeeOrientation + annexee.partOrient[1] - 1
		-- Make sure partOrientation is between 1 and 4
		while partOrientation > 4 do
			partOrientation = partOrientation - 4
		end
		while partOrientation < 1 do
			partOrientation = partOrientation + 4
		end

		local partThere = false
		for i, part in ipairs(self.parts) do
			if self.partCoords[i].x == x and self.partCoords[i].y == y then
				partThere = true
			end
		end
		if partThere then
			table.insert(newStructures, Structure.create(annexee.parts[1],
						 physics, annexee:getAbsPartCoords(1)))
		else
			self:addPart(annexee.parts[1], x, y, partOrientation)
		end
		annexee:removePart(annexee.parts[1])
	end
	return newStructures
end

function Structure:removeSection(part)
	--If there is only one block in the structure then esacpe.
	if #self.parts == 1 and not self.corePart then
		return nil
	end
	local index = self:findPart(part)
	local x, y , angle = self:getAbsPartCoords(index)
	self:removePart(part)
	return Structure.create(part, {x, y, angle})
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
	if orientation == 0 then 
		self.corePart = part
		self.coreFixture = fixture
	else
		table.insert(self.parts, part)
		table.insert(self.partCoords, {x = x, y = y})
		table.insert(self.partOrient, orientation)
		table.insert(self.fixtures, fixture)
	end
end

-- Check if a part is in this structure.
-- If it is, return the index of the part.
-- If it is not, return nil.
function Structure:findPart(query)
	if query == self.corePart then return 0 end
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
	local partIndex

	-- Find out if the argument is a part object or index.
	if type(part) == "table" then
		partIndex = self:findPart(part)
	elseif type(part) == "number" then
		partIndex = part
	else
		error("Argument to Structure:removePart is not a part.")
	end
	-- Destroy the part.
	if partIndex == 0 then
		self.corePart = nil
		self.coreFixture:destroy()
		self.coreFixture = nil
	else
		self.fixtures[partIndex]:destroy()
		table.remove(self.parts, partIndex)
		table.remove(self.partCoords, partIndex)
		table.remove(self.fixtures, partIndex)
		table.remove(self.partOrient, partIndex)
	end

	if #self.parts == 0 and not self.corePart then
		self.isDestroyed = true
	end
end

-- Find the absolute coordinates of a part given the x and y offset values of
-- the part and the absolute coordinates and angle of the structure it is in.
function Structure:getAbsPartCoords(index)
	local x, y, orient = 0, 0, 1
	if index ~= 0 then
		x, y = Util.computeAbsCoords(
			self.partCoords[index].x*self.PARTSIZE,
			self.partCoords[index].y*self.PARTSIZE,
			self.body:getAngle())
		orient = self.partOrient[index]
	end
	return self.body:getX() + x, self.body:getY() + y,
		   self.body:getAngle() + (orient - 1) * math.pi/2
				% (2*math.pi)
end

function Structure:command(orders)
	-- The x and y components of the force
	local directionX = -math.sin(self.body:getAngle())
	local directionY = math.cos(self.body:getAngle())

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

	for i = 0, #self.parts do
		local part
		if i == 0 then part = self.corePart
		else part = self.parts[i]
		end
		if part.thrust then

		local appliedForceX = 0
		local appliedForceY = 0

			-- Apply the force for the engines
				-- Choose parts that have thrust and are pointed the right
				-- direction, but exclude playerBlock, etc.

		if part.type == "control" then
			appliedForceX = directionX * parallel + directionY * perpendicular
			appliedForceY = directionY * parallel + -directionX * perpendicular
			self.body:applyTorque(rotate * part.torque)
		elseif part.type == "generic" then
			partParallel = Util.sign(self.partCoords[i].x)
			partPerpendicular = Util.sign(self.partCoords[i].y)
			local partPerpendicular = perpendicular - rotate * partPerpendicular
			local partParallel = parallel + rotate * partParallel

			--Set to 0 if engine is going backwards.
			if self.partOrient[i] < 3 then
				if partParallel < 0 then partParallel = 0 end
				if partPerpendicular > 0 then	partPerpendicular = 0 end
			elseif self.partOrient[i] > 2 then
				if partParallel > 0 then	partParallel = 0 end
				if partPerpendicular < 0 then	partPerpendicular = 0 end
			end
			--Limit to -1, 0 , 1.
			partParallel = Util.sign(partParallel)
			partPerpendicular = Util.sign(partPerpendicular)
			--Moving forward and backward.
			if self.partOrient[i] % 2 == 1 then
				appliedForceX = directionX * partParallel
				appliedForceY = directionY * partParallel
			--Moving side to side.
			elseif self.partOrient[i] % 2 == 0 then
				appliedForceX = directionY * partPerpendicular
				appliedForceY = -directionX * partPerpendicular
			end
			--Turn on flame.
			if appliedForceX ~= 0 or  appliedForceY ~=0 then
				part.isActive = true
			else
				part.isActive = false
			end
		end
		--Thrust multiplier
		local Fx = appliedForceX * part.thrust
		local Fy = appliedForceY * part.thrust
		self.body:applyForce(Fx, Fy, self:getAbsPartCoords(i))
		end

		if part.gun and shoot and not part.recharge then
			part:shot()
			world:shoot(self, part)
		end
	end
end

function Structure:getPartIndex(locationX, locationY)
	for i = 0,#self.parts do
		local inside, partSide = self:withinPart(i, locationX, locationY)
		if inside then
			if i == 0 then return self.corePart, partSide end
			return self.parts[i], partSide
		end
	end
end

function Structure:withinPart(partIndex, locationX, locationY)
	local partX, partY, partAngle = self:getAbsPartCoords(partIndex)
	local angleToCursor = Util.vectorAngle(locationX - partX,
										   locationY - partY)
	local angleDifference = angleToCursor - partAngle
	local distanceFromPart = Util.vectorMagnitude(locationX - partX,
												  locationY - partY)
	a, b = Util.vectorComponents(distanceFromPart, angleDifference)
	a = Util.absVal(a)
	b = Util.absVal(b)
	partSide = math.floor((angleDifference*2/math.pi - 1/2) % 4 +1)
	if Util.max(a,b) <= 10 then
		if partIndex == 0 and not self.corePart then return false, partside end
		return true, partSide
	end
	return false, partSide
end

function Structure:update(dt, playerLocation, aiData)
	if self.corePart then
		self:command(self.corePart:getOrders({self.body:getX(),self.body:getY(), self.body:getAngle()}, playerLocation, aiData))
		self.corePart:update(dt)
	end
	for i, part in ipairs(self.parts) do
		if part.update then
			part:update(dt)
		end
	end
end

function Structure:draw()
	for i = 0, #self.parts do
		local x, y, angle = self:getAbsPartCoords(i)
		if i == 0 then
			if self.corePart then self.corePart:draw(x, y, angle) end
		else self.parts[i]:draw(x, y, angle)
		end
	end
end

return Structure
