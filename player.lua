local Block = require("block")

local Player = {}
Player.__index = Player
setmetatable(Player, Block)

function Player.create(world, x, y)
	local self = Block.create(world, x, y)
	setmetatable(self, Player)

	self.image = love.graphics.newImage("res/images/player.png")

	self.thrust = 150
	self.torque = 350
	self.body:setAngularDamping(1)
	self.body:setLinearDamping(0.5)

	return self
end

function Player:update(dt)
end

function Player:draw()
	love.graphics.draw(self.image, love.graphics.getWidth()/2,
	                   love.graphics.getHeight()/2, self.body:getAngle(),
					   1, 1, self.width/2, self.height/2)
end

return Player
