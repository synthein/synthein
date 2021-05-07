local ShieldBlock = class(require("world/shipparts/part"))

function ShieldBlock:__create()
	self.image = "shield"
	self.isShield = true

	return self
end

return ShieldBlock
