local LocationTable = require("locationTable")

local WorldObjects = class()

function WorldObjects:__create(worldInfo, location, data, appendix)
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

return WorldObjects
