local Camera = require("camera")

local ViewPort = class()

function ViewPort:__create(world, team, defaultBody)
	self.camera = Camera.create(world, team, defaultBody)
end

function ViewPort:setScissor(x, y, width, height)
	self.camera:setScissor(x, y, width, height)
end

return ViewPort
