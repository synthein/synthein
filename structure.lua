local Structure = {}
Structure.__index = Structure

function Structure.create(block)
	local self = {}
	setmetatable(self, Structure)
	
	-- Each member in the structure remembers the block object it is associated
	-- with and the joint connecting it to another block in the structure.
	self.members = { [1] = {block = block, joints = nil}}

	return self
end

-- Add a block to the structure.
-- block is a Block object to add to the structure.
-- connectionPoint is the Block object to attach block to.
-- side is which side of connectionnPoint to attach block to.
-- jointType is the type of Box2d joint to use.
function Structure:addBlock(block, connectionPoint, side)
	if side == "right" then
		block:fly(connectionPoint.body:getX() + connectionPoint.width,
		          connectionPoint.body:getY(), connectionPoint.body:getAngle())
	end
	
	-- Add the new member to our list and store the block and joint associated
	-- with it.
	table.insert(self.members, {block = block, joint = love.physics.newWeldJoint(block.body, connectionPoint.body, 0, 0)})
end

function Structure:removeBlock(block)
	for i, member in ipairs(self.members) do
		if member == block then
			member.joint:destroy()
			table.remove(self.members, i)
			break
		end
	end
end

function Structure:addHinge()
end

return Structure
