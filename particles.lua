local Particles = {}
Particles.__index = Particles

local explosionImage = love.graphics.newImage("res/images/explosion.png")
function Particles.newExplosion(x, y)
	self = {}
	setmetatable(self, Particles)

	self.image = explosionImage
	self.x = x
	self.y = y
	self.ox = 20
	self.oy = 20
	self.time = 1.0

	function self:update(dt)
		self.time = self.time - dt
	end

	return self
end

function Particles:draw(globalOffsetX, globalOffsetY)
	love.graphics.draw(
		self.image,
		SCREEN_WIDTH/2 - globalOffsetX + self.x,
		SCREEN_HEIGHT/2 - globalOffsetY + self.y,
		0, 1, 1, self.ox, self.oy)
end

return Particles
