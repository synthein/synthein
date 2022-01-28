local Draw = require("world/draw")
local PhysicsReferences = require("world/physicsReferences")
local Timer = require("timer")
local vector = require("vector")

local Missile = class(require("world/worldObjects"))

function Missile:__create(worldInfo, location, data, appendix)
	self.thrust = 10
	self.torque = 0.2
	self.body:setLinearVelocity(location[4], location[5])
	self.body:setAngularVelocity(0)

	local physicsShape = love.physics.newRectangleShape(.4, .8)
	self.fixture = love.physics.newFixture(self.body, physicsShape)
	PhysicsReferences.setFixtureType(self.fixture, "missile")

	local firstContact = true
	self.fixture:setUserData({
		collision = function(fixture, otherFixture)
			if fixture ~= self.sourcePart.fixture and firstContact then
				local object = otherFixture:getUserData()
				object:damage(otherFixture, 10)
				self.exploding = 1
				firstContact = false --this is needed because of bullet body physics
			end
		end,
		draw = Draw.createObjectDrawImageFunction("missile", .4, .8),
		damage = function() self.exploding = 1 end,
	})

	local visionArcRadius = 50
	local visionArcAngle = (60/180)*(math.pi)
	local x, y = vector.components(visionArcRadius, (math.pi/2)-(visionArcAngle/2))
	local visionArcShape = love.physics.newPolygonShape(
		0, 0,
		x, y,
		-x, y
	)

	self.target = nil
	self.visionArc = love.physics.newFixture(self.body, visionArcShape, 0)
	PhysicsReferences.setFixtureType(self.visionArc, "sensor")
	self.visionArc:setUserData({
		collision = function(fixture, otherFixture)
			if not self.target then
				self.target = otherFixture:getBody()
			end
		end,
		draw = function() end,
	})
	self.visionArc:setSensor(true)

	self.timer = Timer(15)
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

function Missile:explode()
	local explosionShape = love.physics.newCircleShape(2)
	local explosionFixture = love.physics.newFixture(self.body, explosionShape)
	PhysicsReferences.setFixtureType(explosionFixture, "sensor")
	explosionFixture:setUserData({
		collision = function(fixture, otherFixture)
			local object = otherFixture:getUserData()
			object:damage(otherFixture, 5)
		end,
	})
end

function Missile:update(dt)
	if self.timer:ready(dt) then
		self:destroy()
		return
	end

	if self.exploding == 1 then
		self:explode()
		self.exploding = self.exploding + 1
	elseif self.exploding == 2 then
		self:destroy()
		return
	elseif self.target then
		local missileX, missileY = self.body:getPosition()
		local targetX, targetY = self.target:getPosition()
		local angle = vector.angle(targetX - missileX, targetY - missileY)
		local angleToTarget = (-self.body:getAngle() + angle + math.pi/2) % (2*math.pi) - math.pi
		local sign = vector.sign(angleToTarget)

		self.body:applyTorque(sign * self.torque)
	end

	self.body:applyForce(vector.components(self.thrust, self.body:getAngle() + math.pi/2))

	return
end

return Missile
