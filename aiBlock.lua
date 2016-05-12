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

return AIBlock
