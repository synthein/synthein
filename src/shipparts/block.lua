local Part = require("shipparts/part")

local Block = {}
Block.__index = Block
setmetatable(Block, Part)

function Block.create()
	local self = Part.create()
	setmetatable(self, Block)

	self.image = love.graphics.newImage("res/images/block.png")
	self.width = self.image:getWidth()
	self.height = self.image:getHeight()

	return self
end

return Block
