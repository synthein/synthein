local Screen = require("screen")

local Particles = {}
Particles.__index = Particles

local explosionImage = love.graphics.newImage("res/images/explosion.png")

function Particles.create(physics, location)
	self = {}
	setmetatable(self, Particles)

	self.physics = physics
	local x, y = unpack(location)
	self.body = love.physics.newBody(self.physics, x, y, "static")
	self.physicsShape = love.physics.newRectangleShape(40, 40)
	self.fixture = love.physics.newFixture(self.body, self.physicsShape)
	self.fixture:setUserData(self)
	self.image = explosionImage
	self.x = x
	self.y = y
	self.ox = 20
	self.oy = 20
	self.time = 0.3
	self.isDestroyed = false

	return self
end

function Particles:destroy()
	self.body:destroy()
	self.isDestroyed = true
end

function Particles:getLocation()
	return self.x, self.y
end

function Particles:update(dt)
	self.time = self.time - dt
	if self.time <= 0 then
		self.body:destroy()
		self.isDestroyed = true
	end
	return {}
end

function Particles:draw(camera)
	camera:draw(
		self.image,
		self.x,
		self.y,
		0, 1, 1, self.ox, self.oy)
end

return Particles
