local Location = require("world/location")

local WorldObjects = class()

function WorldObjects:__create(worldInfo, location, data, appendix)
	local physics = worldInfo.physics
	self.body = Location.createBody(physics, "dynamic", location)
	self.isDestroyed = false
end

function WorldObjects:postCreate(references)
end

function WorldObjects:destroy()
	self.body:destroy()
	self.isDestroyed = true
end

function WorldObjects:getLocation()
	return {Location.bodyCenter6(self.body)}
end

return WorldObjects
