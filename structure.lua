local Part = require("shipparts/part")
local AI = require("ai")
local AIBlock = require("shipparts/aiBlock")
local Util = require("util")
local Particles = require("particles")

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
	self.parts = {}
	self.partCoords = {}
	self.partOrient = {}
	self.fixtures = {}
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
			self.body = love.physics.newBody(Structure.physics, x, y, "dynamic")
			self.body:setAngularDamping(1)
			self.body:setLinearDamping(0.5)
			self.type = "ship"
		elseif shipTable.corePart.type == "anchor" then
			self.body = love.physics.newBody(Structure.physics, x, y, "static")
			self.type = "anchor"
		end
		self:addPart(shipTable.corePart, 0, 0, 1)
		self.corePart = shipTable.corePart
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
function Structure:annex(annexee, annexeePartIndex, annexeePartSide,
				structurePartIndex, structurePartSide)
	local aIndex = annexeePartIndex
	local bIndex = structurePartIndex
	annexeeSide = (annexeePartSide + annexee.partOrient[aIndex] - 2)%4 + 1
	local newStructures = {}
	local structureOffsetX, structureOffsetY
	if bIndex ~= 0 then
		structureOffsetX = self.partCoords[bIndex].x
		structureOffsetY = self.partCoords[bIndex].y
		structureSide = (structurePartSide + self.partOrient[bIndex] - 2)%4 + 1
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

	local annexeeOrientation = (structureSide - annexeePartSide - 2) % 4 +1

			local annexeeX = annexee.partCoords[aIndex].x
			local annexeeY = annexee.partCoords[aIndex].y

	for i=1,#annexee.parts do
		newStructure = self:annexPart(annexee, 1, annexeeOrientation, 
						annexeeX, annexeeY, structureOffsetX, structureOffsetY)
		table.insert(newStructures, newStructure)
	end
	return newStructures
end

function Structure:annexPart(annexee, partIndex, annexeeOrientation, annexeeX,
							 annexeeY, structureOffsetX, structureOffsetY)
	local x, y
	local annexeeOffsetX = annexee.partCoords[partIndex].x - annexeeX
	local annexeeOffsetY = annexee.partCoords[partIndex].y - annexeeY
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
	local partOrientation = annexeeOrientation 
						  + annexee.partOrient[partIndex] - 1
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
			break
		end
	end
	local newStructure
	if partThere then
		local location = {annexee:getAbsPartCoords(partIndex)}
		newStructure = {"structure", location, annexee.parts[partIndex]}
	else
		self:addPart(annexee.parts[partIndex], x, y, partOrientation)
	end
	annexee:removePart(annexee.parts[partIndex])
	return newStructure
end

function Structure:removeSection(index)
	--If there is only one block in the structure then esacpe.
	if self.parts[index] == self.corePart or #self.parts == 1 then
		return nil
	end
	local part = self.parts[index]
	local partX = self.partCoords[index].x
	local partY = self.partCoords[index].y
	local partOrient = (-self.partOrient[index] + 1) % 4 + 1
	local x, y , angle = self:getAbsPartCoords(index)
	self:removePart(index)
	local newStructure = Structure.create(part, {x, y, angle})
	local partList = self:testConnection()
	for i = #partList,1,-1 do
		if partList[i] ~= 1 then
			newStructure:annexPart(self, i, partOrient, partX, partY, 0, 0)
		end
	end
	return newStructure
end

