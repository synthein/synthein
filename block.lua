local Part = require("part")

local Block = {}
Block.__index = Block
setmetatable(Block, Part)

function Block.create(world, x, y)
	local self = Part.create("block")
	setmetatable(self, Block)

	self.physicsShape = love.physics.newRectangleShape(self.width, self.height)

	return self
end

return Block
