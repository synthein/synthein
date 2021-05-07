local ShieldBlock = class(require("world/shipparts/part"))

function ShieldBlock:__create()
	self.image = "shield"
	self.width, self.height = 1, 1
	self.isShield = true

	return self
end

return ShieldBlock
