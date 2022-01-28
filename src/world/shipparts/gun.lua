local Shot = require("world/shot")
local Timer = require("timer")

local Gun = class()

function Gun:__create()
	self.charged = true
	self.rechargeTimer = Timer(0.5)

	return self
end

function Gun.process(orders)
	local shoot = false
	for _, order in ipairs(orders) do
		if order == "shoot" then shoot = true end
	end
	return shoot
end

function Gun:update(inputs, location)
	if not self.charged then
		if self.rechargeTimer:ready(inputs.dt) then
			self.charged = true
		end
	else
		if inputs.controls.gun then
			-- Check if there is a part one block infront of the gun.
			local getPart = inputs.getPart
			if not getPart(location, {0, 1}) then
				self.charged = false
				-- Spawn Shot
				return {Shot, {0, 0, 1}}
			end
		end
	end
end

return Gun
