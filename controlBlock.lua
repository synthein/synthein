local Part = require("part")

local ControlBlock = {}
ControlBlock.__index = ControlBlock
setmetatable(ControlBlock, Part)

function ControlBlock.create()
	local self = Part.create("player")
	setmetatable(self, ControlBlock)

	self.physicsShape = love.physics.newRectangleShape(self.width, self.height)
	self.thrust = 150
	self.torque = 350
	self.type = "player"

	return self
end

function ControlBlock:draw(x, y, angle)
	love.graphics.draw(self.image, SCREEN_WIDTH/2,
	                   SCREEN_HEIGHT/2, angle,
					   1, 1, self.width/2, self.height/2)
end

return ControlBlock
