local Part = require("part")

local Player = {}
Player.__index = Player
setmetatable(Player, Part)

function Player.create()
	local self = Part.create("player")
	setmetatable(self, Player)

	self.shape = love.physics.newRectangleShape(self.width, self.height)

	self.thrust = 150
	self.torque = 350

	return self
end

function Player:update(dt)
end

function Player:draw(x, y, angle)
	love.graphics.draw(self.image, love.graphics.getWidth()/2,
	                   love.graphics.getHeight()/2, angle,
					   1, 1, self.width/2, self.height/2)
end

return Player
