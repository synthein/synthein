local Part = require("part")

local PlayerBlock = {}
PlayerBlock.__index = PlayerBlock
setmetatable(PlayerBlock, Part)

function PlayerBlock.create()
	local self = Part.create("player")
	setmetatable(self, PlayerBlock)

	self.physicsShape = love.physics.newRectangleShape(self.width, self.height)
	self.thrust = 150
	self.torque = 350
	self.type = "player"
	self.gun = true
	self.recharge = false
	self.rechargeStart = 0
	return self
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