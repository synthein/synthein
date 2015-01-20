local Part = require("part")

local PlayerBlock = {}
PlayerBlock.__index = PlayerBlock
setmetatable(PlayerBlock, Part)

function PlayerBlock.create()
	local self = Part.create("player")
	setmetatable(self, PlayerBlock)

	self.shape = love.physics.newRectangleShape(self.width, self.height)
	self.thrust = 150
	self.torque = 350
	self.type = "player"

	return self
end

function PlayerBlock:draw(x, y, angle)
	love.graphics.draw(self.image, SCREEN_WIDTH/2,
	                   SCREEN_HEIGHT/2, angle,
					   1, 1, self.width/2, self.height/2)
end

return PlayerBlock
