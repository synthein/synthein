local Timer = require("synthein").timer
local Draw = require("world/draw")

local Particles = class(require("world/worldObjects"))
local PhysicsReferences = require("world/physicsReferences")

function Particles:__create(worldInfo, location, data, appendix)
	self.physicsShape = love.physics.newRectangleShape(40, 40)
	self.fixture = love.physics.newFixture(self.body, self.physicsShape)
	self.fixture:setUserData(self)
	PhysicsReferences.setFixtureType(self.fixture, "visual")
	self.timer = Timer(0.3)
	self.data = data
end

function Particles:postCreate() --(references)
	self.timer.time = self.data[1]
end

function Particles:type()
	return "particles"
end

function Particles:getSaveData() --(references)
	return {self.timer.time}
end

function Particles.collision() --(fixture)
end

function Particles:update(dt)
	if self.timer:ready(dt) then
		self.body:destroy()
		self.isDestroyed = true
	end
	return {}
end

Particles.draw = Draw.createObjectDrawImageFunction("explosion", 2, 2)

return Particles
