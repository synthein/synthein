local Camera = require("camera")

local ViewPort = class()

function ViewPort:__create()
	self.camera = Camera.create()
end

function ViewPort:setScissor(x, y, width, height)
	self.camera:setScissor(x, y, width, height)
end

return ViewPort
