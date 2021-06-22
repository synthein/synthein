local Hull = require("world/shipparts/hull")

local ShieldBlock = class(require("world/shipparts/part"))

function ShieldBlock:__create()
	self.modules["hull"] = Hull("shield", 10)
	self.isShield = true

	return self
end

return ShieldBlock
