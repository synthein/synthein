local Gun = {}
Gun.__index = Gun
setmetatable(Gun, Part)

function Gun.create()
	local self = {}
	setmetatable(self, Gun)

	self.recharge = false
	self.rechargeTime = 0

	return self
end

function Gun:update(dt, shoot, part)
	if self.recharge then
		self.rechargeTime = self.rechargeTime + dt
		if self.rechargeTime > 0.5 then
			self.recharge = false
		end
	else
		if shoot then
			self.recharge = true
			self.rechargeTime = 0
			return {"shots", {part:getWorldLocation()}, part}
		end
	end
end

return Gun
