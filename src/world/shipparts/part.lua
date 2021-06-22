-- Utilities
local vector = require("vector")
local LocationTable = require("locationTable")
local Draw = require("world/draw")

local Part = class()

function Part:__create()
	self.physicsShape = nil
	self.connectableSides = {true, true, true, true}
	self.thrust = 0
	self.torque = 0
	self.gun = false
	self.type = "generic"

	self.modules = {}
end

function Part:loadData(data)
	if data[1] then self.modules.hull.health = data[1] end
end

function Part:saveData()
	return {self.modules.hull.health}
end

function Part:getModules()
	return self.modules
end

function Part:addFixtures(body)
	self.modules["hull"]:addFixtures(body)
end

function Part:removeFixtures()
	self.modules["hull"]:removeFixtures()
end

function Part:setLocation(location)
	self.location = location
	self.modules["hull"].userData.location = location
end

function Part:withinPart(x, y)
	return self.modules["hull"].fixture:testPoint(x, y)
end

function Part:getWorldLocation()
	if not self.modules["hull"].fixture:isDestroyed() then
		return (LocationTable(self.modules["hull"].fixture, self.location))
	end
end

function Part:getPartSide(locationX, locationY)
	local partX, partY, partAngle = self:getWorldLocation():getXYA()
	local angleToCursor = vector.angle(
		locationX - partX,
		locationY - partY
	)
	local angleDifference = angleToCursor - partAngle
	local partSide = math.floor((angleDifference*2/math.pi - 1/2) % 4 +1)
	return partSide
end

return Part
