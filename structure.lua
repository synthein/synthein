local Part = require("part")
require("util")

local Structure = {}
Structure.__index = Structure

Structure.PARTSIZE = 20

function Structure.create(part, world, x, y)
	local self = {}
	setmetatable(self, Structure)

	self.thrust = 0

	if part.type == "player" then
		self.body = love.physics.newBody(world, x, y, "dynamic")
		self.body:setAngularDamping(1)
		self.body:setLinearDamping(0.5)
		self.thrust = part.thrust
		self.torque = part.torque
	elseif part.type == "anchor" then
		self.body = love.physics.newBody(world, x, y, "static")
	else
		self.body = love.physics.newBody(world, x, y, "dynamic")
		self.body:setAngularDamping(0.2)
		self.body:setLinearDamping(0.1)
	end

	self.type = part.type -- type can be "player", "anchor", or "generic"
	self.parts = {part}
	self.partCoords = { {x = 0, y = 0} }
	self.partOrient = {1}
	self.fixtures = {love.physics.newFixture(self.body, part.shape)}

	return self
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

	local structureOffsetX, structureOffsetY

	if structureSide == 1 then
		structureOffsetX = self.partCoords[bIndex].x
		structureOffsetY = self.partCoords[bIndex].y - 1
	elseif structureSide == 2 then
		structureOffsetX = self.partCoords[bIndex].x + 1
		structureOffsetY = self.partCoords[bIndex].y
	elseif structureSide == 3 then
		structureOffsetX = self.partCoords[bIndex].x
		structureOffsetY = self.partCoords[bIndex].y + 1
	elseif structureSide == 4 then
		structureOffsetX = self.partCoords[bIndex].x - 1
		structureOffsetY = self.partCoords[bIndex].y
	end

	local annexeeOrientation = structureSide - annexeeSide
			while annexeeOrientation < 1 do
				annexeeOrientation = annexeeOrientation + 4
			end

			while annexeeOrientation >4 do
				annexeeOrientation = annexeeOrientation -4
			end

			local annexeeX = annexee.partCoords[aIndex].x
			local annexeeY = annexee.partCoords[aIndex].y

	for i=1,#annexee.parts do

		local x, y
		local annexeeOffsetX = annexee.partCoords[1].x - annexeeX
		local annexeeOffsetY = annexee.partCoords[1].y - annexeeY

		if annexeeOrientation == 1 then
			x = structureOffsetX + annexeeOffsetY
			y = structureOffsetY - annexeeOffsetX
		elseif annexeeOrientation == 2 then
			x = structureOffsetX + annexeeOffsetX
			y = structureOffsetY + annexeeOffsetY
		elseif annexeeOrientation == 3 then
			x = structureOffsetX - annexeeOffsetY
			y = structureOffsetY + annexeeOffsetX
		elseif annexeeOrientation == 4 then
			x = structureOffsetX - annexeeOffsetX
			y = structureOffsetY - annexeeOffsetY
		end

		-- Find out the orientation of the part based on the orientation of
		-- both structures.
		local partOrientation = annexeeOrientation + annexee.partOrient[1] + 2
		-- Make sure partOrientation is between 1 and 4
		while partOrientation > 4 do
			partOrientation = partOrientation - 4
		end
		while partOrientation < 1 do
			partOrientation = partOrientation + 4
		end

		self:addPart(annexee.parts[1], x, y, partOrientation)
		annexee:removePart(annexee.parts[1])
	end
end

-- Add one part to the structure.
-- x, y are the coordinates in the structure
-- orientation is the orientation of the part according to the structure
function Structure:addPart(part, x, y, orientation)
	local x1, y1, x2, y2, x3, y3, x4, y4 = part.shape:getPoints()
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
-- structure, then destroy the structure and return 1. Otherwise return nil.
-- ** Always check the return value and remove the reference to the structure
-- if it is destroyed.
function Structure:removePart(part)
	i = self:findPart(part)
	if i then
		self.fixtures[i]:destroy()
		table.remove(self.parts, i)
		table.remove(self.partCoords, i)
		table.remove(self.fixtures, i)
		table.remove(self.partOrient, i)
	end
	if #self.parts == 0 then
		self:destroy()
		return 1
	end
end

-- todo: this function doesn't actually do anything. maybe remove it.
-- Destroy this structure, removing the physics body from the world
function Structure:destroy()
	self.body:destroy()
	self = nil
end

-- move the structure to a particular location smoothly
function Structure:fly(x, y, angle)
	-- right now this is anything but smooth...
	self.body:setPosition(x, y)
	self.body:setAngle(angle)
end

-- Find the absolute coordinates of a part given the x and y offset values of
-- the part and the absolute coordinates and angle of the structure it is in.
function Structure:getAbsPartCoords(index)
	local x, y = computeAbsCoords(
		self.partCoords[index].x*self.PARTSIZE,
		self.partCoords[index].y*self.PARTSIZE,
		self.body:getAngle())

	return self.body:getX() + x, self.body:getY() + y
end

function Structure:draw()
	for i, part in ipairs(self.parts) do
		local x, y = self:getAbsPartCoords(i)
		part:draw(x, y,
		          self.body:getAngle() + (self.partOrient[i] - 1) * math.pi/2,
		          globalOffsetX, globalOffsetY)
	end
end

function Structure:command(orders)
	local Fx, Fy -- The x and y components of the force
	local direction -- The direction of the engines we want to activate

	for i, order in ipairs(orders) do
		-- Decide the force components based on the direction.
		if order == "forward" then
			Fx = self.thrust * math.cos(self.body:getAngle() - math.pi/2)
			Fy = self.thrust * math.sin(self.body:getAngle() - math.pi/2)
			direction = 1
		elseif order == "back" then
			Fx = -self.thrust * math.cos(self.body:getAngle() - math.pi/2)
			Fy = -self.thrust * math.sin(self.body:getAngle() - math.pi/2)
			direction = 3
		elseif order == "left" then
			self.body:applyTorque(-self.torque)
		elseif order == "right" then
			self.body:applyTorque(self.torque)
		elseif order == "strafeLeft" then
			Fx = -self.thrust * math.cos(self.body:getAngle())
			Fy = -self.thrust * math.sin(self.body:getAngle())
			direction = 2
		elseif order == "strafeRight" then
			Fx = self.thrust * math.cos(self.body:getAngle())
			Fy = self.thrust * math.sin(self.body:getAngle())
			direction = 4
		end

		if order ~= "left" and order ~= "right" then
			-- Apply the base force from the playerBlock.
			self.body:applyForce(Fx, Fy, self.body:getX(), self.body:getY())

			-- Apply the force for the engines
			for i,part in ipairs(self.parts) do
				-- Choose parts that have thrust and are pointed the right
				-- direction, but exclude playerBlock, etc.
				if part.thrust and
				   self.partOrient[i] == direction and
				   part.type == "generic" then
					self.body:applyForce(
						Fx, Fy,
						self.body:getX() + self.partCoords[i].x*self.PARTSIZE,
						self.body:getY() + self.partCoords[i].y*self.PARTSIZE)
				end
			end
		end
	end
end

return Structure
