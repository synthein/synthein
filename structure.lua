local Part = require("part")
require("util")

local Structure = {}
Structure.__index = Structure

Structure.PARTSIZE = 20

function Structure.create(part, world, x, y)
	local self = {}
	setmetatable(self, Structure)

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
	self.fixtures = {love.physics.newFixture(self.body, part.shape)}

	return self
end

-- Merge another structure into this one.
-- ** After calling this method, the merged structure will be destroyed and
-- should be removed from any tables it is referenced in.
-- Parameters:
-- structure is the structure to merge
-- connectionPointA is the block that will connect to this this structure
-- connectionPointB is the block to connect the structure to
-- side is the side of connectionPointB to add the structure to
function Structure:merge(structure, connectionPointA, orientation, 
                         connectionPointB, side)
	local aIndex = structure:findPart(connectionPointA)
	local bIndex = self:findPart(connectionPointB)
	
	-- cplX, cplY are the coordinates of the connection point from the old 
	-- structure
	local cplX, cplY = structure.partCoords[aIndex].x, 
					   structure.partCoords[aIndex].y
	-- offX, offY are the coordinates of the block that the other structure is 
	-- attaching to
	local offX, offY = self.partCoords[bIndex].x, 
					   self.partCoords[bIndex].y
					   
	-- this is to account for which side of the block the structure is being 
	-- attached to 
	if side == 4 then
		offY = offY - Structure.PARTSIZE
	elseif side == 2 then
		offY = offY + Structure.PARTSIZE
	elseif side == 3 then
		offX = offX - Structure.PARTSIZE
	elseif side == 1 then
		offX = offX + Structure.PARTSIZE
	end

	-- this is placing the structure in about the right place
	structure:fly(self.body:getX() + offX, self.body:getY() + offY,
	              self.body:getAngle())

	-- structure.partCoords are the coordinates from the old structure
	-- relX, relY are the new coordinates relative to the offset point
	-- absX, absY are the new coordinates for the block
	for i=1,#structure.parts do
		local relX, relY
		local absX, absY
		if orientation == 4 then 
			relX =  structure.partCoords[1].x - cplX
			relY =  structure.partCoords[1].y - cplY
		elseif orientation == 2 then 
			relX = -structure.partCoords[1].x + cplX
			relY = -structure.partCoords[1].y + cplY
		elseif orientation == 3 then 
			relX =  structure.partCoords[1].y - cplY
			relY = -structure.partCoords[1].x + cplX
		elseif orientation == 1 then 
			relX = -structure.partCoords[1].y + cplY
			relY =  structure.partCoords[1].x - cplX
		end
		absX = relX + offX
		absY = relY + offY
		self:addPart(structure.parts[1], "up", absX, absY)
		structure:removePart(structure.parts[1])
	end
end

-- Add one part to the structure.
-- x, y are the coordinates in the structure 
-- orientation is the orientation of the part according to the structure
function Structure:addPart(part, orientation, x, y)
	local x1, y1, x2, y2, x3, y3, x4, y4 = part.shape:getPoints()
	local width = math.abs(x1 - x3)
	local height = math.abs(y1 - y3)
	local shape = love.physics.newRectangleShape(x, y, width, height)
	local fixture = love.physics.newFixture(self.body, shape)
	table.insert(self.parts, part)
	table.insert(self.partCoords, {x = x, y = y})
	table.insert(self.fixtures, fixture)
end

function Structure:addHinge()
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
		self.partCoords[index].x,
		self.partCoords[index].y,
		self.body:getAngle())

	return self.body:getX() + x, self.body:getY() + y
end

function Structure:draw()
	for i, part in ipairs(self.parts) do
		local x, y = self:getAbsPartCoords(i)
		part:draw(x, y,	self.body:getAngle(), globalOffsetX, globalOffsetY)
	end
end

function Structure:command(orders)
	for i, order in ipairs(orders) do
		if order == "forward" then
			self.body:applyForce(
				self.thrust * math.cos(self.body:getAngle() - math.pi/2),
				self.thrust * math.sin(self.body:getAngle() - math.pi/2))
		elseif order == "back" then
			self.body:applyForce(
				-self.thrust * math.cos(self.body:getAngle() - math.pi/2),
			    -self.thrust * math.sin(self.body:getAngle() - math.pi/2))
		elseif order == "left" then
			self.body:applyTorque(-self.torque)
		elseif order == "right" then
			self.body:applyTorque(self.torque)
		elseif order == "strafeLeft" then
			self.body:applyForce(
				-self.thrust * math.cos(self.body:getAngle()),
				-self.thrust * math.sin(self.body:getAngle()))
		elseif order == "strafeRight" then
			self.body:applyForce(
				self.thrust * math.cos(self.body:getAngle()),
				self.thrust * math.sin(self.body:getAngle()))
		end
	end
end

return Structure
