local Screen = require("screen")

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
	self.time = 0.3
	self.isDestroyed = false

	return self
end

function Particles:update(dt)
	self.time = self.time - dt
	if self.time <= 0 then
		self.isDestroyed = true
	end
	return {}, {}
end

function Particles:draw()
	Screen.draw(
		self.image,
		self.x,
		self.y,
		0, 1, 1, self.ox, self.oy)
end

return Particles
