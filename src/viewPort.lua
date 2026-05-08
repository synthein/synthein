local Camera = require("camera")

local ViewPort = class()

function ViewPort:__create(world, team)
	self.camera = Camera.create(world, team)
end

function ViewPort:setScissor(x, y, width, height)
	self.camera:setScissor(x, y, width, height)
end

return ViewPort
