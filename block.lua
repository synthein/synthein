local Part = require("part")

local Block = {}
Block.__index = Block
setmetatable(Block, Part)

function Block.create(world, x, y)
	local self = Part.create("block")
	setmetatable(self, Block)
	
	self.body = love.physics.newBody(world, x, y, "dynamic")
	self.shape = love.physics.newRectangleShape(self.width, self.height)
	self.fixture = love.physics.newFixture(self.body, self.shape)

	self.body:setAngularDamping(0.2)
	self.body:setLinearDamping(0.1)

	return self
end

return Block
