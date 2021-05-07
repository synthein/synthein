local PhysicsReferences = require("world/physicsReferences")
local Timer = require("timer")
local Util = require("util")

local Missile = class(require("world/worldObjects"))

function Missile:__create(worldInfo, location, data, appendix)
	self.thrust = 10
	self.torque = 0.2
	self.body:setLinearVelocity(location[4], location[5])
	self.body:setAngularVelocity(0)

	local physicsShape = love.physics.newRectangleShape(.4, .8)
	self.fixture = love.physics.newFixture(self.body, physicsShape)
	PhysicsReferences.setFixtureType(self.fixture, "missile")
	self.fixture:setUserData(self)

	local visionArcRadius = 50
	local visionArcAngle = (60/180)*(math.pi)
	local x, y = Util.vectorComponents(visionArcRadius, (math.pi/2)-(visionArcAngle/2))
	local visionArcShape = love.physics.newPolygonShape(
		0, 0,
		x, y,
		-x, y
	)

	self.target = nil
	self.visionArc = love.physics.newFixture(self.body, visionArcShape, 0)
	PhysicsReferences.setFixtureType(self.visionArc, "camera")
	self.visionArc:setUserData({
		collision = function(_, _, targetFixture)
			if not self.target then
				self.target = targetFixture:getBody()
			end
		end,
		draw = function() end,
	})
	self.visionArc:setSensor(true)

	self.timer = Timer(15)
	self.firstContact = true
	self.sourcePart = data
	self.startLocation = location
end

function Missile:postCreate(references)
	local team, time = unpack(self.sourcePart)
	self.team = team
	self.timer:time(time)
end

function Missile:type()
	return "missile"
end

function Missile:getSaveData(references)
	local part = self.sourcePart
	local x, y = unpack(part.location)
	local structure = part.fixture:getBody():getUserData()
	structure = references[structure]
	return {self.timer:time(), structure, x, y}
end

function Missile:collision(fixture, otherFixture)
	if fixture ~= self.sourcePart.fixture and self.firstContact then
		local object = otherFixture:getUserData()
		object:damage(otherFixture, 10)
		self:explode()
		self.firstContact = false --this is needed because of bullet body physics
	end
end

function Missile:damage(fixture)
	self:explode()
end

function Missile:explode()
	self:destroy()
end

function Missile:update(dt)
	if self.timer:ready(dt) then
		self:destroy()
		return
	end

	if self.target then
		local missileX, missileY = self.body:getPosition()
		local targetX, targetY = self.target:getPosition()
		local angle = Util.vectorAngle(targetX - missileX, targetY - missileY)
		local angleToTarget = (-self.body:getAngle() + angle + math.pi/2) % (2*math.pi) - math.pi
		local sign = Util.sign(angleToTarget)

		self.body:applyTorque(sign * self.torque)
	end

	self.body:applyForce(Util.vectorComponents(self.thrust, self.body:getAngle() + math.pi/2))

	return
end

local imageName = "missile"
local image = love.graphics.newImage("res/images/"..imageName..".png")

Missile.draw = Missile.createDrawImageFunction(image, .4, .8)

return Missile
