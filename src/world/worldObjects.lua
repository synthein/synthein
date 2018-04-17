local LocationTable = require("locationTable")
local WorldObjects = class()

function WorldObjects:__create(worldInfo, location, data)
	local physics = worldInfo.physics
	location = LocationTable(unpack(location))
	self.body = location:createBody(physics, "dynamic")

	self.isDestroyed = false
end

function WorldObjects:postCreate(references)
end

function WorldObjects:destroy()
	self.body:destroy()
	self.isDestroyed = true
end

function WorldObjects:getLocation()
	local b = self.body
	local x, y = b:getPosition()
	local a = b:getAngle()
	local vx, vy = b:getLinearVelocity()
	local w = b:getAngularVelocity()
	return x, y, a, vx, vy, w
end

function WorldObjects:draw()
	local x, y, a = self:getLocation()
	local data = self.drawData
	love.graphics.draw(data[1], x, y, a, data[2], data[3], data[4], data[5])
end

return WorldObjects
