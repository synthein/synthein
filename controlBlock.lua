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
	self.gun = true
	self.recharge = false
	self.rechargeStart = 0
	return self
end

function ControlBlock:shot()
	self.recharge = true
	self.rechargeStart = 0
end

function ControlBlock:update(dt)
	if self.recharge then
		self.rechargeStart = self.rechargeStart + dt
		if self.rechargeStart > 0.5 then
			self.recharge = false
		end
	end
end

return ControlBlock
