local Timer = require("syntheinrust").timer

local Heal = class()

function Heal:__create(hull)
	self.timer = Timer(10)
	self.hull = hull
end

function Heal:update(inputs)
	if self.timer:ready(inputs.dt) then
		self.hull.userData.repair(1)
	end
end

return Heal
