local Timer = require("timer")

local Gun = class()

function Gun:__create()
	self.charged = true
	self.rechargeTimer = Timer(0.5)

	return self
end

function Gun:update(dt, shoot, clear)
	if not self.charged then
		if self.rechargeTimer:ready(dt) then
			self.charged = true
		end
	else
		if shoot then
			-- Check if there is a part one block infront of the gun.

			if clear then
				self.charged = false
				-- Spawn Shot
				return true
			end
		end
	end
end

return Gun
