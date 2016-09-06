local Part = require("part")

local Gun = {}
Gun.__index = Gun
setmetatable(Gun, Part)

function Gun.create(world, x, y)
	local self = Part.create()
	setmetatable(self, Gun)

	self.image = love.graphics.newImage("res/images/gun.png")
	self.physicsShape = love.physics.newRectangleShape(self.width, self.height)

	self.gun = true
	self.recharge = false
	self.rechargeStart = 0
	-- Guns can only connect to things on their bottom side.
	self.connectableSides[1] = false
	self.connectableSides[2] = false
	self.connectableSides[4] = false

	return self
end

function Gun:shot()
	self.recharge = true
	self.rechargeStart = 0
end

function Gun:update(dt)
	if self.recharge then
		self.rechargeStart = self.rechargeStart + dt
		if self.rechargeStart > 0.5 then
			self.recharge = false
		end
	end
end

return Gun
