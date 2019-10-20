local Util = require("util")
local Timer = require("timer")

local Shot = class(require("world/worldObjects"))
local PhysicsReferences = require("world/physicsReferences")

function Shot:__create(worldInfo, location, data, appendix)
	local vx, vy = Util.vectorComponents(25, location[3] + math.pi/2)
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
	self.sourcePart = data
	self.startLocation = location
end

function Shot:postCreate(references)
	local time, structure, x, y = unpack(self.sourcePart)
	self.timer:time(time)
	structure = references[structure]
	self.sourcePart = structure.gridTable:index(x, y)
	self.body:setLinearVelocity(self.startLocation[4], self.startLocation[5])
end

function Shot:type()
	return "shot"
end

function Shot:getSaveData(references)
	local part = self.sourcePart
	local x, y = unpack(part.location)
	local structure = part.fixture:getBody():getUserData()
	structure = references[structure]
	return {self.timer:time(), structure, x, y}
end

function Shot:collision(fixture, otherFixture)
	if otherFixture ~= self.sourcePart.fixture and self.firstContact then
		local object = otherFixture:getUserData()
		object:damage(otherFixture, 1)
		self:destroy()
		self.firstContact = false --this is needed because of bullet body physics
	end
end

function Shot:update(dt)
	if self.timer:ready(dt) then
		self:destroy()
	end

	return {}
end

local imageName = "shot"
local image = love.graphics.newImage("res/images/"..imageName..".png")

Shot.draw = Shot.createDrawImageFunction(image, .1, .5)

return Shot
