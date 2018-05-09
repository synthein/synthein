local Timer = require("timer")

local Particles = class(require("world/worldObjects"))

function Particles:__create(worldInfo, location, data, appendix)
	self.physicsShape = love.physics.newRectangleShape(40, 40)
	self.fixture = love.physics.newFixture(self.body, self.physicsShape)
	self.fixture:setUserData(self)
	self.fixture:setSensor(true)
	self.timer = Timer(0.3)
	self.data = data

	local image = love.graphics.newImage("res/images/explosion.png")
	self.drawData = {image, 1/20, -1/20, 20, 20}
end

function Particles:postCreate() --(references)
	self.time = self.data[1]
end

function Particles:getSaveData() --(references)
	return {self.time}
end

function Particles:collision() --(fixture)
end

function Particles:update(dt)
	if self.timer:ready(dt) then
		self.body:destroy()
		self.isDestroyed = true
	end
	return {}
end

return Particles