function Structure:testConnection()
	local xMin = 0
	local xMax = 0
	local yMin = 0
	local yMax = 0
	for i,part in ipairs(self.parts) do
		local x = self.partCoords[i].x
		local y = self.partCoords[i].y
		if x < xMin then
			xMin = x
		elseif x > xMax then
			xMax = x
		end
		if y < yMin then
			yMin = y
		elseif y > yMax then
			yMax = y
		end
	end
	partsLayout = {}
	for i = 1,(yMax-yMin+1) do
		table.insert(partsLayout,{})
		for j = 1,(xMax-xMin+1) do
			table.insert(partsLayout[i], {0, 0, 0})
		end
	end
	for i,part in ipairs(self.parts) do
		local x = self.partCoords[i].x
		local y = self.partCoords[i].y
		partsLayout[y - yMin + 1][x - xMin + 1] = {i, 0, 0}
	end
	if self.corePart then
		for i,part in ipairs(self.parts) do
			if self.corePart == part then
				index = i
			end
		end
	else
		index = 1
	end
	local x = self.partCoords[index].x
	local y = self.partCoords[index].y
	partsLayout[y - yMin + 1][x - xMin + 1][2] = 1
	partsLayout[y - yMin + 1][x - xMin + 1][3] = 1

	local structureIndex = 1
	local checkParts = {index}
	while #checkParts ~= 0 do
		local partIndex = checkParts[#checkParts]
		table.remove(checkParts, #checkParts)
		for i = 1,4 do
			if self.parts[partIndex].connectableSides[i] then
				x = self.partCoords[partIndex].x
				y = self.partCoords[partIndex].y
				if i == 1 then
					y = y + 1
				elseif i == 2 then
					x = x - 1
				elseif i == 3 then
					y = y - 1
				elseif i == 4 then
					x = x + 1
				end
				x1 = x - xMin + 1
				y1 = y - yMin + 1
				local part, side, newIndex, state
				if partsLayout[y1] and partsLayout[y1][x1] then
					newIndex = partsLayout[y1][x1][1]
					state = partsLayout[y1][x1][2]
				end
				if newIndex and newIndex ~= 0 and state == 0 then
					part = self.parts[newIndex]
					side = (i - self.partOrient[newIndex] + 2) % 4 + 1
				end
				if part and side and part.connectableSides[side] then
					table.insert(checkParts, newIndex)
					partsLayout[y1][x1][2] = 1
					partsLayout[y1][x1][3] = structureIndex			
				end
			end
		end
		
		if #checkParts == 0 then
			for i in ipairs (self.parts) do
				partIndex = i
				x = self.partCoords[partIndex].x
				y = self.partCoords[partIndex].y
				x1 = x - xMin + 1
				y1 = y - yMin + 1
				if partsLayout[y1][x1][2] == 0 then
					table.insert(checkParts, partIndex)
					structureIndex = structureIndex + 1
					partsLayout[y1][x1][2] = 1
					partsLayout[y1][x1][3] = structureIndex
					break
				end
			end
		end
	end

	local partList = {}
	for i in ipairs (self.parts) do
		x = self.partCoords[i].x
		y = self.partCoords[i].y
		x1 = x - xMin + 1
		y1 = y - yMin + 1
		table.insert(partList, partsLayout[y1][x1][3])
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
	table.insert(self.parts, part)
	table.insert(self.partCoords, {x = x, y = y})
	table.insert(self.partOrient, orientation)
	table.insert(self.fixtures, fixture)
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
	if self.parts[partIndex] == self.corePart then
		self.corePart = nil
	end
	self.fixtures[partIndex]:destroy()
	table.remove(self.parts, partIndex)
	table.remove(self.partCoords, partIndex)
	table.remove(self.fixtures, partIndex)
	table.remove(self.partOrient, partIndex)

	if #self.parts == 0 then
		self.isDestroyed = true
	end
end

function Structure:damagePart(index)
	self.parts[index]:takeDamage()
	if self.parts[index].destroy then
		x, y = self:getAbsPartCoords(index)
		newParticle = {"particles", x, y}
		self:removePart(index)
		if self.isDestroyed then
			return {newParticle}
		end
		local partList = self:testConnection()
		local structureList = {}
		local coordsList = {}
		for i = #partList,1,-1 do
			if partList[i] ~= 1 then
				local partStructure = structureList[partList[i]]
				if partStructure then
					local partX = coordsList[partList[i]][1]
					local partY = coordsList[partList[i]][2]
					local partOrient = coordsList[partList[i]][3]
					partStructure:annexPart(self, i, partOrient,
											partX, partY, 0, 0)
				else
					local partX = self.partCoords[i].x
					local partY = self.partCoords[i].y
					local partOrient = (-self.partOrient[i] + 1) % 4 + 1
					coordsList[partList[i]] = {partX, partY, partOrient}
					local x, y, angle = self:getAbsPartCoords(i)
					structureList[partList[i]] =
							self:createStructure(self.parts[i], 
												 {x, y, angle})
					self:removePart(i)
				end
			end
		end
	end
	local newObjects
	if newStructures then
		newObjects = newStructures
		table.insert(newObjects, newParticle)
	else
		newObjects = {newParticle}
	end
	return newStructures
end

-- Find the absolute coordinates of a part given the x and y offset values of
-- the part and the absolute coordinates and angle of the structure it is in.
function Structure:getAbsPartCoords(index)
	x, y = Util.computeAbsCoords(
		self.partCoords[index].x*self.PARTSIZE,
		self.partCoords[index].y*self.PARTSIZE,
		self.body:getAngle())
	orient = self.partOrient[index]
	return self.body:getX() + x, self.body:getY() + y,
		   self.body:getAngle() + (orient - 1) * math.pi/2
				% (2*math.pi)
end

function Structure:command(orders)
--	local newObjects = {}

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

--------------------------------------------------------------------------------
--[[
	for i,part in ipairs(self.parts) do
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
	end

	return newObjects, commands
--]]
--------------------------------------------------------------------------------
	
	return commands
end

function Structure:testLocation(locationX, LocationY)
	index, partSide = self:getPartIndex(locationX, LocationY)
	if index then
		return true, {index, partSide}
	else
		return false
	end
end

function Structure:getPartIndex(locationX, locationY)
	for i,part in ipairs(self.parts) do
		local inside, partSide = self:withinPart(i, locationX, locationY)
		if inside then
			return i, partSide
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
		return true, partSide
	end
	return false, partSide
end

function Structure:update(dt, playerLocation, aiData)
	local newObjects = {}
	local partsInfo = {}
	if self.corePart then
		partsInfo = self:command(self.corePart:getOrders({self.body:getX(),self.body:getY(), self.body:getAngle()}, playerLocation, aiData))
	end
	local location = {self:getLocation()}
	local directionX = math.cos(location[3])
	local directionY = math.sin(location[3])
	local locationInfo = {location, {directionX, directionY}}
	partsInfo["locationInfo"] = locationInfo

	for i, part in ipairs(self.parts) do
		local l = {self.partCoords[i].x, self.partCoords[i].y}
		local s = {Util.sign(l[1]), Util.sign(l[2])}
		local newObject = part:update(dt, partsInfo, l, s, self.partOrient[i])
		if newObject then
			table.insert(newObjects, newObject)
		end
	end
	return newObjects
end

function Structure:draw()
	for i,part in ipairs(self.parts) do
		local x, y, angle = self:getAbsPartCoords(i)
		self.parts[i]:draw(x, y, angle)
	end
end

return Structure
