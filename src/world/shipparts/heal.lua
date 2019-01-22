local Timer = require("timer")

local Heal = class()

function Heal:__create(health)
	self.timer = Timer(10)
	self.health = health
end

function Heal:update(inputs)
	if self.timer:ready(inputs.dt) then
		self.health:repair(1)
	end
end

return Heal
