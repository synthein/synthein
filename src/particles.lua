local Particles = {}
Particles.__index = Particles

local explosionImage = love.graphics.newImage("res/images/explosion.png")

function Particles.create(worldInfo, location, data)
	self = {}
	setmetatable(self, Particles)

	self.physics = worldInfo.physics
	self.events = worldInfo.events
	local x, y, a, vx, vy = unpack(location)
	self.body = love.physics.newBody(self.physics, x, y, "dynamic")
	self.body:setLinearVelocity(vx, vy)
	self.physicsShape = love.physics.newRectangleShape(40, 40)
	self.fixture = love.physics.newFixture(self.body, self.physicsShape)
	self.fixture:setUserData(self)
	self.fixture:setSensor(true)
	self.image = explosionImage
	self.ox = 20
	self.oy = 20
	self.time = 0.3
	self.isDestroyed = false
	self.data = data

	return self
end

function Particles:postCreate(references)
	self.time = self.data[1]
end

function Particles:getSaveData(references)
	return {self.time}
end

function Particles:destroy()
	self.body:destroy()
	self.isDestroyed = true
end

function Particles:collision(fixture)
end

function Particles:getLocation()
	return self.body:getPosition()
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
	local x, y = self:getLocation()
	camera:draw(self.image, x, y, 0, 1/20, 1/20, self.ox, self.oy)
end

return Particles
