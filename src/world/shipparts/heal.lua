local Timer = require("timer")

local Heal = class()

function Heal:__create()
	self.timer = Timer(10)

	return self
end

function Heal:update(dt, part)
	if self.timer:ready(dt) then
		if part.health < 10 then
			part.health = part.health + 1
		end
	end
end

return Heal
