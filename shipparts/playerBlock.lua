local Part = require("shipparts/part")

local PlayerBlock = {}
PlayerBlock.__index = PlayerBlock
setmetatable(PlayerBlock, Part)

function PlayerBlock.create()
	local self = Part.create()
	setmetatable(self, PlayerBlock)

	self.image = love.graphics.newImage("res/images/player.png")
	self.width = self.image:getWidth()
	self.height = self.image:getHeight()

	self.physicsShape = love.physics.newRectangleShape(self.width, self.height)
	self.thrust = 150
	self.torque = 350
	self.type = "control"
	self.gun = true
	self.recharge = false
	self.rechargeStart = 0

	self.team = 1
	return self
end

function PlayerBlock:getTeam()
	return self.team
end

function PlayerBlock:getOrders()
	return {}
end

function PlayerBlock:shot()
	self.recharge = true
	self.rechargeStart = 0
end

function PlayerBlock:update(dt)
	if self.recharge then
		self.rechargeStart = self.rechargeStart + dt
		if self.rechargeStart > 0.5 then
			self.recharge = false
		end
	end
end

return PlayerBlock
