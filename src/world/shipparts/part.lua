-- Components
local Health = require("world/shipparts/health")

-- Utilities
local Util = require("util")
local LocationTable = require("locationTable")
local PhysicsReferences = require("world/physicsReferences")

local Part = class()

function Part:__create()
	self.physicsShape = nil
	self.connectableSides = {true, true, true, true}
	self.thrust = 0
	self.torque = 0
	self.gun = false
	self.type = "generic"

	self.modules = {health = Health(10)}

	self.userData = {}
	function self.userData:draw(fixture)
		local x, y, angle = LocationTable(fixture, self.location):getXYA()
		love.graphics.draw(self.image, x, y, angle, 1/self.width, -1/self.height, self.width/2, self.height/2)
	end

	function self.userData:collision(fixture, otherFixture, sqVelocity, pointVelocity)
		local object = otherFixture:getUserData()
		local _, _, mass, _ = otherFixture:getMassData()
		local damage = math.floor(sqVelocity * mass / 40)
		object:damage(otherFixture, damage)
		local body = fixture:getBody()
		local mult = -damage

		if mult < -10 then mult = -10 end
		mult = mult / 10
		local xI, yI = unpack(pointVelocity)
	end

	local modules = self.modules
	function self.userData:damage(fixture, damage)
		local location = LocationTable(fixture, self.location)
		modules.health:damage(damage, location)
	end
end

function Part:loadData(data)
	if data[1] then self.health = data[1] end
end

function Part:saveData()
	return {self.health}
end

function Part:getModules()
	return self.modules
end

function Part:setFixture(fixture)
	self.fixture = fixture

	self.fixture:setUserData(self.userData)
	self.userData.image = self.image
	self.userData.width = self.width
	self.userData.height = self.height

	PhysicsReferences.setFixtureType(self.fixture, "general")
end

function Part:setLocation(location)
	self.location = location
	self.userData.location = location
end

function Part:withinPart(x, y)
	return self.fixture:testPoint(x, y)
end

function Part:getWorldLocation()
	if not self.fixture:isDestroyed() then
		return (LocationTable(self.fixture, self.location))
	end
end

function Part:getPartSide(locationX, locationY)
	local partX, partY, partAngle = self:getWorldLocation():getXYA()
	local angleToCursor = Util.vectorAngle(locationX - partX,
										   locationY - partY)
	local angleDifference = angleToCursor - partAngle
	local partSide = math.floor((angleDifference*2/math.pi - 1/2) % 4 +1)
	return partSide
end

return Part
