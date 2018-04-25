local LocationTable = require("locationTable")
local WorldObjects = class()

function WorldObjects:__create(worldInfo, location, data)
	local physics = worldInfo.physics
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
	return (LocationTable(self.body))
end

function WorldObjects:draw()
	local x, y, angle = self:getLocation():getXYA()
	local data = self.drawData
	love.graphics.draw(data[1], x, y, angle, data[2], data[3], data[4], data[5])
end

return WorldObjects
