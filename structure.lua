local Structure = {}
Structure.__index = Structure

function Structure.create(block)
	local self = {}
	setmetatable(self, Structure)
	
	-- Each member in the structure remembers the block object it is associated
	-- with and the joint connecting it to another block in the structure.
	self.members = { [1] = {block = block, joint = nil}}

	player.isInStructure = true
	self.isPlayerShip = false

	return self
end

function Structure.createPlayerShip(player)
	local self = Structure.create(player)

	player.isInStructure = true
	self.isPlayerShip = true

	return self
end

-- Add a block to the structure.
-- block is a Block object to add to the structure.
-- connectionPoint is the Block object to attach block to.
-- side is which side of connectionnPoint to attach block to.
-- jointType is the type of Box2d joint to use.
function Structure:addBlock(block, connectionPoint, side)
	-- Don't add the block to the structure if it is already here.
	if self:findBlock(block) then return end
	
	if side == "top" then
		block:fly(connectionPoint.body:getX(),
		          connectionPoint.body:getY() - connectionPoint.height,
				  connectionPoint.body:getAngle())
	end
	if side == "bottom" then
		block:fly(connectionPoint.body:getX(),
		          connectionPoint.body:getY() + connectionPoint.width,
				  connectionPoint.body:getAngle())
	end
	if side == "right" then
		block:fly(connectionPoint.body:getX() + connectionPoint.width,
		          connectionPoint.body:getY(),
				  connectionPoint.body:getAngle())
	end
	if side == "left" then
		block:fly(connectionPoint.body:getX() - connectionPoint.width,
		          connectionPoint.body:getY(),
				  connectionPoint.body:getAngle())
	end
	
	-- Add the new member to our list and store the block and joint associated
	-- with it.
	table.insert(self.members, {block = block, joint = love.physics.newWeldJoint(block.body, connectionPoint.body, 0, 0)})
	block.isInStructure = true
end

function Structure:addHinge()
end

-- Check if a block is in this structure.
-- If it is, return the block and its location in the members table.
-- If it is not, return nil.
function Structure:findBlock(block)
	for i, member in ipairs(self.members) do
		if member.block == block then
			return member, i
		end
	end

	return nil
end

function Structure:removeBlock(block)
	member, index = self:findBlock(block) 
	if member then
		member.block.isInStructure = false
		member.joint:destroy()
		table.remove(self.members, i)
	end
end

function Structure:removeLastBlock()
	-- Don't try to remove a member if the structure is already empty.
	if #self.members > 1 then
		self.members[#self.members].block.isInStructure = false
		self.members[#self.members].joint:destroy()
		table.remove(self.members)
	elseif #self.members == 1 then
		self:destroy()
	end
end

function Structure:destroy()
	for i, member in ipairs(self.members) do
		if member.joint then
			member.joint:destroy()
		end
		table.remove(self.members, i)
	end
end

-- todo:
-- don't use members[1]
-- don't call this function from love.update()
function Structure:handleInput()
	if love.keyboard.isDown("up") then
		self.members[1].block.body:applyForce(
			self.members[1].block.thrust*math.cos(self.members[1].block.body:getAngle()-math.pi/2),
			self.members[1].block.thrust*math.sin(self.members[1].block.body:getAngle()-math.pi/2))
	end
	if love.keyboard.isDown("down") then
		self.members[1].block.body:applyForce(
			-self.members[1].block.thrust*math.cos(self.members[1].block.body:getAngle()-math.pi/2),
		    -self.members[1].block.thrust*math.sin(self.members[1].block.body:getAngle()-math.pi/2))
	end
	if love.keyboard.isDown("left") then
		self.members[1].block.body:applyTorque(-self.members[1].block.torque)
	end
	if love.keyboard.isDown("right") then
		self.members[1].block.body:applyTorque(self.members[1].block.torque)
	end
end

return Structure
