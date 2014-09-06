Anchor = {}
Anchor.__index = Anchor

function Anchor.create(world, x, y)
	local self = setmetatable({}, Anchor)
	
	self.image = love.graphics.newImage("anchor.png")
	self.width = self.image:getWidth()
	self.height = self.image:getHeight()
	self.body = love.physics.newBody(world, x, y, "static")
	self.shape = love.physics.newRectangleShape(self.width, self.height)
	self.fixture = love.physics.newFixture(self.body, self.shape)

	return self
end

function Anchor:update(dt)
end

function Anchor:draw(offsetX, offsetY)
	love.graphics.draw(self.image,
	                   love.graphics.getWidth()/2 - offsetX + self.body:getX(),
					   love.graphics.getHeight()/2 - offsetY + self.body:getY(),
					   0, 1, 1, 10, 10)
end

return Anchor
