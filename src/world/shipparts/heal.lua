local Timer = require("timer")

local Heal = class()

function Heal:__create()
	self.timer = Timer(10)
end

function Heal:update(dt, health)
	if self.timer:ready(dt) then
		health:repair(1)
	end
end

return Heal
