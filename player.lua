local Part = require("part")

local Player = {}
Player.__index = Player
setmetatable(Player, Part)

function Player.create(world, x, y)
	local self = Part.create("player")
	setmetatable(self, Player)

	self.body = love.physics.newBody(world, x, y, "dynamic")
	self.shape = love.physics.newRectangleShape(self.width, self.height)
	self.fixture = love.physics.newFixture(self.body, self.shape)

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
