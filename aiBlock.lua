local Part = require("part")

local AIBlock = {}
AIBlock.__index = AIBlock
setmetatable(AIBlock, Part)

function AIBlock.create()
	local self = Part.create("ai")
	setmetatable(self, AIBlock)

	self.physicsShape = love.physics.newRectangleShape(self.width, self.height)
	self.thrust = 150
	self.torque = 350
	self.type = "player"

	return self
end

function AIBlock:draw(x, y, angle, globalOffsetX, globalOffsetY)
	love.graphics.draw(
		self.image,
		SCREEN_WIDTH/2 - globalOffsetX + x,
		SCREEN_HEIGHT/2 - globalOffsetY + y,
		angle, 1, 1, self.width/2, self.height/2)
end

return AIBlock
