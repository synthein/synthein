local Block = {}
Block.__index = Block

function Block.create(world, x, y)
	local self = setmetatable({}, Block)
	
	self.image = love.graphics.newImage("block.png")
	self.width = self.image:getWidth()
	self.height = self.image:getHeight()
	self.body = love.physics.newBody(world, x, y, "dynamic")
	self.shape = love.physics.newRectangleShape(self.width, self.height)
	self.fixture = love.physics.newFixture(self.body, self.shape)

	self.body:setAngularDamping(0.2)
	self.body:setLinearDamping(0.1)

	return self
end

function Block:update(dt)
end

function Block:draw(offsetX, offsetY)
	love.graphics.draw(self.image,
	                   love.graphics.getWidth()/2 - offsetX + self.body:getX(),
					   love.graphics.getHeight()/2 - offsetY + self.body:getY(),
					   self.body:getAngle()-math.pi/2, 1, 1, 10, 10)
end

function Block:fly() -- move the block to a particular location smoothly
end

return Block
