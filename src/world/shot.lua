local Draw = require("world/draw")
local Timer = require("timer")

local vector = require("vector")

local Shot = class(require("world/worldObjects"))
local PhysicsReferences = require("world/physicsReferences")

function Shot:__create(worldInfo, location, data, appendix)
	local vx, vy = vector.components(25, location[3] + math.pi/2)
	self.body:setLinearVelocity(location[4] + vx, location[5] + vy)
	self.body:setAngularVelocity(0)
	self.body:setBullet(true)

	self.physicsShape = love.physics.newRectangleShape(.2, .2)
	self.fixture = love.physics.newFixture(self.body, self.physicsShape)
	self.fixture:setSensor(true)

	PhysicsReferences.setFixtureType(self.fixture, "projectiles")
	self.fixture:setUserData(self)

	self.timer = Timer(5)
	self.firstContact = true
	self.timePassed = false
	self.startLocation = location
	self.data = data
end

function Shot:postCreate(references)
	local time = unpack(self.data)
	self.timer:time(time)
	self.body:setLinearVelocity(self.startLocation[4], self.startLocation[5])
end

function Shot:type()
	return "shot"
end

function Shot:getSaveData(references)
	return {self.timer:time()}
end

function Shot:collision(fixture, otherFixture)
	if self.timePassed and self.firstContact then
		local object = otherFixture:getUserData()
		object:damage(otherFixture, 1)
		self:destroy()
		self.firstContact = false --this is needed because of bullet body physics
	end
end

function Shot:update(dt)
	self.timePassed = true
	if self.timer:ready(dt) then
		self:destroy()
	end

	return {}
end

Shot.draw = Draw.createObjectDrawImageFunction("shot", .1, .5)

return Shot
