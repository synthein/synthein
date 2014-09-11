local Part = require("part")

local Structure = {}
Structure.__index = Structure

function Structure.create(part, world, x, y)
	local self = {}
	setmetatable(self, Structure)

	self.body = love.physics.newBody(world, x, y, "dynamic")

	self.body:setAngularDamping(0.2)
	self.body:setLinearDamping(0.1)

	self.parts = {part}
	self.fixtures = {love.physics.newFixture(self.body, part.shape)}

	self.thrust = part.thrust
	self.torque = part.torque

	return self
end

function Structure.createPlayerShip(player, world, x, y)
	local self = Structure.create(player, world, x, y)

	self.isPlayerShip = true

	return self
end

function Structure.createAnchor(anchor, world, x, y)
	local self = Structure.create(anchor, world, x, y)

	self.isAnchor = true
	self.body:setType("static")

	return self
end

-- Add a part to the structure.
-- part is a part object to add to the structure.
-- connectionPoint is the part object to attach part to.
-- side is which side of connectionnPoint to attach part to.
-- jointType is the type of Box2d joint to use.
function Structure:addpart(part, connectionPoint, side)
	-- Don't add the part to the structure if it is already here.
	if self:findpart(part) then return end

	if side == "top" then
		part:fly(
			connectionPoint.body:getX(),
			connectionPoint.body:getY() - connectionPoint.height,
			connectionPoint.body:getAngle())
	end
	if side == "bottom" then
		part:fly(
			connectionPoint.body:getX(),
			connectionPoint.body:getY() + connectionPoint.width,
			connectionPoint.body:getAngle())
	end
	if side == "right" then
		part:fly(
			connectionPoint.body:getX() + connectionPoint.width,
			connectionPoint.body:getY(),
			connectionPoint.body:getAngle())
	end
	if side == "left" then
		part:fly(
			connectionPoint.body:getX() - connectionPoint.width,
			connectionPoint.body:getY(),
			connectionPoint.body:getAngle())
	end

	-- Add the new member to our list and store the part and joint associated
	-- with it.
	table.insert(self.parts, {part = part, joint = love.physics.newWeldJoint(part.body, connectionPoint.body, 0, 0)})
	part.isInStructure = true
end

function Structure:addHinge()
end

-- Check if a part is in this structure.
-- If it is, return the part and its location in the parts table.
-- If it is not, return nil.
function Structure:findPart(part)
	for i, member in ipairs(self.parts) do
		if member.part == part then
			return member, i
		end
	end

	return nil
end

function Structure:removePart(part)
	member, index = self:findpart(part)
	if member then
		member.part.isInStructure = false
		member.joint:destroy()
		table.remove(self.parts, i)
	end
end

function Structure:removeLastPart()
	-- Don't try to remove a member if the structure is already empty.
	if #self.parts > 1 then
		self.parts[#self.parts].part.isInStructure = false
		self.parts[#self.parts].joint:destroy()
		table.remove(self.parts)
	elseif #self.parts == 1 then
		self:destroy()
	end
end

function Structure:destroy()
	for i, member in ipairs(self.parts) do
		if member.joint then
			member.joint:destroy()
		end
		table.remove(self.parts, i)
	end
end

function Structure:draw()
	for i, part in ipairs(self.parts) do
		part:draw(self.body:getX(), self.body:getY(), self.body:getAngle(),
		          playerX, playerY)
	end
end

-- todo:
-- don't use parts[1]
-- don't call this function from love.update()
function Structure:handleInput()
	if love.keyboard.isDown("up") then
		self.body:applyForce(
			self.thrust*math.cos(self.body:getAngle()-math.pi/2),
			self.thrust*math.sin(self.body:getAngle()-math.pi/2))
	end
	if love.keyboard.isDown("down") then
		self.body:applyForce(
			-self.thrust*math.cos(self.body:getAngle()-math.pi/2),
		    -self.thrust*math.sin(self.body:getAngle()-math.pi/2))
	end
	if love.keyboard.isDown("left") then
		self.body:applyTorque(-self.torque)
	end
	if love.keyboard.isDown("right") then
		self.body:applyTorque(self.torque)
	end
end

return Structure
